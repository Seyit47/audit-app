import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_icon.dart';

/// KPI tile of `265:27616` ("Всего в штате 48 чел. ✓ 92.3% в смене").
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.iconSize,
    this.iconBg,
    this.footer,
    this.footerIcon,
    this.footerIconSize,
    this.footerColor,
  });

  final String label;
  final String value;
  final String unit;
  final String icon;
  final Size iconSize;
  final Color? iconBg;
  final String? footer;
  final String? footerIcon;
  final Size? footerIconSize;
  final Color? footerColor;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      height: 117,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.cardBorder),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), offset: Offset(0, 1), blurRadius: 2)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w500, color: c.textSecondary),
                ),
              ),
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: iconBg ?? c.accent6, borderRadius: BorderRadius.circular(8)),
                child: AppIcon(icon, width: iconSize.width, height: iconSize.height),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: AppTextStyles.title.copyWith(height: 32 / 24, color: c.textPrimary),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    unit,
                    style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 12, height: 16 / 12, color: c.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 3.5),
              if (footer != null)
                Row(
                  children: [
                    if (footerIcon != null) ...[
                      AppIcon(footerIcon!, width: footerIconSize!.width, height: footerIconSize!.height, color: footerColor),
                      const SizedBox(width: 2),
                    ],
                    Flexible(
                      child: Text(
                        footer!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTextStyles.family,
                          fontSize: 11,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                          color: footerColor ?? c.success,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
