import 'package:flutter/material.dart';

import '../../core/theme/abrag_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_typography.dart';
import 'tappable.dart';

/// Amber extended FAB (`.fab`): h54, radius 18, glow.
/// Use as `Scaffold.floatingActionButton`.
class AppFab extends StatelessWidget {
  const AppFab({
    super.key,
    required this.onPressed,
    this.icon = Icons.add,
    this.label,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Tappable(
      onTap: onPressed,
      pressedScale: 0.95,
      child: Container(
        height: 54,
        padding: EdgeInsets.symmetric(horizontal: label != null ? 22 : 17),
        decoration: BoxDecoration(
          color: colors.accent,
          borderRadius: BorderRadius.circular(AppRadius.fab),
          boxShadow: AppShadows.fabGlow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: colors.accentInk),
            if (label != null) ...[
              const SizedBox(width: 9),
              Text(
                label!,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: colors.accentInk,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
