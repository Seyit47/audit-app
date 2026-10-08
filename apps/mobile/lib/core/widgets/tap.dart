import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'adaptive.dart';

/// The platform's touch feedback for a custom tappable area: the Material ink ripple on Android, and on
/// iOS the press-and-dim of [CupertinoButton]. Same arguments as [InkWell], so it drops in for one.
class Pressable extends StatelessWidget {
  const Pressable({super.key, required this.child, required this.onTap, this.borderRadius});

  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    if (context.isCupertino) return _CupertinoPress(onTap: onTap, child: child);
    return InkWell(onTap: onTap, borderRadius: borderRadius, child: child);
  }
}

/// Draws the feedback *above* [child] (photos, decorated tiles), where an ordinary ripple would be hidden
/// behind the picture. On iOS the whole tile dims while pressed.
class InkOverlay extends StatelessWidget {
  const InkOverlay({super.key, required this.child, required this.onTap, this.radius = 0});

  final Widget child;
  final VoidCallback? onTap;
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (context.isCupertino) return _CupertinoPress(onTap: onTap, child: child);
    return Stack(
      fit: StackFit.passthrough,
      children: [
        child,
        Positioned.fill(
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(radius)),
          ),
        ),
      ],
    );
  }
}

/// A tappable text link ("Открыть галерею", "Все фото", sort toggle).
class TextLink extends StatelessWidget {
  const TextLink({super.key, required this.child, required this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (context.isCupertino) return _CupertinoPress(onTap: onTap, child: child);
    return Material(
      type: MaterialType.transparency,
      child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(6), child: child),
    );
  }
}

/// A pill or chip whose colors animate between states, with the platform's press feedback.
class AnimatedChip extends StatelessWidget {
  const AnimatedChip({super.key, this.decoration, required this.child, required this.onTap, this.height, this.padding, this.radius = 999});

  final BoxDecoration? decoration;
  final Widget child;
  final VoidCallback? onTap;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final content = AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      padding: padding ?? EdgeInsets.zero,
      child: Center(widthFactor: 1, child: child),
    );
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      height: height,
      decoration: decoration,
      child: context.isCupertino
          ? _CupertinoPress(onTap: onTap, child: content)
          : Material(
              type: MaterialType.transparency,
              borderRadius: BorderRadius.circular(radius),
              clipBehavior: Clip.antiAlias,
              child: InkWell(onTap: onTap, child: content),
            ),
    );
  }
}

/// iOS press feedback: the content dims while the finger is down, as in [CupertinoButton], without the
/// button's padding or minimum size so it fits any custom layout.
class _CupertinoPress extends StatelessWidget {
  const _CupertinoPress({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // CupertinoButton tints its child's default text and icons with the accent; keep the surrounding ones.
    final text = DefaultTextStyle.of(context);
    final icons = IconTheme.of(context);
    return CupertinoButton(
      onPressed: onTap,
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      pressedOpacity: 0.55,
      child: DefaultTextStyle(
        style: text.style,
        textAlign: text.textAlign,
        maxLines: text.maxLines,
        overflow: text.overflow,
        child: IconTheme(data: icons, child: child),
      ),
    );
  }
}
