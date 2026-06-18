import 'dart:math';
import 'package:examace/const/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/model.dart';
import '../../view_model/providers.dart';

// ── Colors ──────────────────────────────────────────────────────────────────
const kBg = Color(0xFF0E0F0E);
const kCard = Color(0xFF1A1C1A);
const kLime = Color(0xFFC8F135);
const kLimeDark = Color(0xFF3A4A00);
const kIconBg = Color(0xFF2A2E2A);
const kBookBg = Color(0xFF1E201E);
const kBookStroke = Color(0xFF3A3E3A);
const kGoalBarBg = Color(0xFF2A2E2A);
const kMuted = Color(0xFF888888);
const kLocked = Color(0xFF2A2A2A);
const kActivePurple = Color(0xFF2A1A2A);

// ── Main Screen ──────────────────────────────────────────────────────────────
class EnglishProficiencyScreen extends ConsumerStatefulWidget {
  const EnglishProficiencyScreen({super.key});
  @override
  ConsumerState<EnglishProficiencyScreen> createState() =>
      _EnglishProficiencyScreenState();
}

class _EnglishProficiencyScreenState
    extends ConsumerState<EnglishProficiencyScreen> {
  int _expandedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final educationSubject = user?.educationSubject.trim() ?? '';
    final subjectsAsync = ref.watch(activeSubjectsProvider);
    final subjects = subjectsAsync.valueOrNull ?? const <SubjectModel>[];
    final subject = subjects.matchEducationSubject(educationSubject);
    final progressSubjectId = subject?.progressSubjectId ?? '';
    final chaptersSubjectId = subject?.id ?? '';
    final chaptersAsync = chaptersSubjectId.isEmpty
        ? null
        : ref.watch(subjectChaptersProvider(chaptersSubjectId));
    final progressAsync = user == null || progressSubjectId.isEmpty
        ? null
        : ref.watch(
            subjectProgressProvider(
              SubjectProgressRequest(
                uid: user.uid,
                subjectId: progressSubjectId,
              ),
            ),
          );
    final chapters =
        chaptersAsync?.valueOrNull ?? const <SubjectChapterModel>[];
    final progress = progressAsync?.valueOrNull;
    final totalTopics = chapters.fold<int>(
      0,
      (sum, chapter) => sum + chapter.completionUnits,
    );
    final totalChapters = chapters.isEmpty
        ? subject?.totalChapters ?? 0
        : chapters.length;
    final totalUnits = _totalCompletionUnits(chapters, subject);
    final completedUnits = _completedCompletionUnits(
      chapters: chapters,
      progress: progress,
      totalUnits: totalUnits,
    );
    final progressValue = totalUnits == 0 ? 0.0 : completedUnits / totalUnits;

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 4),
              _buildHeroCard(
                subject: subject,
                progressValue: progressValue,
                totalChapters: totalChapters,
                totalTopics: totalTopics,
              ),
              const SizedBox(height: 16),
              _buildChapters(
                chaptersAsync: chaptersAsync,
                chapters: chapters,
                progress: progress,
              ),
              const SizedBox(height: 10),
              _buildFullTestCard(totalTopics: totalTopics),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: const Icon(Icons.arrow_back, color: kLime, size: 22),
          ),
          const Text(
            'English Proficiency',
            style: TextStyle(
              color: kLime,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF444444),
            child: ClipOval(
              child: CustomPaint(
                size: const Size(36, 36),
                painter: _AvatarPainter(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero Card ─────────────────────────────────────────────────────────────
  Widget _buildHeroCard({
    required SubjectModel? subject,
    required int totalChapters,
    required int totalTopics,
    required double progressValue,
  }) {
    final progressPercent = (progressValue * 100).round();
    final totalTopicLabel = totalTopics == 0
        ? 'Topics'
        : 'Total Topics $totalTopics';
    final totalChapterLabel = totalChapters == 0
        ? 'Chapters'
        : 'Total Chapters $totalChapters';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          // Icons row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _iconBox(kIconBg, child: const _TranslationIcon()),
              const SizedBox(width: 12),
              _iconBox(kBookBg, child: const _BookIcon()),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            subject?.level.isNotEmpty == true
                ? subject!.level.toUpperCase()
                : 'ADVANCED LEVEL',
            style: TextStyle(color: kMuted, fontSize: 11, letterSpacing: 1.2),
          ),
          const SizedBox(height: 4),
          Text(
            subject?.displayTitle.isNotEmpty == true
                ? subject!.displayTitle
                : 'Subject Mastery',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.layers_outlined, color: kMuted, size: 14),
              const SizedBox(width: 4),
              Text(
                totalChapterLabel,
                style: const TextStyle(color: kMuted, fontSize: 12),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.emoji_events_outlined, color: kMuted, size: 14),
              const SizedBox(width: 4),
              Text(
                totalTopicLabel,
                style: const TextStyle(color: kMuted, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Progress ring
          SizedBox(
            width: 90,
            height: 90,
            child: CustomPaint(
              painter: _RingPainter(progress: progressValue),
              child: Center(
                child: Text(
                  '$progressPercent%',
                  style: const TextStyle(
                    color: kLime,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBox(Color bg, {required Widget child}) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(child: child),
    );
  }

  // ── Chapters ──────────────────────────────────────────────────────────────
  Widget _buildChapters({
    required AsyncValue<List<SubjectChapterModel>>? chaptersAsync,
    required List<SubjectChapterModel> chapters,
    required SubjectProgressModel? progress,
  }) {
    if (chaptersAsync?.isLoading == true && chapters.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(color: kLime),
      );
    }

    if (chaptersAsync?.hasError == true) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Text(
          'Unable to load chapters from Firebase.',
          style: TextStyle(color: kMuted, fontSize: 13),
        ),
      );
    }

    if (chapters.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Text(
          'No chapters available yet.',
          style: TextStyle(color: kMuted, fontSize: 13),
        ),
      );
    }

    final states = _chapterStates(chapters, progress);
    final firstOpenIndex = states.indexWhere((state) => state.unlocked);
    if (_expandedIndex < 0 ||
        _expandedIndex >= chapters.length ||
        !states[_expandedIndex].unlocked) {
      _expandedIndex = firstOpenIndex == -1 ? 0 : firstOpenIndex;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(chapters.length, (index) {
          final chapter = chapters[index];
          final state = states[index];
          final title = _chapterTitle(chapter, index);
          final child = _expandedIndex == index && state.unlocked
              ? _ChapterExpanded(
                  title: title,
                  subtitle: _chapterSubtitle(chapter, state),
                  dailyGoalText: _dailyGoalText(chapter, state),
                  goalProgress: state.progress,
                  onCollapse: () => setState(() => _expandedIndex = -1),
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, AppRoutes.quizz),
                )
              : _ChapterCollapsed(
                  icon: _chapterIcon(state),
                  title: title,
                  subtitle: _chapterSubtitle(chapter, state),
                  subtitleColor: state.completed || state.inProgress
                      ? kLime
                      : kMuted,
                  locked: !state.unlocked,
                  onTap: state.unlocked
                      ? () => setState(() => _expandedIndex = index)
                      : null,
                );

          return Padding(
            padding: EdgeInsets.only(
              bottom: index == chapters.length - 1 ? 0 : 10,
            ),
            child: child,
          );
        }),
      ),
    );
  }

  Widget _circleIcon(Color bg, IconData icon, Color iconColor) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, color: iconColor, size: 18),
    );
  }

  // ── Full Test Card ────────────────────────────────────────────────────────
  Widget _buildFullTestCard({required int totalTopics}) {
    final testTopics = totalTopics == 0 ? 1 : totalTopics;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: kLime,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(color: kBg, shape: BoxShape.circle),
            child: const Center(
              child: Text('🎯', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Full Subject\nTest',
                  style: TextStyle(
                    color: kBg,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  '$testTopics Topics • 120 Minutes',
                  style: const TextStyle(color: kLimeDark, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward, color: kBg, size: 24),
        ],
      ),
    );
  }

  int _totalCompletionUnits(
    List<SubjectChapterModel> chapters,
    SubjectModel? subject,
  ) {
    final chapterUnits = chapters.fold<int>(
      0,
      (sum, chapter) => sum + chapter.completionUnits,
    );
    if (chapterUnits > 0) return chapterUnits;
    return subject?.totalTopics ?? 0;
  }

  int _completedCompletionUnits({
    required List<SubjectChapterModel> chapters,
    required SubjectProgressModel? progress,
    required int totalUnits,
  }) {
    if (progress == null) return 0;
    final safeTotal = totalUnits == 0 ? 1 : totalUnits;
    final completedFromTopics = progress.completedTopics
        .clamp(0, safeTotal)
        .toInt();
    final completedChapterIds = progress.completedChapterIds.toSet();
    final completedFromChapters = chapters.fold<int>(0, (sum, chapter) {
      if (!_containsChapterId(completedChapterIds, chapter)) return sum;
      return sum + chapter.completionUnits;
    });

    return max(
      completedFromTopics,
      completedFromChapters,
    ).clamp(0, safeTotal).toInt();
  }

  List<_ChapterUiState> _chapterStates(
    List<SubjectChapterModel> chapters,
    SubjectProgressModel? progress,
  ) {
    final completedTopics = progress?.completedTopics ?? 0;
    final completedChapterIds =
        progress?.completedChapterIds.toSet() ?? const <String>{};
    var cumulativeBefore = 0;
    var previousCompleted = true;

    return List.generate(chapters.length, (index) {
      final chapter = chapters[index];
      final units = chapter.completionUnits;
      final completedInChapter = (completedTopics - cumulativeBefore)
          .clamp(0, units)
          .toInt();
      final completed =
          _containsChapterId(completedChapterIds, chapter) ||
          completedInChapter >= units;
      final unlocked = index == 0 || previousCompleted;
      final state = _ChapterUiState(
        unlocked: unlocked,
        completed: completed,
        inProgress: unlocked && completedInChapter > 0 && !completed,
        completedUnits: completed ? units : completedInChapter,
        totalUnits: units,
      );

      cumulativeBefore += units;
      previousCompleted = completed;
      return state;
    });
  }

  bool _containsChapterId(
    Set<String> completedChapterIds,
    SubjectChapterModel chapter,
  ) {
    return completedChapterIds.contains(chapter.progressChapterId) ||
        completedChapterIds.contains(chapter.id) ||
        completedChapterIds.contains(chapter.chapterId);
  }

  Widget _chapterIcon(_ChapterUiState state) {
    if (!state.unlocked) {
      return _circleIcon(kLocked, Icons.lock_outline, const Color(0xFF666666));
    }
    if (state.completed) {
      return _circleIcon(const Color(0xFF1E3A1E), Icons.check, kLime);
    }
    return _circleIcon(kActivePurple, Icons.radio_button_checked, kLime);
  }

  String _chapterTitle(SubjectChapterModel chapter, int index) {
    final title = chapter.displayTitle;
    if (title.toLowerCase().startsWith('chapter')) return title;
    final number = chapter.order > 0 ? chapter.order : index + 1;
    return 'Chapter $number: $title';
  }

  String _chapterSubtitle(SubjectChapterModel chapter, _ChapterUiState state) {
    if (!state.unlocked || (!state.completed && !state.inProgress)) return '';

    final count = chapter.mcqCount == 0 ? 'MCQs' : '${chapter.mcqCount} MCQs';
    final status = state.completed
        ? 'Completed'
        : '${(state.progress * 100).round()}% Completed';
    return '$count • $status';
  }

  String _dailyGoalText(SubjectChapterModel chapter, _ChapterUiState state) {
    final total = chapter.mcqCount > 0 ? chapter.mcqCount : state.totalUnits;
    final done = (total * state.progress).round().clamp(0, total);
    return 'Daily Goal: $done/$total MCQs';
  }
}

