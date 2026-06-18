import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotificationModel {
  final String id;
  final String title;
  final String body;
  final String type;
  final String? route;
  final bool isRead;
  final bool archived;
  final DateTime? createdAt;
  final Map<String, dynamic> data;

  const AppNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.archived,
    required this.data,
    this.route,
    this.createdAt,
  });

  factory AppNotificationModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return AppNotificationModel(
      id: doc.id,
      title: (data['title'] ?? 'Notification').toString(),
      body: (data['body'] ?? '').toString(),
      type: (data['type'] ?? 'general').toString(),
      route: data['route']?.toString(),
      isRead: data['isRead'] == true,
      archived: data['archived'] == true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      data: Map<String, dynamic>.from(data['data'] as Map? ?? const {}),
    );
  }

  String get timeLabel {
    final date = createdAt;
    if (date == null) return 'Now';

    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
