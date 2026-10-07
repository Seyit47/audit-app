import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_icon.dart';

/// Small rounded tag of `246:23300` ("СУПЕРМАРКЕТ", "CL-102").
class Tag extends StatelessWidget {
  const Tag(this.text, {super.key, this.strong = false});

  final String text;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: c.darkAccent, borderRadius: BorderRadius.circular(4)),
      child: Text(strong ? text.toUpperCase() : text,
          style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 10, height: 1.5, letterSpacing: strong ? 0.25 : 0, fontWeight: strong ? FontWeight.w700 : FontWeight.w600, color: strong ? c.accent : c.textSecondary)),
    );
  }
}

/// "icon + text" line of the cards (address, agent, audits, last visit).
class IconLine extends StatelessWidget {
  const IconLine({super.key, required this.icon, required this.text, this.iconSize = const Size(9.33, 11.67), this.iconColor, this.bold});

  final String icon;
  final String text;
  final Size iconSize;
  final Color? iconColor;
  /// Appended in semibold after [text] ("Агент: **Ахмед Джораев**").
  final String? bold;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final style = TextStyle(fontFamily: AppTextStyles.family, fontSize: 12, height: 16 / 12, color: c.textSecondary);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      AppIcon(icon, width: iconSize.width, height: iconSize.height, color: iconColor),
      const SizedBox(width: 6),
      Flexible(
        child: Text.rich(
          TextSpan(text: text, children: [if (bold != null) TextSpan(text: bold, style: style.copyWith(fontWeight: FontWeight.w600, color: c.textPrimary))]),
          maxLines: 1, overflow: TextOverflow.ellipsis, style: style,
        ),
      ),
    ]);
  }
}

/// Card of `246:23300` / `265:27616`: header, title, subtitle, a divided footer, then
/// "Подробнее →", call and navigate.
class ShopCard extends StatelessWidget {
  const ShopCard({
    super.key,
    this.header,
    required this.title,
    this.titleTrailing,
    required this.subtitle,
    required this.footer,
    required this.detailsLabel,
    required this.onDetails,
    this.onCall,
    this.onNavigate,
    this.callLabel,
    this.navigateLabel,
  });

  final Widget? header;
  final String title;
  final Widget? titleTrailing;
  final Widget subtitle;
  final Widget footer;
  final String detailsLabel;
  final VoidCallback onDetails;
  final VoidCallback? onCall;
  final VoidCallback? onNavigate;
  final String? callLabel;
  final String? navigateLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget square(String icon, Size size, String? tip, VoidCallback? onTap) => Tooltip(
          message: tip ?? '',
          child: Material(
            color: c.darkAccent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTap,
              child: SizedBox(width: 36, height: 36, child: Center(child: Opacity(opacity: onTap == null ? 0.4 : 1, child: AppIcon(icon, width: size.width, height: size.height)))),
            ),
          ),
        );
    return Container(
      padding: const EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.cardBorder),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), offset: Offset(0, 1), blurRadius: 2)],
      ),
      child: Stack(clipBehavior: Clip.none, children: [
        // "Overlay+Blur": a soft accent glow in the top-right corner.
        Positioned(
          right: -72, top: -40,
          child: IgnorePointer(
            child: Container(width: 112, height: 112, decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: c.accent.withValues(alpha: 0.05), blurRadius: 40, spreadRadius: 20)])),
          ),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (header != null) ...[header!, const SizedBox(height: 1.5)],
          Padding(
            padding: const EdgeInsets.only(top: 2.5),
            child: Row(children: [
              Flexible(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 16, height: 1.5, fontWeight: FontWeight.w700, color: c.textPrimary))),
              if (titleTrailing != null) ...[const SizedBox(width: 8), titleTrailing!],
            ]),
          ),
          subtitle,
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: c.border))),
            child: footer,
          ),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: Material(
                color: c.accent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: onDetails,
                  child: SizedBox(
                    height: 36,
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(detailsLabel, style: AppTextStyles.label.copyWith(color: Colors.white)),
                      const SizedBox(width: 6),
                      const AppIcon('arrow-right-white', width: 10, height: 10),
                    ]),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            square('call-green', const Size(12.75, 12.75), callLabel, onCall),
            const SizedBox(width: 8),
            square('navigate-arrow', const Size(11.33, 13.46), navigateLabel, onNavigate),
          ]),
        ]),
      ]),
    );
  }
}
