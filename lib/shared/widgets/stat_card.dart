import 'package:flutter/material.dart';

import '../../core/theme/abrag_colors.dart';
import '../../core/theme/app_typography.dart';
import 'app_card.dart';
import 'icon_tile.dart';

/// Dashboard stat card (`StatCard` in the prototype): tinted icon tile,
/// large tabular value, secondary label.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.sub,
    this.tint,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? sub;
  final Color? tint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveTint = tint ?? colors.brand;
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          IconTile(icon: icon, tint: effectiveTint, size: 38),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.tabular(
              AppTextStyles.display.copyWith(color: colors.ink),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.bodyS.copyWith(color: colors.ink2),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (sub != null) ...[
            const SizedBox(height: 6),
            Text(
              sub!,
              style: AppTextStyles.caption.copyWith(color: colors.ink3),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
