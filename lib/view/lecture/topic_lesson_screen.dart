import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/model.dart';
import '../../view_model/providers.dart';

const _bg = Color(0xFF0E0F0E);
const _card = Color(0xFF1A1C1A);
const _lime = Color(0xFFC8F135);
const _muted = Color(0xFF9A9A9A);

class ChapterTopicsScreen extends ConsumerWidget {
  final String subjectDocumentId;
  final String progressSubjectId;
  final String chapterId;
  final String chapterTitle;
  final List<TopicMcqModel> chapterMcqs;

  const ChapterTopicsScreen({
    super.key,
    required this.subjectDocumentId,
    required this.progressSubjectId,
    required this.chapterId,
    required this.chapterTitle,
    required this.chapterMcqs,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final topicsAsync = ref.watch(
      subjectTopicsProvider(
        SubjectTopicsRequest(
          subjectId: subjectDocumentId,
          chapterId: chapterId,
        ),
      ),
    );
    final progress = user == null
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

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: _lime,
        title: Text(chapterTitle),
      ),
      body: topicsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: _lime)),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Unable to load topics from Firebase.\n$error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: _muted),
            ),
          ),
        ),
        data: (topics) {
          if (topics.isEmpty) {
            return const Center(
              child: Text(
                'No topics are available in this chapter.',
                style: TextStyle(color: _muted),
              ),
            );
          }

          final completed = progress?.completedTopicIds.toSet() ?? <String>{};
          final allTopicIds = topics
              .map((topic) => topic.progressTopicId)
              .toList(growable: false);

          final allTopicsCompleted = allTopicIds.every(completed.contains);
          final chapterCompleted =
              progress?.completedChapterIds.contains(chapterId) ?? false;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: topics.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              if (index == topics.length) {
                return Opacity(
                  opacity: allTopicsCompleted ? 1 : .5,
                  child: ListTile(
                    tileColor: _lime.withValues(alpha: .08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: chapterCompleted ? _lime : Colors.white12,
                      ),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: _lime.withValues(alpha: .16),
                      child: Icon(
                        chapterCompleted
                            ? Icons.verified_rounded
                            : allTopicsCompleted
                            ? Icons.quiz_rounded
                            : Icons.lock_outline_rounded,
                        color: allTopicsCompleted ? _lime : _muted,
                      ),
                    ),
                    title: const Text(
                      'Chapter Test',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    subtitle: Text(
                      chapterCompleted
                          ? 'Chapter completed'
                          : allTopicsCompleted
                          ? '${chapterMcqs.length} chapter questions'
                          : 'Complete every topic to unlock',
                      style: TextStyle(
                        color: chapterCompleted ? _lime : _muted,
                        fontSize: 12,
                      ),
                    ),
                    trailing: Icon(
                      allTopicsCompleted
                          ? Icons.arrow_forward_ios_rounded
                          : Icons.lock_outline_rounded,
                      color: allTopicsCompleted ? _lime : _muted,
                      size: 16,
                    ),
                    onTap: !allTopicsCompleted || user == null
                        ? null
                        : () async {
                            var finished = true;
                            if (chapterMcqs.isNotEmpty) {
                              finished =
                                  await Navigator.of(
                                    context,
                                  ).push<QuizAttemptResult>(
                                    MaterialPageRoute(
                                      builder: (_) => TopicQuizScreen(
                                        title: '$chapterTitle Test',
                                        questions: chapterMcqs,
                                        tracking: QuizTrackingData(
                                          uid: user.uid,
                                          title: '$chapterTitle Test',
                                          type: 'chapter',
                                          subjectId: progressSubjectId,
                                          chapterId: chapterId,
                                        ),
                                      ),
                                    ),
                                  ) !=
                                  null;
                            }
                            if (!finished || !context.mounted) return;
                            try {
                              await ref
                                  .read(subjectProgressRepositoryProvider)
                                  .markChapterCompleted(
                                    uid: user.uid,
                                    subjectId: progressSubjectId,
                                    chapterId: chapterId,
                                  );
                              if (context.mounted) {
                                Navigator.of(context).pop(true);
                              }
                            } catch (error) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Could not save chapter progress: $error',
                                  ),
                                ),
                              );
                            }
                          },
                  ),
                );
              }

              final topic = topics[index];
              final isCompleted = completed.contains(topic.progressTopicId);
              final isUnlocked =
                  index == 0 ||
                  completed.contains(topics[index - 1].progressTopicId);

              return Opacity(
                opacity: isUnlocked ? 1 : .5,
                child: ListTile(
                  tileColor: _card,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: isCompleted ? _lime : Colors.white12,
                    ),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: isCompleted
                        ? _lime.withValues(alpha: .18)
                        : Colors.white10,
                    child: Icon(
                      isCompleted
                          ? Icons.check_rounded
                          : isUnlocked
                          ? Icons.menu_book_rounded
                          : Icons.lock_outline_rounded,
                      color: isCompleted || isUnlocked ? _lime : _muted,
                    ),
                  ),
                  title: Text(
                    topic.displayTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    isCompleted
                        ? 'Completed'
                        : isUnlocked
                        ? 'Read lesson first'
                        : 'Complete the previous topic to unlock',
                    style: TextStyle(
                      color: isCompleted ? _lime : _muted,
                      fontSize: 12,
                    ),
                  ),
                  trailing: Icon(
                    isUnlocked
                        ? Icons.arrow_forward_ios_rounded
                        : Icons.lock_outline_rounded,
                    size: 16,
                    color: isUnlocked ? _lime : _muted,
                  ),
                  onTap: !isUnlocked || user == null
                      ? null
                      : () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TopicLessonScreen(
                              topic: topic,
                              uid: user.uid,
                              progressSubjectId: progressSubjectId,
                              chapterId: chapterId,
                              alreadyCompleted: isCompleted,
                            ),
                          ),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class TopicLessonScreen extends ConsumerStatefulWidget {
  final SubjectTopicModel topic;
  final String uid;
  final String progressSubjectId;
  final String chapterId;
  final bool alreadyCompleted;

  const TopicLessonScreen({
    super.key,
    required this.topic,
    required this.uid,
    required this.progressSubjectId,
    required this.chapterId,
    required this.alreadyCompleted,
  });

  @override
  ConsumerState<TopicLessonScreen> createState() => _TopicLessonScreenState();
}

