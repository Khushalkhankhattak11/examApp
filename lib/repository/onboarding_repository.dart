// lib/repository/onboarding_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../const/const.dart';
import '../data/local/onboarding_local_data_source.dart';
import '../data/remote/onboarding_remote_data_source.dart';
import '../model/onboarding_model.dart';
import '../model/result.dart';

abstract interface class IOnboardingRepository {
  Future<void> saveLocally(OnboardingModel data);
  Future<OnboardingModel?> loadLocal();
  Future<Result<void>> pushToFirebase(String uid);
  Future<bool> isCompleted(String uid);
}

class OnboardingRepository implements IOnboardingRepository {
  final OnboardingLocalDataSource _local;
  final OnboardingRemoteDataSource _remote;
  final FirebaseFirestore _db;

  OnboardingRepository({
    OnboardingLocalDataSource? local,
    OnboardingRemoteDataSource? remote,
    FirebaseFirestore? firestore,
  }) : _local = local ?? OnboardingLocalDataSource(),
       _remote = remote ?? OnboardingRemoteDataSource(firestore: firestore),
       _db = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> saveLocally(OnboardingModel data) => _local.save(data);

  @override
  Future<OnboardingModel?> loadLocal() => _local.load();

  @override
  Future<Result<void>> pushToFirebase(String uid) async {
    try {
      final data = await _local.load();
      if (data == null) return const Failure('No onboarding data found');

      // 1. Save full snapshot to the separate `onboarding` collection (audit trail)
      await _remote.save(uid, data);

      // 2. Merge ALL onboarding fields into the `users/{uid}` document so that
      //    UserModel.fromMap() picks them all up in currentUserProvider.
      await _db.collection(AppConstants.usersCollection).doc(uid).set(
        {
          'onboardingCompleted': true,
          'selectedExam': data.selectedExam,
          'fullName': data.fullName,
          'age': data.age,
          'city': data.city,
          'educationLevel': data.educationLevel,
          'educationSubject': data.educationSubject,
          'academicStatus': data.academicStatus,
        },
        SetOptions(merge: true), // never overwrites uid / email / createdAt
      );

      // 3. Remove the local draft now that it's safely in Firestore
      await _local.clear();

      return const Success(null);
    } catch (e) {
      return Failure('Failed onboarding upload: $e', error: e);
    }
  }

  @override
  Future<bool> isCompleted(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data()?['onboardingCompleted'] == true;
  }
}
