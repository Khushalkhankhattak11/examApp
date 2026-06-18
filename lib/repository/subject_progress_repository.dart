import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/model.dart';

class SubjectProgressRepository {
  final FirebaseFirestore _db;

  SubjectProgressRepository({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  Stream<SubjectProgressModel> watchSubjectProgress({
    required String uid,
    required String subjectId,
  }) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('subjectProgress')
        .doc(subjectId)
        .snapshots()
        .map(
          (snapshot) => snapshot.exists
              ? SubjectProgressModel.fromFirestore(snapshot)
              : SubjectProgressModel.empty(subjectId),
        );
  }

  Future<void> markTopicCompleted({
    required String uid,
    required String subjectId,
    required String chapterId,
    required String topicId,
  }) async {
    final ref = _db
        .collection('users')
        .doc(uid)
        .collection('subjectProgress')
        .doc(subjectId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      final data = snapshot.data() ?? const <String, dynamic>{};
      final completedTopicIds =
          (data['completedTopicIds'] as List<dynamic>?)
              ?.whereType<String>()
              .toSet() ??
          <String>{};

      completedTopicIds.add(topicId);

      transaction.set(ref, {
        'subjectId': subjectId,
        'completedTopicIds': completedTopicIds.toList(),
        'completedTopics': completedTopicIds.length,
        'lastChapterId': chapterId,
        'lastTopicId': topicId,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }
}
