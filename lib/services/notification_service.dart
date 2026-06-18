import 'dart:async';

import 'package:examace/const/app_routes.dart';
import 'package:examace/repository/notification_repository.dart';
import 'package:examace/services/firebase/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await FirebaseService.initialize();

  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;

  await NotificationRepository().saveRemoteMessage(uid: uid, message: message);
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();
  static final navigatorKey = GlobalKey<NavigatorState>();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationRepository _repository = NotificationRepository();

  StreamSubscription<User?>? _authSub;

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_saveForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_openNotification);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openNotification(initialMessage);
      });
    }

    _authSub?.cancel();
    _authSub = _auth.authStateChanges().listen((user) async {
      if (user == null) return;
      await _syncToken(user.uid);
      await _messaging.subscribeToTopic('all_users');
    });

    _messaging.onTokenRefresh.listen((token) async {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;
      await _repository.saveFcmToken(uid: uid, token: token);
    });
  }

  Future<void> _syncToken(String uid) async {
    final token = await _messaging.getToken();
    if (token == null) return;
    await _repository.saveFcmToken(uid: uid, token: token);
  }

  Future<void> _saveForegroundMessage(RemoteMessage message) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _repository.saveRemoteMessage(uid: uid, message: message);
  }

  Future<void> _openNotification(RemoteMessage message) async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _repository.saveRemoteMessage(uid: uid, message: message);
    }

    final route = message.data['route']?.toString();
    final nav = navigatorKey.currentState;
    if (nav == null) return;

    if (route != null && route.isNotEmpty) {
      nav.pushNamed(route);
      return;
    }

    nav.pushNamed(AppRoutes.notifications);
  }
}
