import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../const/app_constants.dart';
import '../model/model.dart';

class NotificationRepository {
  final FirebaseFirestore _db;

  NotificationRepository({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _notificationsRef(String uid) {
    return _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .collection(AppConstants.notificationsCollection);
  }

  CollectionReference<Map<String, dynamic>> _tokensRef(String uid) {
    return _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .collection(AppConstants.fcmTokensCollection);
  }

  Stream<List<AppNotificationModel>> watchNotifications(String uid) {
    return _notificationsRef(uid)
        .orderBy('createdAt', descending: true)
        .limit(60)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(AppNotificationModel.fromDoc)
              .toList(growable: false),
        );
  }

  Future<void> markRead(String uid, String notificationId) {
    return _notificationsRef(uid).doc(notificationId).set({
      'isRead': true,
      'readAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> archive(String uid, String notificationId) {
    return _notificationsRef(uid).doc(notificationId).set({
      'archived': true,
      'archivedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> saveFcmToken({
    required String uid,
    required String token,
  }) async {
    final tokenId = token.replaceAll('/', '_');

    await _tokensRef(uid).doc(tokenId).set({
      'token': token,
      'platform': 'flutter',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> saveRemoteMessage({
    required String uid,
    required RemoteMessage message,
  }) async {
    final notification = message.notification;
    final data = Map<String, dynamic>.from(message.data);
    final title = data['title']?.toString() ?? notification?.title;
    final body = data['body']?.toString() ?? notification?.body;

    if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
      return;
    }

    await _notificationsRef(uid).doc(message.messageId).set({
      'title': title ?? 'Notification',
      'body': body ?? '',
      'type': data['type']?.toString() ?? 'general',
      'route': data['route']?.toString(),
      'data': data,
      'isRead': false,
      'archived': false,
      'createdAt': FieldValue.serverTimestamp(),
      'source': 'fcm',
    }, SetOptions(merge: true));
  }
}
