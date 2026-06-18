// lib/view/exams/subject_detail_screen.dart

import 'package:flutter/material.dart';

// ── Chapter model ─────────────────────────────
enum ChapterStatus { completed, inProgress, locked }

class ChapterItem {
  final String title;
  final int mcqCount;
  final ChapterStatus status;
  final String statusLabel;

  const ChapterItem({
    required this.title,
    required this.mcqCount,
    required this.status,
    required this.statusLabel,
  });
}

const _chapters = [
  ChapterItem(
    title: 'Chapter 1: Parts of Speech',
    mcqCount: 24,
    status: ChapterStatus.completed,
    statusLabel: 'Completed',
  ),
  ChapterItem(
    title: 'Chapter 2: Tenses',
    mcqCount: 30,
    status: ChapterStatus.inProgress,
    statusLabel: '60% Accuracy',
  ),
  ChapterItem(
    title: 'Chapter 3: Comprehension',
    mcqCount: 20,
    status: ChapterStatus.locked,
    statusLabel: 'Not started',
  ),
  ChapterItem(
    title: 'Chapter 4: Vocabulary',
    mcqCount: 26,
    status: ChapterStatus.locked,
    statusLabel: 'Not started',
  ),
];

// ─────────────────────────────────────────────
class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  int _expandedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131409),
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),

          Column(
            children: [
              _AppBar(),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(2, 2, 0, 110),
                  child: Column(
                    children: [
                      _SubjectHeroCard(),
                      const SizedBox(height: 20),

                      ...List.generate(_chapters.length, (i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ChapterTile(
                            chapter: _chapters[i],
                            isExpanded: _expandedIndex == i,
                            onTap: () => setState(() {
                              _expandedIndex = _expandedIndex == i ? -1 : i;
                            }),
                          ),
                        );
                      }),

                      const SizedBox(height: 8),
                      _FullTestCTA(),
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
//  APP BAR
// ─────────────────────────────────────────────
class _AppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(20, top + 12, 20, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF131409).withValues(alpha: 0.85),
        border: const Border(bottom: BorderSide(color: Color(0x4D464834))),
      ),
      child: Row(
        children: [
          // Back
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                color: Colors.transparent,
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFFD8EE36),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'English Proficiency',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFFD8EE36),
                letterSpacing: -0.3,
              ),
            ),
          ),

          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF5822B8).withValues(alpha: 0.3),
              border: Border.all(color: const Color(0xFF464834)),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Color(0xFFC7C8AE),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SUBJECT HERO CARD
// ─────────────────────────────────────────────
class _SubjectHeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xCC131309),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF353629)),
      ),
      child: Stack(
        children: [
          // Watermark icon
          Positioned(
            top: -8,
            right: -8,
            child: Icon(
              Icons.menu_book_rounded,
              size: 100,
              color: Colors.white.withValues(alpha: 0.04),
            ),
          ),

          Row(
            children: [
              // Icon box
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFD8EE36).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFD8EE36).withValues(alpha: 0.2),
                  ),
                ),
                child: const Icon(
                  Icons.translate_rounded,
                  color: Color(0xFFD8EE36),
                  size: 34,
                ),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ADVANCED LEVEL',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.5,
                        color: Color(0xFFC7C8AE),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Subject Mastery',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.dataset_rounded,
                          color: Color(0xFFD8EE36),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '2,450 Total MCQs',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFC7C8AE),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.workspace_premium_rounded,
                          color: Color(0xFFD8EE36),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Best: 92%',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFD8EE36),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Circular progress
              SizedBox(
                width: 68,
                height: 68,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: 0.75,
                      strokeWidth: 7,
                      backgroundColor: const Color(0xFF353629),
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xFFD8EE36),
                      ),
                      strokeCap: StrokeCap.round,
                    ),
                    const Text(
                      '75%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD8EE36),
                      ),
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
//  CHAPTER TILE
// ─────────────────────────────────────────────
class _ChapterTile extends StatelessWidget {
  final ChapterItem chapter;
  final bool isExpanded;
  final VoidCallback onTap;

