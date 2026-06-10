import 'package:flutter/material.dart';

import '../../core/theme/abrag_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';
import 'skyline_accent.dart';

/// Empty state (`EmptyState`): brand orb, title, optional subtitle/action,
/// skyline accent footer. Strings come from the caller (localized).
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.sub,
    this.icon = Icons.inbox_outlined,
    this.action,
  });

  final String title;
  final String? sub;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Orb(
              background: colors.brandSoft,
              haloColor: colors.border2,
              child: Icon(icon, size: 30, color: colors.brand),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: AppTextStyles.h3.copyWith(color: colors.ink),
              textAlign: TextAlign.center,
            ),
            if (sub != null) ...[
              const SizedBox(height: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 240),
                child: Text(
                  sub!,
                  style: AppTextStyles.bodyS.copyWith(color: colors.ink2),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 20),
              action!,
            ],
            const SizedBox(height: 26),
            const SizedBox(width: 180, child: SkylineAccent(height: 34)),
          ],
        ),
      ),
    );
  }
}

/// The 84px rounded orb with a faint halo ring (`.empty-orb`).
class _Orb extends StatelessWidget {
  const _Orb({
    required this.child,
    required this.background,
    required this.haloColor,
  });

  final Widget child;
  final Color background;
  final Color haloColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.emptyOrb + 6),
        border: Border.all(color: haloColor.withValues(alpha: 0.5)),
      ),
      child: Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadius.emptyOrb),
        ),
        child: Center(child: child),
      ),
    );
  }
}
