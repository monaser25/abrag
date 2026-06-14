import 'package:flutter/material.dart';

import '../../core/theme/abrag_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';
import 'tappable.dart';

/// Square apartment grid cell (`.apt`): big unit number, status dot,
/// optional footer (e.g. cleaning state caption).
class ApartmentCell extends StatelessWidget {
  const ApartmentCell({
    super.key,
    required this.number,
    required this.statusColor,
    this.footer,
    this.onTap,
    this.selected = false,
  });

  final String number;
  final Color statusColor;
  final Widget? footer;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Tappable(
      onTap: onTap,
      pressedScale: 0.97,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: selected ? colors.surface2 : colors.surface,
            borderRadius: AppRadius.rSm,
            border: Border.all(
              color: selected ? colors.brand : colors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Status dot pinned to the top corner.
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Unit number centered in the tile.
              Expanded(
                child: Center(
                  child: Text(
                    number,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.tabular(
                      TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: colors.ink,
                      ),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              ?footer,
            ],
          ),
        ),
      ),
    );
  }
}
