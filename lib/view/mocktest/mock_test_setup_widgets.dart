part of 'mock_test_screen.dart';

class _SetupTopBar extends StatelessWidget {
  final VoidCallback onBack;

  const _SetupTopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 14, 12),
          decoration: BoxDecoration(
            color: _MockTestSetupScreenState._bg.withValues(alpha: .76),
            border: Border(
              bottom: BorderSide(
                color: _MockTestSetupScreenState._border.withValues(alpha: .45),
              ),
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: _MockTestSetupScreenState._accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'ExamAce',
                style: TextStyle(
                  color: _MockTestSetupScreenState._accent,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 16),
              const _Avatar(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExamHeader extends StatelessWidget {
  final String timeText;

  const _ExamHeader({required this.timeText});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          decoration: BoxDecoration(
            color: _MockTestSetupScreenState._bg.withValues(alpha: .78),
            border: Border(
              bottom: BorderSide(
                color: _MockTestSetupScreenState._border.withValues(alpha: .45),
              ),
            ),
          ),
          child: Row(
            children: [
              const Text(
                'ExamAce',
                style: TextStyle(
                  color: _MockTestSetupScreenState._accent,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'TIME REMAINING',
                    style: TextStyle(
                      color: _MockTestSetupScreenState._accent,
                      fontSize: 8,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    timeText,
                    style: const TextStyle(
                      color: _MockTestSetupScreenState._accent,
                      fontSize: 20,
                      height: .95,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              const _Avatar(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF223B3E), Color(0xFF7C4A25)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: _MockTestSetupScreenState._accent.withValues(alpha: .25),
          width: 1.5,
        ),
      ),
      child: const Icon(Icons.person, color: Colors.white70, size: 18),
    );
  }
}

class _SetupCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  const _SetupCard({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _MockTestSetupScreenState._surface.withValues(alpha: .66),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: _MockTestSetupScreenState._border.withValues(alpha: .82),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _MockTestSetupScreenState._accent, size: 20),
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(
                  color: _MockTestSetupScreenState._muted,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              ?trailing,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  final String label;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  const _ChoiceTile({
    required this.label,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: compact ? 44 : null,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? _MockTestSetupScreenState._tile
              : _MockTestSetupScreenState._tile.withValues(alpha: .7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? _MockTestSetupScreenState._accent
                : Colors.white.withValues(alpha: .03),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: selected
                ? _MockTestSetupScreenState._accent
                : _MockTestSetupScreenState._muted,
            fontSize: 13,
            letterSpacing: selected ? 0 : .6,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _SegmentedMode extends StatelessWidget {
  final bool timedMode;
  final ValueChanged<bool> onChanged;

  const _SegmentedMode({required this.timedMode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 31,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: _MockTestSetupScreenState._tile,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        children: [
          _ModePill(
            label: 'Timed',
            selected: timedMode,
            onTap: () => onChanged(true),
          ),
          _ModePill(
            label: 'Zen Mode',
            selected: !timedMode,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _ModePill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? _MockTestSetupScreenState._accent
                : Colors.transparent,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? const Color(0xFF202600)
                  : _MockTestSetupScreenState._muted,
              fontSize: 10,
              letterSpacing: 1.6,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _SubjectRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SubjectRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: _MockTestSetupScreenState._tile.withValues(alpha: .62),
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: Colors.white.withValues(alpha: .025)),
          ),
          child: Row(
            children: [
              Icon(
                _subjectIcon(label),
                color: const Color(0xFFC4C5B0),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _MockTestSetupScreenState._muted,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: selected
                      ? _MockTestSetupScreenState._accent
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: selected
                        ? _MockTestSetupScreenState._accent
                        : _MockTestSetupScreenState._border,
                  ),
                ),
                child: selected
                    ? const Icon(
                        Icons.check_rounded,
                        color: Color(0xFF303700),
                        size: 14,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _subjectIcon(String label) {
    if (label.contains('Knowledge')) return Icons.public_rounded;
    if (label.contains('Pakistan')) return Icons.flag_outlined;
    if (label.contains('English')) return Icons.translate_rounded;
    return Icons.calculate_outlined;
  }
}
