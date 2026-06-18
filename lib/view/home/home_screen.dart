// lib/view/home/home_screen.dart

// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/model.dart';
import '../lecture/noun_lecture_screen.dart';
import '../../view_model/providers.dart';
import '../../view_model/theme_view_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final themeVm = ref.read(themeViewModelProvider.notifier);
    final isDark = ref.watch(themeViewModelProvider) == ThemeMode.dark;

    // ── Real user from Firestore ──────────────
    final user = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      backgroundColor: const Color(0xFF131409),
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),
          Column(
            children: [
              _TopBar(
                isDark: isDark,
                onToggle: themeVm.toggleDarkLight,
                user: user,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                  child: Column(
                    children: [
                      _ResumeCard(user: user),
                      const SizedBox(height: 20),
                      const _StatsRow(),
                      const SizedBox(height: 20),
                      const _DailyChallengeCard(),
                      const SizedBox(height: 20),
                      const _QuickPracticeSection(),
                      const SizedBox(height: 20),
                      const _RecentActivitySection(),
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
  final bool isDark;
  final VoidCallback onToggle;
  final UserModel? user;

  const _TopBar({
    required this.isDark,
    required this.onToggle,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    // Derive display values from real user
    final initials = user?.initials ?? '?';
    final firstName = () {
      final name = (user?.fullName.isNotEmpty == true)
          ? user!.fullName
          : (user?.displayName ?? '');
      return name.trim().split(' ').first;
    }();
    final greeting = firstName.isNotEmpty
        ? 'Good Morning, $firstName 👋'
        : 'Good Morning 👋';
    final examLabel = (user?.selectedExam.isNotEmpty == true)
        ? user!.selectedExam.toUpperCase()
        : 'ASPIRANT';

    return Container(
      padding: EdgeInsets.fromLTRB(20, top + 12, 20, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF131409).withValues(alpha: 0.85),
        border: const Border(bottom: BorderSide(color: Color(0x4D464834))),
      ),
      child: Row(
        children: [
          // Avatar + greeting
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF5822B8),
                  border: Border.all(
                    color: const Color(0xFFD8EE36).withValues(alpha: 0.3),
                  ),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFD8EE36),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    examLabel,
                    style: const TextStyle(
                      fontSize: 9,
                      letterSpacing: 2,
                      color: Color(0xFFC7C8AE),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    greeting,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),

          // Theme toggle
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2B1F),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF464834).withValues(alpha: 0.5),
                ),
              ),
              child: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: const Color(0xFFD8EE36),
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Streak
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2B1F),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(
                color: const Color(0xFF464834).withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.local_fire_department_rounded,
                  color: Color(0xFFD8EE36),
                  size: 16,
                ),
                SizedBox(width: 4),
                Text(
                  '7',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFD8EE36),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Notification
          Stack(
            children: [
              const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
                size: 24,
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB4AB),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF131409),
                      width: 2,
                    ),
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
//  RESUME CARD
// ─────────────────────────────────────────────
class _ResumeCourse {
  final String subject;
  final String chapter;
  final int completedTopics;
  final int totalTopics;
  final String? metaLabel;

  const _ResumeCourse({
    required this.subject,
    required this.chapter,
    required this.completedTopics,
    required this.totalTopics,
    this.metaLabel,
  });

  double get progress => totalTopics == 0 ? 0 : completedTopics / totalTopics;

  int get progressPercent => (progress * 100).round();
}

const _defaultResumeCourse = _ResumeCourse(
  subject: 'General Preparation',
  chapter: 'No active course found',
  completedTopics: 0,
  totalTopics: 1,
  metaLabel: '0 Chapters / 0 Topics',
);

class _ResumeCard extends ConsumerWidget {
  final UserModel? user;

  const _ResumeCard({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final educationSubject = user?.educationSubject.trim() ?? '';
    final subjectsAsync = ref.watch(activeSubjectsProvider);
    final subjects = subjectsAsync.valueOrNull ?? const <SubjectModel>[];
    final firebaseSubject = subjects.matchEducationSubject(educationSubject);
    final subjectId = firebaseSubject?.progressSubjectId ?? '';
    final progressAsync = user == null || subjectId.isEmpty
        ? null
        : ref.watch(
            subjectProgressProvider(
              SubjectProgressRequest(uid: user!.uid, subjectId: subjectId),
            ),
          );
    final progress = progressAsync?.valueOrNull;
    final course =
        firebaseSubject?.toResumeCourse(progress) ??
        (educationSubject.isEmpty || educationSubject.toLowerCase() == 'other'
            ? _defaultResumeCourse
            : _ResumeCourse(
                subject: educationSubject,
                chapter: 'No course available yet',
                completedTopics: 0,
                totalTopics: 1,
                metaLabel: '0 Chapters / 0 Topics',
              ));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xCC131309),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD8EE36).withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD8EE36).withValues(alpha: 0.08),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD8EE36).withValues(alpha: 0.05),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CONTINUE WHERE YOU LEFT OFF',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.5,
                  color: Color(0xFFD8EE36),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                course.subject,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                course.chapter,
                style: const TextStyle(fontSize: 13, color: Color(0xFFC7C8AE)),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${course.progressPercent}% COMPLETED',
                    style: const TextStyle(
                      fontSize: 11,
                      letterSpacing: 1,
                      color: Color(0xFFD8EE36),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    course.metaLabel ??
                        '${course.completedTopics}/${course.totalTopics} Topics',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFFC7C8AE),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: course.progress,
                  minHeight: 8,
                  backgroundColor: const Color(0xFF1F2015),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFFD8EE36)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD8EE36),
                    foregroundColor: const Color(0xFF191E00),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const EnglishProficiencyScreen(),
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Resume Session'),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 18),
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

  _ResumeCourse toResumeCourse(SubjectProgressModel? progress) {
    final topicCount = totalTopics == 0 ? totalChapters : totalTopics;
    final completedTopics = progress?.completedTopics ?? 0;
    final safeTotalTopics = topicCount == 0 ? 1 : topicCount;
    final safeCompletedTopics = completedTopics
        .clamp(0, safeTotalTopics)
        .toInt();
    final displayTotalTopics = totalTopics == 0 ? safeTotalTopics : totalTopics;

    return _ResumeCourse(
      subject: displayTitle,
      chapter: displayName,
      completedTopics: safeCompletedTopics,
      totalTopics: safeTotalTopics,
      metaLabel: '$safeCompletedTopics/$displayTotalTopics Topics',
    );
  }
}

