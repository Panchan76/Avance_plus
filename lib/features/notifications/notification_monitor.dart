
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../communication/communication_service.dart';

class AppNotification {
  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String type;
  final String title;
  final String body;
  final DateTime createdAt;

  bool isRead = false;
}

class NotificationMonitor extends ChangeNotifier {
  NotificationMonitor._();

  static final instance = NotificationMonitor._();

  final _db = FirebaseFirestore.instance;
  final _communication = CommunicationService.instance;

  final List<AppNotification> _notifications = [];
  final Map<String, StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>
      _messageSubscriptions = {};

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _interviewSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _conversationSubscription;

  final Set<String> _knownMessages = {};
  final Map<String, int> _knownInterviewRevisions = {};

  String? _uid;
  bool _initialMessagesLoaded = false;
  bool _initialInterviewsLoaded = false;
  bool _running = false;

  List<AppNotification> get notifications =>
      List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((item) => !item.isRead).length;

  Future<void> start() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    if (_running && _uid == user.uid) return;

    await stop();

    _uid = user.uid;
    _running = true;

    _conversationSubscription = _db
        .collection('conversations')
        .where('companyId', isEqualTo: user.uid)
        .snapshots()
        .listen(
          (snapshot) => _updateConversations(snapshot, company: true),
          onError: (error) => debugPrint('Erro ao monitorar conversas: $error'),
        );

    // Também monitora as conversas em que o usuário é candidato.
    final candidateSubscription = _db
        .collection('conversations')
        .where('candidateId', isEqualTo: user.uid)
        .snapshots()
        .listen(
          (snapshot) => _updateConversations(snapshot, company: false),
          onError: (error) => debugPrint('Erro ao monitorar conversas: $error'),
        );

    _extraSubscriptions.add(candidateSubscription);

    _interviewSubscription = _db
        .collection('interviews')
        .where('companyId', isEqualTo: user.uid)
        .snapshots()
        .listen(
          (snapshot) => _processInterviews(snapshot),
          onError: (error) => debugPrint('Erro ao monitorar entrevistas: $error'),
        );

    final candidateInterviews = _db
        .collection('interviews')
        .where('candidateId', isEqualTo: user.uid)
        .snapshots()
        .listen(
          (snapshot) => _processInterviews(snapshot),
          onError: (error) => debugPrint('Erro ao monitorar entrevistas: $error'),
        );

    _extraSubscriptions.add(candidateInterviews);
  }

  final List<StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>
      _extraSubscriptions = [];

  void _updateConversations(
    QuerySnapshot<Map<String, dynamic>> snapshot, {
    required bool company,
  }) {
    for (final doc in snapshot.docs) {
      if (!_messageSubscriptions.containsKey(doc.id)) {
        _watchMessages(doc.id);
      }
    }
  }

  void _watchMessages(String conversationId) {
    final subscription = _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .listen(
          (snapshot) {
            for (final change in snapshot.docChanges) {
              final data = change.doc.data();
              if (data == null) continue;

              final messageId = change.doc.id;
              if (!_knownMessages.add(messageId)) continue;

              final senderId = data['senderId'] as String?;

              // A primeira mensagem encontrada é apenas o estado inicial.
              if (!_initialMessagesLoaded) continue;

              if (senderId == null || senderId == _uid) continue;

              _addNotification(
                id: 'message_$messageId',
                type: 'message',
                title: 'Nova mensagem',
                body: 'Você recebeu uma nova mensagem.',
              );
            }

            _initialMessagesLoaded = true;
          },
          onError: (error) => debugPrint('Erro ao monitorar mensagens: $error'),
        );

    _messageSubscriptions[conversationId] = subscription;
  }

  void _processInterviews(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final revision = data['revision'] as int? ?? 0;
      final previous = _knownInterviewRevisions[doc.id];

      _knownInterviewRevisions[doc.id] = revision;

      if (previous == null || previous == revision) continue;

      if (data['updatedBy'] == _uid) continue;

      final status = data['status'] as String? ?? '';

      String title;
      String body;

      switch (status) {
        case 'pending':
          title = 'Novo convite de entrevista';
          body = 'Você recebeu uma proposta de entrevista.';
          break;
        case 'confirmed':
          title = 'Entrevista confirmada';
          body = 'Uma entrevista foi confirmada ou atualizada.';
          break;
        case 'reschedule_requested':
          title = 'Alteração de horário solicitada';
          body = 'A outra pessoa propôs um novo horário.';
          break;
        case 'rejected':
          title = 'Entrevista recusada';
          body = 'A outra pessoa recusou o convite.';
          break;
        case 'cancelled':
          title = 'Entrevista cancelada';
          body = 'Uma entrevista foi cancelada.';
          break;
        default:
          title = 'Atualização de entrevista';
          body = 'Uma entrevista foi atualizada.';
      }

      _addNotification(
        id: 'interview_${doc.id}_$revision',
        type: 'interview',
        title: title,
        body: body,
      );
    }

    _initialInterviewsLoaded = true;
  }

  void _addNotification({
    required String id,
    required String type,
    required String title,
    required String body,
  }) {
    if (_notifications.any((item) => item.id == id)) return;

    _notifications.insert(
      0,
      AppNotification(
        id: id,
        type: type,
        title: title,
        body: body,
        createdAt: DateTime.now(),
      ),
    );

    if (_notifications.length > 100) {
      _notifications.removeLast();
    }

    notifyListeners();
  }

  void markRead(String id) {
    final index = _notifications.indexWhere((item) => item.id == id);
    if (index == -1) return;

    _notifications[index].isRead = true;
    notifyListeners();
  }

  void markAllRead() {
    for (final item in _notifications) {
      item.isRead = true;
    }
    notifyListeners();
  }

  Future<void> stop() async {
    await _conversationSubscription?.cancel();
    await _interviewSubscription?.cancel();

    for (final subscription in _extraSubscriptions) {
      await subscription.cancel();
    }

    for (final subscription in _messageSubscriptions.values) {
      await subscription.cancel();
    }

    _extraSubscriptions.clear();
    _messageSubscriptions.clear();
    _knownMessages.clear();
    _knownInterviewRevisions.clear();
    _notifications.clear();

    _conversationSubscription = null;
    _interviewSubscription = null;
    _uid = null;
    _running = false;
    _initialMessagesLoaded = false;
    _initialInterviewsLoaded = false;

    notifyListeners();
  }
}

