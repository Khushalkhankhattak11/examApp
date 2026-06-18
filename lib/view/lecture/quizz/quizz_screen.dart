// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:ui';

import 'package:examace/const/app_responsive.dart';
import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizQuestion {
  final String category;
  final String question;
  final String highlight;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final int? selectedIndex;
  final bool bookmarked;

  const _QuizQuestion({
    required this.category,
    required this.question,
    required this.highlight,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.selectedIndex,
    this.bookmarked = false,
  });

  _QuizQuestion copyWith({int? selectedIndex, bool? bookmarked}) {
    return _QuizQuestion(
      category: category,
      question: question,
      highlight: highlight,
      options: options,
      correctIndex: correctIndex,
      explanation: explanation,
      selectedIndex: selectedIndex,
      bookmarked: bookmarked ?? this.bookmarked,
    );
  }

  bool get isCorrect => selectedIndex == correctIndex;

  String get selectedAnswer =>
      selectedIndex == null ? 'Not answered' : options[selectedIndex!];

  String get correctAnswer => options[correctIndex];
}

class _QuizScreenState extends State<QuizScreen> {
  static const _totalSeconds = 30 * 60;

  late final Timer _timer;
  int _remainingSeconds = _totalSeconds;
  int _currentIndex = 0;

  final List<_QuizQuestion> _questions = [
    const _QuizQuestion(
      category: 'ENGLISH GRAMMAR',
      question:
          'Which of the following is NOT a type of conjunction in English grammar?',
      highlight: 'NOT',
      options: [
        'Coordinating conjunction',
        'Subordinating conjunction',
        'Participial conjunction',
        'Correlative conjunction',
      ],
      correctIndex: 2,
      explanation:
          'Coordinating, subordinating, and correlative conjunctions are standard conjunction types. Participial conjunction is not usually treated as one of the main conjunction categories.',
      selectedIndex: 2,
    ),
    const _QuizQuestion(
      category: 'PARTS OF SPEECH',
      question: 'Which word in the sentence is used as a noun?',
      highlight: 'noun',
      options: ['Quickly', 'Happiness', 'Blue', 'Because'],
      correctIndex: 1,
      explanation:
          'Happiness names an idea or state, so it functions as a noun.',
    ),
    const _QuizQuestion(
      category: 'VOCABULARY',
      question: 'Choose the closest meaning of the word concise.',
      highlight: 'concise',
      options: ['Brief', 'Confusing', 'Noisy', 'Ancient'],
      correctIndex: 0,
      explanation:
          'Concise means brief and clear, using only the words needed.',
    ),
  ];

