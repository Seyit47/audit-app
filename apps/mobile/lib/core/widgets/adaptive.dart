import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Material widgets on Android, Cupertino widgets on iOS (and macOS).
///
/// Uses the theme's platform rather than the OS directly, so tests and debug tools can render either.
extension AdaptivePlatform on BuildContext {
  bool get isCupertino => switch (Theme.of(this).platform) {
        TargetPlatform.iOS || TargetPlatform.macOS => true,
        _ => false,
      };
}

/// A choice in an [AppMenuButton].
class MenuChoice<T> {
  const MenuChoice(this.value, this.label, {this.destructive = false});

  final T value;
  final String label;
  final bool destructive;
}

/// An action menu: the Material popup menu anchored to [child] on Android, a [CupertinoActionSheet]
/// rising from the bottom on iOS.
class AppMenuButton<T> extends StatelessWidget {
  const AppMenuButton({super.key, required this.choices, required this.onSelected, required this.child, this.tooltip, this.enabled = true, this.cancelLabel});

  final List<MenuChoice<T>> choices;
  final ValueChanged<T> onSelected;
  final Widget child;
  final String? tooltip;
  final bool enabled;
  final String? cancelLabel;

  @override
  Widget build(BuildContext context) {
    if (context.isCupertino) {
      return CupertinoButton(
        onPressed: !enabled
            ? null
            : () async {
                final picked = await showCupertinoModalPopup<T>(
                  context: context,
                  builder: (sheet) => CupertinoActionSheet(
                    title: tooltip == null ? null : Text(tooltip!),
                    actions: [
                      for (final ch in choices)
                        CupertinoActionSheetAction(isDestructiveAction: ch.destructive, onPressed: () => Navigator.pop(sheet, ch.value), child: Text(ch.label)),
                    ],
                    cancelButton: CupertinoActionSheetAction(
                      isDefaultAction: true,
                      onPressed: () => Navigator.pop(sheet),
                      child: Text(cancelLabel ?? CupertinoLocalizations.of(sheet).cancelButtonLabel),
                    ),
                  ),
                );
                if (picked != null) onSelected(picked);
              },
        padding: EdgeInsets.zero,
        minimumSize: const Size.square(36),
        child: child,
      );
    }
    return PopupMenuButton<T>(
      enabled: enabled,
      tooltip: tooltip,
      onSelected: onSelected,
      position: PopupMenuPosition.under,
      itemBuilder: (_) => [
        for (final ch in choices)
          PopupMenuItem(value: ch.value, child: Text(ch.label, style: ch.destructive ? TextStyle(color: Theme.of(context).colorScheme.error) : null)),
      ],
      child: child,
    );
  }
}

/// A dialog action: [TextButton] on Android, [CupertinoDialogAction] on iOS.
class AppDialogAction extends StatelessWidget {
  const AppDialogAction({super.key, required this.label, required this.onPressed, this.primary = false});

  final String label;
  final VoidCallback onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    if (context.isCupertino) return CupertinoDialogAction(isDefaultAction: primary, onPressed: onPressed, child: Text(label));
    return primary ? FilledButton(onPressed: onPressed, child: Text(label)) : TextButton(onPressed: onPressed, child: Text(label));
  }
}

/// [AlertDialog] on Android, [CupertinoAlertDialog] on iOS.
Future<T?> showAppDialog<T>({
  required BuildContext context,
  required Widget title,
  required Widget content,
  required List<Widget> Function(BuildContext dialog) actions,
  bool barrierDismissible = true,
}) =>
    showAdaptiveDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialog) => AlertDialog.adaptive(title: title, content: content, actions: actions(dialog)),
    );

/// A single choice from a list: Material dropdown on Android, a [CupertinoPicker] wheel in a bottom popup
/// on iOS. Shown with the same 44 px field look as the text inputs.
class AppSelect<T> extends StatelessWidget {
  const AppSelect({super.key, required this.value, required this.items, required this.onChanged, this.hint, this.doneLabel});

  final T? value;
  final List<(T, String)> items;
  final ValueChanged<T?> onChanged;
  final String? hint;
  final String? doneLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme.bodyMedium;
    if (!context.isCupertino) {
      return DropdownButtonFormField<T>(
        initialValue: value,
        isExpanded: true,
        hint: hint == null ? null : Text(hint!, style: text?.copyWith(color: scheme.onSurfaceVariant)),
        items: [for (final (v, label) in items) DropdownMenuItem(value: v, child: Text(label, overflow: TextOverflow.ellipsis))],
        onChanged: onChanged,
      );
    }
    final current = items.where((i) => i.$1 == value).firstOrNull;
    final input = Theme.of(context).inputDecorationTheme;
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size(0, 44),
      onPressed: () async {
        var index = current == null ? 0 : items.indexOf(current);
        final picked = await showCupertinoModalPopup<int>(
          context: context,
          builder: (popup) => Container(
            height: 280,
            color: CupertinoColors.systemBackground.resolveFrom(popup),
            child: SafeArea(
              top: false,
              child: Column(children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: CupertinoButton(
                    onPressed: () => Navigator.pop(popup, index),
                    child: Text(doneLabel ?? MaterialLocalizations.of(popup).okButtonLabel),
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 36,
                    scrollController: FixedExtentScrollController(initialItem: index),
                    onSelectedItemChanged: (i) => index = i,
                    children: [for (final (_, label) in items) Center(child: Text(label))],
                  ),
                ),
              ]),
            ),
          ),
        );
        if (picked != null && items[picked].$1 != value) onChanged(items[picked].$1);
      },
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: input.fillColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: (input.enabledBorder as OutlineInputBorder?)?.borderSide.color ?? scheme.outline),
        ),
        child: Row(children: [
          Expanded(
            child: Text(
              current?.$2 ?? hint ?? '',
              overflow: TextOverflow.ellipsis,
              style: text?.copyWith(color: current == null ? scheme.onSurfaceVariant : scheme.onSurface),
            ),
          ),
          Icon(CupertinoIcons.chevron_down, size: 16, color: scheme.onSurfaceVariant),
        ]),
      ),
    );
  }
}
