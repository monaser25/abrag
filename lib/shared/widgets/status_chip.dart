import 'package:flutter/material.dart';

import '../../core/theme/abrag_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';

/// Chip kinds from the prototype (`.chip-*`).
enum StatusChipKind { ok, warn, err, summer, winter, neutral, brand }

/// Pill status chip: soft tinted background, colored text, leading dot or icon.
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    this.kind = StatusChipKind.neutral,
    this.icon,
  });

  final String label;
  final StatusChipKind kind;

  /// Replaces the default 6px dot when provided.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (Color fg, Color bg) = switch (kind) {
      StatusChipKind.ok => (colors.ok, colors.okSoft),
      StatusChipKind.warn => (colors.warn, colors.warnSoft),
      StatusChipKind.err => (colors.err, colors.errSoft),
      StatusChipKind.summer => (colors.summer, colors.summerSoft),
      StatusChipKind.winter => (colors.winter, colors.winterSoft),
      StatusChipKind.neutral => (colors.ink2, colors.surface3),
      StatusChipKind.brand => (colors.brand, colors.brandSoft),
    };

    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.rPill),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(icon, size: 12, color: fg)
          else
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.12,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
