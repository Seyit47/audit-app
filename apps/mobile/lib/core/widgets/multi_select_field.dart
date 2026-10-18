import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'app_icon.dart';
import 'filter_chips.dart';
import 'filter_sheet.dart';
import 'tap.dart';

/// Several choices from a list: a field like [AppSelect] showing the chosen names; tapping it opens the
/// filter sheet with the choices as chips.
class AppMultiSelect extends StatelessWidget {
  const AppMultiSelect({super.key, required this.title, required this.values, required this.items, required this.onChanged, this.hint});

  final String title;
  final Set<String> values;
  final List<(String, String)> items;
  final ValueChanged<Set<String>> onChanged;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme.bodyMedium;
    final input = Theme.of(context).inputDecorationTheme;
    final chosen = [
      for (final (v, label) in items)
        if (values.contains(v)) label,
    ];
    return Material(
      color: input.fillColor,
      borderRadius: BorderRadius.circular(8),
      child: Pressable(
        borderRadius: BorderRadius.circular(8),
        onTap: () async {
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
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: (input.enabledBorder as OutlineInputBorder?)?.borderSide.color ?? scheme.outline),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  chosen.isEmpty ? hint ?? '' : chosen.join(', '),
                  style: text?.copyWith(color: chosen.isEmpty ? scheme.onSurfaceVariant : scheme.onSurface),
                ),
              ),
              AppIcon('chevron-down', width: 14, height: 14, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
