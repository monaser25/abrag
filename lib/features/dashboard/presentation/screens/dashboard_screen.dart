import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/sync_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final syncState = ref.watch(syncControllerProvider);
    final buildingsCount = ref.watch(buildingsCountProvider);
    final apartmentsCount = ref.watch(apartmentsCountProvider);

    ref.listen<AsyncValue<void>>(
      syncControllerProvider,
      (_, state) {
        state.whenOrNull(
          error: (error, _) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Sync failed: $error'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          },
          data: (_) {
            // Only show success if it wasn't a loading state before
            // Or use a more sophisticated approach
          },
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboardTitle),
        actions: [
          IconButton(
            icon: syncState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            onPressed: syncState.isLoading
                ? null
                : () {
                    ref.read(syncControllerProvider.notifier).syncData();
                  },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(loginControllerProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(syncControllerProvider.notifier).syncData(),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              l10n.dashboardWelcome,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => context.go('/buildings'),
                    child: _StatCard(
                      title: l10n.buildings,
                      value: buildingsCount.when(
                        data: (count) => count.toString(),
                        loading: () => '...',
                        error: (err, stack) => '!',
                      ),
                      icon: Icons.domain,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => context.go('/apartments'),
                    child: _StatCard(
                      title: l10n.apartments,
                      value: apartmentsCount.when(
                        data: (count) => count.toString(),
                        loading: () => '...',
                        error: (err, stack) => '!',
                      ),
                      icon: Icons.apartment,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_month, color: Color(0xFFF4A225)),
                title: Text(l10n.summerBookings),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  context.go('/summer_bookings');
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.school, color: Color(0xFFF4A225)),
                title: Text(l10n.winterContracts),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  context.go('/winter_contracts');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
