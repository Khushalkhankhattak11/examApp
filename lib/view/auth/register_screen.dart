// ignore_for_file: deprecated_member_use

import 'package:examace/const/app_colors.dart';
import 'package:examace/const/app_responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../view_model/auth_view_model.dart';
import '../../view_model/onboarding_view_model.dart';
import '../../const/const.dart';
import 'widgets/auth_widgets.dart';

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = AppResponsive(context);
    final state = ref.watch(authViewModelProvider);
    final onboardingState = ref.watch(onboardingProvider);
    final vm = ref.read(authViewModelProvider.notifier);
    final profileName = onboardingState.fullName.trim();

    return Scaffold(
      backgroundColor: const Color(0xFF131409),
      body: Stack(
        children: [
          const AuthGridBackground(),
          Positioned(
            top: -r.h100,
            right: -r.w100,
            child: AuthGlowBlob(
              color: const Color(0xFFD8EE36),
              size: r.wp(100),
            ),
          ),
          Positioned(
            bottom: -r.h50,
            left: -r.w100,
            child: AuthGlowBlob(color: const Color(0xFF5822B8), size: r.wp(75)),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(r.sp20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Text(
                        'ExamAce',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: r.fs24,
                          fontWeight: FontWeight.w600,
                          color: AppColors.yellow,
                        ),
                      ),
                      SizedBox(height: r.h10 * 0.2),
                      Text(
                        'Create Account',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: r.fs42,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: r.h10 * 0.8),
                      Text(
                        'Join the elite circle of civil service aspirants.',
                        style: TextStyle(
                          fontSize: r.fs14,
                          color: const Color(0xFFC7C8AE),
                        ),
                      ),
                      SizedBox(height: r.h30),

                      AuthGlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AuthFieldLabel('FULL NAME'),
                            SizedBox(height: r.h10 * 0.8),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: r.sp12,
                                vertical: r.sp12 + 2,
                              ),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Color(0xFF464834)),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.person_outline_rounded,
                                    color: const Color(0xFF91937A),
                                    size: r.fs20,
                                  ),
                                  SizedBox(width: r.w10),
                                  Expanded(
                                    child: Text(
                                      profileName.isNotEmpty
                                          ? profileName
                                          : 'From profile setup',
                                      style: TextStyle(
                                        color: profileName.isNotEmpty
                                            ? Colors.white
                                            : const Color(0x4DC7C8AE),
                                        fontSize: r.fs15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: r.h20),

                            const AuthFieldLabel('EMAIL ADDRESS'),
                            SizedBox(height: r.h10 * 0.8),
                            AuthUnderlineField(
                              hint: 'name@example.com',
                              icon: Icons.mail_outline_rounded,
                              onChanged: vm.onEmailChanged,
                              inputType: TextInputType.emailAddress,
                            ),
                            SizedBox(height: r.h20),

                            const AuthFieldLabel('PASSWORD'),
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
                            SizedBox(height: r.h20),

                            // Terms
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: state.termsAccepted,
                                  onChanged: state.isLoading
                                      ? null
                                      : vm.toggleTermsAccepted,
                                  activeColor: const Color(0xFFD8EE36),
                                  checkColor: const Color(0xFF191E00),
                                  side: const BorderSide(
                                    color: Color(0xFF464834),
                                  ),
                                ),
                                SizedBox(width: r.w10 * 0.8),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: r.sp12),
                                    child: RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          color: const Color(0xFFC7C8AE),
                                          fontSize: r.fs13,
                                        ),
                                        children: const [
                                          TextSpan(text: 'I agree to the '),
                                          TextSpan(
                                            text: 'Terms of Service',
                                            style: TextStyle(
                                              color: Color(0xFFD8EE36),
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                          TextSpan(text: ' and '),
                                          TextSpan(
                                            text: 'Privacy Policy',
                                            style: TextStyle(
                                              color: Color(0xFFD8EE36),
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
                            SizedBox(height: r.h20),

                            // Sign up button
                            SizedBox(
                              width: double.infinity,
                              height: r.h50 * 1.1,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD8EE36),
                                  foregroundColor: const Color(0xFF191E00),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                  textStyle: TextStyle(
                                    fontSize: r.fs16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                onPressed: state.isLoading || !state.canRegister
                                    ? null
                                    : () async {
                                        final ok = await vm.register();
                                        if (ok && context.mounted) {
                                          // FIX: go to main, not onboarding.
                                          // register() already pushed onboarding
                                          // data to Firestore and set the flag.
                                          Navigator.pushReplacementNamed(
                                            context,
                                            AppRoutes.main,
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
                                            'Sign Up',
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
                          ],
                        ),
                      ),

                      SizedBox(height: r.h30),

                      // Login link
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: TextStyle(
                                color: const Color(0xFFC7C8AE),
                                fontSize: r.fs14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  Navigator.pushNamed(context, AppRoutes.login),
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  color: const Color(0xFFD8EE36),
                                  fontSize: r.fs14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
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
