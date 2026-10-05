import 'package:flutter/painting.dart';

/// Color palette taken from the approved designs. The only place color values live.
class AppColors {
  const AppColors({
    required this.accent,
    required this.accentSoft,
    required this.background,
    required this.surface,
    required this.text,
    required this.textMuted,
    required this.border,
    required this.success,
    required this.error,
  });

  final Color accent;
  final Color accentSoft;
  final Color background;
  final Color surface;
  final Color text;
  final Color textMuted;
  final Color border;
  final Color success;
  final Color error;

  static const light = AppColors(
    accent: Color(0xFF493EE5),
    accentSoft: Color(0xFFEDEDFB),
    background: Color(0xFFFBF8FF),
    surface: Color(0xFFFFFFFF),
    text: Color(0xFF0F172A),
    textMuted: Color(0xFF62617B),
    border: Color(0xFFD0D0E9),
    success: Color(0xFF00685A),
    error: Color(0xFFCE3437),
  );

  static const dark = AppColors(
    accent: Color(0xFF493EE5),
    accentSoft: Color(0xFF1E2549),
    background: Color(0xFF0B0F19),
    surface: Color(0xFF121A2C),
    text: Color(0xFFFCFDFF),
    textMuted: Color(0xFF94A3B8),
    border: Color(0x0DFFFFFF),
    success: Color(0xFF25D998),
    error: Color(0xFFFDA4AF),
  );
}
