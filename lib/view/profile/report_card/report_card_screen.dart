// lib/view/report_card/report_card_screen.dart

// ignore_for_file: deprecated_member_use

import 'package:examace/const/app_responsive.dart';
import 'package:examace/model/model.dart';
import 'package:examace/view_model/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────
//  DATA MODELS
// ─────────────────────────────────────────────
class _SubjectResult {
  final String subject;
  final int score;
  final String grade;
  final Color gradeColor;

  const _SubjectResult({
    required this.subject,
    required this.score,
    required this.grade,
    required this.gradeColor,
  });
}

// ─────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────
class ReportCardScreen extends ConsumerWidget {
  const ReportCardScreen({super.key});

  static const _subjects = [
    _SubjectResult(
      subject: 'English Grammar',
      score: 45,
      grade: 'D',
      gradeColor: Color(0xFFFFB4AB),
    ),
    _SubjectResult(
      subject: 'Urdu Literature',
      score: 78,
      grade: 'B',
      gradeColor: Color(0xFFD8EE36),
    ),
    _SubjectResult(
      subject: 'Islamic Studies',
      score: 82,
      grade: 'A-',
      gradeColor: Color(0xFFD8EE36),
    ),
    _SubjectResult(
      subject: 'Pak Studies',
      score: 51,
      grade: 'C',
      gradeColor: Color(0xFFC7C8AE),
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = AppResponsive(context);
    final user = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      backgroundColor: const Color(0xFF131409),
      body: Stack(
        children: [
          // Grid texture
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),

          Column(
            children: [
              _TopBar(r: r),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    r.sp20,
                    r.h20,
                    r.sp20,
                    r.h100 + r.h20,
                  ),
                  child: Column(
                    children: [
                      // ── Report Card ──────────────────────
                      _ReportCard(r: r, user: user, subjects: _subjects),
                      SizedBox(height: r.h20),

                      // ── Share Button ─────────────────────
                      _ShareButton(r: r),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TOP BAR
// ─────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final AppResponsive r;
  const _TopBar({required this.r});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(r.sp16, top + r.sp12, r.sp20, r.sp12),
      decoration: BoxDecoration(
        color: const Color(0xFF131409).withOpacity(0.85),
        border: const Border(bottom: BorderSide(color: Color(0x4D464834))),
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF1F2015),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF464834).withOpacity(0.4),
                ),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          SizedBox(width: r.w10 + 4),
          Text(
            'ExamAce',
            style: TextStyle(
              fontSize: r.fs22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFD8EE36),
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          const Icon(
            Icons.notifications_outlined,
            color: Colors.white,
            size: 22,
          ),
          SizedBox(width: r.w10),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF5822B8),
            ),
            child: const Center(
              child: Icon(
                Icons.person_rounded,
                color: Color(0xFFD1BCFF),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  REPORT CARD
// ─────────────────────────────────────────────
class _ReportCard extends StatelessWidget {
  final AppResponsive r;
  final UserModel? user;
  final List<_SubjectResult> subjects;

  const _ReportCard({
    required this.r,
    required this.user,
    required this.subjects,
  });

  int get _average => subjects.isEmpty
      ? 0
      : (subjects.fold(0, (sum, s) => sum + s.score) / subjects.length).round();

  String get _finalGrade {
    final avg = _average;
    if (avg >= 90) return 'A+';
    if (avg >= 85) return 'A';
    if (avg >= 80) return 'A-';
    if (avg >= 75) return 'B+';
    if (avg >= 70) return 'B';
    if (avg >= 65) return 'B-';
    if (avg >= 60) return 'C+';
    if (avg >= 55) return 'C';
    if (avg >= 50) return 'C-';
    if (avg >= 45) return 'D';
    return 'F';
  }

  @override
  Widget build(BuildContext context) {
    final displayName = (user?.fullName.isNotEmpty == true)
        ? user!.fullName
        : (user?.displayName ?? 'Student');
    final examLabel = (user?.selectedExam.isNotEmpty == true)
        ? user!.selectedExam
        : 'Competitive Exam';
    final initials = user?.initials ?? '?';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xCC13131A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E1E2E)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD8EE36).withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // ── Header ──────────────────────────
            _CardHeader(
              r: r,
              displayName: displayName,
              examLabel: examLabel,
              initials: initials,
            ),

            // ── Marks Table ─────────────────────
            Padding(
              padding: EdgeInsets.all(r.sp16),
              child: Column(
                children: [
                  _MarksTable(r: r, subjects: subjects),
                  SizedBox(height: r.h20),

                  // ── Average Row ─────────────────
                  _AverageRow(r: r, average: _average, grade: _finalGrade),
                  SizedBox(height: r.h20),

                  // ── AI Insight ──────────────────
                  _AiRemarksBox(r: r, subjects: subjects),
                ],
              ),
            ),

            // ── Footer ──────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: r.sp12,
                horizontal: r.sp16,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2015).withOpacity(0.5),
                border: const Border(top: BorderSide(color: Color(0x1A464834))),
              ),
              child: Text(
                'Verified by ExamAce Assessment Engine • Oct 2023',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: r.fs10,
                  letterSpacing: 0.8,
                  color: const Color(0xFFC7C8AE),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  CARD HEADER
// ─────────────────────────────────────────────
class _CardHeader extends StatelessWidget {
  final AppResponsive r;
  final String displayName;
  final String examLabel;
  final String initials;

  const _CardHeader({
    required this.r,
    required this.displayName,
    required this.examLabel,
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(r.sp20),
      decoration: const BoxDecoration(
        color: Color(0xFF1B1C11),
        border: Border(bottom: BorderSide(color: Color(0x4D464834))),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Watermark icon
          Positioned(
            top: -8,
            child: Icon(
              Icons.school_rounded,
              size: 100,
              color: Colors.white.withOpacity(0.04),
            ),
          ),

          Column(
            children: [
              // Brand
              Text(
                'ExamAce',
                style: TextStyle(
                  fontSize: r.fs28,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFD8EE36),
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: r.sp4),
              Text(
                'ACADEMIC ACHIEVEMENT RECORD',
                style: TextStyle(
                  fontSize: r.fs10,
                  letterSpacing: 1.5,
                  color: const Color(0xFFC7C8AE),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: r.h20),

              // Avatar
              Container(
                width: 80,
                height: 80,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFD8EE36), width: 2),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF2A2B1F),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontSize: r.fs28,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFD8EE36),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: r.sp12),

              // Name
              Text(
                displayName,
                style: TextStyle(
                  fontSize: r.fs22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: r.sp4),
              Text(
                '$examLabel — Competitive Civil Exam',
                style: TextStyle(
                  fontSize: r.fs13,
                  color: const Color(0xFFD1BCFF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  MARKS TABLE
// ─────────────────────────────────────────────
class _MarksTable extends StatelessWidget {
  final AppResponsive r;
  final List<_SubjectResult> subjects;
  const _MarksTable({required this.r, required this.subjects});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1F2015).withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF464834).withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // Header row
          Container(
            padding: EdgeInsets.symmetric(horizontal: r.sp16, vertical: r.sp12),
            decoration: const BoxDecoration(
              color: Color(0xFF353629),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'SUBJECT',
                    style: TextStyle(
                      fontSize: r.fs10,
                      letterSpacing: 1.2,
                      color: const Color(0xFFC7C8AE),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(
                  width: 70,
                  child: Text(
                    'SCORE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: r.fs10,
                      letterSpacing: 1.2,
                      color: const Color(0xFFC7C8AE),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Text(
                    'GRADE',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: r.fs10,
                      letterSpacing: 1.2,
                      color: const Color(0xFFC7C8AE),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Subject rows
          ...subjects.asMap().entries.map((entry) {
            final i = entry.key;
            final s = entry.value;
            final isLast = i == subjects.length - 1;

            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: r.sp16,
                vertical: r.sp12,
              ),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : const Border(
                        bottom: BorderSide(color: Color(0x1A464834)),
                      ),
              ),
              child: Row(
                children: [
                  // Subject name
                  Expanded(
                    child: Text(
                      s.subject,
                      style: TextStyle(fontSize: r.fs14, color: Colors.white),
                    ),
                  ),

                  // Score with mini progress bar
                  SizedBox(
                    width: 70,
                    child: Column(
                      children: [
                        Text(
                          '${s.score}%',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: r.fs16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: r.sp4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: s.score / 100,
                            minHeight: 3,
                            backgroundColor: const Color(0xFF353629),
                            valueColor: AlwaysStoppedAnimation(s.gradeColor),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Grade
                  SizedBox(
                    width: 50,
                    child: Text(
                      s.grade,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: r.fs16,
                        fontWeight: FontWeight.w700,
                        color: s.gradeColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  AVERAGE ROW
// ─────────────────────────────────────────────
class _AverageRow extends StatelessWidget {
  final AppResponsive r;
  final int average;
  final String grade;
  const _AverageRow({
    required this.r,
    required this.average,
    required this.grade,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.sp16, vertical: r.sp16),
      decoration: BoxDecoration(
        color: const Color(0xFFD8EE36).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD8EE36).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Overall average
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'OVERALL AVERAGE',
                style: TextStyle(
                  fontSize: r.fs10,
                  letterSpacing: 1.2,
                  color: const Color(0xFFD8EE36),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: r.sp4),
              Text(
                '$average%',
                style: TextStyle(
                  fontSize: r.fs36,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFD8EE36),
                  height: 1,
                ),
              ),
            ],
          ),
          const Spacer(),

          // Final grade
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'FINAL RATING',
                style: TextStyle(
                  fontSize: r.fs10,
                  letterSpacing: 1.2,
                  color: const Color(0xFFC7C8AE),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: r.sp4),
              Text(
                grade,
                style: TextStyle(
                  fontSize: r.fs36,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  AI REMARKS BOX
// ─────────────────────────────────────────────
class _AiRemarksBox extends StatelessWidget {
  final AppResponsive r;
  final List<_SubjectResult> subjects;
  const _AiRemarksBox({required this.r, required this.subjects});

  // Find weakest and strongest subjects
  String get _weakest => subjects.isEmpty
      ? '—'
      : subjects.reduce((a, b) => a.score < b.score ? a : b).subject;

  String get _strongest => subjects.isEmpty
      ? '—'
      : subjects.reduce((a, b) => a.score > b.score ? a : b).subject;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(r.sp16),
      decoration: BoxDecoration(
        color: const Color(0xFF5822B8).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF5822B8).withOpacity(0.25)),
      ),
      child: Stack(
        children: [
          // Watermark
          Positioned(
            right: -8,
            top: -8,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 60,
              color: const Color(0xFFD1BCFF).withOpacity(0.08),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label
              Row(
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    color: Color(0xFFD1BCFF),
                    size: 14,
                  ),
                  SizedBox(width: r.sp4),
                  Text(
                    'AI INSIGHTS',
                    style: TextStyle(
                      fontSize: r.fs10,
                      letterSpacing: 1.5,
                      color: const Color(0xFFD1BCFF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: r.sp8),

              // Remark text
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: r.fs14,
                    color: const Color(0xFFC7C8AE),
                    height: 1.6,
                  ),
                  children: [
                    const TextSpan(text: 'Needs improvement in '),
                    TextSpan(
                      text: _weakest,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD1BCFF),
                      ),
                    ),
                    const TextSpan(text: '. Strong performance in '),
                    TextSpan(
                      text: _strongest,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD1BCFF),
                      ),
                    ),
                    const TextSpan(
                      text:
                          '. Focus on weaker subjects to boost your competitive score.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SHARE BUTTON
// ─────────────────────────────────────────────
class _ShareButton extends StatelessWidget {
  final AppResponsive r;
  const _ShareButton({required this.r});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: r.sp16),
        decoration: BoxDecoration(
          color: const Color(0xFFD8EE36),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD8EE36).withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.ios_share_rounded,
              color: Color(0xFF191E00),
              size: 20,
            ),
            SizedBox(width: r.w10),
            Text(
              'Share Report',
              style: TextStyle(
                fontSize: r.fs16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF191E00),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  GRID PAINTER
// ─────────────────────────────────────────────
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.025)
      ..strokeWidth = 1;
    const step = 32.0;
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
