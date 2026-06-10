import 'package:flutter/material.dart';

import '../../core/theme/app_radius.dart';

/// Rounded icon tile on a soft tint (`.itile`) — the leading element of
/// stat cards, nav rows, and mini tiles.
class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    required this.icon,
    required this.tint,
    this.size = 40,
    this.iconSize = 20,
    this.radius = AppRadius.iconTile,
  });

  final IconData icon;
  final Color tint;
  final double size;
  final double iconSize;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(icon, size: iconSize, color: tint),
    );
  }
}
