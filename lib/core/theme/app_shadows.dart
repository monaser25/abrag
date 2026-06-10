import 'package:flutter/widgets.dart';

import 'app_colors.dart';

/// Shadow/elevation tokens (dark theme values from `abrag/styles.css`).
class AppShadows {
  AppShadows._();

  /// Card shadow (`--shadow`).
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x66000000), offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(
      color: Color(0x99000000),
      offset: Offset(0, 12),
      blurRadius: 32,
      spreadRadius: -12,
    ),
  ];

  /// Subtle shadow (`--shadow-sm`).
  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x59000000), offset: Offset(0, 1), blurRadius: 2),
  ];

  /// Brand glow ring (`--glow`).
  static const List<BoxShadow> glow = [
    BoxShadow(color: Color(0x661B5CF0), spreadRadius: 1),
    BoxShadow(
      color: Color(0x8C1B5CF0),
      offset: Offset(0, 8),
      blurRadius: 30,
      spreadRadius: -8,
    ),
  ];

  /// Amber glow under primary buttons (`.btn-primary`).
  static const List<BoxShadow> accentGlow = [
    BoxShadow(
      color: AppColors.accent,
      offset: Offset(0, 6),
      blurRadius: 18,
      spreadRadius: -8,
    ),
  ];

  /// Royal glow under brand buttons (`.btn-royal`).
  static const List<BoxShadow> brandGlow = [
    BoxShadow(
      color: AppColors.brand,
      offset: Offset(0, 6),
      blurRadius: 18,
      spreadRadius: -8,
    ),
  ];

  /// FAB glow (`.fab`).
  static const List<BoxShadow> fabGlow = [
    BoxShadow(
      color: AppColors.accent,
      offset: Offset(0, 10),
      blurRadius: 26,
      spreadRadius: -8,
    ),
  ];
}