  _QuizQuestion get _currentQuestion => _questions[_currentIndex];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _remainingSeconds == 0) return;
      setState(() => _remainingSeconds--);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _selectOption(int index) {
    setState(() {
      _questions[_currentIndex] = _currentQuestion.copyWith(
        selectedIndex: index,
      );
    });
  }

  void _toggleBookmark() {
    setState(() {
      _questions[_currentIndex] = _currentQuestion.copyWith(
        selectedIndex: _currentQuestion.selectedIndex,
        bookmarked: !_currentQuestion.bookmarked,
      );
    });
  }

  void _goBack() {
    if (_currentIndex == 0) return;
    setState(() => _currentIndex--);
  }

  void _goForward() {
    if (_currentIndex == _questions.length - 1) {
      _timer.cancel();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ReviewAnswersScreen(items: _reviewItems),
        ),
      );
      return;
    }

    setState(() => _currentIndex++);
  }

  List<ReviewAnswerItem> get _reviewItems {
    return List.generate(_questions.length, (index) {
      final question = _questions[index];
      return ReviewAnswerItem(
        isCorrect: question.isCorrect,
        bookmarked: question.bookmarked,
        questionNo: index + 1,
        question: question.question,
        userAnswer: question.selectedAnswer,
        correctAnswer: question.correctAnswer,
        explanation: question.explanation,
      );
    });
  }

  String get _timeText {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get _timerProgress => _remainingSeconds / _totalSeconds;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive(context);

    return Scaffold(
      backgroundColor: const Color(0xFF131409),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: CustomPaint(painter: DotPatternPainter(spacing: r.sp24)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(r.sp20, r.h20, r.sp20, r.sp12),
                  child: _TopBar(
                    r: r,
                    currentQuestion: _currentIndex + 1,
                    totalQuestions: _questions.length,
                    timerText: _timeText,
                    timerProgress: _timerProgress,
                    bookmarked: _currentQuestion.bookmarked,
                    onBookmark: _toggleBookmark,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(r.sp20, r.sp8, r.sp20, r.h20),
                    child: Column(
                      children: [
                        _QuestionCard(r: r, question: _currentQuestion),
                        SizedBox(height: r.h30),
                        _OptionsList(
                          r: r,
                          question: _currentQuestion,
                          onSelect: _selectOption,
                        ),
                      ],
                    ),
                  ),
                ),
                _BottomArrows(
                  r: r,
                  canGoBack: _currentIndex > 0,
                  canGoForward: true,
                  onBack: _goBack,
                  onForward: _goForward,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final AppResponsive r;
  final int currentQuestion;
  final int totalQuestions;
  final String timerText;
  final double timerProgress;
  final bool bookmarked;
  final VoidCallback onBookmark;

  const _TopBar({
    required this.r,
    required this.currentQuestion,
    required this.totalQuestions,
    required this.timerText,
    required this.timerProgress,
    required this.bookmarked,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final timerSize = r.wp(11.2);
    final bookmarkSize = r.wp(11.2);

    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PROGRESS',
              style: TextStyle(
                fontSize: r.fs10,
                letterSpacing: 2,
                color: const Color(0xFF91937A),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: r.sp4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$currentQuestion',
                  style: TextStyle(
                    fontSize: r.fs22,
                    color: const Color(0xFFD8EE36),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: r.sp4),
                Text(
                  '/ $totalQuestions',
                  style: TextStyle(
                    color: const Color(0xFF6A6B60),
                    fontSize: r.fs14,
                  ),
                ),
              ],
            ),
          ],
        ),
        const Spacer(),
        Row(
          children: [
            SizedBox(
              width: timerSize,
              height: timerSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: timerSize,
                    height: timerSize,
                    child: CircularProgressIndicator(
                      value: timerProgress,
                      strokeWidth: r.wp(0.8),
                      backgroundColor: const Color(0xFF2A2B1F),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFD8EE36),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.timer_outlined,
                    color: const Color(0xFFD8EE36),
                    size: r.fs16,
                  ),
                ],
              ),
            ),
            SizedBox(width: r.sp8),
            Text(
              timerText,
              style: TextStyle(
                color: const Color(0xFFD8EE36),
                fontSize: r.fs14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: onBookmark,
          child: Container(
            width: bookmarkSize,
            height: bookmarkSize,
            decoration: BoxDecoration(
              color: bookmarked
                  ? const Color(0xFFD8EE36).withOpacity(.12)
                  : Colors.white.withOpacity(.03),
              shape: BoxShape.circle,
            ),
            child: Icon(
              bookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: bookmarked
                  ? const Color(0xFFD8EE36)
                  : const Color(0xFFC7C8AE),
              size: r.fs22,
            ),
          ),
        ),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final AppResponsive r;
  final _QuizQuestion question;

  const _QuestionCard({required this.r, required this.question});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(r.sp20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r.sp28),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1F2015).withOpacity(.95),
            const Color(0xFF131409).withOpacity(.98),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFF91937A).withOpacity(.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.45),
            blurRadius: r.sp28,
            offset: Offset(0, r.h10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: r.sp12,
                    vertical: r.sp8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8EE36).withOpacity(.08),
                    borderRadius: BorderRadius.circular(r.sp28),
                    border: Border.all(
                      color: const Color(0xFFD8EE36).withOpacity(.20),
                    ),
                  ),
                  child: Text(
                    question.category,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: r.fs11,
                      letterSpacing: 2,
                      color: const Color(0xFFD8EE36),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(width: r.sp12),
              Icon(
                Icons.auto_awesome,
                color: const Color(0x55D8EE36),
                size: r.fs18,
              ),
            ],
          ),
          SizedBox(height: r.h20),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: r.fs18,
                height: 1.5,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              children: _questionSpans(question),
            ),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _questionSpans(_QuizQuestion question) {
    final highlight = question.highlight;
    if (highlight.isEmpty || !question.question.contains(highlight)) {
      return [TextSpan(text: question.question)];
    }

    final parts = question.question.split(highlight);
    return [
      TextSpan(text: parts.first),
      TextSpan(
        text: highlight,
        style: const TextStyle(
          color: Color(0xFFD8EE36),
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
        ),
      ),
      TextSpan(text: parts.skip(1).join(highlight)),
    ];
  }
}

class _OptionsList extends StatelessWidget {
  final AppResponsive r;
  final _QuizQuestion question;
  final ValueChanged<int> onSelect;

