import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/model.dart';

class SubjectChapterRepository {
  final FirebaseFirestore _db;

  SubjectChapterRepository({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  Stream<List<SubjectChapterModel>> watchSubjectChapters(String subjectId) {
    return _db
        .collection('subjects')
        .doc(subjectId)
        .collection('chapters')
        .snapshots()
        .map((snapshot) {
          final chapters = snapshot.docs
              .map(SubjectChapterModel.fromFirestore)
              .where((chapter) => chapter.active)
              .toList();

          chapters.sort((a, b) {
            final orderCompare = a.order.compareTo(b.order);
            if (orderCompare != 0) return orderCompare;
            return a.displayTitle.compareTo(b.displayTitle);
          });

          return List<SubjectChapterModel>.unmodifiable(chapters);
        });
  }
}
