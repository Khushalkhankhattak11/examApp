import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/mock_exam_model.dart';

class FavoriteMcqRepository {
  final FirebaseFirestore _db;

  FavoriteMcqRepository({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _favorites(String uid) =>
      _db.collection('users').doc(uid).collection('favortie');

  Stream<Set<String>> watchFavoriteIds(String uid) {
    return _favorites(
      uid,
    ).snapshots().map((snapshot) => snapshot.docs.map((doc) => doc.id).toSet());
  }

  Future<bool> toggleFavorite({
    required String uid,
    required MockExamMcqModel mcq,
  }) async {
    final favoriteId = favoriteDocumentId(
      examId: mcq.examId,
      subjectId: mcq.subjectId,
      mcqId: mcq.id,
    );
    final reference = _favorites(uid).doc(favoriteId);
    final snapshot = await reference.get();

    if (snapshot.exists) {
      await reference.delete();
      return false;
    }

    await reference.set({
      'favoriteId': favoriteId,
      'mcqId': mcq.id,
      'examId': mcq.examId,
      'subjectId': mcq.subjectId,
      'subjectName': mcq.subjectName,
      'question': mcq.question,
      'options': mcq.options,
      'correctOption': String.fromCharCode(65 + mcq.correctIndex),
      'explanation': mcq.explanation,
      'difficulty': mcq.difficulty,
      'savedAt': FieldValue.serverTimestamp(),
    });
    return true;
  }

  static String favoriteDocumentId({
    required String examId,
    required String subjectId,
    required String mcqId,
  }) => '${examId}_${subjectId}_$mcqId';
}