  const _OptionsList({
    required this.r,
    required this.question,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: question.options.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final selected = question.selectedIndex == index;

        return Padding(
          padding: EdgeInsets.only(bottom: r.sp16),
          child: GestureDetector(
            onTap: () => onSelect(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: EdgeInsets.all(r.sp16),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFD8EE36)
                    : const Color(0xFF1F2015),
                borderRadius: BorderRadius.circular(r.sp20),
                border: Border.all(
                  color: selected
                      ? const Color(0xFFD8EE36)
                      : const Color(0xFF91937A).withOpacity(.12),
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: const Color(0xFFD8EE36).withOpacity(.25),
                          blurRadius: r.sp20,
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Container(
                    width: r.wp(12.2),
                    height: r.h40,
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.black.withOpacity(.08)
                          : const Color(0xFF353629),
                      borderRadius: BorderRadius.circular(r.sp12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      String.fromCharCode(65 + index),
                      style: TextStyle(
                        fontSize: r.fs14,
                        fontWeight: FontWeight.bold,
                        color: selected
                            ? const Color(0xFF2D3400)
                            : const Color(0xFFC7C8AE),
                      ),
                    ),
                  ),
                  SizedBox(width: r.sp16),
                  Expanded(
                    child: Text(
                      question.options[index],
                      style: TextStyle(
                        fontSize: r.fs15,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: selected
                            ? const Color(0xFF2D3400)
                            : Colors.white,
                      ),
                    ),
                  ),
                  if (selected)
                    Icon(
                      Icons.check_circle,
                      color: const Color(0xFF2D3400),
                      size: r.fs22,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BottomArrows extends StatelessWidget {
  final AppResponsive r;
  final bool canGoBack;
  final bool canGoForward;
  final VoidCallback onBack;
  final VoidCallback onForward;

  const _BottomArrows({
    required this.r,
    required this.canGoBack,
    required this.canGoForward,
    required this.onBack,
    required this.onForward,
  });

  @override
  Widget build(BuildContext context) {
    final buttonSize = r.wp(13);

    return Container(
      padding: EdgeInsets.fromLTRB(r.sp20, r.sp12, r.sp20, r.h20),
      decoration: BoxDecoration(
        color: const Color(0xFF131409).withOpacity(.96),
        border: Border(
          top: BorderSide(color: const Color(0xFF91937A).withOpacity(.10)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ArrowButton(
            size: buttonSize,
            enabled: canGoBack,
            icon: Icons.arrow_back_ios_new_rounded,
            activeColor: const Color(0xFFC7C8AE),
            onTap: onBack,
          ),
          _ArrowButton(
            size: buttonSize,
            enabled: canGoForward,
            icon: Icons.arrow_forward_ios_rounded,
            activeColor: const Color(0xFFD8EE36),
            onTap: onForward,
          ),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final double size;
  final bool enabled;
  final IconData icon;
  final Color activeColor;
  final VoidCallback onTap;

  const _ArrowButton({
    required this.size,
    required this.enabled,
    required this.icon,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: IconButton(
        onPressed: enabled ? onTap : null,
        style: IconButton.styleFrom(
          backgroundColor: enabled
              ? Colors.white.withOpacity(.04)
              : Colors.white.withOpacity(.02),
          shape: const CircleBorder(),
        ),
        icon: Icon(
          icon,
          color: enabled ? activeColor : const Color(0xFF4F5144),
          size: size * .42,
        ),
      ),
    );
  }
}

class DotPatternPainter extends CustomPainter {
  final double spacing;

  const DotPatternPainter({required this.spacing});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFD8EE36);

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), spacing * 0.04, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DotPatternPainter oldDelegate) {
    return oldDelegate.spacing != spacing;
  }
}

enum _ReviewFilter { all, correct, wrong, bookmarked }

class ReviewAnswersScreen extends StatefulWidget {
  final List<ReviewAnswerItem> items;

  const ReviewAnswersScreen({super.key, this.items = const []});

  @override
  State<ReviewAnswersScreen> createState() => _ReviewAnswersScreenState();
}

class _ReviewAnswersScreenState extends State<ReviewAnswersScreen> {
  _ReviewFilter _filter = _ReviewFilter.all;

  List<ReviewAnswerItem> get _filteredItems {
    return switch (_filter) {
      _ReviewFilter.all => widget.items,
      _ReviewFilter.correct => widget.items
          .where((item) => item.isCorrect)
          .toList(growable: false),
      _ReviewFilter.wrong => widget.items
          .where((item) => !item.isCorrect)
          .toList(growable: false),
      _ReviewFilter.bookmarked => widget.items
          .where((item) => item.bookmarked)
          .toList(growable: false),
    };
  }

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive(context);
    final filteredItems = _filteredItems;

    return Scaffold(
      backgroundColor: const Color(0xFF131409),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: .03,
              child: CustomPaint(painter: DotPatternPainter(spacing: r.sp28)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _ReviewTopBar(r: r),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      r.sp20,
                      r.h20,
                      r.sp20,
                      r.h100,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FilterPills(
                          r: r,
                          selected: _filter,
                          onChanged: (filter) {
                            setState(() => _filter = filter);
                          },
                        ),
                        SizedBox(height: r.h20),
                        if (filteredItems.isEmpty)
                          _EmptyReviewState(r: r)
                        else
                          ...List.generate(filteredItems.length, (index) {
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index == filteredItems.length - 1
                                    ? 0
                                    : r.sp16,
                              ),
                              child: _ReviewCard(
                                r: r,
                                item: filteredItems[index],
                                totalQuestions: widget.items.length,
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: r.h30,
            right: r.sp20,
            child: _NextModuleButton(r: r),
          ),
        ],
      ),
    );
  }
}

class ReviewAnswerItem {
  final bool isCorrect;
  final bool bookmarked;
  final int questionNo;
  final String question;
  final String userAnswer;
  final String correctAnswer;
  final String explanation;

  const ReviewAnswerItem({
    required this.isCorrect,
    required this.bookmarked,
    required this.questionNo,
    required this.question,
    required this.userAnswer,
    required this.correctAnswer,
    required this.explanation,
  });
}

class _ReviewTopBar extends StatelessWidget {
  final AppResponsive r;

  const _ReviewTopBar({required this.r});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          height: r.h50 + r.h20,
          padding: EdgeInsets.symmetric(horizontal: r.sp20),
          decoration: BoxDecoration(
            color: const Color(0xFF131409).withOpacity(.8),
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFF464834).withOpacity(.3),
              ),
            ),
          ),
          child: Row(
            children: [
              Text(
                'Review Answers',
                style: TextStyle(
                  fontSize: r.fs24,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.search,
                color: Colors.white.withOpacity(.7),
                size: r.fs24,
              ),
              SizedBox(width: r.sp16),
              Container(
                width: r.wp(10.2),
                height: r.wp(10.2),
                decoration: BoxDecoration(
                  color: const Color(0xFF5822B8),
                  borderRadius: BorderRadius.circular(r.sp20),
                  border: Border.all(
                    color: const Color(0xFFD8EE36).withOpacity(.2),
                  ),
                ),
                child: Icon(
                  Icons.person,
                  color: const Color(0xFFD8EE36),
                  size: r.fs20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterPills extends StatelessWidget {
  final AppResponsive r;
  final _ReviewFilter selected;
  final ValueChanged<_ReviewFilter> onChanged;

  const _FilterPills({
    required this.r,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterPill(
            r: r,
            text: 'All',
            active: selected == _ReviewFilter.all,
            onTap: () => onChanged(_ReviewFilter.all),
          ),
          SizedBox(width: r.sp8),
          _FilterPill(
            r: r,
            text: 'Correct',
            active: selected == _ReviewFilter.correct,
            onTap: () => onChanged(_ReviewFilter.correct),
          ),
          SizedBox(width: r.sp8),
          _FilterPill(
            r: r,
            text: 'Wrong',
            active: selected == _ReviewFilter.wrong,
            onTap: () => onChanged(_ReviewFilter.wrong),
          ),
          SizedBox(width: r.sp8),
          _FilterPill(
            r: r,
            text: 'Bookmarked',
            active: selected == _ReviewFilter.bookmarked,
            onTap: () => onChanged(_ReviewFilter.bookmarked),
          ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final AppResponsive r;
  final String text;
  final bool active;
  final VoidCallback onTap;

  const _FilterPill({
    required this.r,
    required this.text,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: r.sp20, vertical: r.sp12),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFFD8EE36)
              : const Color(0xFF131415).withOpacity(.75),
          borderRadius: BorderRadius.circular(r.sp28),
          border: active ? null : Border.all(color: const Color(0xFF353629)),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: const Color(0xFFD8EE36).withOpacity(.15),
                    blurRadius: r.sp16,
                  ),
                ]
              : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active
                ? const Color(0xFF191E00)
                : Colors.white.withOpacity(.7),
            fontWeight: active ? FontWeight.bold : FontWeight.w500,
            letterSpacing: 1,
            fontSize: r.fs12,
          ),
        ),
      ),
    );
  }
}

class _EmptyReviewState extends StatelessWidget {
  final AppResponsive r;

  const _EmptyReviewState({required this.r});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(r.sp20),
      decoration: BoxDecoration(
        color: const Color(0xFF131415).withOpacity(.75),
        borderRadius: BorderRadius.circular(r.sp20),
        border: Border.all(color: const Color(0xFF353629)),
      ),
      child: Text(
        'No questions found for this filter.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white.withOpacity(.7),
          fontSize: r.fs14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final AppResponsive r;
  final ReviewAnswerItem item;
  final int totalQuestions;

  const _ReviewCard({
    required this.r,
    required this.item,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final accent =
        item.isCorrect ? const Color(0xFFD8EE36) : const Color(0xFFFFB4AB);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131415).withOpacity(.8),
        borderRadius: BorderRadius.circular(r.sp20),
        border: Border.all(color: const Color(0xFF353629)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(r.sp20),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(width: r.wp(1.1), color: accent),
            ),
            Padding(
              padding: EdgeInsets.all(r.sp16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'QUESTION ${item.questionNo} OF $totalQuestions',
                        style: TextStyle(
                          color: Colors.white.withOpacity(.55),
                          fontSize: r.fs11,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(
                        item.bookmarked
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: item.bookmarked
                            ? const Color(0xFFD8EE36)
                            : Colors.white54,
                        size: r.fs22,
                      ),
                    ],
                  ),
                  SizedBox(height: r.h20),
                  Text(
                    item.question,
                    style: TextStyle(
                      fontSize: r.fs18,
                      color: Colors.white,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: r.h20),
                  if (!item.isCorrect) ...[
                    _AnswerTile(
                      r: r,
                      icon: Icons.close,
                      title: item.userAnswer,
                      label: 'YOUR ANSWER',
                      color: const Color(0xFFFFB4AB),
                      bgColor: const Color(0xFF93000A).withOpacity(.15),
                      borderColor: const Color(0xFFFFB4AB).withOpacity(.3),
                    ),
                    SizedBox(height: r.sp12),
                  ],
                  _AnswerTile(
                    r: r,
                    icon: Icons.check_circle,
                    title: item.correctAnswer,
                    label: item.isCorrect ? 'CORRECT' : 'CORRECT ANSWER',
                    color: const Color(0xFFD8EE36),
                    bgColor: const Color(0xFFD8EE36).withOpacity(.08),
                    borderColor: const Color(0xFFD8EE36).withOpacity(.3),
                  ),
                  SizedBox(height: r.h20),
                  Divider(color: const Color(0xFF464834).withOpacity(.25)),
                  SizedBox(height: r.sp8),
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: const Color(0xFFD8EE36),
                        size: r.fs18,
                      ),
                      SizedBox(width: r.sp8),
                      Text(
                        'AI EXPLANATION',
                        style: TextStyle(
                          color: const Color(0xFFD8EE36),
                          letterSpacing: 1,
                          fontWeight: FontWeight.bold,
                          fontSize: r.fs12,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.expand_more,
                        color: Colors.white.withOpacity(.6),
                        size: r.fs24,
                      ),
                    ],
                  ),
                  SizedBox(height: r.sp12),
                  Container(
                    padding: EdgeInsets.all(r.sp16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B1C11).withOpacity(.6),
                      borderRadius: BorderRadius.circular(r.sp12),
                      border: Border(
                        left: BorderSide(
                          color: const Color(0xFFD8EE36).withOpacity(.5),
                          width: r.wp(.8),
                        ),
                      ),
                    ),
                    child: Text(
                      item.explanation,
                      style: TextStyle(
                        color: Colors.white.withOpacity(.7),
                        height: 1.7,
                        fontSize: r.fs14,
                      ),
                    ),
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

class _AnswerTile extends StatelessWidget {
  final AppResponsive r;
  final IconData icon;
  final String title;
  final String label;
  final Color color;
  final Color bgColor;
  final Color borderColor;

  const _AnswerTile({
    required this.r,
    required this.icon,
    required this.title,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(r.sp12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(r.sp16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: r.fs22),
          SizedBox(width: r.sp12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: r.fs14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: r.sp8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: r.fs10,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _NextModuleButton extends StatelessWidget {
  final AppResponsive r;

  const _NextModuleButton({required this.r});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.sp16, vertical: r.sp12),
      decoration: BoxDecoration(
        color: const Color(0xFFD8EE36),
        borderRadius: BorderRadius.circular(r.sp28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD8EE36).withOpacity(.25),
            blurRadius: r.sp20,
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            'NEXT MODULE',
            style: TextStyle(
              color: const Color(0xFF191E00),
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              fontSize: r.fs12,
            ),
          ),
          SizedBox(width: r.sp8),
          Icon(
            Icons.arrow_forward,
            color: const Color(0xFF191E00),
            size: r.fs20,
          ),
        ],
      ),
    );
  }
}
