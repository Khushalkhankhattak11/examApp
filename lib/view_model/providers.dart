// lib/view_model/providers.dart

// ignore_for_file: unnecessary_underscores

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/auth_repository.dart';
import '../repository/onboarding_repository.dart';
import '../repository/subject_chapter_repository.dart';
import '../repository/subject_progress_repository.dart';
import '../repository/subject_repository.dart';
import '../repository/subject_topic_repository.dart';
import '../repository/notification_repository.dart';
import '../repository/user_repository.dart'; // ← ADD
import '../model/model.dart'; // ← ADD

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepository();
});

final onboardingRepositoryProvider = Provider<IOnboardingRepository>((ref) {
  return OnboardingRepository();
});

// ── ADD BELOW ────────────────────────────────────────────────────────────────

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

final subjectRepositoryProvider = Provider<SubjectRepository>((ref) {
  return SubjectRepository();
});

final subjectChapterRepositoryProvider = Provider<SubjectChapterRepository>((
  ref,
) {
  return SubjectChapterRepository();
});

final subjectProgressRepositoryProvider = Provider<SubjectProgressRepository>((
  ref,
) {
  return SubjectProgressRepository();
});

final subjectTopicRepositoryProvider = Provider<SubjectTopicRepository>((ref) {
  return SubjectTopicRepository();
});

class SubjectTopicsRequest {
  final String subjectId;
  final String chapterId;

  const SubjectTopicsRequest({
    required this.subjectId,
    required this.chapterId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubjectTopicsRequest &&
          subjectId == other.subjectId &&
          chapterId == other.chapterId;

  @override
  int get hashCode => Object.hash(subjectId, chapterId);
}

class SubjectProgressRequest {
  final String uid;
  final String subjectId;

  const SubjectProgressRequest({required this.uid, required this.subjectId});

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SubjectProgressRequest &&
            uid == other.uid &&
            subjectId == other.subjectId;
  }

  @override
  int get hashCode => Object.hash(uid, subjectId);
}

/// Streams the raw Firebase auth state (signed-in User or null).
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Streams the full UserModel from Firestore, kept in sync automatically.
/// Both HomeScreen and ProfileScreen watch this — one source of truth.
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final authAsync = ref.watch(authStateProvider);

  return authAsync.when(
    data: (firebaseUser) {
      if (firebaseUser == null) return Stream.value(null);
      return ref
          .read(userRepositoryProvider)
          .watchCurrentUser(firebaseUser.uid);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

/// Records one streak day per local calendar day. Consecutive days increment
/// the counter; returning after a missed day resets it to one.
final dailyStreakProvider = FutureProvider.family<int, String>((ref, uid) {
  return ref.read(userRepositoryProvider).updateDailyStreak(uid);
});

final recentActivitiesProvider =
    StreamProvider.family<List<QuizActivityModel>, String>((ref, uid) {
      return ref.read(userRepositoryProvider).watchRecentActivities(uid);
    });

final userNotificationsProvider =
    StreamProvider.family<List<AppNotificationModel>, String>((ref, uid) {
      return ref.read(notificationRepositoryProvider).watchNotifications(uid);
    });

final activeSubjectsProvider = StreamProvider<List<SubjectModel>>((ref) {
  return ref.read(subjectRepositoryProvider).watchActiveSubjects();
});

final subjectChaptersProvider =
    StreamProvider.family<List<SubjectChapterModel>, String>((ref, subjectId) {
      return ref
          .read(subjectChapterRepositoryProvider)
          .watchSubjectChapters(subjectId);
    });

final subjectTopicsProvider =
    StreamProvider.family<List<SubjectTopicModel>, SubjectTopicsRequest>((
      ref,
      request,
    ) {
      return ref
          .read(subjectTopicRepositoryProvider)
          .watchChapterTopics(
            subjectId: request.subjectId,
            chapterId: request.chapterId,
          );
    });

final subjectProgressProvider =
    StreamProvider.family<SubjectProgressModel, SubjectProgressRequest>((
      ref,
      request,
    ) {
      return ref
          .read(subjectProgressRepositoryProvider)
          .watchSubjectProgress(uid: request.uid, subjectId: request.subjectId);
    });
