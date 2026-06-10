import 'package:flutter/material.dart';

import '../../core/theme/abrag_colors.dart';

/// Subtle towers silhouette (`Skyline` in the prototype) — brand accent for
/// empty states and section footers.
class SkylineAccent extends StatelessWidget {
  const SkylineAccent({
    super.key,
    this.height = 46,
    this.width,
    this.color,
    this.opacity = 0.16,
  });

  final double height;
  final double? width;
  final Color? color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: CustomPaint(
        size: Size(width ?? double.infinity, height),
        painter: _SkylinePainter(color ?? context.colors.brand),
      ),
    );
  }
}

class _SkylinePainter extends CustomPainter {
  _SkylinePainter(this.color);

  final Color color;

  // Tower height fractions from the prototype.
  static const _heights = [
    0.42, 0.70, 0.55, 0.92, 0.60, 1.00, 0.50, 0.78, 0.46,
    0.66, 0.55, 0.85, 0.50, 0.72, 0.44, 0.60, 0.80, 0.50,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final w = size.width / _heights.length;
    for (var i = 0; i < _heights.length; i++) {
      final h = _heights[i] * size.height;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(i * w + 1, size.height - h, w - 2, h),
          const Radius.circular(1.5),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SkylinePainter oldDelegate) =>
      oldDelegate.color != color;
}
