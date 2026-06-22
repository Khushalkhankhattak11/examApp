// lib/view/onboarding/steps/education_background_step.dart

// ignore_for_file: deprecated_member_use

import 'package:examace/const/app_responsive.dart';
import 'package:examace/view/onboarding/widget/step_line_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../view_model/onboarding_view_model.dart';
import '../../../const/const.dart';

const _degrees = [
  'Matric',
  'Intermediate',
  'BA/BSc',
  'MA/MSc',
  'B.Ed',
  'M.Ed',
  'Other',
];

const _subjects = [
  'Accounting',
  'Agriculture',
  'Anthropology',
  'Applied Mathematics',
  'Artificial Intelligence',
  'Banking and Finance',
  'Biochemistry',
  'Biology',
  'Biotechnology',
  'Botany',
  'Business Administration',
  'Chemistry',
  'Civics',
  'Civil Engineering',
  'Commerce',
  'Computer Science',
  'Criminology',
  'Cyber Security',
  'Data Science',
  'Economics',
  'Electrical Engineering',
  'English Grammar Basics',
  'Environmental Science',
  'Geography',
  'General Science',
  'Health and Physical Education',
  'History',
  'Information Technology',
  'International Relations',
  'Islamic Studies',
  'Journalism',
  'Law',
  'Library Science',
  'Mass Communication',
  'Mathematics',
  'Mechanical Engineering',
  'Microbiology',
  'Pakistan Studies',
  'Pharmacy',
  'Philosophy',
  'Physics',
  'Physiology',
  'Political Science',
  'Psychology',
  'Software Engineering',
  'Sociology',
  'Statistics',
  'Urdu',
  'Zoology',
  'Other',
];

enum _AcademicStatus { studying, graduated }

class EducationBackgroundStep extends ConsumerStatefulWidget {
  const EducationBackgroundStep({super.key});

  @override
  ConsumerState<EducationBackgroundStep> createState() =>
      _EducationBackgroundStepState();
}

class _EducationBackgroundStepState
    extends ConsumerState<EducationBackgroundStep> {
  String? _selectedDegree;
  String? _selectedSubject;
  late final TextEditingController _otherSubjectController;
  _AcademicStatus _status = _AcademicStatus.graduated;

  bool get _isOtherSubject => _selectedSubject == 'Other';
  String get _educationSubject => _isOtherSubject
      ? _otherSubjectController.text.trim()
      : (_selectedSubject ?? '');
  bool get _canContinue =>
      _selectedDegree != null &&
      (_selectedSubject != null &&
          (!_isOtherSubject || _educationSubject.isNotEmpty));

  @override
  void initState() {
    super.initState();
    _otherSubjectController = TextEditingController();

    final state = ref.read(onboardingProvider);
    _selectedDegree = state.educationLevel.isEmpty
        ? null
        : state.educationLevel;
    if (state.educationSubject.isEmpty) {
      _selectedSubject = null;
    } else if (_subjects.contains(state.educationSubject)) {
      _selectedSubject = state.educationSubject;
    } else {
      _selectedSubject = 'Other';
      _otherSubjectController.text = state.educationSubject;
    }
    _status = state.academicStatus == 'studying'
        ? _AcademicStatus.studying
        : _AcademicStatus.graduated;
  }

  @override
  void dispose() {
    _otherSubjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive(context);
    final notifier = ref.read(onboardingProvider.notifier);
    final state = ref.watch(onboardingProvider);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(r.sp20, r.h40, r.sp20, r.h20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StepIndicator(currentStep: state.currentStep),
                SizedBox(height: r.h30),

                // Title
                Text(
                  'Your education\nbackground',
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
                  'We tailor your exam preparation based on your\nacademic history and eligibility.',
                  style: TextStyle(
                    fontSize: r.fs13,
                    color: const Color(0xFFC7C8AE),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: r.h30),

                // Degree chips
                _SectionLabel(r: r, text: 'HIGHEST DEGREE ATTAINED'),
                SizedBox(height: r.h10),
                Wrap(
                  spacing: r.w10 * 0.8,
                  runSpacing: r.w10 * 0.8,
                  children: _degrees.map((d) {
                    final selected = _selectedDegree == d;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDegree = d),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: EdgeInsets.symmetric(
                          horizontal: r.sp20,
                          vertical: r.sp8 + 2,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(99),
                          color: selected
                              ? const Color(0xFFD8EE36).withValues(alpha: 0.08)
                              : Colors.transparent,
                          border: Border.all(
                            color: selected
                                ? const Color(0xFFD8EE36)
                                : const Color(
                                    0xFF464834,
                                  ).withValues(alpha: 0.5),
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          d,
                          style: TextStyle(
                            fontSize: r.fs13,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: selected
                                ? const Color(0xFFD8EE36)
                                : const Color(0xFFC7C8AE),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: r.h30),

                // Subject dropdown
                _SectionLabel(r: r, text: 'GRADUATION SUBJECT / MAJOR'),
                SizedBox(height: r.h10),
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFF464834)),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedSubject,
                      dropdownColor: const Color(0xFF1F2015),
                      icon: Icon(
                        Icons.expand_more_rounded,
                        color: const Color(0xFFC7C8AE),
                        size: r.fs20,
                      ),
                      hint: Text(
                        'Select your specialization',
                        style: TextStyle(
                          color: const Color(0x4DC7C8AE),
                          fontSize: r.fs15,
                        ),
                      ),
                      style: TextStyle(color: Colors.white, fontSize: r.fs15),
                      items: _subjects
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedSubject = v),
                    ),
                  ),
                ),
                if (_isOtherSubject) ...[
                  SizedBox(height: r.h20),
                  TextField(
                    controller: _otherSubjectController,
                    onChanged: (_) => setState(() {}),
                    textCapitalization: TextCapitalization.words,
                    cursorColor: const Color(0xFFD8EE36),
                    style: TextStyle(color: Colors.white, fontSize: r.fs15),
                    decoration: InputDecoration(
                      hintText: 'Enter your subject',
                      hintStyle: TextStyle(
                        color: const Color(0x4DC7C8AE),
                        fontSize: r.fs15,
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF464834)),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFD8EE36)),
                      ),
                    ),
                  ),
                ],
                SizedBox(height: r.h30),

                // Academic status
                _SectionLabel(r: r, text: 'ACADEMIC STATUS'),
                SizedBox(height: r.h10),
                _RadioTile(
                  r: r,
                  label: 'Currently studying',
                  selected: _status == _AcademicStatus.studying,
                  onTap: () =>
                      setState(() => _status = _AcademicStatus.studying),
                ),
                SizedBox(height: r.h10 * 0.8),
                _RadioTile(
                  r: r,
                  label: 'Already graduated',
                  selected: _status == _AcademicStatus.graduated,
                  onTap: () =>
                      setState(() => _status = _AcademicStatus.graduated),
                ),
                SizedBox(height: r.h20),

                // AI insight card
                if (_selectedDegree != null)
                  Container(
                    padding: EdgeInsets.all(r.sp16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD8EE36).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(r.sp12 + 2),
                      border: Border.all(
                        color: const Color(0xFFD8EE36).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          color: const Color(0xFFD8EE36),
                          size: r.fs20,
                        ),
                        SizedBox(width: r.w10),
                        Expanded(
                          child: Text(
                            'Based on your $_selectedDegree degree, you are eligible for upcoming FPSC and PPSC general recruitment tests.',
                            style: TextStyle(
                              fontSize: r.fs13,
                              color: const Color(0xFFE4E3D1),
                              height: 1.5,
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

        // ── Footer ────────────────────────────────────────────────────────────
        // FIX: save locally then navigate to Register.
        //      pushToFirebase() is called inside AuthViewModel.register()
        //      after the user actually creates an account.
        _Footer(
          r: r,
          isLoading: state.isLoading,
          onTap: (_canContinue && !state.isLoading)
              ? () async {
                  // 1. Sync local widget state → notifier
                  notifier.updateEducation(
                    educationLevel: _selectedDegree ?? '',
                    educationSubject: _educationSubject,
                    academicStatus: _status == _AcademicStatus.studying
                        ? 'studying'
                        : 'graduated',
                  );

                  // 2. Persist the complete model locally (no Firebase yet)
                  await notifier.saveLocally();

                  if (!context.mounted) return;

                  // 3. Go to Register — the user hasn't created an account yet
                  Navigator.pushReplacementNamed(context, AppRoutes.register);
                }
              : null,
        ),
      ],
    );
  }
}

