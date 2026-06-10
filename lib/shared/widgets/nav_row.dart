import 'package:flutter/material.dart';

import '../../core/theme/abrag_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_typography.dart';
import 'icon_tile.dart';
import 'status_chip.dart';
import 'tappable.dart';

/// Navigation row (`NavRow`): tinted icon tile, title + caption, optional
/// trailing widget/badge, direction-aware chevron.
class NavRow extends StatelessWidget {
  const NavRow({
    super.key,
    required this.icon,
    required this.title,
    this.sub,
    this.tint,
    this.onTap,
    this.trailing,
    this.badge,
  });

  final IconData icon;
  final String title;
  final String? sub;
  final Color? tint;
  final VoidCallback? onTap;
  final Widget? trailing;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Tappable(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsetsDirectional.fromSTEB(14, 13, 14, 13),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AppRadius.rMd,
          boxShadow: AppShadows.sm,
        ),
        child: Row(
          children: [
            IconTile(icon: icon, tint: tint ?? colors.brand),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.title.copyWith(color: colors.ink),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (sub != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      sub!,
                      style:
                          AppTextStyles.caption.copyWith(color: colors.ink3),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
            if (badge != null) ...[
              const SizedBox(width: 8),
              StatusChip(label: badge!, kind: StatusChipKind.brand),
            ],
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: colors.ink3,
            ),
          ],
        ),
      ),
    );
  }
}
