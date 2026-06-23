part of 'mock_test_screen.dart';

class _QuestionPanel extends StatelessWidget {
  final _MockQuestion question;
  final VoidCallback onFlag;
  final VoidCallback onSave;
  final ValueChanged<int> onSelect;
  final bool saved;
  final bool saving;

  const _QuestionPanel({
    required this.question,
    required this.onFlag,
    required this.onSave,
    required this.onSelect,
    required this.saved,
    required this.saving,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 26),
      decoration: BoxDecoration(
        color: _MockTestSetupScreenState._surface.withValues(alpha: .72),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _MockTestSetupScreenState._border.withValues(alpha: .82),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _MockTestSetupScreenState._purple.withValues(
                    alpha: .9,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  question.subject.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFFC7A8FF),
                    fontSize: 8,
                    letterSpacing: 1.8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: saving ? null : onSave,
                child: Row(
                  children: [
                    if (saving)
                      const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _MockTestSetupScreenState._accent,
                        ),
                      )
                    else
                      Icon(
                        saved
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: saved
                            ? _MockTestSetupScreenState._accent
                            : _MockTestSetupScreenState._muted,
                        size: 18,
                      ),
                    const SizedBox(width: 5),
                    Text(
                      saved ? 'SAVED' : 'SAVE',
                      style: TextStyle(
                        color: saved
                            ? _MockTestSetupScreenState._accent
                            : _MockTestSetupScreenState._muted,
                        fontSize: 8,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              GestureDetector(
                onTap: onFlag,
                child: Row(
                  children: [
                    Icon(
                      question.flagged
                          ? Icons.flag_rounded
                          : Icons.flag_outlined,
                      color: question.flagged
                          ? _MockTestSetupScreenState._accent
                          : _MockTestSetupScreenState._muted,
                      size: 17,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'FLAG FOR REVIEW',
                      style: TextStyle(
                        color: _MockTestSetupScreenState._muted,
                        fontSize: 8,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            question.question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              height: 1.48,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 24),
          ...List.generate(question.options.length, (index) {
            return _AnswerOption(
              letter: String.fromCharCode(65 + index),
              text: question.options[index],
              selected: question.selectedIndex == index,
              onTap: () => onSelect(index),
            );
          }),
        ],
      ),
    );
  }
}

class _AnswerOption extends StatelessWidget {
  final String letter;
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _AnswerOption({
    required this.letter,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: const BoxConstraints(minHeight: 55),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? _MockTestSetupScreenState._accent.withValues(alpha: .08)
                : _MockTestSetupScreenState._bg.withValues(alpha: .4),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? _MockTestSetupScreenState._accent
                  : _MockTestSetupScreenState._border.withValues(alpha: .85),
              width: selected ? 1.8 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: _MockTestSetupScreenState._accent.withValues(
                        alpha: .16,
                      ),
                      blurRadius: 14,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? _MockTestSetupScreenState._accent
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: selected
                        ? _MockTestSetupScreenState._accent
                        : _MockTestSetupScreenState._border,
                  ),
                ),
                child: Text(
                  letter,
                  style: TextStyle(
                    color: selected
                        ? const Color(0xFF303700)
                        : _MockTestSetupScreenState._muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: selected
                        ? _MockTestSetupScreenState._accent
                        : _MockTestSetupScreenState._muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_circle_outline_rounded,
                  color: _MockTestSetupScreenState._accent,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
