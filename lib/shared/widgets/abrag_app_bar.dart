import 'package:flutter/material.dart';

import '../../core/theme/abrag_colors.dart';
import '../../core/theme/app_typography.dart';
import 'app_icon_button.dart';

/// Prototype app bar (`AppBar` in components.jsx): start-aligned title with
/// optional caption subtitle, direction-aware back chevron, trailing
/// [AppIconButton] actions. Transparent — sits on [AppBackground]/scaffold bg.
class AbragAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AbragAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.large = false,
    this.showBack,
    this.onBack,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;

  /// Large variant (`.appbar-lg`) uses the h1 style.
  final bool large;

  /// Defaults to whether the route can pop.
  final bool? showBack;
  final VoidCallback? onBack;
  final List<Widget> actions;

  @override
  Size get preferredSize => Size.fromHeight(large ? 74 : 60);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final canPop = showBack ?? Navigator.of(context).canPop();
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(
          canPop ? 8 : 18,
          6,
          12,
          large ? 16 : 12,
        ),
        child: Row(
          children: [
            if (canPop) ...[
              AppIconButton(
                icon: Icons.arrow_back_ios_new,
                onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(width: 4),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: (large ? AppTextStyles.h1 : AppTextStyles.h3)
                        .copyWith(color: colors.ink),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
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
