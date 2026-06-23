// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/model.dart';
import '../../repository/favorite_mcq_repository.dart';
import '../../view_model/providers.dart';

part 'mock_test_review_widgets.dart';
part 'mock_test_setup_widgets.dart';
part 'mock_test_question_widgets.dart';
part 'mock_test_common_widgets.dart';

class MockTestSetupScreen extends ConsumerStatefulWidget {
  const MockTestSetupScreen({super.key});

  @override
  ConsumerState<MockTestSetupScreen> createState() =>
      _MockTestSetupScreenState();
}

enum _MockStage { setup, test, review }

enum _ReviewState { correct, incorrect, skipped }

class _MockQuestion {
  final MockExamMcqModel source;
  final String id;
  final String subject;
  final String question;
  final List<String> options;
  final String tip;
  final String explanation;
  final int correctIndex;
  final int selectedIndex;
  final bool flagged;

  const _MockQuestion({
    required this.source,
    required this.id,
    required this.subject,
    required this.question,
    required this.options,
    required this.tip,
    required this.explanation,
    required this.correctIndex,
    this.selectedIndex = -1,
    this.flagged = false,
  });

  _MockQuestion copyWith({int? selectedIndex, bool? flagged}) {
    return _MockQuestion(
      source: source,
      id: id,
      subject: subject,
      question: question,
      options: options,
      tip: tip,
      explanation: explanation,
      correctIndex: correctIndex,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      flagged: flagged ?? this.flagged,
    );
  }
}

class _ReviewItem {
  final String number;
  final String question;
  final _ReviewState state;
  final String? yourAnswer;
  final String? correctAnswer;
  final String? note;

  const _ReviewItem({
    required this.number,
    required this.question,
    required this.state,
    this.yourAnswer,
    this.correctAnswer,
    this.note,
  });
}

class _MockTestSetupScreenState extends ConsumerState<MockTestSetupScreen> {
  static const _bg = Color(0xFF0B0E05);
  static const _surface = Color(0xFF13160B);
  static const _tile = Color(0xFF202215);
  static const _border = Color(0xFF2B3018);
  static const _muted = Color(0xFF969984);
  static const _accent = Color(0xFFDFFF1F);
  static const _purple = Color(0xFF6E35C9);
  _MockStage _stage = _MockStage.setup;
  String _selectedExamId = '';
  int _questionCount = 10;
  bool _timedMode = true;
  bool _isStarting = false;
  bool _exitDialogOpen = false;
  bool _resultRecorded = false;
  int _currentIndex = 0;
  int _remainingSeconds = 0;
  Timer? _timer;
  final Map<String, Set<String>> _subjectSelections = {};
  final Set<String> _favoriteUpdates = {};
  List<_MockQuestion> _questions = [];

