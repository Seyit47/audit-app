import 'package:flutter/material.dart';

/// Native touch feedback for widgets that paint their own content.
///
/// [InkOverlay] draws the ripple *above* [child] (photos, decorated tiles), where an ordinary [InkWell]
/// would be hidden behind the picture.
class InkOverlay extends StatelessWidget {
  const InkOverlay({super.key, required this.child, required this.onTap, this.radius = 0});

  final Widget child;
  final VoidCallback? onTap;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.passthrough, children: [
      child,
      Positioned.fill(
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(radius)),
        ),
      ),
    ]);
  }
}

/// A tappable text link ("Открыть галерею", "Все фото", sort toggle) with a rounded ripple.
class TextLink extends StatelessWidget {
  const TextLink({super.key, required this.child, required this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(6), child: child),
    );
  }
}

/// A pill or chip whose colors animate between states, with a ripple clipped to its shape.
class AnimatedChip extends StatelessWidget {
  const AnimatedChip({
    super.key,
    this.decoration,
    required this.child,
    required this.onTap,
    this.height,
    this.padding,
    this.radius = 999,
  });

  final BoxDecoration? decoration;
  final Widget child;
  final VoidCallback? onTap;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      height: height,
      decoration: decoration,
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: padding ?? EdgeInsets.zero,
            child: Center(widthFactor: 1, child: child),
          ),
        ),
      ),
    );
  }
}
