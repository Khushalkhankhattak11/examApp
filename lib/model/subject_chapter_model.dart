import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectChapterModel {
  final String id;
  final String chapterId;
  final String title;
  final String name;
  final int order;
  final int mcqCount;
  final int topicCount;
  final List<String> topicIds;
  final bool active;

  const SubjectChapterModel({
    required this.id,
    this.chapterId = '',
    this.title = '',
    this.name = '',
    this.order = 0,
    this.mcqCount = 0,
    this.topicCount = 0,
    this.topicIds = const [],
    this.active = true,
  });

  factory SubjectChapterModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final map = doc.data() ?? {};
    final topicIds =
        (map['topicIds'] as List<dynamic>?)?.whereType<String>().toList() ??
        const <String>[];

    return SubjectChapterModel(
      id: doc.id,
      chapterId: map['chapterId'] as String? ?? doc.id,
      title: map['title'] as String? ?? '',
      name: map['name'] as String? ?? '',
      order:
          (map['order'] as num?)?.toInt() ??
          (map['chapterNumber'] as num?)?.toInt() ??
          (map['index'] as num?)?.toInt() ??
          0,
      mcqCount:
          (map['mcqCount'] as num?)?.toInt() ??
          (map['totalMcqs'] as num?)?.toInt() ??
          (map['totalMCQs'] as num?)?.toInt() ??
          0,
      topicCount:
          (map['topicCount'] as num?)?.toInt() ??
          (map['totalTopics'] as num?)?.toInt() ??
          topicIds.length,
      topicIds: topicIds,
      active: map['active'] as bool? ?? true,
    );
  }

  String get progressChapterId => chapterId.isNotEmpty ? chapterId : id;

  String get displayTitle {
    final value = title.isNotEmpty ? title : name;
    return value.isNotEmpty ? value : 'Chapter';
  }

  int get completionUnits {
    if (topicIds.isNotEmpty) return topicIds.length;
    if (topicCount > 0) return topicCount;
    return 1;
  }
}
