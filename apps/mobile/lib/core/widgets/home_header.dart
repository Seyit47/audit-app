import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'adaptive.dart';
import 'app_icon.dart';

/// Theme switch of the Home header (`111:6788` / `102:3279`): sun in light, moon in dark.
/// A Material [IconButton] on Android, a [CupertinoButton] on iOS.
class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key, required this.onPressed, required this.tooltip});

  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final icon = AppIcon(dark ? 'theme-moon' : 'theme-sun', width: 16, height: 16);
    if (context.isCupertino) {
      return Semantics(
        label: tooltip,
        button: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: c.toggleBg,
            shape: BoxShape.circle,
            border: Border.all(color: c.toggleBorder),
          ),
          child: CupertinoButton(onPressed: onPressed, padding: EdgeInsets.zero, minimumSize: const Size.square(36), child: icon),
        ),
      );
    }
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: icon,
      style: IconButton.styleFrom(
        backgroundColor: c.toggleBg,
        side: BorderSide(color: c.toggleBorder),
        fixedSize: const Size.square(36),
        minimumSize: const Size.square(36),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

/// RU / EN switch of the Home header (`111:6788`): a rounded track with a fully rounded accent pill that
/// slides to the chosen language. Android: Material ink on each half; iOS: the native
/// [CupertinoSlidingSegmentedControl] in the same track. Choosing the current language does nothing.
class LocaleToggle extends StatelessWidget {
  const LocaleToggle({super.key, required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  static const _codes = ['ru', 'en'];
  static const _segment = 52.0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final track = BoxDecoration(
      color: c.white5,
      border: Border.all(color: c.toggleBorder),
      borderRadius: BorderRadius.circular(999),
    );
    Widget label(String code) {
      final on = code == value;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (on) ...[const AppIcon('radio-dot', width: 12, height: 12), const SizedBox(width: 4)],
          Text(
            code.toUpperCase(),
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w500, height: 16 / 12, color: on ? const Color(0xFFFCFDFF) : c.toggleOff),
          ),
        ],
      );
    }

    if (context.isCupertino) {
      return DecoratedBox(
        decoration: track,
        child: CupertinoSlidingSegmentedControl<String>(
          groupValue: value,
          thumbColor: c.accent,
          backgroundColor: const Color(0x00000000),
          padding: const EdgeInsets.all(2),
          onValueChanged: (code) {
            if (code != null && code != value) onChanged(code);
          },
          children: {
            for (final code in _codes)
              code: SizedBox(
                width: _segment - 4,
                height: 28,
                child: Center(child: label(code)),
              ),
          },
        ),
      );
    }
    final index = _codes.indexOf(value);
    return Container(
      height: 36,
      width: _segment * _codes.length + 6, // + 2 px padding and 1 px border on each side
      padding: const EdgeInsets.all(2),
      decoration: track,
      child: Stack(
        children: [
          // The pill slides between the halves.
          AnimatedAlign(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: index == 0 ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              width: _segment,
              decoration: BoxDecoration(
                color: c.accent,
                borderRadius: BorderRadius.circular(999),
                boxShadow: const [BoxShadow(color: Color(0x0D000000), offset: Offset(0, 1), blurRadius: 2)],
              ),
            ),
          ),
          Row(
            children: [
              for (final code in _codes)
                SizedBox(
                  width: _segment,
                  child: Material(
                    type: MaterialType.transparency,
                    shape: const StadiumBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: code == value ? null : () => onChanged(code),
                      child: Semantics(
                        selected: code == value,
                        button: true,
                        child: Center(child: label(code)),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
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
      decoration: BoxDecoration(
        color: c.syncBadgeBg,
        border: Border.all(color: c.syncBadgeBorder),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (syncing)
            SizedBox.square(dimension: 10, child: CircularProgressIndicator.adaptive(strokeWidth: 1.5, valueColor: AlwaysStoppedAnimation(c.accent)))
          else
            AppIcon(dark ? 'sync-cloud-dark' : 'sync-cloud', width: 13.75, height: 10),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontFamily: dark ? AppTextStyles.mono : AppTextStyles.family,
              fontSize: 12,
              height: 16 / 12,
              fontWeight: dark ? FontWeight.w400 : FontWeight.w500,
              color: c.textSecondary,
            ),
          ),
        ],
      ),
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
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
    return IgnorePointer(
      child: Stack(clipBehavior: Clip.hardEdge, children: [blob(3, -96, 384, g[0]), blob(188, 438, 320, g[1]), blob(-76, 470, 288, g[2])]),
    );
  }
}
