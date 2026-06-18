import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectProgressModel {
  final String subjectId;
  final List<String> completedChapterIds;
  final List<String> completedTopicIds;
  final int completedTopics;
  final String lastChapterId;
  final String lastTopicId;
  final DateTime? updatedAt;

  const SubjectProgressModel({
    required this.subjectId,
    this.completedChapterIds = const [],
    this.completedTopicIds = const [],
    this.completedTopics = 0,
    this.lastChapterId = '',
    this.lastTopicId = '',
    this.updatedAt,
  });

  factory SubjectProgressModel.empty(String subjectId) {
    return SubjectProgressModel(subjectId: subjectId);
  }

  factory SubjectProgressModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final map = doc.data() ?? {};
    final completedTopicIds =
        (map['completedTopicIds'] as List<dynamic>?)
            ?.whereType<String>()
            .toList() ??
        const <String>[];
    final completedChapterIds =
        (map['completedChapterIds'] as List<dynamic>?)
            ?.whereType<String>()
            .toList() ??
        const <String>[];

    return SubjectProgressModel(
      subjectId: map['subjectId'] as String? ?? doc.id,
      completedChapterIds: completedChapterIds,
      completedTopicIds: completedTopicIds,
      completedTopics:
          (map['completedTopics'] as num?)?.toInt() ??
          completedTopicIds.length,
      lastChapterId: map['lastChapterId'] as String? ?? '',
      lastTopicId: map['lastTopicId'] as String? ?? '',
      updatedAt: _dateTimeFromValue(map['updatedAt']),
    );
  }

  static DateTime? _dateTimeFromValue(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);

    try {
      final converted = (value as dynamic).toDate();
      if (converted is DateTime) return converted;
    } catch (_) {
      return null;
    }

    return null;
  }
}
