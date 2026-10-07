import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_icon.dart';

/// "Empty State Photo Target" of `83:17207` (also the storefront target of `252:26487`).
class PhotoEmptyTarget extends StatelessWidget {
  const PhotoEmptyTarget({super.key, required this.title, required this.hint, required this.buttonLabel, required this.onTake});

  final String title;
  final String hint;
  final String buttonLabel;

  final VoidCallback? onTake;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return DashedBorder(
      color: c.border,
      radius: 12,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: c.accent6, borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          Container(
            width: 48, height: 48, alignment: Alignment.center,
            decoration: BoxDecoration(color: c.accent6, shape: BoxShape.circle, boxShadow: const [BoxShadow(color: Color(0x0D000000), offset: Offset(0, 1), blurRadius: 2)]),
            child: const AppIcon('camera', width: 21.67, height: 19.5),
          ),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center, style: AppTextStyles.label.copyWith(color: c.textPrimary)),
          const SizedBox(height: 4),
          SizedBox(
            width: 259,
            child: Text(hint, textAlign: TextAlign.center,
                style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 11, height: 17.88 / 11, color: c.textSecondary)),
          ),
          const SizedBox(height: 12),
          Material(
            color: c.accent,
            borderRadius: BorderRadius.circular(8),
            elevation: 2,
            shadowColor: const Color(0x33000000),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onTake,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 40,
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const AppIcon('camera-add', width: 16.5, height: 15),
                    const SizedBox(width: 8),
                    Text(buttonLabel, style: AppTextStyles.label.copyWith(color: Colors.white)),
                  ]),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

/// A 1 px dashed rounded border (the photo targets of `83:17207` / `83:17285`).
class DashedBorder extends StatelessWidget {
  const DashedBorder({super.key, required this.child, required this.color, required this.radius});

  final Widget child;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) => CustomPaint(foregroundPainter: _DashPainter(color, radius), child: child);
}

class _DashPainter extends CustomPainter {
  _DashPainter(this.color, this.radius);

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)).deflate(0.5));
    for (final ui.PathMetric m in path.computeMetrics()) {
      for (double d = 0; d < m.length; d += 7) {
        canvas.drawPath(m.extractPath(d, d + 4), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.color != color || old.radius != radius;
}
