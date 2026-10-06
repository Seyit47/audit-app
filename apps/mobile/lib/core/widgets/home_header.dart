import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_icon.dart';

/// Theme switch of the Home header (`111:6788` / `102:3279`): sun in light, moon in dark.
class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key, required this.onPressed, required this.tooltip});

  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: c.toggleBg,
        shape: CircleBorder(side: BorderSide(color: c.toggleBorder)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox.square(
            dimension: 36,
            child: Center(child: AppIcon(dark ? 'theme-moon' : 'theme-sun', width: 16, height: 16)),
          ),
        ),
      ),
    );
  }
}

/// RU/EN radio group of the Home header (`111:6792`).
class LocaleToggle extends StatelessWidget {
  const LocaleToggle({super.key, required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget option(String code) {
      final selected = code == value;
      return Semantics(
        selected: selected,
        button: true,
        child: GestureDetector(
          onTap: () => onChanged(code),
          child: Container(
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: selected
                ? BoxDecoration(
                    color: c.accent,
                    borderRadius: BorderRadius.circular(9999),
                    boxShadow: const [BoxShadow(color: Color(0x0D000000), offset: Offset(0, 1), blurRadius: 2)],
                  )
                : null,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (selected) ...[const AppIcon('radio-dot', width: 12, height: 12), const SizedBox(width: 4)],
              Text(code.toUpperCase(), style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w500, color: selected ? const Color(0xFFFCFDFF) : c.toggleOff)),
            ]),
          ),
        ),
      );
    }

    return Container(
      height: 36,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: c.white5,
        border: Border.all(color: c.toggleBorder),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [option('ru'), option('en')]),
    );
  }
}

/// "Данные синхронизированы" / "Синхронизация…" pill at the bottom of Home (`83:16877` / `102:3267`).
class SyncStatusBadge extends StatelessWidget {
  const SyncStatusBadge({super.key, required this.label, this.syncing = false});

  final String label;
  final bool syncing;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: dark ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8) : const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: c.syncBadgeBg, border: Border.all(color: c.syncBadgeBorder), borderRadius: BorderRadius.circular(9999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (syncing)
          SizedBox.square(dimension: 10, child: CircularProgressIndicator(strokeWidth: 1.5, color: c.accent))
        else
          AppIcon(dark ? 'sync-cloud-dark' : 'sync-cloud', width: 13.75, height: 10),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontFamily: dark ? AppTextStyles.mono : AppTextStyles.family, fontSize: 12, height: 16 / 12, fontWeight: dark ? FontWeight.w400 : FontWeight.w500, color: c.textSecondary)),
      ]),
    );
  }
}

/// Soft blurred circles behind the Home content (`83:16801`).
class HomeGlow extends StatelessWidget {
  const HomeGlow({super.key});

  @override
  Widget build(BuildContext context) {
    final g = context.colors.glow;
    Widget blob(double left, double top, double size, Color color) => Positioned(
          left: left,
          top: top,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
            child: Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          ),
        );
    return IgnorePointer(
      child: Stack(clipBehavior: Clip.hardEdge, children: [
        blob(3, -96, 384, g[0]),
        blob(188, 438, 320, g[1]),
        blob(-76, 470, 288, g[2]),
      ]),
    );
  }
}