  const _ChapterTile({
    required this.chapter,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = chapter.status == ChapterStatus.completed;
    final isInProgress = chapter.status == ChapterStatus.inProgress;
    final isLocked = chapter.status == ChapterStatus.locked;

    return AnimatedOpacity(
      opacity: isLocked ? 0.55 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xCC131309),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isCompleted || isInProgress
                ? const Color(0xFFD8EE36).withValues(alpha: 0.4)
                : const Color(0xFF353629),
          ),
          boxShadow: isInProgress
              ? [
                  BoxShadow(
                    color: const Color(0xFFD8EE36).withValues(alpha: 0.08),
                    blurRadius: 15,
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            // ── Header row ──────────────────────
            GestureDetector(
              onTap: isLocked ? null : onTap,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isExpanded
                      ? const Color(0xFF353629).withValues(alpha: 0.3)
                      : Colors.transparent,
                  borderRadius: isExpanded
                      ? const BorderRadius.vertical(top: Radius.circular(14))
                      : BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    // Status icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? const Color(0xFFD8EE36).withValues(alpha: 0.15)
                            : isInProgress
                            ? const Color(0xFF5822B8).withValues(alpha: 0.3)
                            : const Color(0xFF353629),
                      ),
                      child: Icon(
                        isCompleted
                            ? Icons.check_circle_rounded
                            : isInProgress
                            ? Icons.pending_rounded
                            : Icons.lock_rounded,
                        color: isCompleted || isInProgress
                            ? const Color(0xFFD8EE36)
                            : const Color(0xFFC7C8AE),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Title + subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chapter.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isLocked
                                  ? const Color(0xFFC7C8AE)
                                  : Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${chapter.mcqCount} MCQs • ${chapter.statusLabel}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isInProgress
                                  ? const Color(0xFFD8EE36)
                                  : const Color(0xFFC7C8AE),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Icon(
                      isExpanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      color: isInProgress
                          ? const Color(0xFFD8EE36)
                          : const Color(0xFFC7C8AE).withValues(alpha: 0.4),
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),

            // ── Expanded panel ──────────────────
            if (isExpanded && !isLocked)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF1B1C11),
                  border: Border(top: BorderSide(color: Color(0x4D464834))),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(14),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: _ActionBtn(
                            label: 'PRACTICE',
                            icon: Icons.history_edu_rounded,
                            filled: false,
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionBtn(
                            label: 'TAKE QUIZ',
                            icon: Icons.timer_rounded,
                            filled: true,
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Daily goal progress
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Daily Goal: 18/30 MCQs',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFC7C8AE),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: const LinearProgressIndicator(
                              value: 0.6,
                              minHeight: 4,
                              backgroundColor: Color(0xFF353629),
                              valueColor: AlwaysStoppedAnimation(
                                Color(0xFFD8EE36),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ACTION BUTTON
// ─────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: filled ? const Color(0xFFD8EE36) : const Color(0xFF353629),
          borderRadius: BorderRadius.circular(12),
          border: filled ? null : Border.all(color: const Color(0xFF464834)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: filled ? const Color(0xFF191E00) : const Color(0xFFD8EE36),
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
                color: filled ? const Color(0xFF191E00) : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  FULL SUBJECT TEST CTA
// ─────────────────────────────────────────────
class _FullTestCTA extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xCC131309),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFD8EE36).withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            // Medal icon
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFD8EE36),
              ),
              child: const Icon(
                Icons.military_tech_rounded,
                color: Color(0xFF191E00),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Text
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Full Subject Test',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '100 MCQs • 120 Minutes',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.2,
                      color: Color(0xFFD8EE36),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_rounded,
              color: Color(0xFFD8EE36),
              size: 22,
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
      ..color = Colors.white.withValues(alpha: 0.02)
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
