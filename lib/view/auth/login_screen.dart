// lib/view/auth/login_screen.dart

// ignore_for_file: deprecated_member_use

import 'package:examace/const/app_responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../view_model/auth_view_model.dart';
import '../../const/const.dart';
import 'widgets/auth_widgets.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = AppResponsive(context);
    final state = ref.watch(authViewModelProvider);
    final vm = ref.read(authViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF131409),
      body: Stack(
        children: [
          // ── Background layers ──────────────────────────────
          const AuthGridBackground(),
          Positioned(
            top: -r.h100,
            left: -r.w100,
            child: AuthGlowBlob(
              color: const Color(0xFFD8EE36),
              size: r.wp(100),
            ),
          ),
          Positioned(
            bottom: -r.h50,
            right: -r.w100,
            child: AuthGlowBlob(color: const Color(0xFF5822B8), size: r.wp(80)),
          ),

          // ── Content ────────────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(r.sp20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    children: [
                      // ── Brand ──────────────────────────────
                      Column(
                        children: [
                          Container(
                            width: r.w50 * 1.1,
                            height: r.w50 * 1.1,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD8EE36),
                              borderRadius: BorderRadius.circular(r.sp16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFD8EE36,
                                  ).withValues(alpha: 0.3),
                                  blurRadius: r.sp20,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.school_rounded,
                              color: const Color(0xFF191E00),
                              size: r.fs28,
                            ),
                          ),
                          SizedBox(height: r.h20 * 0.8),
                          Text(
                            'ExamAce',
                            style: TextStyle(
                              fontSize: r.fs42,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFD8EE36),
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: r.h10 * 0.4),
                          Text(
                            'COMPETITIVE EXCELLENCE',
                            style: TextStyle(
                              fontSize: r.fs11,
                              letterSpacing: 3,
                              color: const Color(0xFFC7C8AE),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: r.h30),

                      // ── Glass card ─────────────────────────
                      AuthGlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome Back',
                              style: TextStyle(
                                fontSize: r.fs24,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: r.h10 * 0.4),
                            Text(
                              'Continue your journey to civil service success.',
                              style: TextStyle(
                                fontSize: r.fs14,
                                color: const Color(0xFFC7C8AE),
                              ),
                            ),
                            SizedBox(height: r.h30),

                            // Email
                            const AuthFieldLabel('OFFICIAL EMAIL'),
                            SizedBox(height: r.h10 * 0.8),
                            AuthUnderlineField(
                              hint: 'name@example.com',
                              icon: Icons.mail_outline_rounded,
                              onChanged: vm.onEmailChanged,
                              inputType: TextInputType.emailAddress,
                            ),
                            SizedBox(height: r.h20),

                            // Password label row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const AuthFieldLabel('SECURE PASSWORD'),
                                GestureDetector(
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.forgotPassword,
                                  ),
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      fontSize: r.fs11,
                                      color: const Color(0xFFBCD20E),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: r.h10 * 0.8),
                            AuthUnderlineField(
                              hint: '••••••••',
                              icon: Icons.lock_outline_rounded,
                              onChanged: vm.onPasswordChanged,
                              obscure: !state.isPasswordVisible,
                              suffix: IconButton(
                                icon: Icon(
                                  state.isPasswordVisible
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: const Color(0xFF91937A),
                                  size: r.fs20,
                                ),
                                onPressed: vm.togglePasswordVisibility,
                              ),
                            ),

                            if (state.errorMessage != null) ...[
                              SizedBox(height: r.h10 * 0.8),
                              Text(
                                state.errorMessage!,
                                style: TextStyle(
                                  color: const Color(0xFFFFB4AB),
                                  fontSize: r.fs13,
                                ),
                              ),
                            ],
                            SizedBox(height: r.h30),

                            // Sign in button
                            SizedBox(
                              width: double.infinity,
                              height: r.h50 * 1.1,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD8EE36),
                                  foregroundColor: const Color(0xFF191E00),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(r.sp12),
                                  ),
                                  elevation: 0,
                                  textStyle: TextStyle(
                                    fontSize: r.fs16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                onPressed: state.isLoading
                                    ? null
                                    : () async {
                                        final ok = await vm.signIn();
                                        if (!ok || !context.mounted) return;

                                        // FIX: check onboardingDone from state.
                                        // signIn() sets it by calling isCompleted()
                                        // on Firestore — so route accordingly.
                                        final authState = ref.read(
                                          authViewModelProvider,
                                        );

                                        if (authState.onboardingDone) {
                                          Navigator.pushReplacementNamed(
                                            context,
                                            AppRoutes.main,
                                          );
                                        } else {
                                          // Signed in but never finished onboarding
                                          Navigator.pushReplacementNamed(
                                            context,
                                            AppRoutes.onboarding,
                                          );
                                        }
                                      },
                                child: state.isLoading
                                    ? SizedBox(
                                        width: r.fs22,
                                        height: r.fs22,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xFF191E00),
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Enter Academy',
                                            style: TextStyle(fontSize: r.fs16),
                                          ),
                                          SizedBox(width: r.w10 * 0.8),
                                          Icon(
                                            Icons.arrow_forward_rounded,
                                            size: r.fs20,
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            SizedBox(height: r.h20),

                            // Server status
                            Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: r.w10 * 0.8,
                                    height: r.w10 * 0.8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFD8EE36),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: r.w10 * 0.8),
                                  Text(
                                    'Elite Performance Server Active',
                                    style: TextStyle(
                                      fontSize: r.fs11,
                                      color: const Color(0xFFC7C8AE),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: r.h20),

                      // Sign up link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              color: const Color(0xFFC7C8AE),
                              fontSize: r.fs14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes
                                  .onboarding, // FIX: new users go to onboarding first, not register
                            ),
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                color: const Color(0xFFD8EE36),
                                fontSize: r.fs14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
