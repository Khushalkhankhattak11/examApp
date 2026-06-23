import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/mock_exam_model.dart';

class MockExamRepository {
  final FirebaseFirestore _db;

  MockExamRepository({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  Stream<List<MockExamModel>> watchActiveExams() {
    return _db.collection('exams').snapshots().map((snapshot) {
      final exams = snapshot.docs
          .map(MockExamModel.fromFirestore)
          .where((exam) => exam.active)
          .toList(growable: false);
      exams.sort((a, b) => a.displayName.compareTo(b.displayName));
      return exams;
    });
  }

  Stream<List<MockExamSubjectModel>> watchActiveSubjects(String examId) {
    return _db
        .collection('exams')
        .doc(examId)
        .collection('subjects')
        .snapshots()
        .map((snapshot) {
          final subjects = snapshot.docs
              .map(MockExamSubjectModel.fromFirestore)
              .where((subject) => subject.active)
              .toList(growable: false);
          subjects.sort((a, b) => a.name.compareTo(b.name));
          return subjects;
        });
  }

  Future<List<MockExamMcqModel>> fetchMcqs({
    required String examId,
    required Iterable<MockExamSubjectModel> subjects,
  }) async {
    final snapshots = await Future.wait(
      subjects.map(
        (subject) => _db
            .collection('exams')
            .doc(examId)
            .collection('subjects')
            .doc(subject.id)
            .collection('mcqs')
            .get(),
      ),
    );

    return snapshots
        .expand((snapshot) => snapshot.docs)
        .map(MockExamMcqModel.fromFirestore)
        .where((mcq) => mcq.isUsable)
        .toList(growable: false);
  }
}
