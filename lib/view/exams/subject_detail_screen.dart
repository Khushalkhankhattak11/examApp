// lib/view/exams/subject_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/model.dart';
import '../../view_model/nav_view_model.dart';
import '../../view_model/providers.dart';
import '../lecture/topic_lesson_screen.dart';

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

// ─────────────────────────────────────────────
class ExamScreen extends ConsumerStatefulWidget {
  const ExamScreen({super.key});

  @override
  ConsumerState<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends ConsumerState<ExamScreen> {
  int _expandedIndex = 0;
  String? _appliedProgressKey;

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.valueOrNull;
    final subjectsAsync = ref.watch(activeSubjectsProvider);
    final subjects = subjectsAsync.valueOrNull ?? const <SubjectModel>[];
    final subject = subjects.matchEducationSubject(
      user?.educationSubject.trim() ?? '',
    );
    final chaptersAsync = subject == null
        ? null
        : ref.watch(subjectChaptersProvider(subject.id));
    final chapters =
        chaptersAsync?.valueOrNull ?? const <SubjectChapterModel>[];
    final progressSubjectId = subject?.progressSubjectId ?? '';
    final progress = user == null || progressSubjectId.isEmpty
        ? null
        : ref
              .watch(
                subjectProgressProvider(
                  SubjectProgressRequest(
                    uid: user.uid,
                    subjectId: progressSubjectId,
                  ),
                ),
              )
              .valueOrNull;
    final chapterItems = _chapterItems(chapters, progress);
    _applyResumeChapter(chapterItems, progress);

    final isLoading =
        userAsync.isLoading ||
        subjectsAsync.isLoading ||
        chaptersAsync?.isLoading == true;
    final error = subjectsAsync.error ?? chaptersAsync?.error;
    final completedChapters = chapterItems
        .where((item) => item.status == ChapterStatus.completed)
        .length;
    final progressValue = chapterItems.isEmpty
        ? 0.0
        : completedChapters / chapterItems.length;
    final totalMcqs = chapters.fold<int>(
      0,
      (total, chapter) => total + chapter.mcqCount,
    );
    final fullTestQuestions = chapters
        .expand((chapter) => chapter.chapterMcqs)
        .toList(growable: false);

    return Scaffold(
      backgroundColor: const Color(0xFF131409),
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),

          Column(
            children: [
              _AppBar(
                title: subject?.displayTitle ?? 'Exams',
                initials: user?.initials ?? '?',
                onBack: () => ref.read(navIndexProvider.notifier).setTab(0),
              ),

              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFD8EE36),
                        ),
                      )
                    : error != null
                    ? _ExamMessage(
                        message: 'Unable to load exams from Firebase.\n$error',
                      )
                    : subject == null
                    ? _ExamMessage(
                        message:
                            'No course matches ${user?.educationSubject.isNotEmpty == true ? user!.educationSubject : 'your education subject'}.',
                      )
                    : chapters.isEmpty
                    ? const _ExamMessage(
                        message: 'No chapters are available for this subject.',
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(2, 2, 0, 110),
                        child: Column(
                          children: [
                            _SubjectHeroCard(
                              subject: subject,
                              totalMcqs: totalMcqs,
                              bestScore: user?.bestScore ?? 0,
                              progress: progressValue,
                            ),
                            const SizedBox(height: 20),
                            ...List.generate(chapters.length, (i) {
                              final chapter = chapters[i];
                              final item = chapterItems[i];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _ChapterTile(
                                  chapter: item,
                                  isExpanded: _expandedIndex == i,
                                  onTap: () => setState(() {
                                    _expandedIndex = _expandedIndex == i
                                        ? -1
                                        : i;
                                  }),
                                  onOpen: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ChapterTopicsScreen(
                                        subjectDocumentId: subject.id,
                                        progressSubjectId: progressSubjectId,
                                        chapterId: chapter.id,
                                        chapterTitle: item.title,
                                        chapterMcqs: chapter.chapterMcqs,
                                      ),
                                    ),
                                  ),
                                  onQuiz: () => _takeChapterQuiz(
                                    user: user!,
                                    chapter: chapter,
                                    progressSubjectId: progressSubjectId,
                                    chapterTitle: item.title,
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 8),
                            _FullTestCTA(
                              totalMcqs: totalMcqs,
                              onTap: fullTestQuestions.isEmpty
                                  ? null
                                  : () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => TopicQuizScreen(
                                          title: '${subject.displayTitle} Test',
                                          questions: fullTestQuestions,
                                          tracking: QuizTrackingData(
                                            uid: user!.uid,
                                            title:
                                                '${subject.displayTitle} Test',
                                            type: 'subject',
                                            subjectId: progressSubjectId,
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
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

  List<ChapterItem> _chapterItems(
    List<SubjectChapterModel> chapters,
    SubjectProgressModel? progress,
  ) {
    final completedIds = progress?.completedChapterIds.toSet() ?? <String>{};
    var previousCompleted = true;

    return List.generate(chapters.length, (index) {
      final chapter = chapters[index];
      final completed =
          completedIds.contains(chapter.id) ||
          completedIds.contains(chapter.chapterId) ||
          completedIds.contains(chapter.progressChapterId);
      final unlocked = index == 0 || previousCompleted;
      final isCurrent =
          progress?.lastChapterId == chapter.id ||
          progress?.lastChapterId == chapter.chapterId;
      final status = completed
          ? ChapterStatus.completed
          : unlocked
          ? ChapterStatus.inProgress
          : ChapterStatus.locked;
      previousCompleted = completed;

      final number = chapter.order > 0 ? chapter.order : index + 1;
      final rawTitle = chapter.displayTitle;
      final title = rawTitle.toLowerCase().startsWith('chapter')
          ? rawTitle
          : 'Chapter $number: $rawTitle';
      return ChapterItem(
        title: title,
        mcqCount: chapter.mcqCount,
        status: status,
        statusLabel: completed
            ? 'Completed'
            : !unlocked
            ? 'Locked'
            : isCurrent
            ? 'In progress'
            : 'Ready to start',
      );
    });
  }

  void _applyResumeChapter(
    List<ChapterItem> chapters,
    SubjectProgressModel? progress,
  ) {
    if (chapters.isEmpty) return;
    final progressKey = [
      progress?.lastChapterId ?? '',
      ...?progress?.completedChapterIds,
    ].join('|');
    if (_appliedProgressKey == progressKey) return;
    _appliedProgressKey = progressKey;
    final firstIncomplete = chapters.indexWhere(
      (chapter) => chapter.status == ChapterStatus.inProgress,
    );
    _expandedIndex = firstIncomplete == -1
        ? chapters.length - 1
        : firstIncomplete;
  }

  Future<void> _takeChapterQuiz({
    required UserModel user,
    required SubjectChapterModel chapter,
    required String progressSubjectId,
    required String chapterTitle,
  }) async {
    if (chapter.chapterMcqs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No chapter MCQs are available in Firebase yet.'),
        ),
      );
      return;
    }

    final result = await Navigator.of(context).push<QuizAttemptResult>(
      MaterialPageRoute(
        builder: (_) => TopicQuizScreen(
          title: '$chapterTitle Quiz',
          questions: chapter.chapterMcqs,
          tracking: QuizTrackingData(
            uid: user.uid,
            title: '$chapterTitle Quiz',
            type: 'chapter',
            subjectId: progressSubjectId,
            chapterId: chapter.id,
          ),
        ),
      ),
    );
    if (result == null || !mounted) return;

    try {
      await ref
          .read(subjectProgressRepositoryProvider)
          .markChapterCompleted(
            uid: user.uid,
            subjectId: progressSubjectId,
            chapterId: chapter.id,
          );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save chapter completion: $error')),
      );
    }
  }
}

// ─────────────────────────────────────────────
//  APP BAR
// ─────────────────────────────────────────────
class _AppBar extends StatelessWidget {
  final String title;
  final String initials;
  final VoidCallback onBack;

  const _AppBar({
    required this.title,
    required this.initials,
    required this.onBack,
  });

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
            onTap: onBack,
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
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
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
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Color(0xFFD8EE36),
                  fontWeight: FontWeight.w700,
                ),
              ),
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
  final SubjectModel subject;
  final int totalMcqs;
  final int bestScore;
  final double progress;

  const _SubjectHeroCard({
    required this.subject,
    required this.totalMcqs,
    required this.bestScore,
    required this.progress,
  });

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
                    Text(
                      subject.level.isNotEmpty
                          ? subject.level.toUpperCase().replaceAll('_', ' ')
                          : 'COURSE',
                      style: const TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.5,
                        color: Color(0xFFC7C8AE),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subject.displayTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.dataset_rounded,
                              color: Color(0xFFD8EE36),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$totalMcqs Total MCQs',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFC7C8AE),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.workspace_premium_rounded,
                              color: Color(0xFFD8EE36),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Best: $bestScore%',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFD8EE36),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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
                      value: progress,
                      strokeWidth: 7,
                      backgroundColor: const Color(0xFF353629),
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xFFD8EE36),
                      ),
                      strokeCap: StrokeCap.round,
                    ),
                    Text(
                      '${(progress * 100).round()}%',
                      style: const TextStyle(
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
  final VoidCallback onOpen;
  final VoidCallback onQuiz;

  const _ChapterTile({
    required this.chapter,
    required this.isExpanded,
    required this.onTap,
    required this.onOpen,
    required this.onQuiz,
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
                            label: 'LEARN TOPICS',
                            icon: Icons.menu_book_outlined,
                            filled: false,
                            onTap: onOpen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionBtn(
                            label: 'TAKE QUIZ',
                            icon: Icons.quiz_rounded,
                            filled: true,
                            onTap: onQuiz,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Daily goal progress
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          chapter.status == ChapterStatus.completed
                              ? 'Chapter completed'
                              : 'Chapter progress',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFC7C8AE),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: LinearProgressIndicator(
                              value: isCompleted ? 1 : 0,
                              minHeight: 4,
                              backgroundColor: const Color(0xFF353629),
                              valueColor: const AlwaysStoppedAnimation(
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
  final int totalMcqs;
  final VoidCallback? onTap;

  const _FullTestCTA({required this.totalMcqs, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? .55 : 1,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Full Subject Test',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$totalMcqs MCQs • Subject Test',
                      style: const TextStyle(
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
      ),
    );
  }
}

class _ExamMessage extends StatelessWidget {
  final String message;

  const _ExamMessage({required this.message});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Color(0xFFC7C8AE), fontSize: 14),
      ),
    ),
  );
}

extension on SubjectModel {
  String get progressSubjectId => subjectId.isNotEmpty ? subjectId : id;
}

extension on List<SubjectModel> {
  SubjectModel? matchEducationSubject(String educationSubject) {
    final needle = educationSubject.normalizedSubjectKey;
    if (needle.isEmpty || needle == 'other') return null;

    for (final subject in this) {
      final exactKeys = [
        subject.id,
        subject.subjectId,
        subject.title,
        subject.name,
        subject.code,
      ].map((value) => value.normalizedSubjectKey);
      if (exactKeys.contains(needle)) return subject;
    }

    for (final subject in this) {
      final searchable = [
        subject.title,
        subject.name,
        subject.description,
        subject.category,
      ].map((value) => value.normalizedSubjectKey);
      if (searchable.any(
        (value) =>
            value.isNotEmpty &&
            (needle.contains(value) || value.contains(needle)),
      )) {
        return subject;
      }
    }
    return null;
  }
}

extension on String {
  String get normalizedSubjectKey =>
      toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
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
