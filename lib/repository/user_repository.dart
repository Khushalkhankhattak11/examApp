// lib/repository/user_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/model.dart';

abstract interface class IUserRepository {
  Stream<UserModel?> watchCurrentUser(String uid);
  Future<UserModel?> fetchUser(String uid);
}

class UserRepository implements IUserRepository {
  final FirebaseFirestore _db;

  UserRepository({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  @override
  Stream<UserModel?> watchCurrentUser(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snap) => snap.exists ? UserModel.fromMap(snap.data()!) : null);
  }

  @override
  Future<UserModel?> fetchUser(String uid) async {
    final snap = await _db.collection('users').doc(uid).get();
    return snap.exists ? UserModel.fromMap(snap.data()!) : null;
  }
}
