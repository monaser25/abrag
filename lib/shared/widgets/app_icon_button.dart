import 'package:flutter/material.dart';

import '../../core/theme/abrag_colors.dart';
import '../../core/theme/app_radius.dart';
import 'tappable.dart';

/// 42px rounded icon button (`.iconbtn`) with optional amber count badge
/// and active (brand-tinted) state.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.badgeCount = 0,
    this.active = false,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final int badgeCount;
  final bool active;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Widget button = Tappable(
      onTap: onPressed,
      pressedScale: 0.92,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: active ? colors.brandSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.iconButton),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Icon(
                icon,
                size: 21,
                color: active ? colors.brand : colors.ink,
              ),
            ),
            if (badgeCount > 0)
              PositionedDirectional(
                top: 4,
                end: 4,
                child: Container(
                  constraints:
                      const BoxConstraints(minWidth: 16, minHeight: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: colors.accent,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: colors.bg, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '$badgeCount',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: colors.accentInk,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
