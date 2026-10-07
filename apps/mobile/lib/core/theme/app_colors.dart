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
    required this.inputBg,
    required this.inputBorder,
    required this.secondaryButtonBg,
    required this.secondaryButtonBorder,
    required this.secondaryButtonText,
    required this.heroGradient,
    required this.heroBorder,
    required this.tileGradient,
    required this.tileBorder,
    required this.tileArrowBg,
    required this.tileArrowBorder,
    required this.toggleBg,
    required this.toggleBorder,
    required this.toggleOff,
    required this.syncBadgeBg,
    required this.syncBadgeBorder,
    required this.glow,
    required this.card,
    required this.cardBorder,
    required this.cardShadow,
    required this.chipBg,
    required this.chipBorder,
    required this.infoBg,
    required this.infoBorder,
    required this.alertBg,
    required this.alertBorder,
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

  // Component colors that differ between the light and dark frames.
  final Color inputBg;
  final Color inputBorder;
  final Color secondaryButtonBg;
  final Color secondaryButtonBorder;
  final Color secondaryButtonText;
  final List<Color> heroGradient;
  final Color heroBorder;
  final List<Color> tileGradient;
  final Color tileBorder;
  final Color tileArrowBg;
  final Color tileArrowBorder;
  final Color toggleBg;
  final Color toggleBorder;
  final Color toggleOff;
  final Color syncBadgeBg;
  final Color syncBadgeBorder;
  final List<Color> glow;
  // Cards, search bars and chips (`83:16884` / `101:1985`).
  final Color card;
  final Color cardBorder;
  final Color cardShadow;
  final Color chipBg;
  final Color chipBorder;
  // Info bar ("Последний визит") and alert bar of the shop sheet (`83:17917` / `106:5732`).
  final Color infoBg;
  final Color infoBorder;
  final Color alertBg;
  final Color alertBorder;

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
    inputBg: Color(0x33FFFFFF),
    inputBorder: Color(0xFFE2E8F0),
    secondaryButtonBg: Color(0x0F493EE5),
    secondaryButtonBorder: Color(0x00000000),
    secondaryButtonText: Color(0xFF0F172A),
    heroGradient: [Color(0xFF2F28E4), Color(0xFF6041DC), Color(0xFF6058EA)],
    heroBorder: Color(0x00000000),
    tileGradient: [Color(0xFFFFFFFF), Color(0xFFF5F7FF), Color(0xFFEEF2FF)],
    tileBorder: Color(0x00000000),
    tileArrowBg: Color(0xFFFFFFFF),
    tileArrowBorder: Color(0x00000000),
    toggleBg: Color(0x00000000),
    toggleBorder: Color(0xFFE2E8F0),
    toggleOff: Color(0xFF94A3B8),
    syncBadgeBg: Color(0xB3F3F2FF),
    syncBadgeBorder: Color(0x4DC7C4D8),
    glow: [Color(0x0D493EE5), Color(0x1A493EE5), Color(0xFFF2F4FE)],
    card: Color(0xFFFFFFFF),
    cardBorder: Color(0x00000000),
    cardShadow: Color(0x0D191B25),
    chipBg: Color(0xFFEDEDFB),
    chipBorder: Color(0x00000000),
    infoBg: Color(0x0F493EE5),
    infoBorder: Color(0x00000000),
    alertBg: Color(0x66FFDAD6),
    alertBorder: Color(0x00000000),
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
    inputBg: Color(0xFF121A2C),
    inputBorder: Color(0x0DFFFFFF),
    secondaryButtonBg: Color(0xFF121A2C),
    secondaryButtonBorder: Color(0x0DFFFFFF),
    secondaryButtonText: Color(0xFF94A3B8),
    heroGradient: [Color(0xFF2C26C6), Color(0xFF4428B3), Color(0xFF3C33D0)],
    heroBorder: Color(0x0DFFFFFF),
    tileGradient: [Color(0xFF131B2E), Color(0xFF131B2E), Color(0xFF1D2843)],
    tileBorder: Color(0x0DFFFFFF),
    tileArrowBg: Color(0x0DFFFFFF),
    tileArrowBorder: Color(0x0DFFFFFF),
    toggleBg: Color(0xFF121A2C),
    toggleBorder: Color(0x0DFFFFFF),
    toggleOff: Color(0xFF94A3B8),
    syncBadgeBg: Color(0xFF121A2C),
    syncBadgeBorder: Color(0x0DFFFFFF),
    glow: [Color(0x0D493EE5), Color(0x0D493EE5), Color(0x0D493EE5)],
    card: Color(0xFF121A2C),
    cardBorder: Color(0x0DFFFFFF),
    cardShadow: Color(0x0D000000),
    chipBg: Color(0xFF121A2C),
    chipBorder: Color(0x0DFFFFFF),
    infoBg: Color(0xFF121D31),
    infoBorder: Color(0x0DFFFFFF),
    alertBg: Color(0xFF211528),
    alertBorder: Color(0xFF562035),
  );

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(AppColors? other, double t) => t < 0.5 ? this : (other ?? this);
}

extension AppColorsX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
