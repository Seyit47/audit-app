import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_icon.dart';

/// A district card in the shop lists: name and shop count, today's visits as a bar ("12 из 24 сегодня") and
/// the overdue shops; opening it lists the shops. Admins rename / delete from [trailing] or a long press.
class DistrictTile extends StatelessWidget {
  const DistrictTile({
    super.key,
    required this.name,
    required this.shops,
    required this.onTap,
    this.visitedToday = 0,
    this.overdue = 0,
    this.muted = false,
    this.trailing,
    this.onLongPress,
  });

  final String name;
  final int shops;
  final int visitedToday;
  final int overdue;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  /// "Без района": the shops from before districts.
  final bool muted;

  /// The admin's rename / delete menu.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final done = shops > 0 && visitedToday >= shops;
    final progress = shops == 0 ? 0.0 : (visitedToday / shops).clamp(0.0, 1.0);
    final small = TextStyle(fontFamily: AppTextStyles.family, fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w500, color: c.textSecondary);
    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.cardBorder),
        boxShadow: [BoxShadow(color: c.cardShadow, offset: const Offset(0, 4), blurRadius: 16)],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 14, trailing == null ? 16 : 6, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(color: c.accent6, borderRadius: BorderRadius.circular(10)),
                      child: Center(child: AppIcon('sector', width: 15, height: 15, color: muted ? c.textSecondary : c.accent)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTextStyles.family,
                          fontSize: 16,
                          height: 22 / 16,
                          fontWeight: FontWeight.w700,
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
                        style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 12, height: 1.5, fontWeight: FontWeight.w700, color: c.accent),
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
                if (shops > 0) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: c.accent6,
                      valueColor: AlwaysStoppedAnimation(done ? c.success : c.accent),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: Text(l10n.districtVisitedToday(visitedToday, shops), style: small)),
                      if (overdue > 0) ...[
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(color: c.error, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.districtOverdue(overdue),
                          style: small.copyWith(color: c.error, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
