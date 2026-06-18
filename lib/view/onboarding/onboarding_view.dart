// lib/view/onboarding/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../view_model/onboarding_view_model.dart';
import 'steps/exam_selection_step.dart';
import 'steps/profile_setup_step.dart';
import 'steps/education_background_step.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  Widget _buildStep(int step) {
    return switch (step) {
      0 => const ExamSelectionStep(),
      1 => const ProfileSetupStep(),
      2 => const EducationBackgroundStep(),
      _ => const ExamSelectionStep(),
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          SizedBox(height: 10),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.05, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: KeyedSubtree(
                key: ValueKey(state.currentStep),
                child: _buildStep(state.currentStep),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
