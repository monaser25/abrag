import 'package:flutter/material.dart';

import '../../core/theme/abrag_colors.dart';
import '../../core/theme/app_typography.dart';

/// Label/value row for detail sheets (`DetailRow`).
class DetailRow extends StatelessWidget {
  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.strong = false,
    this.valueColor,
  });

  final String label;
  final String value;

  /// Renders the value in the title style (used for totals).
  final bool strong;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyS.copyWith(color: colors.ink2),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: (strong ? AppTextStyles.title : AppTextStyles.body)
                  .copyWith(color: valueColor ?? colors.ink),
            ),
          ),
        ],
      ),
    );
  }
}
