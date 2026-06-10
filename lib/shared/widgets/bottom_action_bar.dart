import 'package:flutter/material.dart';

import '../../core/theme/abrag_colors.dart';

/// Pinned bottom action area (`.actionbar`): top hairline, safe-area aware.
/// Children are laid out in a row; pass [expanded] children yourself or use
/// the default equal spacing.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({super.key, required this.children, this.spacing = 12});

  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.bg,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) SizedBox(width: spacing),
                children[i],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
