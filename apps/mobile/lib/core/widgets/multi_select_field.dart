import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_icon.dart';
import 'filter_chips.dart';
import 'filter_sheet.dart';
import 'tap.dart';

/// Several choices from a list (the shop's agents): the chosen ones as chips, each removable, and an "add"
/// chip that opens the filter sheet with every choice.
class AppMultiSelect extends StatelessWidget {
  const AppMultiSelect({super.key, required this.title, required this.values, required this.items, required this.onChanged, this.hint});

  final String title;
  final Set<String> values;
  final List<(String, String)> items;
  final ValueChanged<Set<String>> onChanged;
  final String? hint;

  Future<void> _pick(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final next = await showFilterSheet(
      context,
      title: title,
      applyLabel: l10n.apply,
      resetLabel: l10n.reset,
      values: {'v': values},
      sections: [
        FilterSection(key: 'v', label: title, multi: true, options: [for (final (v, label) in items) ChipOption(v, label)]),
      ],
    );
    if (next != null) onChanged(next['v'] ?? const {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final chosen = [
      for (final (v, label) in items)
        if (values.contains(v)) (v, label),
    ];
    final chip = TextStyle(fontFamily: AppTextStyles.family, fontSize: 13, height: 18 / 13, fontWeight: FontWeight.w600, color: c.accent);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final (v, label) in chosen)
          Material(
            color: c.darkAccent,
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 5, 4, 5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: chip),
                  const SizedBox(width: 4),
                  Tooltip(
                    message: l10n.remove,
                    child: Pressable(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () => onChanged({...values}..remove(v)),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: Center(child: AppIcon('field-clear', width: 18, height: 18, color: c.accent)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        Material(
          color: Colors.transparent,
          shape: StadiumBorder(side: BorderSide(color: c.cardBorder)),
          child: Pressable(
            borderRadius: BorderRadius.circular(999),
            onTap: () => _pick(context),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 14, 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppIcon('plus', width: 10, height: 10, color: c.textSecondary),
                  const SizedBox(width: 6),
                  Text(chosen.isEmpty ? (hint ?? title) : l10n.add, style: chip.copyWith(color: c.textSecondary)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