// ── Radio tile ────────────────────────────────
class _RadioTile extends StatelessWidget {
  final AppResponsive r;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RadioTile({
    required this.r,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: r.sp16, vertical: r.sp16),
        decoration: BoxDecoration(
          color: const Color(0xCC131309),
          borderRadius: BorderRadius.circular(r.sp12 + 2),
          border: Border.all(
            color: selected
                ? const Color(0xFFD8EE36).withValues(alpha: 0.4)
                : const Color(0xFF1E1E2E),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.white, fontSize: r.fs15),
            ),
            Container(
              width: r.w10 * 2,
              height: r.w10 * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? const Color(0xFFD8EE36) : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? const Color(0xFFD8EE36)
                      : const Color(0xFF464834),
                  width: 2,
                ),
              ),
              child: selected
                  ? Icon(
                      Icons.check_rounded,
                      color: const Color(0xFF191E00),
                      size: r.fs12,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section label ─────────────────────────────
class _SectionLabel extends StatelessWidget {
  final AppResponsive r;
  final String text;
  const _SectionLabel({required this.r, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: r.fs11,
        letterSpacing: 1.5,
        color: const Color(0xFFC7C8AE),
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

// ── Footer ────────────────────────────────────
class _Footer extends StatelessWidget {
  final AppResponsive r;
  final VoidCallback? onTap;
  final bool isLoading;
  const _Footer({required this.r, required this.onTap, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(r.sp20, r.sp12, r.sp20, r.h30),
      decoration: BoxDecoration(
        color: const Color(0xFF131409).withValues(alpha: 0.9),
        border: const Border(top: BorderSide(color: Color(0xFF1E1E2E))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: r.h50 * 1.1,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: onTap != null
                ? const Color(0xFFD8EE36)
                : const Color(0xFF353629),
            foregroundColor: onTap != null
                ? const Color(0xFF191E00)
                : const Color(0xFF91937A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(r.sp12 + 2),
            ),
            elevation: 0,
            textStyle: TextStyle(fontSize: r.fs16, fontWeight: FontWeight.w700),
          ),
          onPressed: onTap,
          child: isLoading
              ? SizedBox(
                  width: r.fs22,
                  height: r.fs22,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF191E00),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Continue', style: TextStyle(fontSize: r.fs16)),
                    SizedBox(width: r.w10 * 0.8),
                    Icon(Icons.arrow_forward_rounded, size: r.fs20),
                  ],
                ),
        ),
      ),
    );
  }
}
