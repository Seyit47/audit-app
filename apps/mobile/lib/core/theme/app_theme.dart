import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Light and dark themes, built only from [AppColors].
abstract final class AppTheme {
  static const double radius = 12;

  static ThemeData get light => _build(AppColors.light, Brightness.light);
  static ThemeData get dark => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors colors, Brightness brightness) {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: colors.accent,
          brightness: brightness,
        ).copyWith(
          primary: colors.accent,
          onPrimary: const Color(0xFFFFFFFF),
          surface: colors.surface,
          onSurface: colors.text,
          onSurfaceVariant: colors.textMuted,
          outline: colors.border,
          error: colors.error,
        );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.text,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        shape: shape,
        elevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(shape: shape),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        indicatorColor: colors.accentSoft,
      ),
      extensions: [AppColorsExtension(colors)],
    );
  }
}

/// Exposes [AppColors] through the theme for colors the [ColorScheme] does not cover.
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension(this.colors);

  final AppColors colors;

  @override
  AppColorsExtension copyWith({AppColors? colors}) =>
      AppColorsExtension(colors ?? this.colors);

  @override
  AppColorsExtension lerp(AppColorsExtension? other, double t) =>
      t < 0.5 ? this : other ?? this;
}

extension AppColorsContext on BuildContext {
  AppColors get colors =>
      Theme.of(this).extension<AppColorsExtension>()!.colors;
}
