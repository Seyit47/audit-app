import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

/// Material 3 on Android and Cupertino on iOS, both themed with the Figma tokens: the stock platform
/// widgets carry the design's colors, radii and type, and keep their native behaviour.
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
    final radius12 = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
    OutlineInputBorder inputBorder(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color),
    );
    final buttonText = AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, height: 20 / 14);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.mainBg,
      fontFamily: AppTextStyles.family,
      // Native Android touch and navigation: the platform's sparkle ripple, and Android 14's predictive-back
      // page transition (the page follows the back swipe; needs enableOnBackInvokedCallback in the manifest).
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {TargetPlatform.android: PredictiveBackPageTransitionsBuilder(), TargetPlatform.iOS: CupertinoPageTransitionsBuilder()},
      ),
      // "Сохранить" (252:26602): 48 px, accent, 12 px radius, half opacity when disabled.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.accent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: c.accent.withValues(alpha: 0.5),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.8),
          minimumSize: const Size(64, 48),
          shape: radius12,
          textStyle: buttonText,
          elevation: 0,
        ),
      ),
      // "Отмена" (252:26599): outlined secondary of the same size.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: c.secondaryButtonBg,
          foregroundColor: c.secondaryButtonText,
          side: BorderSide(color: c.secondaryButtonBorder),
          minimumSize: const Size(64, 48),
          shape: radius12,
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.accent,
          textStyle: AppTextStyles.label,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(style: IconButton.styleFrom(foregroundColor: c.textPrimary)),
      // Filter pills (101:1985): stadium, chip background and border, accent when selected, no checkmark.
      chipTheme: ChipThemeData(
        backgroundColor: c.chipBg,
        selectedColor: c.accent,
        disabledColor: c.chipBg,
        side: BorderSide(color: c.chipBorder),
        shape: const StadiumBorder(),
        showCheckmark: false,
        labelStyle: AppTextStyles.label.copyWith(height: 1.5, color: c.textSecondary),
        secondaryLabelStyle: AppTextStyles.label.copyWith(height: 1.5, color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      // 44 px inputs of the add-shop form.
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: c.inputBg,
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: c.textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13.5),
        enabledBorder: inputBorder(c.inputBorder),
        disabledBorder: inputBorder(c.inputBorder),
        focusedBorder: inputBorder(c.accent),
        errorBorder: inputBorder(c.error),
        focusedErrorBorder: inputBorder(c.error),
      ),
      textSelectionTheme: TextSelectionThemeData(cursorColor: c.accent, selectionHandleColor: c.accent, selectionColor: c.accent.withValues(alpha: 0.25)),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          backgroundColor: c.white5,
          foregroundColor: c.toggleOff,
          selectedBackgroundColor: c.accent,
          selectedForegroundColor: const Color(0xFFFCFDFF),
          side: BorderSide(color: c.toggleBorder),
          textStyle: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w500),
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      switchTheme: SwitchThemeData(trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.accent : null)),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: c.accent),
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: c.card, showDragHandle: true, dragHandleColor: c.border),
      dialogTheme: DialogThemeData(
        backgroundColor: c.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: c.card,
        shape: radius12,
        textStyle: AppTextStyles.bodyMedium.copyWith(color: c.textPrimary),
      ),
      snackBarTheme: SnackBarThemeData(behavior: SnackBarBehavior.floating, shape: radius12),
      // Cupertino widgets (iOS) take the same accent, backgrounds and type.
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: brightness,
        primaryColor: c.accent,
        scaffoldBackgroundColor: c.mainBg,
        barBackgroundColor: c.card,
        textTheme: CupertinoTextThemeData(
          textStyle: AppTextStyles.body.copyWith(color: c.textPrimary),
          primaryColor: c.accent,
        ),
      ),
      extensions: [c],
    );
  }
}
