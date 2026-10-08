import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'tap.dart';

/// A shimmering placeholder block shown while content loads.
class Bone extends StatefulWidget {
  const Bone({super.key, this.width, this.height = 12, this.radius = 6});

  final double? width;
  final double height;
  final double radius;

  @override
  State<Bone> createState() => _BoneState();
}

class _BoneState extends State<Bone> with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final base = c.secondaryBg;
    final light = Color.lerp(base, c.card, 0.6)!;
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (context, _) {
        final t = _shimmer.value * 3 - 1; // sweeps from left (-1) to right (2)
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(begin: Alignment(t - 1, 0), end: Alignment(t + 1, 0), colors: [base, light, base]),
          ),
        );
      },
    );
  }
}

/// Card-shaped placeholders for a loading list: the same frame as the real cards, so nothing jumps
/// when the content arrives.
class CardListSkeleton extends StatelessWidget {
  const CardListSkeleton({super.key, this.count = 4, this.lines = 2});

  final int count;
  final int lines;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      children: [
        for (var i = 0; i < count; i++) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.cardBorder),
            ),
            child: Row(
              children: [
                const Bone(width: 44, height: 44, radius: 12),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Bone(width: 160, height: 14),
                      for (var l = 1; l < lines + 1; l++) ...[const SizedBox(height: 8), Bone(width: l.isOdd ? 220 : 120, height: 10)],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

/// A failed load: the message and a retry button (pull to refresh also works where available).
class LoadErrorView extends StatelessWidget {
  const LoadErrorView({super.key, required this.onRetry, this.padding = const EdgeInsets.all(24)});

  final VoidCallback onRetry;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.loadError,
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: AppTextStyles.family, color: c.textSecondary),
          ),
          const SizedBox(height: 8),
          TextLink(
            onTap: onRetry,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(l10n.retry, style: AppTextStyles.label.copyWith(color: c.accent)),
            ),
          ),
        ],
      ),
    );
  }
}
