// lib/view/auth/widgets/auth_widgets.dart

// ignore_for_file: unused_local_variable, deprecated_member_use

import 'dart:ui';
import 'package:examace/const/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Grid background ───────────────────────────
class AuthGridBackground extends StatelessWidget {
  const AuthGridBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(child: CustomPaint(painter: GridPainter()));
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x141E1E2E)
      ..strokeWidth = 1;
    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Glow blob ─────────────────────────────────
class AuthGlowBlob extends StatelessWidget {
  final Color color;
  final double size;
  const AuthGlowBlob({super.key, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.12),
        ),
      ),
    );
  }
}

// ── Glass card ────────────────────────────────
class AuthGlassCard extends StatelessWidget {
  final Widget child;
  const AuthGlassCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardColor.withOpacity(.80),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E1E2E)),
      ),
      child: child,
    );
  }
}

// ── Field label ───────────────────────────────
class AuthFieldLabel extends StatelessWidget {
  final String text;
  const AuthFieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      style: GoogleFonts.spaceMono(
        fontSize: 12,
        letterSpacing: 1.5,
        wordSpacing: 2,
        color: AppColors.artichoke,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

// ── Underline text field ───────────────────────
class AuthUnderlineField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final ValueChanged<String>? onChanged;
  final TextInputType? inputType;
  final bool obscure;
  final Widget? suffix;
  final TextEditingController? controller;

  const AuthUnderlineField({
    super.key,
    required this.hint,
    required this.icon,
    this.onChanged,
    this.inputType,
    this.obscure = false,
    this.suffix,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: inputType,
      obscureText: obscure,
      style: TextStyle(color: AppColors.onPrimaryContainerDark.withOpacity(.6)),
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Icon(icon, color: AppColors.artichoke, size: 20),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 28,
          minHeight: 20,
        ),
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.darkOvel),
        filled: false,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.artichoke),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.artichoke),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.artichoke, width: 2),
        ),
        suffixIcon: suffix,
      ),
    );
  }
}
