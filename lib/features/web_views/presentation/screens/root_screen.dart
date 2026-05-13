import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../users/presentation/providers/users_provider.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import 'broker_web_screen.dart';
import 'cleaner_web_screen.dart';
import 'viewer_web_screen.dart';

class RootScreen extends ConsumerWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roleAsync = ref.watch(currentUserRoleProvider);

    return roleAsync.when(
      data: (role) {
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
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(body: Center(child: Text('Error loading role: $e'))),
    );
  }
}
