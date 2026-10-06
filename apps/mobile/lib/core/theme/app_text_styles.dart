import 'package:flutter/material.dart';

/// Inter text styles. Exact sizes, weights and line heights are taken per frame from Figma;
/// these are the shared base styles.
abstract final class AppTextStyles {
  static const family = 'Inter';

  static const title = TextStyle(fontFamily: family, fontSize: 24, fontWeight: FontWeight.w700, height: 1.25);
  static const heading = TextStyle(fontFamily: family, fontSize: 18, fontWeight: FontWeight.w600, height: 1.33);
  static const body = TextStyle(fontFamily: family, fontSize: 14, fontWeight: FontWeight.w400, height: 1.43);
  static const bodyMedium = TextStyle(fontFamily: family, fontSize: 14, fontWeight: FontWeight.w500, height: 1.43);
  static const caption = TextStyle(fontFamily: family, fontSize: 12, fontWeight: FontWeight.w400, height: 1.33);
  static const label = TextStyle(fontFamily: family, fontSize: 12, fontWeight: FontWeight.w600, height: 1.33);
  static const button = TextStyle(fontFamily: family, fontSize: 16, fontWeight: FontWeight.w600, height: 1.25);
}
