import 'package:flutter/material.dart';

import '../../core/theme/abrag_colors.dart';
import '../../core/theme/app_typography.dart';

/// Initials avatar (`Avatar`): tinted circle with up to two initials.
class AppAvatar extends StatelessWidget {
  const AppAvatar({super.key, required this.name, this.size = 40, this.tint});

  final String name;
  final double size;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveTint = tint ?? colors.brand;
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w.characters.first)
        .join();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: effectiveTint.withValues(alpha: 0.18),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials.isEmpty ? '?' : initials,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: size * 0.36,
            fontWeight: FontWeight.w700,
            color: effectiveTint,
          ),
        ),
      ),
    );
  }
}
