import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectTopicModel {
  final String id;
  final String topicId;
  final String title;
  final String definition;
  final String explanation;
  final List<String> examples;
  final List<TopicTypeModel> types;
  final List<TopicMcqModel> mcqs;
  final int order;
  final bool active;

  const SubjectTopicModel({
    required this.id,
    this.topicId = '',
    this.title = '',
    this.definition = '',
    this.explanation = '',
    this.examples = const [],
    this.types = const [],
    this.mcqs = const [],
    this.order = 0,
    this.active = true,
  });

  factory SubjectTopicModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final map = doc.data() ?? const <String, dynamic>{};

    return SubjectTopicModel(
      id: doc.id,
      topicId: map['topicId'] as String? ?? doc.id,
      title: map['title'] as String? ?? '',
      definition: map['definition'] as String? ?? '',
      explanation: map['explanation'] as String? ?? '',
      examples: _strings(map['examples']),
      types: (map['types'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((value) => TopicTypeModel.fromMap(value.cast<String, dynamic>()))
          .toList(growable: false),
      mcqs: (map['mcqs'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((value) => TopicMcqModel.fromMap(value.cast<String, dynamic>()))
          .where((mcq) => mcq.question.isNotEmpty && mcq.options.isNotEmpty)
          .toList(growable: false),
      order:
          (map['order'] as num?)?.toInt() ??
          (map['index'] as num?)?.toInt() ??
          0,
      active: map['active'] as bool? ?? true,
    );
  }

  String get progressTopicId => topicId.isNotEmpty ? topicId : id;
  String get displayTitle => title.isNotEmpty ? title : progressTopicId;

  static List<String> _strings(Object? value) =>
      (value as List<dynamic>?)?.whereType<String>().toList(growable: false) ??
      const [];
}

class TopicTypeModel {
  final String type;
  final String definition;
  final List<String> examples;

  const TopicTypeModel({
    this.type = '',
    this.definition = '',
    this.examples = const [],
  });

  factory TopicTypeModel.fromMap(Map<String, dynamic> map) => TopicTypeModel(
    type: map['type'] as String? ?? '',
    definition: map['definition'] as String? ?? '',
    examples:
        (map['examples'] as List<dynamic>?)?.whereType<String>().toList(
          growable: false,
        ) ??
        const [],
  );
}

class TopicMcqModel {
  final String question;
  final List<String> options;
  final String answer;

  const TopicMcqModel({
    this.question = '',
    this.options = const [],
    this.answer = '',
  });

  factory TopicMcqModel.fromMap(Map<String, dynamic> map) => TopicMcqModel(
    question: map['question'] as String? ?? '',
    options:
        (map['options'] as List<dynamic>?)?.whereType<String>().toList(
          growable: false,
        ) ??
        const [],
    answer: map['answer'] as String? ?? '',
  );
}
