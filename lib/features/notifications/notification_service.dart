import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppNotification {
  AppNotification({required this.id, required this.title, required this.body,
    required this.type, DateTime? createdAt}) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String title;
  final String body;
  final String type;
  final DateTime createdAt;
  bool read = false;
}

/// Notificações em tempo real, sem FCM, Cloud Functions ou cobrança adicional.
/// Os avisos existem em memória enquanto a sessão do aplicativo está aberta.
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _events = StreamController<AppNotification>.broadcast();
  final _changes = StreamController<List<AppNotification>>.broadcast();
  final List<AppNotification> _items = [];
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  final Map<String, StreamSubscription<QuerySnapshot<Map<String, dynamic>>>> _messageSubscriptions = {};
  final Set<String> _knownConversationIds = {};
  bool _started = false;
  bool _appActive = true;
  bool _firstConversationsSnapshot = true;
  bool _firstInterviewsSnapshot = true;
  bool _firstCareerRolesSnapshot = true;
  bool _firstRequestedRolesSnapshot = true;
  bool _firstResumesSnapshot = true;
  String? _uid;
  bool _company = false;
  final Set<String> _reportedErrors = {};
  Set<String> _candidateRoleIds = {};

  Stream<AppNotification> get events => _events.stream;
  Stream<List<AppNotification>> get notifications => _changes.stream;
  List<AppNotification> get current => List.unmodifiable(_items);
  int get unreadCount => _items.where((item) => !item.read).length;

  void _publish(AppNotification item) {
    if (_items.any((existing) => existing.id == item.id)) return;
    _items.insert(0, item);
    if (_items.length > 100) _items.removeLast();
    _events.add(item);
    _changes.add(List.unmodifiable(_items));
  }

  void setAppActive(bool active) { _appActive = active; }

  void _reportError(String source, Object error, [StackTrace? stackTrace]) {
    final key = '$source:${error.runtimeType}:$error';
    if (_reportedErrors.add(key)) {
      debugPrint('[Avance+][Notificações][$source] $error');
      if (stackTrace != null) debugPrintStack(stackTrace: stackTrace);
    }
  }

  void _notify(String id, String title, String body, String type) {
    if (!_appActive) return;
    _publish(AppNotification(id: id, title: title, body: body, type: type));
  }

  void markRead(String id) {
    AppNotification? item;
    for (final candidate in _items) { if (candidate.id == id) { item = candidate; break; } }
    if (item == null || item.read) return;
    item.read = true;
    _changes.add(List.unmodifiable(_items));
  }

  void markAllRead() {
    for (final item in _items) { item.read = true; }
    _changes.add(List.unmodifiable(_items));
  }

  void start({required bool company}) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (_started && _uid == user.uid && _company == company) return;
    stop();
    _started = true;
    _uid = user.uid;
    _company = company;
    _reportedErrors.clear();
    debugPrint('[Avance+][Notificações] iniciando uid=${user.uid}, perfil=${company ? 'empresa' : 'candidato'}');
    final db = FirebaseFirestore.instance;

    final conversations = db.collection('conversations')
        .where(company ? 'companyId' : 'candidateId', isEqualTo: user.uid);
    _subscriptions.add(conversations.snapshots().listen((snapshot) {
      for (final change in snapshot.docChanges) {
        final data = change.doc.data();
        if (data == null) continue;
        final id = change.doc.id;
        if (change.type == DocumentChangeType.added) {
          if (!_firstConversationsSnapshot) {
            _notify('conversation_$id', 'Nova conversa',
              '${company ? data['candidateName'] : data['companyName']} iniciou uma conversa com você.', 'conversation');
          }
          _knownConversationIds.add(id);
          _watchMessages(id, data);
        }
      }
      _firstConversationsSnapshot = false;
    }, onError: (Object error, StackTrace stack) { _reportError('conversas', error, stack); }));

    final interviews = db.collection('interviews')
        .where(company ? 'companyId' : 'candidateId', isEqualTo: user.uid);
    _subscriptions.add(interviews.snapshots().listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (_firstInterviewsSnapshot) continue;
        final data = change.doc.data();
        if (data == null || data['updatedBy'] == user.uid) continue;
        final status = data['status'] as String? ?? '';
        final title = change.type == DocumentChangeType.added
            ? 'Nova entrevista' : 'Entrevista atualizada';
        final statusText = switch (status) {
          'pending' => 'Um convite ou novo horário de entrevista aguarda sua resposta.',
          'confirmed' => 'A entrevista foi confirmada.',
          'rejected' => 'O convite para entrevista foi recusado.',
          'cancelled' => 'A entrevista foi cancelada.',
          'reschedule_requested' => 'Foi solicitada uma alteração na data da entrevista.',
          _ => 'Os dados de uma entrevista foram atualizados.',
        };
        _notify('interview_${change.doc.id}_${data['revision'] ?? 0}', title, statusText, 'interview');
      }
      _firstInterviewsSnapshot = false;
    }, onError: (Object error, StackTrace stack) { _reportError('listener Firestore', error, stack); }));

    if (company) {
      _subscriptions.add(db.collection('resumes').where('shared', isEqualTo: true)
          .snapshots().listen((snapshot) {
        for (final change in snapshot.docChanges) {
          if (_firstResumesSnapshot || change.doc.id == user.uid) continue;
          if (change.type == DocumentChangeType.added || change.type == DocumentChangeType.modified) {
            final data = change.doc.data();
            if (data == null) continue;
            if (data['shared'] == true) {
              _notify('resume_${change.doc.id}_${data['updatedAt']?.hashCode ?? DateTime.now().millisecondsSinceEpoch}',
                'Novo currículo disponível', '${data['name'] ?? 'Um candidato'} disponibilizou um currículo para consulta.', 'resume');
            }
          }
        }
        _firstResumesSnapshot = false;
      }, onError: (Object error, StackTrace stack) { _reportError('listener Firestore', error, stack); }));
    } else {
      _subscriptions.add(db.collection('career_roles').where('status', isEqualTo: 'approved')
          .snapshots().listen((snapshot) async {
        if (_candidateRoleIds.isEmpty) await _loadCandidateRoles(user.uid);
        for (final change in snapshot.docChanges) {
          if (_firstCareerRolesSnapshot || change.type != DocumentChangeType.added) continue;
          final data = change.doc.data();
          if (data == null) continue;
          if (_candidateRoleIds.contains(change.doc.id)) {
            _notify('role_${change.doc.id}', 'Novo cargo disponível',
              'O cargo "${data['title'] ?? 'selecionado'}" está disponível no catálogo.', 'career_role');
          }
        }
        _firstCareerRolesSnapshot = false;
      }, onError: (Object error, StackTrace stack) { _reportError('listener Firestore', error, stack); }));
    }

    _subscriptions.add(db.collection('career_roles').where('requestedBy', isEqualTo: user.uid)
        .snapshots().listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (_firstRequestedRolesSnapshot || change.type != DocumentChangeType.modified) continue;
        final data = change.doc.data();
        if (data == null) continue;
        final status = data['status'];
        if (status == 'approved' || status == 'rejected') {
          _notify('role_request_${change.doc.id}_$status',
            status == 'approved' ? 'Cargo aprovado' : 'Solicitação não aprovada',
            status == 'approved'
                ? 'O cargo "${data['title']}" foi aprovado.'
                : 'A solicitação do cargo "${data['title']}" não foi aprovada.', 'career_role');
        }
      }
      _firstRequestedRolesSnapshot = false;
    }, onError: (Object error, StackTrace stack) { _reportError('listener Firestore', error, stack); }));
  }

  Future<void> _loadCandidateRoles(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('resumes').doc(uid).get();
      _candidateRoleIds = Set<String>.from(doc.data()?['roleIds'] as List? ?? const []);
    } catch (error, stack) { _reportError('carregar cargos do currículo', error, stack); }
  }

  void _watchMessages(String conversationId, Map<String, dynamic> conversation) {
    if (_messageSubscriptions.containsKey(conversationId)) return;
    final uid = _uid;
    if (uid == null) return;
    var firstSnapshot = true;
    final subscription = FirebaseFirestore.instance.collection('conversations')
        .doc(conversationId).collection('messages').orderBy('createdAt', descending: true)
        .limit(30).snapshots().listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (firstSnapshot || change.type != DocumentChangeType.added) continue;
        final data = change.doc.data();
        if (data == null || data['senderId'] == uid) continue;
        final sender = data['senderId'] == conversation['companyId']
            ? conversation['companyName'] : conversation['candidateName'];
        final text = (data['text'] as String? ?? '').trim();
        _notify('message_${change.doc.id}', 'Nova mensagem',
          '${sender ?? 'Você recebeu uma mensagem'}: ${text.length > 100 ? '${text.substring(0, 97)}...' : text}', 'message');
      }
      firstSnapshot = false;
    }, onError: (Object error) {});
    _messageSubscriptions[conversationId] = subscription;
  }

  void stop() {
    for (final subscription in _subscriptions) { subscription.cancel(); }
    for (final subscription in _messageSubscriptions.values) { subscription.cancel(); }
    _subscriptions.clear();
    _messageSubscriptions.clear();
    _knownConversationIds.clear();
    _started = false;
    _uid = null;
    _candidateRoleIds = {};
    _appActive = true;
    _firstConversationsSnapshot = true;
    _firstInterviewsSnapshot = true;
    _firstCareerRolesSnapshot = true;
    _firstRequestedRolesSnapshot = true;
    _firstResumesSnapshot = true;
    debugPrint('[Avance+][Notificações] serviço interrompido');
  }
}
