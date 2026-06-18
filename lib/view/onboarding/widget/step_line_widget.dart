import 'package:examace/const/app_responsive.dart';
import 'package:flutter/material.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  const StepIndicator({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StepDot(
          r: r,
          number: 1,
          active: currentStep >= 0,
          done: currentStep > 0,
        ),
        _StepLine(r: r, active: currentStep > 0),
        _StepDot(
          r: r,
          number: 2,
          active: currentStep >= 1,
          done: currentStep > 1,
        ),
        _StepLine(r: r, active: currentStep > 1),
        _StepDot(r: r, number: 3, active: currentStep >= 2, done: false),
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  final AppResponsive r;
  final int number;
  final bool active;
  final bool done;

  const _StepDot({
    required this.r,
    required this.number,
    required this.active,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: active ? 1 : 0.4,
      duration: const Duration(milliseconds: 200),
      child: Container(
        width: r.w30 * 1.07,
        height: r.w30 * 1.07,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? const Color(0xFFD8EE36) : Colors.transparent,
          border: active ? null : Border.all(color: const Color(0xFF91937A)),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: const Color(0xFFD8EE36).withValues(alpha: 0.4),
                    blurRadius: 15,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: done
              ? Icon(
                  Icons.check_rounded,
                  color: const Color(0xFF191E00),
                  size: r.fs16,
                )
              : Text(
                  '$number',
                  style: TextStyle(
                    fontSize: r.fs12,
                    fontWeight: FontWeight.w700,
                    color: active
                        ? const Color(0xFF191E00)
                        : const Color(0xFFC7C8AE),
                  ),
                ),
        ),
      ),
    );
  }
}

class _StepLine extends StatelessWidget {
  final AppResponsive r;
  final bool active;
  const _StepLine({required this.r, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: r.w50 * 0.96,
      height: 1,
      margin: EdgeInsets.symmetric(horizontal: r.w10 * 0.8),
      color: active ? const Color(0xFFD8EE36) : const Color(0xFF464834),
    );
  }
}
