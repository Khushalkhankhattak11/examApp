import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectModel {
  final String id;
  final bool active;
  final List<String> authors;
  final String category;
  final String code;
  final DateTime? createdAt;
  final String definition;
  final String description;
  final String level;
  final String name;
  final String subjectId;
  final String title;
  final int totalChapters;
  final int totalTopics;
  final DateTime? updatedAt;

  const SubjectModel({
    required this.id,
    this.active = true,
    this.authors = const [],
    this.category = '',
    this.code = '',
    this.createdAt,
    this.definition = '',
    this.description = '',
    this.level = '',
    this.name = '',
    this.subjectId = '',
    this.title = '',
    this.totalChapters = 0,
    this.totalTopics = 0,
    this.updatedAt,
  });

  factory SubjectModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final map = doc.data() ?? {};

    return SubjectModel(
      id: doc.id,
      // Existing Firestore subjects may not have an `active` field. Treat
      // those as enabled; only an explicit `active: false` disables one.
      active: map['active'] as bool? ?? true,
      authors:
          (map['authors'] as List<dynamic>?)?.whereType<String>().toList() ??
          const [],
      category: map['category'] as String? ?? '',
      code: map['code'] as String? ?? '',
      createdAt: _dateTimeFromValue(map['createdAt']),
      definition: map['definition'] as String? ?? '',
      description: map['description'] as String? ?? '',
      level: map['level'] as String? ?? '',
      name: map['name'] as String? ?? '',
      subjectId: map['subjectId'] as String? ?? doc.id,
      title: map['title'] as String? ?? '',
      totalChapters: (map['totalChapters'] as num?)?.toInt() ?? 0,
      totalTopics: (map['totalTopics'] as num?)?.toInt() ?? 0,
      updatedAt: _dateTimeFromValue(map['updatedAt']),
    );
  }

  String get displayTitle => title.isNotEmpty ? title : name;

  String get displayName => name.isNotEmpty ? name : displayTitle;

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
