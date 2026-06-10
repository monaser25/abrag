import 'package:flutter/material.dart';

import '../../core/theme/abrag_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';
import 'app_card.dart';
import 'icon_tile.dart';

/// Compact inline metric (`MiniMetric`): small tile + value + caption.
class MiniMetric extends StatelessWidget {
  const MiniMetric({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.tint,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconTile(
          icon: icon,
          tint: tint ?? colors.brand,
          size: 34,
          iconSize: 17,
          radius: AppRadius.iconTileSm,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: AppTextStyles.tabular(
                AppTextStyles.h3.copyWith(color: colors.ink, height: 1.1),
              ),
            ),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(color: colors.ink3),
            ),
          ],
        ),
      ],
    );
  }
}

/// Compact navigation card (`MiniNav`): tile + title, used in shortcut grids.
class MiniNavCard extends StatelessWidget {
  const MiniNavCard({
    super.key,
    required this.icon,
    required this.title,
    this.tint,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final Color? tint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          IconTile(
            icon: icon,
            tint: tint ?? colors.brand,
            size: 36,
            iconSize: 18,
            radius: AppRadius.iconTileSm,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.title.copyWith(color: colors.ink),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
