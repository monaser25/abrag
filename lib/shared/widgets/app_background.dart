import 'package:flutter/material.dart';

import '../../core/theme/abrag_colors.dart';

/// Page background (`.app-field`): vertical bg→bg2 gradient with a soft
/// radial brand glow bleeding in from the top — echoes the logo field.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colors.bg, colors.bg2],
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -1.1),
            radius: 1.3,
            colors: [
              colors.brand.withValues(alpha: 0.16),
              colors.brand.withValues(alpha: 0),
            ],
            stops: const [0, 0.55],
          ),
        ),
        child: child,
      ),
    );
  }
}
