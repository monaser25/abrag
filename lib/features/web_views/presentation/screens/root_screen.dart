import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../users/presentation/providers/users_provider.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../dashboard/presentation/providers/sync_provider.dart';
import '../../../../core/services/push_notification_service.dart';
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
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('جاري إعداد بيئة العمل...'),
                ],
              ),
            ),
          );
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
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) =>
          Scaffold(body: Center(child: Text('Error loading role: $e'))),
    );
  }
}
