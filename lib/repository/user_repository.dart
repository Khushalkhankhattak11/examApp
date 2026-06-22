// lib/repository/user_repository.dart

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/model.dart';

abstract interface class IUserRepository {
  Stream<UserModel?> watchCurrentUser(String uid);
  Future<UserModel?> fetchUser(String uid);
  Future<int> updateDailyStreak(String uid);
  Stream<List<QuizActivityModel>> watchRecentActivities(String uid);
  Future<void> recordQuizAttempt({
    required String uid,
    required String title,
    required String type,
    required int correctAnswers,
    required int totalQuestions,
    String subjectId,
    String chapterId,
    String topicId,
  });
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

  @override
  Future<int> updateDailyStreak(String uid) async {
    final userRef = _db.collection('users').doc(uid);
    final now = DateTime.now();
    final today = _dateKey(now);
    final yesterday = _dateKey(
      DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1)),
    );

    return _db.runTransaction<int>((transaction) async {
      final snapshot = await transaction.get(userRef);
      if (!snapshot.exists) return 0;

      final data = snapshot.data() ?? const <String, dynamic>{};
      final currentStreak = (data['streakDays'] as num?)?.toInt() ?? 0;
      final lastStreakDate = data['lastStreakDate'] as String? ?? '';

      // Opening the app again on the same calendar day must not increment it.
      if (lastStreakDate == today && currentStreak > 0) {
        return currentStreak;
      }

      final nextStreak = lastStreakDate == yesterday ? currentStreak + 1 : 1;
      transaction.set(userRef, {
        'streakDays': nextStreak,
        'lastStreakDate': today,
        'streakUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return nextStreak;
    });
  }

  @override
  Stream<List<QuizActivityModel>> watchRecentActivities(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('recentActivities')
        .orderBy('completedAt', descending: true)
        .limit(10)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(QuizActivityModel.fromFirestore)
              .toList(growable: false),
        );
  }

  @override
  Future<void> recordQuizAttempt({
    required String uid,
    required String title,
    required String type,
    required int correctAnswers,
    required int totalQuestions,
    String subjectId = '',
    String chapterId = '',
    String topicId = '',
  }) async {
    if (totalQuestions <= 0) return;

    final userRef = _db.collection('users').doc(uid);
    final activityRef = userRef.collection('recentActivities').doc();
    final safeCorrect = correctAnswers.clamp(0, totalQuestions).toInt();
    final scorePercent = ((safeCorrect / totalQuestions) * 100).round();

    await _db.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      if (!userSnapshot.exists) {
        throw StateError('User profile does not exist');
      }

      final data = userSnapshot.data() ?? const <String, dynamic>{};
      final oldTests = (data['testsTaken'] as num?)?.toInt() ?? 0;
      final oldAverage = (data['averageScore'] as num?)?.toInt() ?? 0;
      final oldScoreTotal =
          (data['scoreTotal'] as num?)?.toInt() ?? oldAverage * oldTests;
      final oldBest = (data['bestScore'] as num?)?.toInt() ?? 0;
      final oldSolved = (data['totalSolved'] as num?)?.toInt() ?? 0;
      final newTests = oldTests + 1;
      final newScoreTotal = oldScoreTotal + scorePercent;

      transaction.set(userRef, {
        'testsTaken': newTests,
        'scoreTotal': newScoreTotal,
        'averageScore': (newScoreTotal / newTests).round(),
        'bestScore': max(oldBest, scorePercent),
        'totalSolved': oldSolved + totalQuestions,
        'lastActivityAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      transaction.set(activityRef, {
        'title': title,
        'type': type,
        'subjectId': subjectId,
        'chapterId': chapterId,
        'topicId': topicId,
        'correctAnswers': safeCorrect,
        'totalQuestions': totalQuestions,
        'scorePercent': scorePercent,
        'completedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  String _dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
