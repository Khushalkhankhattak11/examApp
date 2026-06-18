// ignore_for_file: unused_local_variable, deprecated_member_use

import 'package:examace/const/app_responsive.dart';
import 'package:flutter/material.dart';

class PremiumStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color activeColor;
  final Color inactiveColor;

  const PremiumStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive(context);
    const primary = Color(0xFFD8EE36);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: r.sp28, vertical: r.h30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r.sp28),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F1008), Color(0xFF131409)],
        ),
      ),
      child: Row(
        children: [
          _step(
            r: r,
            number: 1,
            isActive: currentStep == 0,
            isCompleted: currentStep > 0,
          ),
          _line(r: r, active: currentStep > 0),
          _step(
            r: r,
            number: 2,
            isActive: currentStep == 1,
            isCompleted: currentStep > 1,
          ),
          _line(r: r, active: currentStep > 1),
          _step(
            r: r,
            number: 3,
            isActive: currentStep == 2,
            isCompleted: false,
          ),
        ],
      ),
    );
  }

  Widget _line({required AppResponsive r, required bool active}) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: r.sp12 + 2),
        height: 1,
        color: active
            ? const Color(0xFFD8EE36).withOpacity(0.5)
            : Colors.white.withOpacity(0.08),
      ),
    );
  }

  Widget _step({
    required AppResponsive r,
    required int number,
    required bool isActive,
    required bool isCompleted,
  }) {
    const primary = Color(0xFFD8EE36);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: r.w50 * 1.24,
      height: r.w50 * 1.24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? primary : Colors.transparent,
        border: Border.all(
          color: isActive ? primary : Colors.white.withOpacity(0.18),
          width: 1.5,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: primary.withOpacity(0.35),
                  blurRadius: r.sp24,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: Center(
        child: Text(
          '$number',
          style: TextStyle(
            color: isActive ? Colors.black : Colors.white.withOpacity(0.55),
            fontSize: r.fs28,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
