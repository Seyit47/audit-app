import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'adaptive.dart';
import 'app_icon.dart';

/// Screen header of `83:16884`: back, title, optional count badge and an action on the right.
class AppTopBar extends StatelessWidget {
  const AppTopBar({super.key, this.title, this.titleWidget, this.count, this.action, this.onBack});

  final String? title;

  /// Replaces [title] (e.g. the date and time of the photo detail, `83:18045`).
  final Widget? titleWidget;
  final int? count;
  final Widget? action;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox(
      height: 64,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            SizedBox(
              width: 36,
              height: 44,
              child: OverflowBox(
                maxWidth: 44,
                // The platform's own back control: Material IconButton or CupertinoButton.
                child: context.isCupertino
                    ? CupertinoButton(
                        onPressed: onBack ?? () => context.pop(),
                        padding: EdgeInsets.zero,
                        minimumSize: const Size.square(44),
                        child: Semantics(
                          label: MaterialLocalizations.of(context).backButtonTooltip,
                          child: AppIcon('back', width: 11.77, height: 20, color: c.textPrimary),
                        ),
                      )
                    : IconButton(
                        onPressed: onBack ?? () => context.pop(),
                        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                        icon: AppIcon('back', width: 11.77, height: 20, color: c.textPrimary),
                      ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Row(
                children: [
                  if (titleWidget != null) Flexible(child: titleWidget!),
                  if (title != null)
                    Flexible(
                      child: Text(
                        title!,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: AppTextStyles.title.copyWith(fontSize: 20, height: 1.5, letterSpacing: -0.5, color: c.textPrimary),
                      ),
                    ),
                  if (count != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: c.darkAccent, borderRadius: BorderRadius.circular(999)),
                      child: Text(
                        '$count',
                        style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 11, height: 1.5, fontWeight: FontWeight.w600, color: c.accent),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (action != null) const SizedBox(width: 12),
            ?action,
          ],
        ),
      ),
    );
  }
}

/// The small accent button of the header ("+ Добавить", `83:16911`).
class HeaderButton extends StatelessWidget {
  const HeaderButton({super.key, required this.label, required this.onPressed, this.icon = 'plus'});

  final String label;
  final String? icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[AppIcon(icon!, width: 10.5, height: 10.5), const SizedBox(width: 6)],
        Text(
          label,
          style: const TextStyle(fontFamily: AppTextStyles.family, fontSize: 12, height: 1.5, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ],
    );
    // Small filled button: CupertinoButton on iOS, FilledButton on Android, with the design's accent glow.
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: c.accent.withValues(alpha: 0.22), offset: const Offset(0, 4), blurRadius: 12)],
      ),
      child: context.isCupertino
          ? CupertinoButton.filled(
              onPressed: onPressed,
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              borderRadius: BorderRadius.circular(12),
              child: content,
            )
          : FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                elevation: 0,
              ),
              child: content,
            ),
    );
  }
}
