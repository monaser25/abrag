import 'package:flutter/material.dart';

import '../../core/theme/abrag_colors.dart';
import '../../core/theme/app_typography.dart';

/// Dimmed, letter-spaced section heading with optional trailing action.
class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(4, 22, 4, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.label.copyWith(
              color: colors.ink3,
              letterSpacing: 0.72,
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}
