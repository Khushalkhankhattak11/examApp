// lib/main.dart

import 'package:examace/const/app_theme.dart';
import 'package:examace/view/auth/forget_password_screen.dart';
import 'package:examace/view/exams/subject_detail_screen.dart';
import 'package:examace/view/lecture/quizz/quizz_screen.dart';
import 'package:examace/view/main/main_screen.dart';
import 'package:examace/view/onboarding/onboarding_view.dart';
import 'package:examace/view/profile/notifications/notifications_screen.dart';
import 'package:examace/view/profile/profile_screen.dart';
import 'package:examace/view/profile/report_card/report_card_screen.dart';
import 'package:examace/view/splach/splach_screen.dart';
import 'package:examace/view/stats/state_view.dart';
import 'package:examace/view/test/test_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'const/const.dart';
import 'services/firebase/firebase_service.dart';
import 'services/notification_service.dart';
import 'view/auth/login_screen.dart';
import 'view/auth/register_screen.dart';
import 'view/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();
  await NotificationService.instance.initialize();

  runApp(const ProviderScope(child: App()));
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: AppConstants.appName,
      navigatorKey: NotificationService.navigatorKey,
      debugShowCheckedModeBanner: false,

      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,

      // ✅ KEEP SPLASH ONLY ENTRY
      initialRoute: AppRoutes.splash,

      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.onboarding: (_) => const OnboardingScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.register: (_) => const RegisterScreen(),
        AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
        AppRoutes.main: (_) => const MainScreen(),
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.exams: (_) => const ExamScreen(),
        AppRoutes.test: (_) => const TestScreen(),
        AppRoutes.stats: (_) => const StatsScreen(),
        AppRoutes.profile: (_) => const ProfileScreen(),
        AppRoutes.notifications: (_) => const NotificationsScreen(),
        AppRoutes.reportCard: (_) => const ReportCardScreen(),
        AppRoutes.quizz: (_) => const QuizScreen(),
        AppRoutes.quizzResult: (_) => const ReviewAnswersScreen(),
      },
    );
  }
}