class _TopicLessonScreenState extends ConsumerState<TopicLessonScreen> {
  bool _saving = false;

  Future<void> _completeTopic() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(subjectProgressRepositoryProvider)
          .markTopicCompleted(
            uid: widget.uid,
            subjectId: widget.progressSubjectId,
            chapterId: widget.chapterId,
            topicId: widget.topic.progressTopicId,
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save progress: $error')),
      );
    }
  }

  Future<void> _openQuiz() async {
    if (widget.topic.mcqs.isEmpty) {
      await _completeTopic();
      return;
    }

    final result = await Navigator.of(context).push<QuizAttemptResult>(
      MaterialPageRoute(
        builder: (_) => TopicQuizScreen(
          title: widget.topic.displayTitle,
          questions: widget.topic.mcqs,
          tracking: QuizTrackingData(
            uid: widget.uid,
            title: '${widget.topic.displayTitle} Quiz',
            type: 'topic',
            subjectId: widget.progressSubjectId,
            chapterId: widget.chapterId,
            topicId: widget.topic.progressTopicId,
          ),
        ),
      ),
    );
    if (result != null && mounted) await _completeTopic();
  }

  @override
  Widget build(BuildContext context) {
    final topic = widget.topic;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: _lime,
        title: Text(topic.displayTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
        children: [
          _LessonSection(
            icon: Icons.lightbulb_outline_rounded,
            title: 'Definition',
            child: Text(
              topic.definition,
              style: const TextStyle(color: Colors.white, fontSize: 17),
            ),
          ),
          if (topic.explanation.isNotEmpty) ...[
            const SizedBox(height: 12),
            _LessonSection(
              icon: Icons.notes_rounded,
              title: 'Explanation',
              child: Text(
                topic.explanation,
                style: const TextStyle(color: Colors.white70, height: 1.5),
              ),
            ),
          ],
          if (topic.types.isNotEmpty) ...[
            const SizedBox(height: 12),
            _LessonSection(
              icon: Icons.account_tree_outlined,
              title: 'Types',
              child: Column(
                children: topic.types
                    .map(
                      (type) => Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .04),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              type.type,
                              style: const TextStyle(
                                color: _lime,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              type.definition,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            if (type.examples.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Examples: ${type.examples.join(', ')}',
                                style: const TextStyle(
                                  color: _muted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          ],
          if (topic.examples.isNotEmpty) ...[
            const SizedBox(height: 12),
            _LessonSection(
              icon: Icons.format_quote_rounded,
              title: 'Examples',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: topic.examples
                    .map(
                      (example) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '• $example',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: _lime,
              foregroundColor: _bg,
            ),
            onPressed: _saving ? null : _openQuiz,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    widget.topic.mcqs.isEmpty
                        ? Icons.check_rounded
                        : Icons.quiz_outlined,
                  ),
            label: Text(
              widget.topic.mcqs.isEmpty
                  ? 'COMPLETE TOPIC'
                  : widget.alreadyCompleted
                  ? 'RETAKE TOPIC QUIZ'
                  : 'TAKE TOPIC QUIZ',
            ),
          ),
        ),
      ),
    );
  }
}

class _LessonSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _LessonSection({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _card,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: _lime, size: 20),
            const SizedBox(width: 8),
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                color: _lime,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}

class QuizTrackingData {
  final String uid;
  final String title;
  final String type;
  final String subjectId;
  final String chapterId;
  final String topicId;

  const QuizTrackingData({
    required this.uid,
    required this.title,
    required this.type,
    this.subjectId = '',
    this.chapterId = '',
    this.topicId = '',
  });
}

class QuizAttemptResult {
  final int correctAnswers;
  final int totalQuestions;

  const QuizAttemptResult({
    required this.correctAnswers,
    required this.totalQuestions,
  });
}

class TopicQuizScreen extends ConsumerStatefulWidget {
  final String title;
  final List<TopicMcqModel> questions;
  final QuizTrackingData tracking;

  const TopicQuizScreen({
    super.key,
    required this.title,
    required this.questions,
    required this.tracking,
  });

  @override
  ConsumerState<TopicQuizScreen> createState() => _TopicQuizScreenState();
}

class _TopicQuizScreenState extends ConsumerState<TopicQuizScreen> {
  int _index = 0;
  bool _submitting = false;
  late final List<int?> _answers = List<int?>.filled(
    widget.questions.length,
    null,
  );

  Future<void> _next() async {
    if (_submitting) return;
    if (_answers[_index] == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Select an answer first.')));
      return;
    }
    if (_index < widget.questions.length - 1) {
      setState(() => _index++);
      return;
    }

    var correct = 0;
    for (var i = 0; i < widget.questions.length; i++) {
      final selected = widget.questions[i].options[_answers[i]!];
      if (_normalized(selected) == _normalized(widget.questions[i].answer)) {
        correct++;
      }
    }

    setState(() => _submitting = true);
    try {
      await ref
          .read(userRepositoryProvider)
          .recordQuizAttempt(
            uid: widget.tracking.uid,
            title: widget.tracking.title,
            type: widget.tracking.type,
            correctAnswers: correct,
            totalQuestions: widget.questions.length,
            subjectId: widget.tracking.subjectId,
            chapterId: widget.tracking.chapterId,
            topicId: widget.tracking.topicId,
          );
    } catch (error) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save quiz result: $error')),
      );
      return;
    }

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _card,
        title: const Text('Quiz completed', style: TextStyle(color: _lime)),
        content: Text(
          'You answered $correct of ${widget.questions.length} correctly.',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('CONTINUE'),
          ),
        ],
      ),
    );
    if (mounted) {
      Navigator.of(context).pop(
        QuizAttemptResult(
          correctAnswers: correct,
          totalQuestions: widget.questions.length,
        ),
      );
    }
  }

  String _normalized(String value) => value.trim().toLowerCase();

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[_index];

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: _lime,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'QUESTION ${_index + 1} OF ${widget.questions.length}',
              style: const TextStyle(color: _lime, letterSpacing: 1.2),
            ),
            const SizedBox(height: 14),
            Text(
              question.question,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: question.options.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, optionIndex) {
                  final selected = _answers[_index] == optionIndex;
                  return ListTile(
                    onTap: () => setState(() => _answers[_index] = optionIndex),
                    tileColor: selected ? _lime.withValues(alpha: .14) : _card,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: selected ? _lime : Colors.white12,
                      ),
                    ),
                    leading: Icon(
                      selected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: selected ? _lime : _muted,
                    ),
                    title: Text(
                      question.options[optionIndex],
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
            ),
            Row(
              children: [
                if (_index > 0) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _index--),
                      child: const Text('BACK'),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: _lime,
                      foregroundColor: _bg,
                    ),
                    onPressed: _submitting ? null : _next,
                    child: _submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            _index == widget.questions.length - 1
                                ? 'FINISH'
                                : 'NEXT',
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
