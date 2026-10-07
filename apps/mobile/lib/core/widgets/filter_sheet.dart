import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'bottom_sheet_card.dart';
import 'adaptive.dart';
import 'buttons.dart';
import 'filter_chips.dart';

/// One group of the filter sheet: a label and its chips. [multi] allows several values.
class FilterSection {
  const FilterSection({required this.key, required this.label, required this.options, this.multi = false});

  final String key;
  final String label;
  final List<ChipOption<String>> options;
  final bool multi;
}

/// Selected values per section key.
typedef FilterValues = Map<String, Set<String>>;

/// The B3 filter bottom sheet: the existing sheet card and chips, configured per screen
/// (status, region, date). Returns the new values, or null when dismissed.
Future<FilterValues?> showFilterSheet(
  BuildContext context, {
  required String title,
  required List<FilterSection> sections,
  required FilterValues values,
  required String applyLabel,
  required String resetLabel,
}) =>
    // iOS: a Cupertino modal popup (iOS motion and dimming); Android: a Material modal bottom sheet.
    context.isCupertino
        ? showCupertinoModalPopup<FilterValues>(
            context: context,
            builder: (_) => Material(
              type: MaterialType.transparency,
              child: _FilterSheet(title: title, sections: sections, initial: values, applyLabel: applyLabel, resetLabel: resetLabel),
            ),
          )
        : showModalBottomSheet<FilterValues>(
            context: context,
            isScrollControlled: true,
            showDragHandle: false,
            backgroundColor: Colors.transparent,
            builder: (_) => _FilterSheet(title: title, sections: sections, initial: values, applyLabel: applyLabel, resetLabel: resetLabel),
          );

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.title, required this.sections, required this.initial, required this.applyLabel, required this.resetLabel});

  final String title;
  final List<FilterSection> sections;
  final FilterValues initial;
  final String applyLabel;
  final String resetLabel;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late final FilterValues values = {for (final s in widget.sections) s.key: {...?widget.initial[s.key]}};

  void toggle(FilterSection s, String v) => setState(() {
        final set = values[s.key]!;
        if (set.contains(v)) {
          set.remove(v);
        } else {
          if (!s.multi) set.clear();
          set.add(v);
        }
      });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return BottomSheetCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
        Text(widget.title, style: AppTextStyles.heading.copyWith(color: c.textPrimary)),
        const SizedBox(height: 12),
        for (final s in widget.sections) ...[
          Text(s.label, style: AppTextStyles.label.copyWith(color: c.textSecondary)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final o in s.options) Pill(label: o.label, tone: o.tone, selected: values[s.key]!.contains(o.value), onTap: () => toggle(s, o.value)),
          ]),
          const SizedBox(height: 16),
        ],
        Row(children: [
          Expanded(child: SecondaryButton(label: widget.resetLabel, onPressed: () => Navigator.pop(context, <String, Set<String>>{}))),
          const SizedBox(width: 12),
          Expanded(child: PrimaryButton(label: widget.applyLabel, onPressed: () => Navigator.pop(context, values))),
        ]),
      ]),
    );
  }
}
