import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsCard(
            context,
            title: 'الملف الشخصي',
            icon: Icons.person,
            route: '/settings/profile',
          ),
          _buildSettingsCard(
            context,
            title: 'المستخدمين والصلاحيات',
            icon: Icons.security,
            route: '/settings/users',
          ),
          _buildSettingsCard(
            context,
            title: 'الانتقال بين المواسم',
            icon: Icons.swap_horiz,
            route: '/settings/season_transition',
          ),
          _buildSettingsCard(
            context,
            title: 'الخزنة والتحويلات',
            icon: Icons.account_balance_wallet,
            route: '/financial_transfers',
          ),
          _buildSettingsCard(
            context,
            title: 'مواعيد الخروج',
            icon: Icons.schedule,
            route: '/settings/checkout_times',
          ),
          _buildSettingsCard(
            context,
            title: 'إدارة الخطوط الأرضية',
            icon: Icons.phone,
            route: '/apartments/landlines',
          ),
          _buildSettingsCard(
            context,
            title: 'تصدير / استيراد / مسح البيانات',
            icon: Icons.storage,
            route: '/settings/data_management',
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String route,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => context.push(route),
      ),
    );
  }
}
