import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../settings/presentation/providers/permissions_provider.dart';
import '../../../../core/config/app_settings_provider.dart';
import '../../../../core/utils/season_utils.dart';
import '../../../users/presentation/providers/users_provider.dart';
import '../providers/sync_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final syncState = ref.watch(syncControllerProvider);
    final buildingsCount = ref.watch(buildingsCountProvider);
    final apartmentsCount = ref.watch(apartmentsCountProvider);

    final settingsAsync = ref.watch(appSettingsProvider);
    final activeSeasonKey =
        (settingsAsync.value?['active_season_key'] as String?) ??
        currentSeasonKey();
    final isWinter =
        activeSeasonKey.startsWith('winter') ||
        (settingsAsync.value?['active_season'] ?? 'winter') == 'winter';
    final role = ref.watch(currentUserRoleProvider).value;
    final isSuperAdmin = role == 'admin';
    final userId = ref.watch(authStateProvider).value?.session?.user.id;
    final rolesConfig = ref.watch(rolesConfigProvider);

    bool hasPerm(String perm) {
      if (isSuperAdmin) return true;
      if (userId == null) return false;
      final customRoleName = rolesConfig.userRoles[userId];
      if (customRoleName == null) return false;
      final perms = rolesConfig.roleTemplates[customRoleName] ?? [];
      return perms.contains(perm);
    }

    ref.listen<AsyncValue<void>>(syncControllerProvider, (_, state) {
      state.whenOrNull(
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sync failed: $error'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboardTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, size: 22),
            onPressed: () {
              context.push('/settings/notifications');
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              context.push('/search');
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.push('/settings');
            },
          ),
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
            if (hasPerm('view_apartments')) ...[
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
            ],

            if (hasPerm('manage_expenses') ||
                hasPerm('manage_maintenance') ||
                hasPerm('checkout_winter')) ...[
              Text(
                'العمليات والمالية',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (hasPerm('manage_expenses')) ...[
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.money_off,
                      color: Color(0xFFF4A225),
                    ),
                    title: Text(l10n.expenses),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.go('/expenses'),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.home_work,
                      color: Color(0xFFF4A225),
                    ),
                    title: Text(l10n.buildingRent),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.go('/building_rent'),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.account_balance_wallet,
                      color: Color(0xFFF4A225),
                    ),
                    title: const Text('الخزنة والتحويلات'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.go('/financial_transfers'),
                  ),
                ),
              ],
              if (hasPerm('manage_maintenance')) ...[
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.build, color: Color(0xFFF4A225)),
                    title: Text(l10n.maintenance),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.go('/maintenance'),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.engineering,
                      color: Color(0xFFF4A225),
                    ),
                    title: const Text('العمال والفنيين'),
                    subtitle: const Text(
                      'إدارة عمال الصيانة والسباكة والنجارة',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.go('/technicians'),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.cleaning_services,
                      color: Color(0xFFF4A225),
                    ),
                    title: const Text('أدوات ومواد النظافة'),
                    subtitle: const Text(
                      'إدارة المخزون من المنظفات وتسجيل الاستهلاك',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.go('/cleaning_supplies'),
                  ),
                ),
              ],
              if (hasPerm('checkout_winter')) ...[
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.check_circle_outline,
                      color: Color(0xFFF4A225),
                    ),
                    title: const Text('فحص واستلام الشقق'),
                    subtitle: const Text(
                      'تسجيل حالة الشقة، التلفيات، وغرامات المستأجرين',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.go('/inspections'),
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],

            if (hasPerm('manage_bookings') ||
                hasPerm('view_customers') ||
                hasPerm('view_brokers')) ...[
              Text(
                'الحجوزات والعقود',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (hasPerm('manage_bookings') && (isSuperAdmin || !isWinter))
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.calendar_month,
                      color: Color(0xFFF4A225),
                    ),
                    title: Text(l10n.summerBookings),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.go('/summer_bookings'),
                  ),
                ),
              if (hasPerm('manage_bookings') && (isSuperAdmin || isWinter))
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.school, color: Color(0xFFF4A225)),
                    title: Text(l10n.winterContracts),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.go('/winter_contracts'),
                  ),
                ),
              if (hasPerm('view_customers'))
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.people, color: Color(0xFFF4A225)),
                    title: const Text('إدارة العملاء'),
                    subtitle: const Text(
                      'سجل متكامل للعملاء المصيفين وطلبة الشتوي',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.go('/customers'),
                  ),
                ),
              if (hasPerm('view_brokers'))
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.handshake,
                      color: Color(0xFFF4A225),
                    ),
                    title: const Text('إدارة السماسرة'),
                    subtitle: const Text(
                      'إضافة سماسرة ومتابعة أرقامهم وعمولاتهم',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.go('/brokers'),
                  ),
                ),
              const SizedBox(height: 24),
            ],

            if (hasPerm('view_reports')) ...[
              Text(
                'التقارير المالية',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.analytics,
                    color: Color(0xFFF4A225),
                  ),
                  title: const Text('التقارير الإجمالية'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.go('/reports'),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.history, color: Color(0xFFF4A225)),
                  title: const Text('سجل النظام (الأنشطة)'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push('/reports/log'),
                ),
              ),
            ],
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
            Text(value, style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 4),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
