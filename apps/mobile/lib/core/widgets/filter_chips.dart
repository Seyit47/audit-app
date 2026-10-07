import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'adaptive.dart';

enum ChipTone { normal, error }

class ChipOption<T> {
  const ChipOption(this.value, this.label, {this.tone = ChipTone.normal});

  final T value;
  final String label;
  final ChipTone tone;
}

/// "Horizontally Scrollable Pills" of `83:16884` / `101:1985`.
class FilterChips<T> extends StatelessWidget {
  const FilterChips({super.key, required this.options, required this.selected, required this.onSelected});

  final List<ChipOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        child: Row(children: [
          for (final (i, o) in options.indexed) ...[
            if (i > 0) const SizedBox(width: 8),
            Pill(label: o.label, selected: o.value == selected, tone: o.tone, onTap: () { if (o.value != selected) onSelected(o.value); }), // re-tapping the selected chip does nothing
          ],
        ]),
      );
}

class Pill extends StatelessWidget {
  const Pill({super.key, required this.label, required this.selected, required this.onTap, this.tone = ChipTone.normal});

  final String label;
  final bool selected;
  final ChipTone tone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final error = tone == ChipTone.error && !selected;
    final fg = selected ? Colors.white : error ? c.error : c.textSecondary;
    final label = Row(mainAxisSize: MainAxisSize.min, children: [
      if (error) ...[Container(width: 6, height: 6, decoration: BoxDecoration(color: c.error, shape: BoxShape.circle)), const SizedBox(width: 4)],
      Text(this.label, style: AppTextStyles.label.copyWith(height: 1.5, color: fg)),
    ]);
    if (context.isCupertino) {
      // iOS has no chips: a capsule CupertinoButton with the same colors.
      return Semantics(
        selected: selected,
        button: true,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 30,
          decoration: BoxDecoration(
            color: selected ? c.accent : error ? c.errorBg : c.chipBg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? Colors.transparent : error ? c.errorStroke.withValues(alpha: 0.3) : c.chipBorder),
          ),
          child: CupertinoButton(onPressed: onTap, padding: const EdgeInsets.symmetric(horizontal: 12), minimumSize: const Size(0, 30), child: label),
        ),
      );
    }
    return ChoiceChip(
      label: label,
      selected: selected,
      onSelected: (_) => onTap(),
      backgroundColor: error ? c.errorBg : null,
      side: selected ? BorderSide.none : error ? BorderSide(color: c.errorStroke.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.3 : 0)) : null,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
