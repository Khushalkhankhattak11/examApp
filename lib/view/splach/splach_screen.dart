// lib/view/splash/splash_screen.dart

// ignore_for_file: unused_local_variable, deprecated_member_use

import 'package:examace/const/app_responsive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../const/const.dart';
import '../../view_model/providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );

    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) _decideNavigation();
    });
  }

  Future<void> _decideNavigation() async {
    final prefs = await SharedPreferences.getInstance();

    // ── Flag is set by AuthViewModel.register() after the user completes
    //    onboarding AND creates an account. On a fresh install (or after
    //    the user clears app data) it is always false.
    final hasSeenOnboarding = prefs.getBool(AppConstants.kOnboarded) ?? false;

    // ── CASE 1: Fresh install or app data cleared ──────────────────────────
    // Always send to onboarding, even if Firebase still has a cached token
    // (Android can keep the Firebase Auth token across reinstalls via Google
    // account backup, but we have no local onboarding data).
    if (!hasSeenOnboarding) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      return;
    }

    // ── CASE 2: Flag is set but session expired ────────────────────────────
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }

    // ── CASE 3: Logged in — verify Firestore onboarding completion ─────────
    // Edge case: flag is set but Firestore write failed previously.
    final repo = ref.read(onboardingRepositoryProvider);
    final onboardingDone = await repo.isCompleted(firebaseUser.uid);

    if (!mounted) return;

    if (onboardingDone) {
      // ── CASE 3a: Fully onboarded → go straight to the app ─────────────
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    } else {
      // ── CASE 3b: Logged in but onboarding not in Firestore ─────────────
      // Shouldn't normally happen, but handles partial failures gracefully.
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive(context);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFF131409),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8EE36),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD8EE36).withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    color: const Color(0xFF191E00),
                    size: r.fs36,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  AppConstants.appName,
                  style: text.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFD8EE36),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'CRACK EVERY GOVERNMENT EXAM',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: const Color(0xFFC7C8AE),
                  ),
                ),
                const SizedBox(height: 48),
                const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Color(0xFFD8EE36),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
