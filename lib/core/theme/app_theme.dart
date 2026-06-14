import 'package:flutter/material.dart';

import 'abrag_colors.dart';
import 'app_radius.dart';
import 'app_typography.dart';

/// App-wide [ThemeData] built from the prototype tokens.
///
/// Dark is the shipping theme. The builder is parameterized on [AbragColors]
/// so a light theme can be added later by passing [AbragColors.light] —
/// not exposed yet (see docs/UI_REDESIGN_MIGRATION_PLAN.md).
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme => _build(AbragColors.dark, Brightness.dark);

  static ThemeData get lightTheme => _build(AbragColors.light, Brightness.light);

  static ThemeData _build(AbragColors c, Brightness brightness) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: c.brand,
      onPrimary: c.brandInk,
      primaryContainer: c.surface3,
      onPrimaryContainer: c.ink,
      secondary: c.accent,
      onSecondary: c.accentInk,
      secondaryContainer: c.surface2,
      onSecondaryContainer: c.ink,
      tertiary: c.winter,
      onTertiary: c.bg,
      error: c.err,
      onError: Colors.white,
      errorContainer: c.errSoft,
      onErrorContainer: c.err,
      surface: c.surface,
      onSurface: c.ink,
      surfaceContainerHighest: c.surface3,
      onSurfaceVariant: c.ink2,
      outline: c.border2,
      outlineVariant: c.border,
      shadow: Colors.black,
      scrim: Colors.black54,
      inverseSurface: c.ink,
      onInverseSurface: c.bg,
      inversePrimary: c.brand,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: AppTypography.fontFamily,
      colorScheme: colorScheme,
      primaryColor: c.brand,
      scaffoldBackgroundColor: c.bg,
      cardColor: c.surface,
      canvasColor: c.bg,
      dividerColor: c.border,
      textTheme: AppTypography.textTheme.apply(
        bodyColor: c.ink,
        displayColor: c.ink,
      ),
      iconTheme: IconThemeData(color: c.ink),
      extensions: [c],
      appBarTheme: AppBarTheme(
        backgroundColor: c.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: c.ink),
        titleTextStyle: AppTextStyles.h3.copyWith(color: c.ink),
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 2,
        shadowColor: Colors.black54,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.rMd),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        // `.btn-primary`: amber, dark ink, h48, radius sm.
        style: ElevatedButton.styleFrom(
          backgroundColor: c.accent,
          foregroundColor: c.accentInk,
          disabledBackgroundColor: c.surface3,
          disabledForegroundColor: c.ink3,
          elevation: 0,
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.rSm),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        // `.btn-royal`: brand blue.
        style: FilledButton.styleFrom(
          backgroundColor: c.brand,
          foregroundColor: c.brandInk,
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.rSm),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        // `.btn-outline`.
        style: OutlinedButton.styleFrom(
          foregroundColor: c.ink,
          side: BorderSide(color: c.border2),
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.rSm),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.brand,
          textStyle: const TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        // `.field`: surface3 fill, hairline border, brand focus.
        filled: true,
        fillColor: c.surface3,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: AppRadius.rSm,
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.rSm,
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.rSm,
          borderSide: BorderSide(color: c.brand, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.rSm,
          borderSide: BorderSide(color: c.err),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.rSm,
          borderSide: BorderSide(color: c.err, width: 2),
        ),
        labelStyle: TextStyle(color: c.ink2),
        hintStyle: TextStyle(color: c.ink3),
      ),
      dividerTheme: DividerThemeData(
        color: c.border,
        thickness: 1,
        space: 1,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? c.brand : c.surface3,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? c.brand
              : Colors.transparent,
        ),
        side: BorderSide(color: c.border2, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? c.brand : c.border2,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.accent,
        linearTrackColor: c.surface3,
        circularTrackColor: c.surface3,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.accent,
        foregroundColor: c.accentInk,
        elevation: 0,
        highlightElevation: 0,
        extendedTextStyle: const TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.fab),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.surface3,
        labelStyle: AppTextStyles.label.copyWith(color: c.ink2),
        side: BorderSide.none,
        shape: const StadiumBorder(),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.rMd),
        titleTextStyle: AppTextStyles.h3.copyWith(color: c.ink),
        contentTextStyle: AppTextStyles.body.copyWith(color: c.ink2),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.surface2,
        contentTextStyle: AppTextStyles.body.copyWith(color: c.ink),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.rSm),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: c.ink2,
        textColor: c.ink,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.rSm),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: c.surface2,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.rSm),
        textStyle: AppTextStyles.body.copyWith(color: c.ink),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: c.ink,
        unselectedLabelColor: c.ink2,
        indicatorColor: c.brand,
        dividerColor: c.border,
      ),
    );
  }
}
