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
  const AppMenuButton({
    super.key,
    required this.choices,
    required this.onSelected,
    required this.child,
    this.tooltip,
    this.enabled = true,
    this.cancelLabel,
    this.header,
  });

  final List<MenuChoice<T>> choices;
  final ValueChanged<T> onSelected;
  final Widget child;
  final String? tooltip;
  final bool enabled;
  final String? cancelLabel;

  /// Shown above the choices and not selectable (e.g. who is signed in).
  final Widget? header;

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
                    title: header ?? (tooltip == null ? null : Text(tooltip!)),
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
        if (header case final header?) ...[PopupMenuItem<T>(enabled: false, child: header), const PopupMenuDivider()],
        for (final ch in choices)
          PopupMenuItem(
            value: ch.value,
            child: Text(ch.label, style: ch.destructive ? TextStyle(color: Theme.of(context).colorScheme.error) : null),
          ),
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
}) => showAdaptiveDialog<T>(
  context: context,
  barrierDismissible: barrierDismissible,
  builder: (dialog) => AlertDialog.adaptive(title: title, content: content, actions: actions(dialog)),
);

/// A single choice from a list, in the platform's own picker: on Android a Material 3 bottom sheet with
/// radio rows (what Android apps use for a short list), on iOS a [CupertinoPicker] wheel in a bottom popup.
/// Shown with the same 44 px field look as the text inputs.
class AppSelect<T> extends StatelessWidget {
  const AppSelect({super.key, required this.value, required this.items, required this.onChanged, this.hint, this.title, this.doneLabel});

  final T? value;
  final List<(T, String)> items;
  final ValueChanged<T?> onChanged;
  final String? hint;

  /// The sheet's heading (the field's label); [hint] when not given.
  final String? title;
  final String? doneLabel;

  @override
  Widget build(BuildContext context) {
    final current = items.where((i) => i.$1 == value).firstOrNull;
    return _SelectField(
      text: current?.$2,
      hint: hint,
      onTap: () async {
        if (context.isCupertino) return _pickCupertino(context, current);
        final picked = await showOptionsSheet<T>(context, title: title ?? hint ?? '', items: items, selected: {?value});
        if (picked != null && picked.firstOrNull != value) onChanged(picked.firstOrNull);
      },
    );
  }

  Future<void> _pickCupertino(BuildContext context, (T, String)? current) async {
    var index = current == null ? 0 : items.indexOf(current);
    final picked = await showCupertinoModalPopup<int>(
      context: context,
      builder: (popup) => Container(
        height: 280,
        color: CupertinoColors.systemBackground.resolveFrom(popup),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: CupertinoButton(onPressed: () => Navigator.pop(popup, index), child: Text(doneLabel ?? MaterialLocalizations.of(popup).okButtonLabel)),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 36,
                  scrollController: FixedExtentScrollController(initialItem: index),
                  onSelectedItemChanged: (i) => index = i,
                  children: [for (final (_, label) in items) Center(child: Text(label))],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (picked != null && items[picked].$1 != value) onChanged(items[picked].$1);
  }
}

/// The 44 px field of [AppSelect] and [AppMultiSelect]: the chosen text (or the hint) and a chevron.
class _SelectField extends StatelessWidget {
  const _SelectField({required this.text, required this.hint, required this.onTap});

  final String? text;
  final String? hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme.bodyMedium;
    final input = Theme.of(context).inputDecorationTheme;
    return Material(
      color: input.fillColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: (input.enabledBorder as OutlineInputBorder?)?.borderSide.color ?? scheme.outline),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text ?? hint ?? '',
                  overflow: TextOverflow.ellipsis,
                  style: style?.copyWith(color: text == null ? scheme.onSurfaceVariant : scheme.onSurface),
                ),
              ),
              Icon(
                context.isCupertino ? CupertinoIcons.chevron_down : Icons.arrow_drop_down,
                size: context.isCupertino ? 16 : 24,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The platform's list picker in a bottom sheet: Material 3 radio rows ([multi] false: the tap picks and
/// closes) or checkbox rows with a Done button. A search field appears for long lists. Returns the chosen
/// values, or null when dismissed.
Future<Set<T>?> showOptionsSheet<T>(
  BuildContext context, {
  required String title,
  required List<(T, String)> items,
  required Set<T> selected,
  bool multi = false,
  String? doneLabel,
}) {
  final sheet = _OptionsSheet<T>(title: title, items: items, selected: selected, multi: multi, doneLabel: doneLabel);
  // iOS: the Cupertino popup motion and dimming; Android: the Material modal bottom sheet.
  return context.isCupertino
      ? showCupertinoModalPopup<Set<T>>(
          context: context,
          builder: (_) => Material(type: MaterialType.transparency, child: sheet),
        )
      : showModalBottomSheet<Set<T>>(context: context, isScrollControlled: true, useSafeArea: true, showDragHandle: true, builder: (_) => sheet);
}

class _OptionsSheet<T> extends StatefulWidget {
  const _OptionsSheet({required this.title, required this.items, required this.selected, required this.multi, required this.doneLabel});

  final String title;
  final List<(T, String)> items;
  final Set<T> selected;
  final bool multi;
  final String? doneLabel;

  @override
  State<_OptionsSheet<T>> createState() => _OptionsSheetState<T>();
}

class _OptionsSheetState<T> extends State<_OptionsSheet<T>> {
  late final Set<T> _chosen = {...widget.selected};
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final needle = _q.trim().toLowerCase();
    final shown = [
      for (final i in widget.items)
        if (needle.isEmpty || i.$2.toLowerCase().contains(needle)) i,
    ];
    final maxHeight = MediaQuery.sizeOf(context).height * 0.7;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
            child: Text(widget.title, style: theme.textTheme.titleMedium),
          ),
          if (widget.items.length > 8)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: SearchBar(
                leading: const Padding(padding: EdgeInsets.only(left: 8), child: Icon(Icons.search)),
                hintText: MaterialLocalizations.of(context).searchFieldLabel,
                elevation: const WidgetStatePropertyAll(0),
                onChanged: (v) => setState(() => _q = v),
              ),
            ),
          Flexible(
            child: RadioGroup<T>(
              groupValue: _chosen.firstOrNull,
              onChanged: (picked) => Navigator.pop(context, {?picked}),
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final (v, label) in shown)
                    if (widget.multi)
                      CheckboxListTile(
                        value: _chosen.contains(v),
                        title: Text(label),
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (on) => setState(() => on == true ? _chosen.add(v) : _chosen.remove(v)),
                      )
                    else
                      RadioListTile<T>(value: v, title: Text(label)),
                ],
              ),
            ),
          ),
          if (widget.multi)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: FilledButton(
                onPressed: () => Navigator.pop(context, _chosen),
                child: Text(widget.doneLabel ?? MaterialLocalizations.of(context).okButtonLabel),
              ),
            ),
        ],
      ),
    );
  }
}
