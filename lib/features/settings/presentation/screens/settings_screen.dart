import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../users/presentation/providers/users_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final roleAsync = ref.watch(currentUserRoleProvider);

    if (roleAsync.isLoading) {
      return const AppScaffold(
        body: SafeArea(child: LoadingSkeleton()),
      );
    }

    if (roleAsync.valueOrNull != 'admin') {
      return const AppScaffold(
        body: SafeArea(
          child: EmptyState(
            icon: Icons.lock_outline,
            title: 'غير مصرح لك بفتح الإعدادات',
          ),
        ),
      );
    }

    return AppScaffold(
      appBar: const AbragAppBar(title: 'الإعدادات', subtitle: 'للمدير فقط'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const SectionTitle(title: 'الحساب'),
          NavRow(
            icon: Icons.person_outline,
            title: 'الملف الشخصي',
            tint: colors.brand,
            onTap: () => context.push('/settings/profile'),
          ),
          NavRow(
            icon: Icons.security_outlined,
            title: 'المستخدمين والصلاحيات',
            tint: colors.accent,
            onTap: () => context.push('/settings/users'),
          ),
          const SectionTitle(title: 'التطبيق'),
          NavRow(
            icon: Icons.swap_horiz,
            title: 'الانتقال بين المواسم',
            tint: colors.summer,
            onTap: () => context.push('/settings/season_transition'),
          ),
          NavRow(
            icon: Icons.account_balance_wallet_outlined,
            title: 'الخزنة والتحويلات',
            tint: colors.ok,
            onTap: () => context.push('/financial_transfers'),
          ),
          NavRow(
            icon: Icons.schedule_outlined,
            title: 'مواعيد الخروج',
            tint: colors.winter,
            onTap: () => context.push('/settings/checkout_times'),
          ),
          NavRow(
            icon: Icons.phone_outlined,
            title: 'إدارة الخطوط الأرضية',
            tint: colors.brand,
            onTap: () => context.push('/apartments/landlines'),
          ),
          const SectionTitle(title: 'البيانات'),
          NavRow(
            icon: Icons.storage_outlined,
            title: 'تصدير / استيراد / مسح البيانات',
            tint: colors.ink2,
            onTap: () => context.push('/settings/data_management'),
          ),
        ],
      ),
    );
  }
}
