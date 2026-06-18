part of 'mock_test_screen.dart';

class _AiTip extends StatelessWidget {
  final String text;

  const _AiTip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _MockTestSetupScreenState._surface.withValues(alpha: .75),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _MockTestSetupScreenState._accent.withValues(alpha: .25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFE6EF79), Color(0xFF8151E6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFF222510),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: _MockTestSetupScreenState._muted,
                  fontSize: 12,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
                children: [
                  const TextSpan(
                    text: 'AI Tip: ',
                    style: TextStyle(
                      color: _MockTestSetupScreenState._accent,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  TextSpan(text: text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmitDialog extends StatelessWidget {
  final int answered;
  final int total;
  final int flagged;
  final VoidCallback onSubmit;

  const _SubmitDialog({
    required this.answered,
    required this.total,
    required this.flagged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.fromLTRB(28, 30, 28, 34),
        decoration: BoxDecoration(
          color: _MockTestSetupScreenState._bg.withValues(alpha: .96),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: _MockTestSetupScreenState._border.withValues(alpha: .95),
          ),
          boxShadow: const [
            BoxShadow(
              color: _MockTestSetupScreenState._accent,
              blurRadius: 0,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: const BoxDecoration(
                color: _MockTestSetupScreenState._purple,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_outlined,
                color: _MockTestSetupScreenState._accent,
                size: 30,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Submit Examination?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Verify your progress before concluding the\nsession.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _MockTestSetupScreenState._muted,
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: _SubmitStat(
                    label: 'ANSWERED',
                    value: '$answered',
                    suffix: '/$total',
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: _SubmitStat(
                    label: 'FLAGGED',
                    value: '$flagged',
                    icon: Icons.flag_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF2B120B),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF6A2B17)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFFFA49A),
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Warning: ',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          TextSpan(
                            text:
                                'You cannot change your answers after submission. All marked responses will be locked.',
                          ),
                        ],
                      ),
                      style: TextStyle(
                        color: Color(0xFFE6B7AF),
                        fontSize: 12,
                        height: 1.15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _PrimaryButton(
              label: 'Submit Now',
              icon: Icons.send_rounded,
              onTap: onSubmit,
            ),
            const SizedBox(height: 22),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_back_rounded,
                    color: _MockTestSetupScreenState._muted,
                    size: 17,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Back to Test',
                    style: TextStyle(
                      color: _MockTestSetupScreenState._muted,
                      fontSize: 11,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w900,
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

class _SubmitStat extends StatelessWidget {
  final String label;
  final String value;
  final String? suffix;
  final IconData? icon;

  const _SubmitStat({
    required this.label,
    required this.value,
    this.suffix,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.fromLTRB(15, 11, 12, 10),
      decoration: BoxDecoration(
        color: _MockTestSetupScreenState._tile,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _MockTestSetupScreenState._muted,
              fontSize: 8,
              letterSpacing: 1.3,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  height: .85,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (suffix != null) ...[
                const SizedBox(width: 4),
                Text(
                  suffix!,
                  style: const TextStyle(
                    color: _MockTestSetupScreenState._muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
              if (icon != null) ...[
                const SizedBox(width: 6),
                Icon(icon, color: _MockTestSetupScreenState._accent, size: 17),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _MockTestSetupScreenState._accent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: _MockTestSetupScreenState._accent.withValues(alpha: .18),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF243000), size: 22),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF243000),
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool enabled;
  final bool accent;
  final bool reverseIcon;
  final VoidCallback onTap;

  const _NavButton({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.onTap,
    this.accent = false,
    this.reverseIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final fg = accent
        ? const Color(0xFF243000)
        : _MockTestSetupScreenState._muted;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : .42,
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: accent
                ? _MockTestSetupScreenState._accent
                : _MockTestSetupScreenState._tile,
            borderRadius: BorderRadius.circular(8),
            border: accent
                ? null
                : Border.all(color: _MockTestSetupScreenState._border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: reverseIcon
                ? [
                    Text(
                      label,
                      style: TextStyle(
                        color: fg,
                        fontSize: 9,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Icon(icon, color: fg, size: 17),
                  ]
                : [
                    Icon(icon, color: fg, size: 17),
                    const SizedBox(width: 7),
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: fg,
                          fontSize: 9,
                          letterSpacing: 1.4,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
          ),
        ),
      ),
    );
  }
}

class _GridBackground extends StatelessWidget {
  final double opacity;

  const _GridBackground({required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: CustomPaint(painter: _DotGridPainter(), size: Size.infinite),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = _MockTestSetupScreenState._accent;
    const spacing = 23.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
