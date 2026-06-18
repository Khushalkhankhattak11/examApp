// lib/view/onboarding/steps/exam_selection_step.dart

// ignore_for_file: deprecated_member_use

import 'package:examace/const/app_responsive.dart';
import 'package:examace/view/onboarding/widget/footer_widget.dart';
import 'package:examace/view/onboarding/widget/step_line_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../view_model/onboarding_view_model.dart';

class _ExamItem {
  final String name;
  final String subtitle;
  final String subjects;
  final IconData icon;

  const _ExamItem({
    required this.name,
    required this.subtitle,
    required this.subjects,
    required this.icon,
  });
}

const _exams = [
  _ExamItem(
    name: 'SST',
    subtitle: 'Secondary Teacher',
    subjects: '8 SUBJECTS',
    icon: Icons.school_rounded,
  ),
  _ExamItem(
    name: 'PST',
    subtitle: 'Primary Teacher',
    subjects: '6 SUBJECTS',
    icon: Icons.menu_book_rounded,
  ),
  _ExamItem(
    name: 'FIA',
    subtitle: 'Comp. Operator',
    subjects: '5 SUBJECTS',
    icon: Icons.computer_rounded,
  ),
  _ExamItem(
    name: 'NTS',
    subtitle: 'NTS General',
    subjects: '7 SUBJECTS',
    icon: Icons.assignment_rounded,
  ),
  _ExamItem(
    name: 'CSS',
    subtitle: 'CSS / PMS Elite',
    subjects: '12 SUBJECTS',
    icon: Icons.account_balance_rounded,
  ),
  _ExamItem(
    name: 'FPSC',
    subtitle: 'FPSC Clerk',
    subjects: '4 SUBJECTS',
    icon: Icons.gavel_rounded,
  ),
];

class ExamSelectionStep extends ConsumerWidget {
  const ExamSelectionStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = AppResponsive(context);
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return ListView(
      children: [
        // ── Header ──────────────────────────────────────
        Padding(
          padding: EdgeInsets.fromLTRB(r.sp20, r.h20, r.sp20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: r.h10),
              StepIndicator(currentStep: state.currentStep),
              SizedBox(height: r.h20),

              Text(
                'Which exam are\nyou targeting?',
                style: TextStyle(
                  fontSize: r.fs36,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.1,
                  letterSpacing: -0.5,
                ),
              ),

              SizedBox(height: r.h10 * 0.8),

              Text(
                'Tailor your learning path for Pakistani\ncivil service success.',
                style: TextStyle(
                  fontSize: r.fs14,
                  color: const Color(0xFFC7C8AE),
                  height: 1.5,
                ),
              ),

              SizedBox(height: r.h20),
            ],
          ),
        ),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: r.sp20),
          child: GridView.builder(
            shrinkWrap: true,
            primary: true,
            padding: EdgeInsets.only(bottom: r.h100 * .099),
            itemCount: _exams.length,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) {
              final exam = _exams[index];
              final selected = state.selectedExam == exam.name;

              return _ExamCard(
                r: r,
                exam: exam,
                selected: selected,
                onTap: () => notifier.selectExam(exam.name),
              );
            },
          ),
        ),

        // ── Footer CTA ───────────────────────────────────
        FooterCTA(
          r: r,
          btnTitle: 'Continue',
          enabled: state.isStep1Valid,
          onTap: () async {
            await notifier.saveLocally();
            notifier.nextStep();
          },
        ),
      ],
    );
  }
}

// ── Exam card ─────────────────────────────────
class _ExamCard extends StatelessWidget {
  final AppResponsive r;
  final _ExamItem exam;
  final bool selected;
  final VoidCallback onTap;

  const _ExamCard({
    required this.r,
    required this.exam,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(r.sp16),
        decoration: BoxDecoration(
          color: const Color(0xCC131309),
          borderRadius: BorderRadius.circular(r.sp16),
          border: Border.all(
            color: selected ? const Color(0xFFD8EE36) : const Color(0xFF1E1E2E),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFFD8EE36).withValues(alpha: 0.15),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon box
            Container(
              width: r.w40,
              height: r.w40,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFD8EE36).withValues(alpha: 0.15)
                    : const Color(0xFF353629),
                borderRadius: BorderRadius.circular(r.sp8 + 2),
              ),
              child: Icon(
                exam.icon,
                size: r.fs20,
                color: selected
                    ? const Color(0xFFD8EE36)
                    : const Color(0xFFC7C8AE),
              ),
            ),

            SizedBox(height: r.h10),

            // Exam name
            Text(
              exam.name,
              style: TextStyle(
                fontSize: r.fs22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),

            SizedBox(height: r.h10 * 0.2),

            // Subtitle
            Text(
              exam.subtitle,
              style: TextStyle(
                fontSize: r.fs12,
                color: const Color(0xFFC7C8AE),
              ),
            ),

            const Spacer(),

            // Subject badge + check
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: r.sp8,
                    vertical: r.sp4 - 1,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFD8EE36).withValues(alpha: 0.1)
                        : const Color(0xFF353629),
                    borderRadius: BorderRadius.circular(r.sp4),
                  ),
                  child: Text(
                    exam.subjects,
                    style: TextStyle(
                      fontSize: r.fs10,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? const Color(0xFFD8EE36)
                          : const Color(0xFFC7C8AE),
                    ),
                  ),
                ),

                if (selected) ...[
                  SizedBox(width: r.w10 * 0.6),

                  Icon(
                    Icons.check_circle_rounded,
                    color: const Color(0xFFD8EE36),
                    size: r.fs16,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Footer CTA ────────────────────────────────
