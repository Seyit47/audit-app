import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// 48 px primary action ("Сохранить", `252:26602`): accent, 12 px radius, 50% opacity when disabled.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed, this.loading = false, this.icon});

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final enabled = onPressed != null && !loading;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: enabled ? 1 : 0.5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.accent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: c.accent.withValues(alpha: 0.25), offset: const Offset(0, 2), blurRadius: 4, spreadRadius: -2),
            BoxShadow(color: c.accent.withValues(alpha: 0.25), offset: const Offset(0, 4), blurRadius: 6, spreadRadius: -1),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: enabled ? onPressed : null,
            child: SizedBox(
              height: 48,
              child: Center(
                // The label and the spinner cross-fade instead of swapping.
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: loading
                      ? const SizedBox.square(key: ValueKey('loading'), dimension: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Row(key: const ValueKey('label'), mainAxisSize: MainAxisSize.min, children: [
                          if (icon != null) ...[icon!, const SizedBox(width: 8)],
                          Text(label, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, height: 20 / 14, color: Colors.white)),
                        ]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 48 px secondary action ("Отмена", `252:26599` / `101:2584`).
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.secondaryButtonBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: c.secondaryButtonBorder)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: SizedBox(
          height: 48,
          child: Center(
            child: Text(label, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, height: 20 / 14, color: c.secondaryButtonText)),
          ),
        ),
      ),
    );
  }
}
