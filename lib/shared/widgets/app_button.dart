import 'package:flutter/material.dart';

import '../../core/theme/abrag_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';
import 'tappable.dart';

/// Button variants from the prototype (`.btn-*`).
enum AppButtonVariant {
  /// Amber CTA (`.btn-primary`).
  primary,

  /// Royal blue (`.btn-royal`).
  royal,

  /// Soft surface (`.btn-ghost`).
  ghost,

  /// Hairline outline (`.btn-outline`).
  outline,
}

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.small = false,
    this.expand = false,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;

  /// `.btn-sm`: height 38, smaller type.
  final bool small;

  /// `.btn-block`: fill available width.
  final bool expand;

  /// Shows a spinner instead of the label and blocks taps.
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = onPressed != null || loading;

    final (Color bg, Color fg, BoxBorder? side, List<BoxShadow>? shadow) =
        switch (variant) {
      AppButtonVariant.primary => (
          colors.accent,
          colors.accentInk,
          null,
          [
            BoxShadow(
              color: colors.accent,
              offset: const Offset(0, 6),
              blurRadius: 18,
              spreadRadius: -8,
            ),
          ],
        ),
      AppButtonVariant.royal => (
          colors.brand,
          colors.brandInk,
          null,
          [
            BoxShadow(
              color: colors.brand,
              offset: const Offset(0, 6),
              blurRadius: 18,
              spreadRadius: -8,
            ),
          ],
        ),
      AppButtonVariant.ghost => (colors.surface3, colors.ink, null, null),
      AppButtonVariant.outline => (
          Colors.transparent,
          colors.ink,
          Border.all(color: colors.border2),
          null,
        ),
    };

    final height = small ? 38.0 : 48.0;
    final textStyle = TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: small ? 13.5 : 15,
      fontWeight: FontWeight.w600,
      color: fg,
    );

    return Tappable(
      onTap: loading ? null : onPressed,
      pressedScale: 0.97,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: Container(
          height: height,
          width: expand ? double.infinity : null,
          constraints: BoxConstraints(minWidth: height),
          padding: EdgeInsets.symmetric(horizontal: small ? 16 : 20),
          decoration: BoxDecoration(
            color: bg,
            border: side,
            borderRadius: AppRadius.rSm,
            boxShadow: enabled ? shadow : null,
          ),
          child: loading
              ? Center(
                  child: SizedBox(
                    width: small ? 16 : 20,
                    height: small ? 16 : 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: fg,
                    ),
                  ),
                )
              : Row(
                  mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: small ? 15 : 18, color: fg),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        style: textStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
