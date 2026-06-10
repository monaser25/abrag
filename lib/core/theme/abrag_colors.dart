import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Semantic color set carried on [ThemeData] as a [ThemeExtension], so a
/// complete light palette can be shipped later as a pure data swap.
/// Widgets read it via `context.colors`.
class AbragColors extends ThemeExtension<AbragColors> {
  const AbragColors({
    required this.bg,
    required this.bg2,
    required this.surface,
    required this.surface2,
    required this.surface3,
    required this.border,
    required this.border2,
    required this.ink,
    required this.ink2,
    required this.ink3,
    required this.brand,
    required this.brandInk,
    required this.brandSoft,
    required this.accent,
    required this.accentInk,
    required this.accentSoft,
    required this.summer,
    required this.summerSoft,
    required this.winter,
    required this.winterSoft,
    required this.ok,
    required this.okSoft,
    required this.warn,
    required this.warnSoft,
    required this.err,
    required this.errSoft,
  });

  final Color bg;
  final Color bg2;
  final Color surface;
  final Color surface2;
  final Color surface3;
  final Color border;
  final Color border2;
  final Color ink;
  final Color ink2;
  final Color ink3;
  final Color brand;
  final Color brandInk;
  final Color brandSoft;
  final Color accent;
  final Color accentInk;
  final Color accentSoft;
  final Color summer;
  final Color summerSoft;
  final Color winter;
  final Color winterSoft;
  final Color ok;
  final Color okSoft;
  final Color warn;
  final Color warnSoft;
  final Color err;
  final Color errSoft;

  static const AbragColors dark = AbragColors(
    bg: AppColors.bg,
    bg2: AppColors.bg2,
    surface: AppColors.surface,
    surface2: AppColors.surface2,
    surface3: AppColors.surface3,
    border: AppColors.border,
    border2: AppColors.border2,
    ink: AppColors.ink,
    ink2: AppColors.ink2,
    ink3: AppColors.ink3,
    brand: AppColors.brand,
    brandInk: AppColors.brandInk,
    brandSoft: AppColors.brandSoft,
    accent: AppColors.accent,
    accentInk: AppColors.accentInk,
    accentSoft: AppColors.accentSoft,
    summer: AppColors.summer,
    summerSoft: AppColors.summerSoft,
    winter: AppColors.winter,
    winterSoft: AppColors.winterSoft,
    ok: AppColors.ok,
    okSoft: AppColors.okSoft,
    warn: AppColors.warn,
    warnSoft: AppColors.warnSoft,
    err: AppColors.err,
    errSoft: AppColors.errSoft,
  );

  /// Light palette from the prototype (`abrag/styles.css` → `.theme-light`).
  /// Defined for forward-compatibility; NOT registered on any ThemeData yet —
  /// light mode ships only when complete (see migration plan, open question 2).
  static const AbragColors light = AbragColors(
    bg: Color(0xFFEEF2FE),
    bg2: Color(0xFFE4EAFB),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFF5F7FF),
    surface3: Color(0xFFECF0FE),
    border: Color(0xFFDBE2F6),
    border2: Color(0xFFC7D2F0),
    ink: Color(0xFF0B1437),
    ink2: Color(0xFF4A568A),
    ink3: Color(0xFF8390BD),
    brand: AppColors.brand,
    brandInk: Color(0xFFFFFFFF),
    brandSoft: Color(0x1A1B5CF0),
    accent: AppColors.accent,
    accentInk: Color(0xFF3A2A00),
    accentSoft: Color(0x2EFCBC15),
    summer: Color(0xFFE89A00),
    summerSoft: Color(0x24E89A00),
    winter: Color(0xFF0E9CC8),
    winterSoft: Color(0x1F0E9CC8),
    ok: Color(0xFF0E9E73),
    okSoft: Color(0x1F0E9E73),
    warn: Color(0xFFC98A00),
    warnSoft: Color(0x1FC98A00),
    err: Color(0xFFD63B47),
    errSoft: Color(0x1AD63B47),
  );

  @override
  AbragColors copyWith({
    Color? bg,
    Color? bg2,
    Color? surface,
    Color? surface2,
    Color? surface3,
    Color? border,
    Color? border2,
    Color? ink,
    Color? ink2,
    Color? ink3,
    Color? brand,
    Color? brandInk,
    Color? brandSoft,
    Color? accent,
    Color? accentInk,
    Color? accentSoft,
    Color? summer,
    Color? summerSoft,
    Color? winter,
    Color? winterSoft,
    Color? ok,
    Color? okSoft,
    Color? warn,
    Color? warnSoft,
    Color? err,
    Color? errSoft,
  }) {
    return AbragColors(
      bg: bg ?? this.bg,
      bg2: bg2 ?? this.bg2,
      surface: surface ?? this.surface,
      surface2: surface2 ?? this.surface2,
      surface3: surface3 ?? this.surface3,
      border: border ?? this.border,
      border2: border2 ?? this.border2,
      ink: ink ?? this.ink,
      ink2: ink2 ?? this.ink2,
      ink3: ink3 ?? this.ink3,
      brand: brand ?? this.brand,
      brandInk: brandInk ?? this.brandInk,
      brandSoft: brandSoft ?? this.brandSoft,
      accent: accent ?? this.accent,
      accentInk: accentInk ?? this.accentInk,
      accentSoft: accentSoft ?? this.accentSoft,
      summer: summer ?? this.summer,
      summerSoft: summerSoft ?? this.summerSoft,
      winter: winter ?? this.winter,
      winterSoft: winterSoft ?? this.winterSoft,
      ok: ok ?? this.ok,
      okSoft: okSoft ?? this.okSoft,
      warn: warn ?? this.warn,
      warnSoft: warnSoft ?? this.warnSoft,
      err: err ?? this.err,
      errSoft: errSoft ?? this.errSoft,
    );
  }

  @override
  AbragColors lerp(ThemeExtension<AbragColors>? other, double t) {
    if (other is! AbragColors) return this;
    return AbragColors(
      bg: Color.lerp(bg, other.bg, t)!,
      bg2: Color.lerp(bg2, other.bg2, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      surface3: Color.lerp(surface3, other.surface3, t)!,
      border: Color.lerp(border, other.border, t)!,
      border2: Color.lerp(border2, other.border2, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      ink2: Color.lerp(ink2, other.ink2, t)!,
      ink3: Color.lerp(ink3, other.ink3, t)!,
      brand: Color.lerp(brand, other.brand, t)!,
      brandInk: Color.lerp(brandInk, other.brandInk, t)!,
      brandSoft: Color.lerp(brandSoft, other.brandSoft, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentInk: Color.lerp(accentInk, other.accentInk, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      summer: Color.lerp(summer, other.summer, t)!,
      summerSoft: Color.lerp(summerSoft, other.summerSoft, t)!,
      winter: Color.lerp(winter, other.winter, t)!,
      winterSoft: Color.lerp(winterSoft, other.winterSoft, t)!,
      ok: Color.lerp(ok, other.ok, t)!,
      okSoft: Color.lerp(okSoft, other.okSoft, t)!,
      warn: Color.lerp(warn, other.warn, t)!,
      warnSoft: Color.lerp(warnSoft, other.warnSoft, t)!,
      err: Color.lerp(err, other.err, t)!,
      errSoft: Color.lerp(errSoft, other.errSoft, t)!,
    );
  }
}

extension AbragColorsX on BuildContext {
  /// Shorthand for the active [AbragColors] palette.
  AbragColors get colors =>
      Theme.of(this).extension<AbragColors>() ?? AbragColors.dark;
}
