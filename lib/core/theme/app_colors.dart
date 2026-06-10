import 'package:flutter/material.dart';

/// Abrag design tokens — extracted from the ابراج prototype (`abrag/styles.css`).
/// Royal-blue indigo field · cool-white ink · amber sun accent. Dark-first.
class AppColors {
  AppColors._();

  // Brand
  static const Color brand = Color(0xFF1B5CF0); // royal blue
  static const Color accent = Color(0xFFFCBC15); // amber sun
  static const Color brandInk = Color(0xFFFFFFFF); // text on brand
  static const Color accentInk = Color(0xFF1A1300); // text on amber
  static const Color brandSoft = Color(0x291B5CF0); // brand @16%
  static const Color accentSoft = Color(0x24FCBC15); // accent @14%

  // Surfaces (dark)
  static const Color bg = Color(0xFF080C24); // deep indigo
  static const Color bg2 = Color(0xFF0A1030); // gradient lower
  static const Color surface = Color(0xFF111A44); // card
  static const Color surface2 = Color(0xFF18225A); // raised
  static const Color surface3 = Color(0xFF1F2C6E); // hover / input fill
  static const Color border = Color(0xFF283577); // hairline
  static const Color border2 = Color(0xFF34439A);

  // Ink (dark)
  static const Color ink = Color(0xFFEAF0FF); // primary text
  static const Color ink2 = Color(0xFFA7B4E6); // secondary
  static const Color ink3 = Color(0xFF6E7CB8); // tertiary / hints

  // Seasons
  static const Color summer = Color(0xFFFCBC15);
  static const Color summerSoft = Color(0x24FCBC15);
  static const Color winter = Color(0xFF36C6F0);
  static const Color winterSoft = Color(0x2436C6F0);

  // Status
  static const Color ok = Color(0xFF34D6A0);
  static const Color okSoft = Color(0x2434D6A0);
  static const Color warn = Color(0xFFFCBC15);
  static const Color warnSoft = Color(0x24FCBC15);
  static const Color err = Color(0xFFFB5A66);
  static const Color errSoft = Color(0x24FB5A66);

  static const Color white = Color(0xFFFFFFFF);

  // ---------------------------------------------------------------------
  // Legacy aliases — old navy/gold identity names, re-pointed at the new
  // palette so un-migrated screens adopt it without code changes.
  // Scheduled for removal in Phase 8 (ui-redesign/final-qa).
  // ---------------------------------------------------------------------
  static const Color navyBackground = bg;
  static const Color goldPrimary = accent;
  static const Color cardBackground = surface;
  static const Color textPrimary = ink;
  static const Color textSecondary = ink2;
  static const Color divider = border;
  static const Color error = err;
  static const Color success = ok;
  static const Color warning = warn;
  static const Color info = brand;
}
