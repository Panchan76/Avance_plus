import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Notification messages are displayed by the operating system while the
  // application is in the background. This handler is reserved for data work.
  debugPrint('FCM background message: ${message.messageId}');
}

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _db = FirebaseFirestore.instance;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<String>? _tokenSubscription;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  String? _activeUid;
  String? _activeToken;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    try {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
    } catch (error) {
      // A notification permission/plugin issue must never block app startup.
      debugPrint(
        'Não foi possível solicitar permissão de notificações: $error',
      );
    }

    // iOS foreground presentation. Android foreground messages are shown
    // inside the app as a SnackBar; background notifications use the OS tray.
    try {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (error) {
      debugPrint(
        'Não foi possível configurar notificações em primeiro plano: $error',
      );
    }

    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
      _showForegroundMessage,
    );
    _tokenSubscription = _messaging.onTokenRefresh.listen((token) {
      _activeToken = token;
      final uid = _activeUid;
      if (uid != null) {
        _saveToken(uid, token).catchError((error) {
          debugPrint('Não foi possível atualizar o token FCM: $error');
        });
      }
    });

    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((
      user,
    ) async {
      final previousUid = _activeUid;
      if (previousUid != null &&
          previousUid != user?.uid &&
          _activeToken != null) {
        try {
          await _db
              .collection('users')
              .doc(previousUid)
              .collection('fcmTokens')
              .doc(_activeToken)
              .delete();
        } catch (error) {
          debugPrint('Não foi possível remover o token antigo: $error');
        }
      }

      _activeUid = user?.uid;
      if (user == null) return;

      try {
        final token = await _messaging.getToken(
          vapidKey:
              'BKLTtWyvzVw_RMML1xoeXxEsO0F1fCKDfucUwk2s41EEjDtgdcCSebnm6pBO3QICHgWJ_Y8f1d_4LLfTlO3vc0o',
        );

        if (token == null) {
          debugPrint('FCM não retornou um token.');
          return;
        }

        _activeToken = token;
        await _saveToken(user.uid, token);

        debugPrint('Token FCM registrado com sucesso.');
      } catch (error) {
        debugPrint('Não foi possível registrar o token FCM: $error');
      }
    });
  }

  Future<void> _saveToken(String uid, String token) async {
    debugPrint('UID autenticado: $uid');
    debugPrint(
      'UID atual do Firebase: ${FirebaseAuth.instance.currentUser?.uid}',
    );
    debugPrint('Token recebido: ${token.isNotEmpty}');
    debugPrint('Tamanho do token: ${token.length}');

    await _db
        .collection('users')
        .doc(uid)
        .collection('fcmTokens')
        .doc(token)
        .set({
          'token': token,
          'platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  void _showForegroundMessage(RemoteMessage message) {
    final title = message.notification?.title ?? 'Nova notificação';
    final body = message.notification?.body ?? '';
    final messenger = appScaffoldMessengerKey.currentState;
    messenger?.showSnackBar(
      SnackBar(
        content: Text(body.isEmpty ? title : '$title\n$body'),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> dispose() async {
    await _authSubscription?.cancel();
    await _tokenSubscription?.cancel();
    await _foregroundSubscription?.cancel();
  }
}

class AppNotification {
  const AppNotification({required this.id, required this.data});
  final String id;
  final Map<String, dynamic> data;

  String get title => data['title'] as String? ?? 'Notificação';
  String get body => data['body'] as String? ?? '';
  bool get isRead => data['read'] == true;
  DateTime? get createdAt => (data['createdAt'] as Timestamp?)?.toDate();
}

class NotificationRepository {
  NotificationRepository._();
  static final instance = NotificationRepository._();
  final _db = FirebaseFirestore.instance;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  Stream<List<AppNotification>> watchNotifications() => _db
      .collection('users')
      .doc(_uid)
      .collection('notifications')
      .orderBy('createdAt', descending: true)
      .limit(100)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => AppNotification(id: doc.id, data: doc.data()))
            .toList(),
      );

  Future<void> markRead(String id) => _db
      .collection('users')
      .doc(_uid)
      .collection('notifications')
      .doc(id)
      .update({'read': true, 'readAt': FieldValue.serverTimestamp()});

  Future<void> markAllRead(List<String> ids) async {
    if (ids.isEmpty) return;
    final batch = _db.batch();
    for (final id in ids) {
      batch.update(
        _db.collection('users').doc(_uid).collection('notifications').doc(id),
        {'read': true, 'readAt': FieldValue.serverTimestamp()},
      );
    }
    await batch.commit();
  }
}
