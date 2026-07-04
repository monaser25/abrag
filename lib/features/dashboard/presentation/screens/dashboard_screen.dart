import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../settings/presentation/providers/permissions_provider.dart';
import '../../../../core/config/app_settings_provider.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/season_utils.dart';
import '../../../users/presentation/providers/users_provider.dart';
import '../../../settings/presentation/providers/notifications_provider.dart';
import '../../../../shared/widgets/widgets.dart';
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
    final notificationsAsync = ref.watch(appNotificationsProvider);
    final role = ref.watch(currentUserRoleProvider).value;
    final isSuperAdmin = role == 'admin';
    final userId = ref.watch(authStateProvider).value?.session?.user.id;
    final rolesConfig = ref.watch(rolesConfigProvider);
    final colors = context.colors;

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
              content: const Text('فشلت المزامنة، تأكد من اتصال الإنترنت'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        },
      );
    });

    return AppScaffold(
      appBar: HomeAppBar(
        title: l10n.dashboardTitle,
        subtitle: l10n.dashboardWelcome,
        actions: [
          if (hasPerm('view_notifications'))
            AppIconButton(
              icon: Icons.notifications_none,
              badgeCount: notificationsAsync.value?.length ?? 0,
              onPressed: () {
                context.push('/notifications');
              },
            ),
          AppIconButton(
            icon: Icons.search,
            onPressed: () {
              context.push('/search');
            },
          ),
          if (isSuperAdmin)
            AppIconButton(
              icon: Icons.settings_outlined,
              onPressed: () {
                context.push('/settings');
              },
            ),
          // IconButton(
          //   icon: const Icon(Icons.admin_panel_settings),
          //   tooltip: 'ترقية الحساب لمدير',
          //   onPressed: () async {
          //     try {
          //       await Supabase.instance.client.functions.invoke(
          //         'make-me-admin',
          //       );
          //       if (context.mounted) {
          //         ScaffoldMessenger.of(context).showSnackBar(
          //           const SnackBar(
          //             content: Text(
          //               'أنت الآن مدير! اعمل إعادة تشغيل (Sync) للتطبيق.',
          //             ),
          //           ),
          //         );
          //       }
          //     } catch (e) {
          //       if (context.mounted) {
          //         ScaffoldMessenger.of(
          //           context,
          //         ).showSnackBar(SnackBar(content: Text('Error: $e')));
          //       }
          //     }
          //   },
          // ),
          if (syncState.isLoading)
            const SizedBox(
              width: 42,
              height: 42,
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            AppIconButton(
              icon: Icons.sync,
              onPressed: () {
                ref.read(syncControllerProvider.notifier).syncData();
              },
            ),
          AppIconButton(
            icon: Icons.logout,
            onPressed: () {
              ref.read(loginControllerProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(syncControllerProvider.notifier).syncData(),
        child: ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 28),
          children: [
            SeasonHero(
              season: isWinter ? Season.winter : Season.summer,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatusChip(
                    kind: isWinter
                        ? StatusChipKind.winter
                        : StatusChipKind.summer,
                    icon: isWinter ? Icons.ac_unit : Icons.wb_sunny_outlined,
                    label: isWinter ? 'الموسم الشتوي' : 'موسم المصيف',
                  ),
                  Row(
                    children: [
                      if (syncState.isLoading)
                        SpinningIcon(size: 13, color: colors.brand)
                      else
                        Icon(
                          Icons.check_circle_outline,
                          size: 13,
                          color: colors.ok,
                        ),
                      const SizedBox(width: 5),
                      Text(
                        syncState.isLoading ? 'جارٍ المزامنة' : 'تمت المزامنة',
                        style: AppTextStyles.caption.copyWith(
                          color: colors.ink3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (hasPerm('view_apartments')) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.domain,
                      label: l10n.buildings,
                      value: buildingsCount.when(
                        data: (count) => count.toString(),
                        loading: () => '...',
                        error: (err, stack) => '!',
                      ),
                      tint: colors.brand,
                      onTap: () => context.go('/buildings'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      icon: Icons.apartment,
                      label: l10n.apartments,
                      value: apartmentsCount.when(
                        data: (count) => count.toString(),
                        loading: () => '...',
                        error: (err, stack) => '!',
                      ),
                      tint: colors.accent,
                      onTap: () => context.go('/apartments'),
                    ),
                  ),
                ],
              ),
            ],

            if (hasPerm('manage_expenses') ||
                hasPerm('manage_maintenance') ||
                hasPerm('checkout_winter')) ...[
              const SectionTitle(title: 'العمليات والمالية'),
              if (hasPerm('manage_expenses')) ...[
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 9,
                  crossAxisSpacing: 9,
                  childAspectRatio: 2.85,
                  children: [
                    MiniNavCard(
                      icon: Icons.account_balance_wallet_outlined,
                      title: l10n.expenses,
                      tint: colors.brand,
                      onTap: () => context.go('/expenses'),
                    ),
                    MiniNavCard(
                      icon: Icons.home_work_outlined,
                      title: l10n.buildingRent,
                      tint: colors.accent,
                      onTap: () => context.go('/building_rent'),
                    ),
                    MiniNavCard(
                      icon: Icons.savings_outlined,
                      title: 'الخزنة والتحويلات',
                      tint: colors.ok,
                      onTap: () => context.go('/financial_transfers'),
                    ),
                    MiniNavCard(
                      icon: Icons.beach_access_outlined,
                      title: 'حجوزات الصيف',
                      tint: colors.summer,
                      onTap: () => context.go('/summer_bookings'),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
              ],
              if (hasPerm('manage_maintenance')) ...[
                NavRow(
                  icon: Icons.build_outlined,
                  title: l10n.maintenance,
                  tint: colors.summer,
                  onTap: () => context.go('/maintenance'),
                ),
                NavRow(
                  icon: Icons.engineering_outlined,
                  title: 'العمال والفنيين',
                  sub: 'إدارة عمال الصيانة والسباكة والنجارة',
                  tint: colors.brand,
                  onTap: () => context.go('/technicians'),
                ),
                NavRow(
                  icon: Icons.cleaning_services_outlined,
                  title: 'أدوات ومواد النظافة',
                  sub: 'إدارة المخزون من المنظفات وتسجيل الاستهلاك',
                  tint: colors.ok,
                  onTap: () => context.go('/cleaning_supplies'),
                ),
              ],
              if (hasPerm('checkout_winter'))
                NavRow(
                  icon: Icons.fact_check_outlined,
                  title: 'فحص واستلام الشقق',
                  sub: 'تسجيل حالة الشقة، التلفيات، وغرامات المستأجرين',
                  tint: colors.winter,
                  onTap: () => context.go('/inspections'),
                ),
            ],

            if (hasPerm('manage_bookings') ||
                hasPerm('view_customers') ||
                hasPerm('view_brokers')) ...[
              const SectionTitle(title: 'الحجوزات والعقود'),
              if (hasPerm('manage_bookings') && (isSuperAdmin || !isWinter))
                NavRow(
                  icon: Icons.wb_sunny_outlined,
                  title: l10n.summerBookings,
                  tint: colors.summer,
                  onTap: () => context.go('/summer_bookings'),
                ),
              if (hasPerm('manage_bookings') && (isSuperAdmin || isWinter))
                NavRow(
                  icon: Icons.ac_unit,
                  title: l10n.winterContracts,
                  tint: colors.winter,
                  onTap: () => context.go('/winter_contracts'),
                ),
              if (hasPerm('view_customers'))
                NavRow(
                  icon: Icons.people_outline,
                  title: 'إدارة العملاء',
                  sub: 'سجل متكامل للعملاء المصيفين وطلبة الشتوي',
                  tint: colors.brand,
                  onTap: () => context.go('/customers'),
                ),
              if (hasPerm('view_brokers'))
                NavRow(
                  icon: Icons.handshake_outlined,
                  title: 'إدارة السماسرة',
                  sub: 'إضافة سماسرة ومتابعة أرقامهم وعمولاتهم',
                  tint: colors.accent,
                  onTap: () => context.go('/brokers'),
                ),
            ],

            if (hasPerm('view_reports')) ...[
              const SectionTitle(title: 'التقارير المالية'),
              NavRow(
                icon: Icons.analytics_outlined,
                title: 'التقارير الإجمالية',
                tint: colors.brand,
                onTap: () => context.go('/reports'),
              ),
              NavRow(
                icon: Icons.history,
                title: 'سجل النظام (الأنشطة)',
                tint: colors.accent,
                onTap: () => context.push('/reports/log'),
              ),
            ],

            const SizedBox(height: 18),
            Opacity(
              opacity: 0.6,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.domain, size: 13, color: colors.ink3),
                  const SizedBox(width: 6),
                  Text(
                    'أبراج · يعمل دون اتصال',
                    style: AppTextStyles.caption.copyWith(color: colors.ink3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
