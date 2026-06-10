import 'package:flutter/material.dart';

import '../../core/theme/abrag_colors.dart';
import '../../core/theme/app_radius.dart';

enum Season { summer, winter }

/// Season banner (`.season-hero`): large-radius card with a diagonal
/// season-tinted gradient.
class SeasonHero extends StatelessWidget {
  const SeasonHero({
    super.key,
    required this.season,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Season season;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final seasonColor = season == Season.summer ? colors.summer : colors.winter;
    final mix = season == Season.summer ? 0.24 : 0.22;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: AppRadius.rLg,
        border: Border.all(color: colors.border),
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            Color.alphaBlend(
              seasonColor.withValues(alpha: mix),
              colors.surface,
            ),
            colors.surface,
          ],
        ),
      ),
      child: child,
    );
  }
}
