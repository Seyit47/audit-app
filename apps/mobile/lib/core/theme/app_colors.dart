import 'package:flutter/material.dart';

/// Colors from the Figma variables ("Light Mobile/*", "Dark Mobile/*").
/// The only place color values are defined in the app.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.mainBg,
    required this.secondaryBg,
    required this.surface,
    required this.accent,
    required this.accent6,
    required this.darkAccent,
    required this.lightAccent,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.grey3,
    required this.success,
    required this.success10,
    required this.lightGreen,
    required this.error,
    required this.errorBg,
    required this.errorStroke,
    required this.white5,
    required this.white20,
  });

  final Color mainBg;
  final Color secondaryBg;
  final Color surface;
  final Color accent;
  final Color accent6;
  final Color darkAccent;
  final Color lightAccent;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color grey3;
  final Color success;
  final Color success10;
  final Color lightGreen;
  final Color error;
  final Color errorBg;
  final Color errorStroke;
  final Color white5;
  final Color white20;

  static const light = AppColors(
    mainBg: Color(0xFFFBF8FF),
    secondaryBg: Color(0xFFF3F2FF),
    surface: Color(0xFFFFFFFF),
    accent: Color(0xFF493EE5),
    accent6: Color(0x0F493EE5),
    darkAccent: Color(0xFFEDEDFB),
    lightAccent: Color(0xFFEDEDFB),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF62617B),
    border: Color(0xFFE2E8F0),
    grey3: Color(0xFFF1F5F9),
    success: Color(0xFF00685A),
    success10: Color(0x1A00685A),
    lightGreen: Color(0xFF03D66C),
    error: Color(0xFFCE3437),
    errorBg: Color(0xFFF9EDEC),
    errorStroke: Color(0xFFCE3437),
    white5: Color(0x0DFFFFFF),
    white20: Color(0x33FFFFFF),
  );

  static const dark = AppColors(
    mainBg: Color(0xFF0B0F19),
    secondaryBg: Color(0xFF121A2C),
    surface: Color(0xFF121A2C),
    accent: Color(0xFF493EE5),
    accent6: Color(0x0F493EE5),
    darkAccent: Color(0xFF1E2549),
    lightAccent: Color(0xFFA5B4FC),
    textPrimary: Color(0xFFFCFDFF),
    textSecondary: Color(0xFF94A3B8),
    border: Color(0x0DFFFFFF),
    grey3: Color(0xFF121A2C),
    success: Color(0xFF25D998),
    success10: Color(0x1A25D998),
    lightGreen: Color(0xFF25D998),
    error: Color(0xFFFDA4AF),
    errorBg: Color(0xFF450A0A),
    errorStroke: Color(0xFF9F1239),
    white5: Color(0x0DFFFFFF),
    white20: Color(0x33FFFFFF),
  );

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(AppColors? other, double t) => t < 0.5 ? this : (other ?? this);
}

extension AppColorsX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
