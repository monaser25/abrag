import 'package:flutter/material.dart';

import '../../core/theme/abrag_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';
import 'app_button.dart';

/// Error state (`ErrorState`) with a retry action.
/// Strings come from the caller (localized).
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.title,
    required this.message,
    required this.retryLabel,
    this.onRetry,
  });

  final String title;
  final String message;
  final String retryLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: colors.errSoft,
                borderRadius: BorderRadius.circular(AppRadius.emptyOrb),
              ),
              child: Icon(Icons.warning_amber_rounded,
                  size: 28, color: colors.err),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: AppTextStyles.h3.copyWith(color: colors.ink),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 250),
              child: Text(
                message,
                style: AppTextStyles.bodyS.copyWith(color: colors.ink2),
                textAlign: TextAlign.center,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 18),
              AppButton(
                label: retryLabel,
                icon: Icons.sync,
                variant: AppButtonVariant.outline,
                small: true,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
