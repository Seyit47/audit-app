import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'adaptive.dart';
import 'app_icon.dart';

/// "Search Bar" of `83:16884` / `101:1985` with the Filters button (B3) and its active count.
class SearchField extends StatelessWidget {
  const SearchField({super.key, required this.hint, required this.onChanged, this.onFilters, this.filtersLabel, this.activeFilters = 0});

  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback? onFilters;
  final String? filtersLabel;
  final int activeFilters;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(dark ? 12 : 8),
        border: Border.all(color: c.cardBorder),
        boxShadow: const [BoxShadow(color: Color(0x0A191B25), offset: Offset(0, 2), blurRadius: 8)],
      ),
      child: Row(children: [
        AppIcon('search', width: 15, height: 15, color: c.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          // iOS: the native search field (clear button, search keyboard); Android: a Material TextField.
          child: context.isCupertino
              ? CupertinoSearchTextField(
                  onChanged: onChanged,
                  placeholder: hint,
                  style: AppTextStyles.body.copyWith(height: 1.21, color: c.textPrimary),
                  placeholderStyle: AppTextStyles.body.copyWith(height: 1.21, color: c.textSecondary),
                  decoration: const BoxDecoration(),
                  prefixIcon: const SizedBox.shrink(),
                  prefixInsets: EdgeInsets.zero,
                  padding: EdgeInsets.zero,
                )
              : TextField(
                  onChanged: onChanged,
                  textInputAction: TextInputAction.search,
                  style: AppTextStyles.body.copyWith(height: 1.21, color: c.textPrimary),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: hint,
                    hintStyle: AppTextStyles.body.copyWith(height: 1.21, color: c.textSecondary),
                  ),
                ),
        ),
        if (onFilters != null) ...[
          const SizedBox(width: 4),
          Badge(
            isLabelVisible: activeFilters > 0,
            label: Text('$activeFilters'),
            backgroundColor: c.accent,
            child: context.isCupertino
                ? CupertinoButton(
                    onPressed: onFilters,
                    color: c.darkAccent,
                    borderRadius: BorderRadius.circular(8),
                    padding: const EdgeInsets.all(6),
                    minimumSize: const Size.square(26),
                    child: Semantics(label: filtersLabel, child: const AppIcon('filters', width: 13.5, height: 13.5)),
                  )
                : IconButton(
                    onPressed: onFilters,
                    tooltip: filtersLabel,
                    icon: const AppIcon('filters', width: 13.5, height: 13.5),
                    style: IconButton.styleFrom(
                      backgroundColor: c.darkAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.all(6),
                      minimumSize: const Size.square(26),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
          ),
        ],
      ]),
    );
  }
}
