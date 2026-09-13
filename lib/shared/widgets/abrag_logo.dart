import 'package:flutter/material.dart';

import '../../core/theme/abrag_colors.dart';

/// Brand mark (`Logo` in the prototype): rounded-square logo image with an
/// optional royal-blue glow. Falls back to a tinted icon if the asset is
/// unavailable.
class AbragLogo extends StatelessWidget {
  const AbragLogo({super.key, this.size = 64, this.radius, this.glow = false});

  final double size;
  final double? radius;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final r = radius ?? size * 0.3;
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: colors.brand.withValues(alpha: 0.7),
                  offset: const Offset(0, 10),
                  blurRadius: 40,
                  spreadRadius: -8,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  offset: const Offset(0, 4),
                  blurRadius: 14,
                  spreadRadius: -4,
                ),
              ],
      ),
      child: Image.asset(
        'assets/icons/abrag_icon.png',
        fit: BoxFit.cover,
        errorBuilder: (context, _, _) => ColoredBox(
          color: colors.brand,
          child: Icon(Icons.domain, size: size * 0.55, color: colors.brandInk),
        ),
      ),
    );
  }
}