class _ChapterUiState {
  final bool unlocked;
  final bool completed;
  final bool inProgress;
  final int completedUnits;
  final int totalUnits;

  const _ChapterUiState({
    required this.unlocked,
    required this.completed,
    required this.inProgress,
    required this.completedUnits,
    required this.totalUnits,
  });

  double get progress => totalUnits == 0 ? 0 : completedUnits / totalUnits;
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
        subject.definition,
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

    final subjectWords = educationSubject.trim().split(RegExp(r'\s+'));
    final firstWordKey = subjectWords.isEmpty
        ? ''
        : subjectWords.first.normalizedSubjectKey;
    if (firstWordKey.isEmpty) return null;

    for (final subject in this) {
      if (subject.title.normalizedSubjectKey == firstWordKey ||
          subject.name.normalizedSubjectKey.contains(firstWordKey)) {
        return subject;
      }
    }

    return null;
  }
}

extension on SubjectModel {
  String get progressSubjectId => subjectId.isNotEmpty ? subjectId : id;
}

extension on String {
  String get normalizedSubjectKey =>
      toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
}

// ── Collapsed Chapter Row ─────────────────────────────────────────────────
class _ChapterCollapsed extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subtitle;
  final Color subtitleColor;
  final bool locked;
  final VoidCallback? onTap;

  const _ChapterCollapsed({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.subtitleColor,
    this.locked = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: locked ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: kCard,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              icon,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(color: subtitleColor, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF888888),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Expanded Active Chapter ───────────────────────────────────────────────
class _ChapterExpanded extends StatelessWidget {
  final String title;
  final String subtitle;
  final String dailyGoalText;
  final double goalProgress;
  final VoidCallback onCollapse;
  final VoidCallback onPressed;

  const _ChapterExpanded({
    required this.title,
    required this.subtitle,
    required this.dailyGoalText,
    required this.goalProgress,
    required this.onCollapse,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kLime, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: kActivePurple,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.radio_button_checked,
                    color: kLime,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(color: kLime, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              GestureDetector(
                onTap: onCollapse,
                child: const Icon(
                  Icons.keyboard_arrow_up,
                  color: kLime,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Buttons
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: kIconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.grid_view_rounded,
                        color: Colors.white70,
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'PRACTICE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: onPressed,
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: kLime,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.timer_outlined, color: kBg, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'TAKE QUIZ',
                          style: TextStyle(
                            color: kBg,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            dailyGoalText,
            style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 12),
          ),
          const SizedBox(height: 8),
          // Goal bar
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: goalProgress,
              minHeight: 4,
              backgroundColor: kGoalBarBg,
              valueColor: const AlwaysStoppedAnimation<Color>(kLime),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Custom Painters ───────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  final double progress;
  const _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = (size.width - 14) / 2;

    final trackPaint = Paint()
      ..color = kGoalBarBg
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7;
    canvas.drawCircle(Offset(cx, cy), radius, trackPaint);

    final arcPaint = Paint()
      ..color = kLime
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _AvatarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF999999);
    // head
    canvas.drawCircle(Offset(size.width / 2, size.height * 0.39), 7, paint);
    // body
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.83),
        width: 24,
        height: 16,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Translation Icon (文A) ────────────────────────────────────────────────
class _TranslationIcon extends StatelessWidget {
  const _TranslationIcon();
  @override
  Widget build(BuildContext context) {
    return const Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          left: 4,
          top: 4,
          child: Text(
            '文',
            style: TextStyle(
              color: kLime,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Positioned(
          right: 4,
          bottom: 4,
          child: Text(
            'A',
            style: TextStyle(
              color: kLime,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Book Icon ─────────────────────────────────────────────────────────────
class _BookIcon extends StatelessWidget {
  const _BookIcon();
  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(30, 28), painter: _BookPainter());
  }
}

class _BookPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = kBookStroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, 2, size.width - 2, size.height - 4),
      const Radius.circular(2),
    );
    canvas.drawRRect(rrect, p);
    canvas.drawLine(
      Offset(size.width / 2, 2),
      Offset(size.width / 2, size.height - 4),
      p,
    );

    for (final y in [8.0, 12.0, 16.0]) {
      canvas.drawLine(Offset(3, y), Offset(size.width / 2 - 2, y), p);
      canvas.drawLine(
        Offset(size.width / 2 + 2, y),
        Offset(size.width - 3, y),
        p,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
