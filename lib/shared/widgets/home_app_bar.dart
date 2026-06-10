import 'package:flutter/material.dart';

import '../../core/theme/abrag_colors.dart';
import '../../core/theme/app_typography.dart';
import 'abrag_logo.dart';

/// Home-screen app bar (`HomeBar`/`RoleBar` in the prototype): brand logo,
/// title + caption, trailing icon actions. No back button — for root screens.
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(18, 8, 12, 12),
        child: Row(
          children: [
            const AbragLogo(size: 42, radius: 13),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.h3.copyWith(color: colors.ink),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      subtitle!,
                      style:
                          AppTextStyles.caption.copyWith(color: colors.ink3),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            ...actions,
          ],
        ),
      ),
    );
  }
}
