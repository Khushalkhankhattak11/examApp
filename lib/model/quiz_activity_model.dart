import 'package:cloud_firestore/cloud_firestore.dart';

class QuizActivityModel {
  final String id;
  final String title;
  final String type;
  final String subjectId;
  final String chapterId;
  final String topicId;
  final int correctAnswers;
  final int totalQuestions;
  final int scorePercent;
  final DateTime? completedAt;

  const QuizActivityModel({
    required this.id,
    this.title = '',
    this.type = 'quiz',
    this.subjectId = '',
    this.chapterId = '',
    this.topicId = '',
    this.correctAnswers = 0,
    this.totalQuestions = 0,
    this.scorePercent = 0,
    this.completedAt,
  });

  factory QuizActivityModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final map = doc.data() ?? const <String, dynamic>{};
    return QuizActivityModel(
      id: doc.id,
      title: map['title'] as String? ?? 'Quiz',
      type: map['type'] as String? ?? 'quiz',
      subjectId: map['subjectId'] as String? ?? '',
      chapterId: map['chapterId'] as String? ?? '',
      topicId: map['topicId'] as String? ?? '',
      correctAnswers: (map['correctAnswers'] as num?)?.toInt() ?? 0,
      totalQuestions: (map['totalQuestions'] as num?)?.toInt() ?? 0,
      scorePercent: (map['scorePercent'] as num?)?.toInt() ?? 0,
      completedAt: _dateTime(map['completedAt']),
    );
  }

  static DateTime? _dateTime(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
