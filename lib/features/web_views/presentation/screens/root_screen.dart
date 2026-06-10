import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../users/presentation/providers/users_provider.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../dashboard/presentation/providers/sync_provider.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/widgets.dart';
import 'broker_web_screen.dart';
import 'cleaner_web_screen.dart';
import 'viewer_web_screen.dart';

class RootScreen extends ConsumerStatefulWidget {
  const RootScreen({super.key});

  @override
  ConsumerState<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends ConsumerState<RootScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger sync automatically when root screen mounts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PushNotificationService.registerCurrentDevice();
      ref.read(syncControllerProvider.notifier).syncData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final roleAsync = ref.watch(currentUserRoleProvider);

    return roleAsync.when(
      data: (role) {
        if (role == null) {
          return const _RoleLoadingShell(label: 'جاري إعداد بيئة العمل...');
        }

        switch (role) {
          case 'admin':
          case 'staff':
            return const DashboardScreen();
          case 'broker':
            return const BrokerWebScreen();
          case 'cleaner':
            return const CleanerWebScreen();
          case 'viewer':
          default:
            return const ViewerWebScreen();
        }
      },
      loading: () => const _RoleLoadingShell(),
      error: (e, st) => AppScaffold(
        body: ErrorState(
          title: 'تعذّر تحميل بيانات المستخدم',
          message: '$e',
          retryLabel: 'إعادة المحاولة',
          onRetry: () => ref.invalidate(currentUserRoleProvider),
        ),
      ),
    );
  }
}

/// Branded waiting shell shown while the user role resolves.
class _RoleLoadingShell extends StatelessWidget {
  const _RoleLoadingShell({this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppScaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AbragLogo(size: 64, glow: true),
            const SizedBox(height: 24),
            SpinningIcon(size: 20, color: colors.brand),
            if (label != null) ...[
              const SizedBox(height: 12),
              Text(
                label!,
                style: AppTextStyles.bodyS.copyWith(color: colors.ink2),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
