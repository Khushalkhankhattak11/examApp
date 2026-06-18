// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

part 'mock_test_review_widgets.dart';
part 'mock_test_setup_widgets.dart';
part 'mock_test_question_widgets.dart';
part 'mock_test_common_widgets.dart';

class MockTestSetupScreen extends StatefulWidget {
  const MockTestSetupScreen({super.key});

  @override
  State<MockTestSetupScreen> createState() => _MockTestSetupScreenState();
}

enum _MockStage { setup, test, review }

enum _ReviewState { correct, incorrect, skipped }

class _MockQuestion {
  final String subject;
  final String question;
  final List<String> options;
  final String tip;
  final int selectedIndex;
  final bool flagged;

  const _MockQuestion({
    required this.subject,
    required this.question,
    required this.options,
    required this.tip,
    this.selectedIndex = -1,
    this.flagged = false,
  });

  _MockQuestion copyWith({int? selectedIndex, bool? flagged}) {
    return _MockQuestion(
      subject: subject,
      question: question,
      options: options,
      tip: tip,
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

class _MockTestSetupScreenState extends State<MockTestSetupScreen> {
  static const _bg = Color(0xFF0B0E05);
  static const _surface = Color(0xFF13160B);
  static const _tile = Color(0xFF202215);
  static const _border = Color(0xFF2B3018);
  static const _muted = Color(0xFF969984);
  static const _accent = Color(0xFFDFFF1F);
  static const _purple = Color(0xFF6E35C9);
  static const _totalSeconds = 42 * 60 + 15;

  _MockStage _stage = _MockStage.setup;
  String _selectedExam = 'CSS';
  int _questionCount = 25;
  bool _timedMode = true;
  int _currentIndex = 13;
  int _remainingSeconds = _totalSeconds;
  Timer? _timer;

  final Map<String, bool> _subjects = {
    'General Knowledge': true,
    'Pakistan Affairs': true,
    'English Précis': false,
    'General Ability & Maths': false,
  };

  final List<_ReviewItem> _reviewItems = const [
    _ReviewItem(
      number: '01',
      state: _ReviewState.correct,
      question:
          'Which branch of mechanics deals with the motion of objects without considering the forces that cause the motion?',
      yourAnswer: 'Kinematics',
    ),
    _ReviewItem(
      number: '02',
      state: _ReviewState.incorrect,
      question:
          'A projectile is fired at an angle of 45 degrees. At the peak of its trajectory, its vertical velocity is:',
      yourAnswer: 'Maximum',
      correctAnswer: 'Zero',
    ),
    _ReviewItem(
      number: '03',
      state: _ReviewState.skipped,
      question:
          'Calculate the centripetal acceleration of a car traveling at 20 m/s around a curve with a radius of 40m.',
      correctAnswer: '10 m/s²',
    ),
    _ReviewItem(
      number: '04',
      state: _ReviewState.correct,
      question:
          'The work-energy theorem states that the net work done on an object is equal to the change in its:',
      yourAnswer: 'Kinetic Energy',
      note:
          'Great job! You consistently get Work-Energy questions right. This is a core concept for the PCS Physics section.',
    ),
  ];

  final List<_MockQuestion> _questions = List.generate(
    50,
    (index) => _MockQuestion(
      subject: index.isEven ? 'General Knowledge' : 'Pakistan Affairs',
      question:
          'Who was the first Governor General of Pakistan and served until his death in September 1948?',
      options: const [
        'Liaquat Ali Khan',
        'Muhammad Ali Jinnah',
        'Khawaja Nazimuddin',
        'Ghulam Muhammad',
      ],
      selectedIndex: index == 13 ? 1 : -1,
      flagged: index == 13,
      tip:
          'Think about the "Father of the Nation" and his leadership during the crucial first year of independence.',
    ),
  );

  _MockQuestion get _question => _questions[_currentIndex];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startSession() {
    setState(() => _stage = _MockStage.test);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _remainingSeconds == 0) return;
      setState(() => _remainingSeconds--);
    });
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
                onSubmit: () {
                  Navigator.of(context).pop();
                  _timer?.cancel();
                  setState(() => _stage = _MockStage.review);
                },
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

  int get _answeredCount =>
      _questions.where((question) => question.selectedIndex >= 0).length;

  int get _flaggedCount =>
      _questions.where((question) => question.flagged).length;

  String get _timeText {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      child: switch (_stage) {
        _MockStage.setup => _buildSetup(),
        _MockStage.test => _buildTest(),
        _MockStage.review => _buildReview(),
      },
    );
  }

  Widget _buildSetup() {
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
            label: 'Initialize Session',
            icon: Icons.play_circle_outline_rounded,
            onTap: _startSession,
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
                            children: ['CSS', 'PMS', 'Tehsildar', 'Inspector']
                                .map(
                                  (exam) => _ChoiceTile(
                                    label: exam,
                                    selected: _selectedExam == exam,
                                    onTap: () {
                                      setState(() => _selectedExam = exam);
                                    },
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _SetupCard(
                          title: 'Question Count',
                          icon: Icons.format_list_bulleted_rounded,
                          child: Row(
                            children: [25, 50, 100].map((count) {
                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: count == 100 ? 0 : 8,
                                  ),
                                  child: _ChoiceTile(
                                    label: '$count',
                                    selected: _questionCount == count,
                                    compact: true,
                                    onTap: () {
                                      setState(() => _questionCount = count);
                                    },
                                  ),
                                ),
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
                                for (final subject in _subjects.keys) {
                                  _subjects[subject] = true;
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
                            children: _subjects.entries.map((entry) {
                              return _SubjectRow(
                                label: entry.key,
                                selected: entry.value,
                                onTap: () {
                                  setState(() {
                                    _subjects[entry.key] = !entry.value;
                                  });
                                },
                              );
                            }).toList(),
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

  Widget _buildTest() {
    final percent = ((_currentIndex + 1) / _questions.length).clamp(0.0, 1.0);

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
                _ExamHeader(timeText: _timeText),
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
                        ),
                        const SizedBox(height: 24),
                        _AiTip(text: _question.tip),
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
                        const _ReviewScorePanel(),
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
