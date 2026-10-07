import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_icon.dart';
import 'tap.dart';

// Home tiles of 83:16786 / 101:1880. Gradient alignments convert the Figma handle positions.

/// "Начать аудит": the primary action tile.
class HomeHeroTile extends StatelessWidget {
  const HomeHeroTile({super.key, required this.badge, required this.title, required this.subtitle, required this.onTap});

  final String badge;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final glassBorder = dark ? c.white5 : Colors.white.withValues(alpha: 0.3);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.heroBorder),
        gradient: LinearGradient(begin: const Alignment(-0.7, -1.82), end: const Alignment(0.7, 1.82), colors: c.heroGradient),
        boxShadow: [
          BoxShadow(color: c.accent.withValues(alpha: 0.25), offset: const Offset(0, 8), blurRadius: 10, spreadRadius: -6),
          BoxShadow(color: c.accent.withValues(alpha: 0.25), offset: const Offset(0, 20), blurRadius: 25, spreadRadius: -5),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Pressable(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(children: [
              _Glass(size: 56, radius: 16, border: glassBorder, child: const AppIcon('home-audit', width: 25, height: 22.5)),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(badge.toUpperCase(), style: const TextStyle(fontFamily: AppTextStyles.family, fontSize: 10, height: 1.5, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: Colors.white)),
                    ),
                    const SizedBox(height: 3.3),
                    Text(title, style: const TextStyle(fontFamily: AppTextStyles.family, fontSize: 21, height: 1.25, fontWeight: FontWeight.w800, letterSpacing: -0.52, color: Colors.white)),
                    Text(subtitle, style: const TextStyle(fontFamily: AppTextStyles.family, fontSize: 12, height: 16.5 / 12, fontWeight: FontWeight.w500, color: Colors.white)),
                  ]),
                ),
              ),
              const SizedBox(width: 16),
              _Glass(size: 44, radius: 9999, border: glassBorder, child: const AppIcon('arrow-white', width: 13.33, height: 13.33)),
            ]),
          ),
        ),
      ),
    );
  }
}

class _Glass extends StatelessWidget {
  const _Glass({required this.size, required this.radius, required this.border, required this.child});

  final double size;
  final double radius;
  final Color border;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: child,
      );
}

/// "Мои магазины" / "Карта" / "Галерея" tiles.
class HomeActionTile extends StatelessWidget {
  const HomeActionTile({
    super.key,
    required this.icon,
    required this.iconSize,
    required this.iconGradient,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String icon;
  final Size iconSize;
  final List<Color> iconGradient;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.tileBorder),
        gradient: LinearGradient(begin: const Alignment(-0.64, -2.2), end: const Alignment(0.64, 2.2), stops: const [0, 0.6, 1], colors: c.tileGradient),
        boxShadow: [BoxShadow(color: const Color(0x143B82F6), offset: const Offset(0, 4), blurRadius: 20, spreadRadius: -4)],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Pressable(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: iconGradient),
                  boxShadow: const [
                    BoxShadow(color: Color(0x333B82F6), offset: Offset(0, 2), blurRadius: 4, spreadRadius: -2),
                    BoxShadow(color: Color(0x333B82F6), offset: Offset(0, 4), blurRadius: 6, spreadRadius: -1),
                  ],
                ),
                child: AppIcon(icon, width: iconSize.width, height: iconSize.height),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 18, height: 28 / 18, fontWeight: FontWeight.w700, letterSpacing: -0.45, color: c.textPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w500, color: c.textSecondary)),
                ]),
              ),
              const SizedBox(width: 8),
              Container(
                width: dark ? 44 : 40,
                height: dark ? 44 : 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c.tileArrowBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: c.tileArrowBorder),
                  boxShadow: dark ? null : const [BoxShadow(color: Color(0x0D000000), offset: Offset(0, 1), blurRadius: 2)],
                ),
                child: dark ? const AppIcon('arrow-accent-dark', width: 20, height: 20) : const AppIcon('arrow-accent', width: 12, height: 12),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
