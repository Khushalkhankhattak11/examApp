import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/model.dart';

class SubjectRepository {
  final FirebaseFirestore _db;

  SubjectRepository({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  Stream<List<SubjectModel>> watchActiveSubjects() {
    return _db
        .collection('subjects')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(SubjectModel.fromFirestore)
              .where((subject) => subject.active)
              .toList(growable: false),
        );
  }
}
