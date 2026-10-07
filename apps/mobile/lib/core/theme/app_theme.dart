import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  // Built once: ColorScheme.fromSeed generates whole tonal palettes, and a new ThemeData instance on every
  // rebuild would make MaterialApp treat the theme as changed.
  static final ThemeData _light = _build(AppColors.light, Brightness.light);
  static final ThemeData _dark = _build(AppColors.dark, Brightness.dark);
  static ThemeData light() => _light;
  static ThemeData dark() => _dark;

  static ThemeData _build(AppColors c, Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: c.accent, brightness: brightness).copyWith(
      primary: c.accent,
      onPrimary: const Color(0xFFFFFFFF),
      surface: c.surface,
      onSurface: c.textPrimary,
      onSurfaceVariant: c.textSecondary,
      outline: c.border,
      error: c.error,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.mainBg,
      fontFamily: AppTextStyles.family,
      // Native Android touch and navigation: the platform's sparkle ripple, and Android 14's predictive-back
      // page transition (the page follows the back swipe; needs enableOnBackInvokedCallback in the manifest).
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
      extensions: [c],
    );
  }
}
