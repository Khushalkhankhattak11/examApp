// lib/data/remote/auth_remote_data_source.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../model/model.dart';
import '../../const/const.dart';

class AuthRemoteDataSource {
  final FirebaseAuth      _auth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSource({
    FirebaseAuth?      auth,
    FirebaseFirestore? firestore,
  })  : _auth      = auth      ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  // ── Sign In ───────────────────────────────────
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email, password: password,
    );
    return _fetchOrCreateUser(credential.user!);
  }

  // ── Register ──────────────────────────────────
  Future<UserModel> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email, password: password,
    );
    await credential.user!.updateDisplayName(displayName);

    final user = UserModel(
      uid         : credential.user!.uid,
      email       : email,
      displayName : displayName,
      createdAt   : DateTime.now(),
    );

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set(user.toMap());

    return user;
  }

  // ── Sign Out ──────────────────────────────────
  Future<void> signOut() => _auth.signOut();

  // ── Current User Stream ───────────────────────
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Helpers ───────────────────────────────────
  Future<UserModel> _fetchOrCreateUser(User firebaseUser) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(firebaseUser.uid)
        .get();

    if (doc.exists) return UserModel.fromMap(doc.data()!);

    // First-time social login: create profile
    final user = UserModel(
      uid         : firebaseUser.uid,
      email       : firebaseUser.email ?? '',
      displayName : firebaseUser.displayName ?? 'User',
      photoUrl    : firebaseUser.photoURL,
      createdAt   : DateTime.now(),
    );
    await doc.reference.set(user.toMap());
    return user;
  }
}
