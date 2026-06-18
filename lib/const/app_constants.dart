// lib/const/app_constants.dart

class AppConstants {
  AppConstants._();

  // ── App Info ──────────────────────────────────
  static const String appName = 'ExamAce';
  static const String appVersion = '1.0.0';

  // ── Firebase Collections ──────────────────────
  static const String usersCollection = 'users';
  static const String notificationsCollection = 'notifications';
  static const String fcmTokensCollection = 'fcmTokens';
  static const String postsCollection = 'posts';

  // ── SharedPreferences Keys ────────────────────
  static const String kThemeMode = 'theme_mode';
  static const String kOnboarded = 'has_seen_onboarding';
  static const String kAccessToken = 'access_token';

  // ── Timeouts ──────────────────────────────────
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration aiTimeout = Duration(seconds: 60);

  // ── Pagination ────────────────────────────────
  static const int pageSize = 20;
}
