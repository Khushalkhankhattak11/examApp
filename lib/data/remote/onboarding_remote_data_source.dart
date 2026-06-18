// lib/data/remote/onboarding_remote_data_source.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/onboarding_model.dart';

class OnboardingRemoteDataSource {
  static const _collection = 'onboarding';

  final FirebaseFirestore _firestore;

  OnboardingRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> save(String uid, OnboardingModel data) async {
    await _firestore
        .collection(_collection)
        .doc(uid)
        .set({
          ...data.toMap(),
          'uid'       : uid,
          'savedAt'   : FieldValue.serverTimestamp(),
        });
  }
}