  _MockQuestion get _question => _questions[_currentIndex];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startSession(
    MockExamModel exam,
    List<MockExamSubjectModel> subjects,
  ) async {
    if (_isStarting) return;
    final selectedSubjects = subjects
        .where((subject) => _isSubjectSelected(exam.id, subject.id))
        .toList(growable: false);
    if (selectedSubjects.isEmpty) {
      _showMessage('Select at least one core subject.');
      return;
    }

    setState(() => _isStarting = true);
    try {
      final mcqs = await ref
          .read(mockExamRepositoryProvider)
          .fetchMcqs(examId: exam.id, subjects: selectedSubjects);
      if (!mounted) return;
      if (mcqs.isEmpty) {
        _showMessage('No active MCQs are available for the selected subjects.');
        return;
      }

      mcqs.shuffle(Random());
      final count = min(_questionCount, mcqs.length);
      _questions = mcqs.take(count).map(_questionFromModel).toList();
      _selectedExamId = exam.id;
      _currentIndex = 0;
      _remainingSeconds = count * 60;
      _resultRecorded = false;
      setState(() => _stage = _MockStage.test);
      if (mcqs.length < _questionCount) {
        _showMessage(
          'Only ${mcqs.length} active MCQs are available for this selection.',
        );
      }
    } catch (error) {
      if (mounted) _showMessage('Unable to load MCQs from Firebase: $error');
      return;
    } finally {
      if (mounted) setState(() => _isStarting = false);
    }

    _timer?.cancel();
    if (_timedMode) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted || _remainingSeconds <= 0) return;
        setState(() => _remainingSeconds--);
        if (_remainingSeconds == 0) {
          _timer?.cancel();
          setState(() => _stage = _MockStage.review);
          unawaited(_recordResult());
        }
      });
    }
  }

  _MockQuestion _questionFromModel(MockExamMcqModel mcq) => _MockQuestion(
    source: mcq,
    id: mcq.id,
    subject: mcq.subjectName.isEmpty ? 'General' : mcq.subjectName,
    question: mcq.question,
    options: mcq.options,
    correctIndex: mcq.correctIndex,
    explanation: mcq.explanation,
    tip: mcq.difficulty.isEmpty
        ? ''
        : 'Difficulty: ${mcq.difficulty[0].toUpperCase()}${mcq.difficulty.substring(1)}',
  );

  bool _isSubjectSelected(String examId, String subjectId) {
    final selection = _subjectSelections[examId];
    return selection == null || selection.contains(subjectId);
  }

  void _toggleSubject(
    String examId,
    String subjectId,
    List<MockExamSubjectModel> subjects,
  ) {
    setState(() {
      final selection = _subjectSelections.putIfAbsent(
        examId,
        () => subjects.map((subject) => subject.id).toSet(),
      );
      selection.contains(subjectId)
          ? selection.remove(subjectId)
          : selection.add(subjectId);
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _toggleFavorite(String uid, _MockQuestion question) async {
    if (uid.isEmpty || _favoriteUpdates.contains(question.id)) return;
    setState(() => _favoriteUpdates.add(question.id));
    try {
      final saved = await ref
          .read(favoriteMcqRepositoryProvider)
          .toggleFavorite(uid: uid, mcq: question.source);
      if (mounted) {
        _showMessage(
          saved ? 'MCQ saved to favorites.' : 'MCQ removed from favorites.',
        );
      }
    } catch (error) {
      if (mounted) _showMessage('Unable to update favorite: $error');
    } finally {
      if (mounted) setState(() => _favoriteUpdates.remove(question.id));
    }
  }

  void _selectOption(int index) {
    setState(() {
      _questions[_currentIndex] = _question.copyWith(selectedIndex: index);
    });
  }

  void _toggleFlag() {
    setState(() {
      _questions[_currentIndex] = _question.copyWith(
        flagged: !_question.flagged,
      );
    });
  }

  void _previousQuestion() {
    if (_currentIndex == 0) return;
    setState(() => _currentIndex--);
  }

  void _nextQuestion() {
    if (_currentIndex == _questions.length - 1) {
      _showSubmitDialog();
      return;
    }
    setState(() => _currentIndex++);
  }

  void _showSubmitDialog() {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Submit Examination',
      barrierColor: Colors.black.withOpacity(.68),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, _, _) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: _SubmitDialog(
                answered: _answeredCount,
                total: _questions.length,
                flagged: _flaggedCount,
                onSubmit: _submitAndClose,
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, _, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: .96, end: 1).animate(animation),
            child: child,
          ),
        );
      },
    );
  }

  void _submitAndClose() {
    Navigator.of(context).pop();
    _timer?.cancel();

    // Start the Firebase write while the completed session data is still in
    // memory, then immediately close and clear the current test locally.
    unawaited(_recordResult());
    setState(() {
      _clearCurrentTest();
    });
    _showMessage('Test submitted. Your score is being saved.');
  }

  Future<void> _showCloseConfirmation() async {
    if (_exitDialogOpen || _stage != _MockStage.test) return;
    _exitDialogOpen = true;
    final shouldClose = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: _border),
        ),
        title: const Text(
          'Close current test?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'Your current answers and progress will be cleared. This test will not be counted as completed.',
          style: TextStyle(color: _muted, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('CONTINUE TEST'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'CLOSE TEST',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
    _exitDialogOpen = false;
    if (!mounted || shouldClose != true) return;

    _timer?.cancel();
    setState(() {
      _clearCurrentTest();
      _resultRecorded = false;
    });
    _showMessage('Current test closed.');
  }

  void _clearCurrentTest() {
    _stage = _MockStage.setup;
    _questions = [];
    _currentIndex = 0;
    _remainingSeconds = 0;
    _selectedExamId = '';
    _questionCount = 10;
    _timedMode = true;
    _subjectSelections.clear();
    _favoriteUpdates.clear();
  }

  int get _answeredCount =>
      _questions.where((question) => question.selectedIndex >= 0).length;

  int get _flaggedCount =>
      _questions.where((question) => question.flagged).length;

  int get _correctCount => _questions
      .where((question) => question.selectedIndex == question.correctIndex)
      .length;

  List<_ReviewItem> get _reviewItems => List.generate(_questions.length, (
    index,
  ) {
    final question = _questions[index];
    final skipped = question.selectedIndex < 0;
    final correct = question.selectedIndex == question.correctIndex;
    return _ReviewItem(
      number: '${index + 1}'.padLeft(2, '0'),
      question: question.question,
      state: skipped
          ? _ReviewState.skipped
          : correct
          ? _ReviewState.correct
          : _ReviewState.incorrect,
      yourAnswer: skipped ? null : question.options[question.selectedIndex],
      correctAnswer: correct ? null : question.options[question.correctIndex],
      note: question.explanation.isEmpty ? null : question.explanation,
    );
  });

  Future<void> _recordResult() async {
    if (_resultRecorded || _questions.isEmpty) return;
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;
    _resultRecorded = true;
    try {
      await ref
          .read(userRepositoryProvider)
          .recordQuizAttempt(
            uid: user.uid,
            title: '$_selectedExamId Mock Test',
            type: 'mock_test',
            correctAnswers: _correctCount,
            totalQuestions: _questions.length,
            subjectId: _selectedSubjectIdsForResult,
          );
    } catch (_) {
      _resultRecorded = false;
    }
  }

  String get _selectedSubjectIdsForResult {
    final selection = _subjectSelections[_selectedExamId];
    return selection?.join(',') ?? 'all';
  }

  MockExamModel? _resolveExam(List<MockExamModel> exams, String preferredExam) {
    if (exams.isEmpty) return null;
    final selected = exams.where((exam) => exam.id == _selectedExamId);
    if (selected.isNotEmpty) return selected.first;

    final needle = _normalize(preferredExam);
    if (needle.isNotEmpty) {
      for (final exam in exams) {
        if ({
          _normalize(exam.id),
          _normalize(exam.code),
          _normalize(exam.title),
        }.contains(needle)) {
          return exam;
        }
      }
    }
    return exams.first;
  }

  String _normalize(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  static const List<int> _questionCountOptions = [
    10,
    20,
    25,
    30,
    40,
    50,
    65,
    75,
    100,
  ];

  String get _timeText {
    if (!_timedMode) return 'UNTIMED';
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _stage != _MockStage.test,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _stage == _MockStage.test) {
          unawaited(_showCloseConfirmation());
        }
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        child: switch (_stage) {
          _MockStage.setup => _buildSetup(),
          _MockStage.test => _buildTest(),
          _MockStage.review => _buildReview(),
        },
      ),
    );
  }

  Widget _buildSetup() {
    final examsAsync = ref.watch(activeMockExamsProvider);
    final exams = examsAsync.valueOrNull ?? const <MockExamModel>[];
    final preferredExam =
        ref.watch(currentUserProvider).valueOrNull?.selectedExam ?? '';
    final selectedExam = _resolveExam(exams, preferredExam);
    final subjectsAsync = selectedExam == null
        ? null
        : ref.watch(mockExamSubjectsProvider(selectedExam.id));
    final subjects =
        subjectsAsync?.valueOrNull ?? const <MockExamSubjectModel>[];
    const countOptions = _questionCountOptions;

    return Scaffold(
      backgroundColor: _bg,
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: _purple),
        child: const Icon(Icons.auto_awesome, color: _accent),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          color: Colors.transparent,
          child: _PrimaryButton(
            label: _isStarting
                ? 'Loading Firebase MCQs…'
                : 'Initialize Session',
            icon: Icons.play_circle_outline_rounded,
            onTap: () {
              if (selectedExam != null && !_isStarting) {
                _startSession(selectedExam, subjects);
              }
            },
          ),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: _GridBackground(opacity: .045)),
          SafeArea(
            child: Column(
              children: [
                _SetupTopBar(onBack: () => Navigator.maybePop(context)),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SIMULATOR 2.0',
                          style: TextStyle(
                            color: _accent,
                            fontSize: 10,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Mock Test',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 33,
                            height: 1,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Configure your high-stakes practice session\nwith precision.',
                          style: TextStyle(
                            color: _muted,
                            fontSize: 15,
                            height: 1.45,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 28),
                        _SetupCard(
                          title: 'Select Target Exam',
                          icon: Icons.assignment_outlined,
                          child: GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 2.6,
                            children: exams
                                .map(
                                  (exam) => _ChoiceTile(
                                    label: exam.displayName,
                                    selected: selectedExam?.id == exam.id,
                                    onTap: () {
                                      setState(() {
                                        _selectedExamId = exam.id;
                                        _questionCount = 10;
                                      });
                                    },
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        if (examsAsync.isLoading) ...[
                          const SizedBox(height: 10),
                          const LinearProgressIndicator(color: _accent),
                        ],
                        if (examsAsync.hasError ||
                            (!examsAsync.isLoading && exams.isEmpty)) ...[
                          const SizedBox(height: 10),
                          Text(
                            examsAsync.hasError
                                ? 'Unable to load exams from Firebase.'
                                : 'No active exams are available.',
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        _SetupCard(
                          title: 'Question Count',
                          icon: Icons.format_list_bulleted_rounded,
                          child: GridView.count(
                            crossAxisCount: 3,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 2.3,
                            children: countOptions.map((count) {
                              return _ChoiceTile(
                                label: '$count',
                                selected: _questionCount == count,
                                compact: true,
                                onTap: () {
                                  setState(() => _questionCount = count);
                                },
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _SetupCard(
                          title: 'Exam Mode',
                          icon: Icons.timer_outlined,
                          child: _SegmentedMode(
                            timedMode: _timedMode,
                            onChanged: (value) {
                              setState(() => _timedMode = value);
                            },
                          ),
                        ),
                        const SizedBox(height: 14),
                        _SetupCard(
                          title: 'Core Subjects',
                          icon: Icons.library_books_outlined,
                          trailing: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (selectedExam != null) {
                                  _subjectSelections.remove(selectedExam.id);
                                }
                              });
                            },
                            child: const Text(
                              'SELECT ALL',
                              style: TextStyle(
                                color: _accent,
                                fontSize: 8,
                                letterSpacing: .8,
                                decoration: TextDecoration.underline,
                                decorationColor: _accent,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          child: Column(
                            children: subjects.map((subject) {
                              return _SubjectRow(
                                label: subject.mcqCount > 0
                                    ? '${subject.name} (${subject.mcqCount})'
                                    : subject.name,
                                selected:
                                    selectedExam != null &&
                                    _isSubjectSelected(
                                      selectedExam.id,
                                      subject.id,
                                    ),
                                onTap: () {
                                  if (selectedExam != null) {
                                    _toggleSubject(
                                      selectedExam.id,
                                      subject.id,
                                      subjects,
                                    );
                                  }
                                },
                              );
                            }).toList(),
                          ),
                        ),
                        if (subjectsAsync?.isLoading == true) ...[
                          const SizedBox(height: 10),
                          const LinearProgressIndicator(color: _accent),
                        ],
                        if (subjectsAsync?.hasError == true ||
                            (selectedExam != null &&
                                subjectsAsync?.isLoading == false &&
                                subjects.isEmpty)) ...[
                          const SizedBox(height: 10),
                          Text(
                            subjectsAsync?.hasError == true
                                ? 'Unable to load subjects from Firebase.'
                                : 'No active subjects are available for this exam.',
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTest() {
    final percent = ((_currentIndex + 1) / _questions.length).clamp(0.0, 1.0);
    final uid = ref.watch(currentUserProvider).valueOrNull?.uid ?? '';
    final favoriteIds =
        ref.watch(favoriteMcqIdsProvider(uid)).valueOrNull ?? {};
    final favoriteId = FavoriteMcqRepository.favoriteDocumentId(
      examId: _question.source.examId,
      subjectId: _question.source.subjectId,
      mcqId: _question.id,
    );

    return Scaffold(
      backgroundColor: _bg,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
          decoration: BoxDecoration(
            color: _bg.withOpacity(.96),
            border: Border(top: BorderSide(color: _border.withOpacity(.8))),
          ),
          child: Row(
            children: [
              Expanded(
                child: _NavButton(
                  label: 'PREVIOUS',
                  icon: Icons.arrow_back_rounded,
                  enabled: _currentIndex > 0,
                  onTap: _previousQuestion,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _NavButton(
                  label: 'REVIEW',
                  icon: Icons.rate_review_outlined,
                  enabled: true,
                  onTap: _showSubmitDialog,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _NavButton(
                  label: _currentIndex == _questions.length - 1
                      ? 'SUBMIT'
                      : 'NEXT',
                  icon: Icons.arrow_forward_rounded,
                  enabled: true,
                  accent: true,
                  reverseIcon: true,
                  onTap: _nextQuestion,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: _GridBackground(opacity: .04)),
          SafeArea(
            child: Column(
              children: [
                _ExamHeader(
                  timeText: _timeText,
                  onClose: _showCloseConfirmation,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(14, 18, 14, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Question ${_currentIndex + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'of ${_questions.length}',
                              style: const TextStyle(
                                color: _muted,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${(percent * 100).round()}% COMPLETE',
                              style: const TextStyle(
                                color: _muted,
                                fontSize: 9,
                                letterSpacing: 1.4,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: percent,
                            minHeight: 4,
                            backgroundColor: _tile,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              _accent,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        _QuestionPanel(
                          question: _question,
                          onFlag: _toggleFlag,
                          onSelect: _selectOption,
                          saved: favoriteIds.contains(favoriteId),
                          saving: _favoriteUpdates.contains(_question.id),
                          onSave: () => _toggleFavorite(uid, _question),
                        ),
                        if (_question.tip.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          _AiTip(text: _question.tip),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReview() {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          const Positioned.fill(child: _GridBackground(opacity: .035)),
          SafeArea(
            child: Column(
              children: [
                _AnswerReviewTopBar(
                  onBack: () => setState(() => _stage = _MockStage.test),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ReviewScorePanel(
                          correct: _correctCount,
                          total: _questions.length,
                        ),
                        const SizedBox(height: 22),
                        const _ReviewTabs(),
                        const SizedBox(height: 18),
                        ..._reviewItems.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ReviewQuestionCard(item: item),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
