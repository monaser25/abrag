import 'package:flutter/material.dart';

import '../../core/theme/abrag_colors.dart';

/// Slim animated progress bar (`.prog`): h7, accent fill.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({super.key, required this.value, this.fillColor});

  /// Progress in `[0, 1]`.
  final double value;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Container(
        height: 7,
        color: colors.surface3,
        child: AnimatedFractionallySizedBox(
          duration: const Duration(milliseconds: 500),
          curve: const Cubic(0.22, 0.61, 0.36, 1),
          alignment: AlignmentDirectional.centerStart,
          widthFactor: value.clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              color: fillColor ?? colors.accent,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
      ),
    );
  }
}
