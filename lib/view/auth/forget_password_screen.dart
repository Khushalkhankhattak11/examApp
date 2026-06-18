import 'package:examace/const/app_responsive.dart';
import 'package:examace/view/auth/widgets/auth_widgets.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Please enter your email.');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        setState(() {
          _sent = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Could not send reset email. Check the address.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Stack(
        children: [
          // ── Dot-grid background ────────────────────────────
          Positioned.fill(child: CustomPaint(painter: _DotGridPainter())),

          SafeArea(
            child: Column(
              children: [
                // ── Back button ────────────────────────────────
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.all(r.sp12),
                    child: IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF1F2015),
                        shape: const CircleBorder(
                          side: BorderSide(
                            color: Color(0xFF464834),
                            width: 0.5,
                          ),
                        ),
                      ),
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: const Color(0xFFC7C8AE),
                        size: r.fs20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),

                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(r.sp20),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Header ─────────────────────────
                            Row(
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                        colors: [
                                          Color(0xFFD1BCFF),
                                          Color(0xFFD8EE36),
                                        ],
                                      ).createShader(bounds),
                                  child: Icon(
                                    Icons.auto_awesome_rounded,
                                    color: Colors.white,
                                    size: r.fs22,
                                  ),
                                ),
                                SizedBox(width: r.w10 * 0.8),
                                Text(
                                  'SECURITY PROTOCOL',
                                  style: TextStyle(
                                    fontSize: r.fs11,
                                    letterSpacing: 3,
                                    color: const Color(0xFFD8EE36),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: r.h10),
                            Text(
                              'Reset\nPassword',
                              style: TextStyle(
                                fontSize: r.fs42,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.1,
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: r.h10),
                            Text(
                              'Enter your email to receive reset instructions.',
                              style: TextStyle(
                                fontSize: r.fs15,
                                color: const Color(0xFFC7C8AE),
                              ),
                            ),
                            SizedBox(height: r.h30),

                            // ── Glass card ─────────────────────
                            AuthGlassCard(
                              child: _sent
                                  ? _SuccessView(r: r)
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const AuthFieldLabel(
                                          'OFFICIAL EMAIL ADDRESS',
                                        ),
                                        SizedBox(height: r.h10),
                                        AuthUnderlineField(
                                          controller: _emailController,
                                          hint: 'name@example.com',
                                          icon: Icons.mail_outline_rounded,
                                          inputType: TextInputType.emailAddress,
                                        ),

                                        if (_error != null) ...[
                                          SizedBox(height: r.h10 * 0.8),
                                          Text(
                                            _error!,
                                            style: TextStyle(
                                              color: const Color(0xFFFFB4AB),
                                              fontSize: r.fs13,
                                            ),
                                          ),
                                        ],
                                        SizedBox(height: r.h30),

                                        // Send button
                                        SizedBox(
                                          width: double.infinity,
                                          height: r.h50 * 1.1,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFFD8EE36,
                                              ),
                                              foregroundColor: const Color(
                                                0xFF191E00,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      r.sp12,
                                                    ),
                                              ),
                                              elevation: 0,
                                              textStyle: TextStyle(
                                                fontSize: r.fs16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            onPressed: _isLoading
                                                ? null
                                                : _send,
                                            child: _isLoading
                                                ? SizedBox(
                                                    width: r.fs22,
                                                    height: r.fs22,
                                                    child:
                                                        const CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: Color(
                                                            0xFF191E00,
                                                          ),
                                                        ),
                                                  )
                                                : Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        'Send Instructions',
                                                        style: TextStyle(
                                                          fontSize: r.fs16,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: r.w10 * 0.8,
                                                      ),
                                                      Icon(
                                                        Icons.send_rounded,
                                                        size: r.fs18,
                                                      ),
                                                    ],
                                                  ),
                                          ),
                                        ),
                                        SizedBox(height: r.h20),

                                        // Encrypted note
                                        Center(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.verified_user_outlined,
                                                color: const Color(0xFFC7C8AE),
                                                size: r.fs16,
                                              ),
                                              SizedBox(width: r.w10 * 0.6),
                                              Text(
                                                'Encrypted with AES-256 standard',
                                                style: TextStyle(
                                                  color: const Color(
                                                    0xFFC7C8AE,
                                                  ),
                                                  fontSize: r.fs12,
                                                ),
                                              ),
                                            ],
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

                // ── Footer ────────────────────────────────────
                Padding(
                  padding: EdgeInsets.only(bottom: r.h20),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: const Color(0xFFC7C8AE),
                        fontSize: r.fs13,
                      ),
                      children: const [
                        TextSpan(text: 'Stuck? '),
                        TextSpan(
                          text: 'Contact Academic Support',
                          style: TextStyle(
                            color: Color(0xFFD8EE36),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Success view ──────────────────────────────
class _SuccessView extends StatelessWidget {
  final AppResponsive r;
  const _SuccessView({required this.r});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.mark_email_read_outlined,
          color: const Color(0xFFD8EE36),
          size: r.fs42 * 1.1,
        ),
        SizedBox(height: r.h20 * 0.8),
        Text(
          'Check your inbox',
          style: TextStyle(
            fontSize: r.fs20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        SizedBox(height: r.h10 * 0.8),
        Text(
          "We've sent password reset instructions to your email address.",
          textAlign: TextAlign.center,
          style: TextStyle(color: const Color(0xFFC7C8AE), fontSize: r.fs14),
        ),
        SizedBox(height: r.h20),
        SizedBox(
          width: double.infinity,
          height: r.h50,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFD8EE36),
              side: const BorderSide(color: Color(0xFFD8EE36)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(r.sp12),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Back to Login',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: r.fs15),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Dot grid painter ──────────────────────────
class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    const step = 32.0;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
