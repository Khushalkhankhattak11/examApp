import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/model.dart';

class SubjectTopicRepository {
  final FirebaseFirestore _db;

  SubjectTopicRepository({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  Stream<List<SubjectTopicModel>> watchChapterTopics({
    required String subjectId,
    required String chapterId,
  }) {
    return _db
        .collection('subjects')
        .doc(subjectId)
        .collection('chapters')
        .doc(chapterId)
        .collection('topics')
        .snapshots()
        .map((snapshot) {
          final topics = snapshot.docs
              .map(SubjectTopicModel.fromFirestore)
              .where((topic) => topic.active)
              .toList();
          topics.sort((a, b) {
            final aPriority = _topicPriority(a);
            final bPriority = _topicPriority(b);
            if (aPriority != bPriority) {
              return aPriority.compareTo(bPriority);
            }
            final order = a.order.compareTo(b.order);
            if (order != 0) return order;
            return a.displayTitle.compareTo(b.displayTitle);
          });
          return List<SubjectTopicModel>.unmodifiable(topics);
        });
  }

  int _topicPriority(SubjectTopicModel topic) {
    const priorities = <String, int>{
      'noun': 0,
      'pronoun': 1,
      'verb': 2,
      'adverb': 3,
      'adjective': 4,
      'conjunction': 5,
      'conjuncation': 5,
      'interjection': 6,
      'injection': 6,
      'preposition': 7,
    };
    final candidates = [topic.topicId, topic.id, topic.title];
    for (final candidate in candidates) {
      final key = candidate.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
      final priority = priorities[key];
      if (priority != null) return priority;
    }
    return 100;
  }
}