extension on String {
  String get normalizedSubjectKey =>
      toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
}

// ─────────────────────────────────────────────
//  STATS ROW
// ─────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _StatCard(label: 'TESTS DONE', value: '24'),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _StatCard(label: 'AVG SCORE', value: '71%', highlight: true),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _StatCard(label: 'BEST RANK', value: '#142'),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _StatCard({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xCC131309),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlight
              ? const Color(0xFFD8EE36).withValues(alpha: 0.2)
              : const Color(0xFF1E1E2E),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              letterSpacing: 1.2,
              color: highlight
                  ? const Color(0xFFD8EE36)
                  : const Color(0xFFC7C8AE),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  DAILY CHALLENGE
// ─────────────────────────────────────────────
class _DailyChallengeCard extends StatelessWidget {
  const _DailyChallengeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2015),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF75D1FF).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.bolt_rounded,
                        color: Color(0xFF75D1FF),
                        size: 20,
                      ),
                      SizedBox(width: 6),
                      Text(
                        "Today's Challenge",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    '20 MCQs · 15 Minutes · High Intensity',
                    style: TextStyle(fontSize: 13, color: Color(0xFFC7C8AE)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2B1F),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF464834).withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      color: Color(0xFF75D1FF),
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '04:32:10',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF75D1FF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF75D1FF),
                side: const BorderSide(color: Color(0x6675D1FF)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              onPressed: () {},
              child: const Text('ATTEMPT NOW'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  QUICK PRACTICE
// ─────────────────────────────────────────────
class _PracticeItem {
  final String label;
  final String mcqs;
  final double progress;
  final Color color;
  final IconData icon;

  const _PracticeItem({
    required this.label,
    required this.mcqs,
    required this.progress,
    required this.color,
    required this.icon,
  });
}

const _practiceCards = [
  _PracticeItem(
    label: 'Education\nPsychology',
    mcqs: '50 MCQS',
    progress: 0.75,
    color: Color(0xFFD8EE36),
    icon: Icons.psychology_rounded,
  ),
  _PracticeItem(
    label: 'English\nGrammar',
    mcqs: '50 MCQS',
    progress: 0.32,
    color: Color(0xFFD1BCFF),
    icon: Icons.translate_rounded,
  ),
  _PracticeItem(
    label: 'Pak\nStudies',
    mcqs: '50 MCQS',
    progress: 0.91,
    color: Color(0xFF75D1FF),
    icon: Icons.history_edu_rounded,
  ),
];

class _QuickPracticeSection extends StatelessWidget {
  const _QuickPracticeSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Quick Practice',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'VIEW ALL',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  color: Color(0xFFD8EE36),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 170,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _practiceCards.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) => _PracticeCard(item: _practiceCards[i]),
          ),
        ),
      ],
    );
  }
}

class _PracticeCard extends StatelessWidget {
  final _PracticeItem item;
  const _PracticeCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xCC131309),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E1E2E)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: item.progress,
                  strokeWidth: 4,
                  backgroundColor: const Color(0xFF353629),
                  valueColor: AlwaysStoppedAnimation(item.color),
                  strokeCap: StrokeCap.round,
                ),
                Icon(item.icon, color: item.color, size: 22),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2015),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              item.mcqs,
              style: const TextStyle(
                fontSize: 9,
                letterSpacing: 0.8,
                color: Color(0xFFC7C8AE),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  RECENT ACTIVITY
// ─────────────────────────────────────────────
class _RecentActivitySection extends StatelessWidget {
  const _RecentActivitySection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Icon(Icons.history_rounded, color: Color(0xFFC7C8AE), size: 20),
          ],
        ),
        const SizedBox(height: 12),
        _ActivityTile(
          title: 'CSS MPT Mock #04',
          date: 'Oct 24, 2023',
          score: '82/100',
          scoreColor: const Color(0xFFD1BCFF),
          scoreBg: const Color(0xFF5822B8),
        ),
        const SizedBox(height: 10),
        _ActivityTile(
          title: 'GK: Current Affairs',
          date: 'Oct 22, 2023',
          score: '45/60',
          scoreColor: const Color(0xFFFFB4AB),
          scoreBg: const Color(0xFF93000A),
        ),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final String title;
  final String date;
  final String score;
  final Color scoreColor;
  final Color scoreBg;

  const _ActivityTile({
    required this.title,
    required this.date,
    required this.score,
    required this.scoreColor,
    required this.scoreBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xCC131309),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E1E2E)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFC7C8AE),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: scoreBg.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: scoreBg.withValues(alpha: 0.5)),
            ),
            child: Text(
              score,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: scoreColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFFC7C8AE),
            size: 20,
          ),
        ],
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
      ..color = Colors.white.withValues(alpha: 0.03)
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
