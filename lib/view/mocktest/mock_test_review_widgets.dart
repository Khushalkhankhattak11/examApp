part of 'mock_test_screen.dart';

class _AnswerReviewTopBar extends StatelessWidget {
  final VoidCallback onBack;

  const _AnswerReviewTopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: _MockTestSetupScreenState._bg.withValues(alpha: .82),
            border: Border(
              bottom: BorderSide(
                color: _MockTestSetupScreenState._border.withValues(alpha: .85),
              ),
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Answer Review',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewScorePanel extends StatelessWidget {
  const _ReviewScorePanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 13, 18, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF101116),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: _MockTestSetupScreenState._border),
      ),
      child: Row(
        children: [
          const Expanded(
            child: _MetricBlock(label: 'ACCURACY', value: '84%'),
          ),
          Container(width: 1, height: 32, color: const Color(0xFF4A4F36)),
          const Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: _MetricBlock(
                label: 'SCORE',
                value: '42/50',
                alignRight: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricBlock extends StatelessWidget {
  final String label;
  final String value;
  final bool alignRight;

  const _MetricBlock({
    required this.label,
    required this.value,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _MockTestSetupScreenState._muted,
            fontSize: 9,
            letterSpacing: 1.7,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: _MockTestSetupScreenState._accent,
            fontSize: 25,
            height: .95,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _ReviewTabs extends StatelessWidget {
  const _ReviewTabs();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: const [
          _ReviewTab(label: 'ALL', selected: true),
          SizedBox(width: 8),
          _ReviewTab(label: 'CORRECT'),
          SizedBox(width: 8),
          _ReviewTab(label: 'INCORRECT'),
          SizedBox(width: 8),
          _ReviewTab(label: 'SKIPPED'),
        ],
      ),
    );
  }
}

class _ReviewTab extends StatelessWidget {
  final String label;
  final bool selected;

  const _ReviewTab({required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected
            ? _MockTestSetupScreenState._accent
            : _MockTestSetupScreenState._tile.withValues(alpha: .62),
        borderRadius: BorderRadius.circular(99),
        border: selected
            ? null
            : Border.all(color: _MockTestSetupScreenState._border),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected
              ? const Color(0xFF1F2700)
              : _MockTestSetupScreenState._muted,
          fontSize: 8,
          letterSpacing: 1.4,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ReviewQuestionCard extends StatelessWidget {
  final _ReviewItem item;

  const _ReviewQuestionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final accent = _stateColor(item.state);
    final isCorrect = item.state == _ReviewState.correct;
    final isIncorrect = item.state == _ReviewState.incorrect;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF101116),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCorrect
              ? _MockTestSetupScreenState._accent.withValues(alpha: .45)
              : _MockTestSetupScreenState._border.withValues(alpha: .9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'QUESTION ${item.number}',
                style: const TextStyle(
                  color: _MockTestSetupScreenState._muted,
                  fontSize: 9,
                  letterSpacing: 1.6,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Icon(
                isCorrect
                    ? Icons.check_circle_outline_rounded
                    : isIncorrect
                    ? Icons.cancel_outlined
                    : Icons.info_outline_rounded,
                color: accent,
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.55,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 13),
          if (item.state == _ReviewState.skipped) ...[
            const _SkippedBadge(),
            const SizedBox(height: 12),
          ],
          if (item.yourAnswer != null)
            _ReviewAnswerBox(
              label: 'YOUR ANSWER',
              value: item.yourAnswer!,
              state: item.state,
              isCorrectAnswer: item.state == _ReviewState.correct,
            ),
          if (item.correctAnswer != null) ...[
            if (item.yourAnswer != null) const SizedBox(height: 9),
            _ReviewAnswerBox(
              label: 'CORRECT ANSWER',
              value: item.correctAnswer!,
              state: _ReviewState.correct,
              isCorrectAnswer: true,
              mutedGreen: item.state == _ReviewState.skipped,
            ),
          ],
          if (item.note != null) ...[
            const SizedBox(height: 13),
            _ReviewNote(text: item.note!),
          ],
        ],
      ),
    );
  }

  Color _stateColor(_ReviewState state) {
    return switch (state) {
      _ReviewState.correct => _MockTestSetupScreenState._accent,
      _ReviewState.incorrect => const Color(0xFFE59A92),
      _ReviewState.skipped => const Color(0xFFC8C9BC),
    };
  }
}

class _ReviewAnswerBox extends StatelessWidget {
  final String label;
  final String value;
  final _ReviewState state;
  final bool isCorrectAnswer;
  final bool mutedGreen;

  const _ReviewAnswerBox({
    required this.label,
    required this.value,
    required this.state,
    required this.isCorrectAnswer,
    this.mutedGreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final wrong = state == _ReviewState.incorrect && !isCorrectAnswer;
    final bg = wrong
        ? const Color(0xFF421019)
        : mutedGreen
        ? const Color(0xFF2A2D1E)
        : _MockTestSetupScreenState._tile.withValues(alpha: .86);
    final border = wrong
        ? const Color(0xFF8B3038)
        : _MockTestSetupScreenState._accent.withValues(alpha: .55);
    final iconColor = wrong
        ? const Color(0xFFE59A92)
        : _MockTestSetupScreenState._accent;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.fromLTRB(13, 8, 13, 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: wrong
                        ? const Color(0xFFE9A6A2)
                        : _MockTestSetupScreenState._accent,
                    fontSize: 7,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            wrong ? Icons.close_rounded : Icons.check_rounded,
            color: iconColor,
            size: 14,
          ),
        ],
      ),
    );
  }
}

class _SkippedBadge extends StatelessWidget {
  const _SkippedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: _MockTestSetupScreenState._tile,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'SKIPPED',
        style: TextStyle(
          color: _MockTestSetupScreenState._muted,
          fontSize: 8,
          letterSpacing: 1,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ReviewNote extends StatelessWidget {
  final String text;

  const _ReviewNote({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF20113A),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF52328B)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            color: Color(0xFFC6A7FF),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFFC6A7FF),
                fontSize: 11,
                height: 1.35,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
