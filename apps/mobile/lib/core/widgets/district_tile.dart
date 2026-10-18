import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_icon.dart';
import 'tap.dart';

/// A district in the shop lists: its name and number of shops; opening it lists them.
class DistrictTile extends StatelessWidget {
  const DistrictTile({super.key, required this.name, required this.shops, required this.onTap, this.muted = false, this.trailing});

  final String name;
  final int shops;
  final VoidCallback onTap;

  /// "Без района": the shops from before districts.
  final bool muted;

  /// The admin's rename / delete menu.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.cardBorder),
        boxShadow: [BoxShadow(color: c.cardShadow, offset: const Offset(0, 4), blurRadius: 16)],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Pressable(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.fromLTRB(14, 12, trailing == null ? 14 : 4, 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: c.accent6, borderRadius: BorderRadius.circular(10)),
                  child: Center(child: AppIcon('sector', width: 16, height: 16, color: muted ? c.textSecondary : c.accent)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTextStyles.family,
                      fontSize: 15,
                      height: 20 / 15,
                      fontWeight: FontWeight.w600,
                      color: muted ? c.textSecondary : c.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: c.darkAccent, borderRadius: BorderRadius.circular(999)),
                  child: Text(
                    '$shops',
                    style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 11, height: 1.5, fontWeight: FontWeight.w600, color: c.accent),
                  ),
                ),
                if (trailing != null)
                  trailing!
                else ...[
                  const SizedBox(width: 6),
                  AppIcon('chevron-right-accent', width: 16, height: 16, color: c.textSecondary),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
