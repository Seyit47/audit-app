import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'adaptive.dart';

/// 48 px primary action ("Сохранить", `252:26602`): a Material [FilledButton] on Android and a filled
/// [CupertinoButton] on iOS, both accent with a 12 px radius (styling in AppTheme).
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed, this.loading = false, this.icon});

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    // The label and the platform's progress indicator cross-fade instead of swapping.
    final content = AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: loading
          ? const SizedBox.square(key: ValueKey('loading'), dimension: 20, child: CircularProgressIndicator.adaptive(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
          : Row(key: const ValueKey('label'), mainAxisSize: MainAxisSize.min, children: [
              if (icon != null) ...[icon!, const SizedBox(width: 8)],
              Text(label),
            ]),
    );
    if (context.isCupertino) {
      return CupertinoButton.filled(
        onPressed: enabled ? onPressed : null,
        minimumSize: const Size(64, 48),
        borderRadius: BorderRadius.circular(12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: DefaultTextStyle.merge(style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, color: Colors.white), child: content),
      );
    }
    return FilledButton(onPressed: enabled ? onPressed : null, child: content);
  }
}

/// 48 px secondary action ("Отмена", `252:26599` / `101:2584`): Material [OutlinedButton] on Android,
/// a bordered [CupertinoButton] on iOS.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (context.isCupertino) {
      final c = context.colors;
      return DecoratedBox(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: c.secondaryButtonBorder)),
        child: CupertinoButton(
          onPressed: onPressed,
          color: c.secondaryButtonBg,
          minimumSize: const Size(64, 48),
          borderRadius: BorderRadius.circular(12),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(label, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, color: c.secondaryButtonText)),
        ),
      );
    }
    return OutlinedButton(onPressed: onPressed, child: Text(label));
  }
}
