import 'package:cloud_firestore/cloud_firestore.dart';

class MockExamModel {
  final String id;
  final String code;
  final String title;
  final bool active;

  const MockExamModel({
    required this.id,
    required this.code,
    required this.title,
    required this.active,
  });

  factory MockExamModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    return MockExamModel(
      id: doc.id,
      code: (data['code'] as String? ?? '').trim(),
      title: (data['title'] as String? ?? '').trim(),
      active: data['active'] as bool? ?? true,
    );
  }

  String get displayName =>
      title.isNotEmpty ? title : (code.isNotEmpty ? code : id);
}

class MockExamSubjectModel {
  final String id;
  final String name;
  final String subjectKey;
  final int mcqCount;
  final bool active;

  const MockExamSubjectModel({
    required this.id,
    required this.name,
    required this.subjectKey,
    required this.mcqCount,
    required this.active,
  });

  factory MockExamSubjectModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    final name = (data['name'] as String? ?? data['subject'] as String? ?? '')
        .trim();
    return MockExamSubjectModel(
      id: doc.id,
      name: name.isNotEmpty ? name : doc.id,
      subjectKey:
          (data['subjectKey'] as String? ??
                  data['subjectId'] as String? ??
                  doc.id)
              .trim(),
      mcqCount: (data['mcqCount'] as num?)?.toInt() ?? 0,
      active: data['active'] as bool? ?? true,
    );
  }
}

class MockExamMcqModel {
  final String id;
  final String examId;
  final String subjectId;
  final String subjectName;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String difficulty;
  final bool active;

  const MockExamMcqModel({
    required this.id,
    required this.examId,
    required this.subjectId,
    required this.subjectName,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.difficulty,
    required this.active,
  });

  factory MockExamMcqModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    final options = (data['options'] as List<dynamic>? ?? const [])
        .map((value) => value.toString().trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    return MockExamMcqModel(
      id: doc.id,
      examId: doc.reference.parent.parent?.parent.parent?.id ?? '',
      subjectId: doc.reference.parent.parent?.id ?? '',
      subjectName:
          (data['subjectName'] as String? ?? data['subject'] as String? ?? '')
              .trim(),
      question: (data['question'] as String? ?? '').trim(),
      options: options,
      correctIndex: _correctIndex(data['correctOption'], options),
      explanation: (data['explanation'] as String? ?? '').trim(),
      difficulty: (data['difficulty'] as String? ?? '').trim(),
      active: data['active'] as bool? ?? true,
    );
  }

  bool get isUsable =>
      active && question.isNotEmpty && options.length >= 2 && correctIndex >= 0;

  static int _correctIndex(Object? value, List<String> options) {
    if (value is num) {
      final index = value.toInt();
      if (index >= 0 && index < options.length) return index;
      if (index > 0 && index <= options.length) return index - 1;
    }

    final text = value?.toString().trim() ?? '';
    if (text.length == 1) {
      final index = text.toUpperCase().codeUnitAt(0) - 65;
      if (index >= 0 && index < options.length) return index;
    }
    final optionIndex = options.indexWhere(
      (option) => option.toLowerCase() == text.toLowerCase(),
    );
    return optionIndex;
  }
}
