import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'adaptive.dart';

/// Several choices from a list (the shop's agents, the agent's districts): the same field as [AppSelect],
/// showing the chosen names ("A, B" or how many), opening the platform's list picker with checkboxes.
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
    final style = Theme.of(context).textTheme.bodyMedium;
    final input = Theme.of(context).inputDecorationTheme;
    final chosen = [
      for (final (v, label) in items)
        if (values.contains(v)) label,
    ];
    final text = chosen.isEmpty
        ? null
        : chosen.length <= 2
        ? chosen.join(', ')
        : l10n.chosenCount(chosen.length);
    return Material(
      color: input.fillColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () async {
          final next = await showOptionsSheet<String>(context, title: title, items: items, selected: values, multi: true, doneLabel: l10n.apply);
          if (next != null) onChanged(next);
        },
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
                  text ?? hint ?? title,
                  overflow: TextOverflow.ellipsis,
                  style: style?.copyWith(color: text == null ? scheme.onSurfaceVariant : scheme.onSurface),
                ),
              ),
              Icon(context.isCupertino ? Icons.expand_more : Icons.arrow_drop_down, size: 24, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
