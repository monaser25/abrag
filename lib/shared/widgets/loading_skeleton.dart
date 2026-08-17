import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/abrag_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';
import 'app_card.dart';

/// Single skeleton placeholder box (`.skel`).
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 13,
    this.radius = AppRadius.skeleton,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.colors.surface2,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// List loading state (`Loading` in the prototype): pulsing skeleton cards
/// with a spinner caption. Strings are provided by the caller (localized).
class LoadingSkeleton extends StatefulWidget {
  const LoadingSkeleton({super.key, this.label, this.items = 3});

  final String? label;
  final int items;

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void initState() {
    super.initState();
    _controller.repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final pulse =
            0.55 +
            0.45 * (0.5 + 0.5 * math.sin(_controller.value * 2 * math.pi));
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              for (var i = 0; i < widget.items; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Opacity(
                    opacity: pulse,
                    child: AppCard(
                      child: Row(
                        children: [
                          const SkeletonBox(width: 40, height: 40, radius: 12),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                SkeletonBox(width: 160, height: 13),
                                SizedBox(height: 8),
                                SkeletonBox(width: 100, height: 11),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (widget.label != null) ...[
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.rotate(
                      angle: _controller.value * 2 * math.pi,
                      child: Icon(Icons.sync, size: 15, color: colors.ink3),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.label!,
                      style: AppTextStyles.caption.copyWith(color: colors.ink3),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
