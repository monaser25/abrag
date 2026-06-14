import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/data_management_provider.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/widgets.dart';

class DataManagementScreen extends ConsumerStatefulWidget {
  const DataManagementScreen({super.key});

  @override
  ConsumerState<DataManagementScreen> createState() =>
      _DataManagementScreenState();
}

class _DataManagementScreenState extends ConsumerState<DataManagementScreen> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AbragAppBar(title: 'إدارة البيانات'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _ActionCard(
            title: 'تصدير كل البيانات',
            subtitle: 'ينشئ ملف JSON تقدر تحتفظ به أو تبعته لنفسك.',
            icon: Icons.upload_file,
            onTap: _busy
                ? null
                : () async {
                    await _run(() async {
                      final file = await ref
                          .read(dataManagementProvider)
                          .exportAllData();
                      await ref.read(dataManagementProvider).shareExport(file);
                    });
                  },
          ),
          _ActionCard(
            title: 'استيراد بيانات',
            subtitle: 'استيراد ملف JSON قديم أو قائمة عملاء.',
            icon: Icons.download,
            onTap: _busy
                ? null
                : () async {
                    await _run(
                      () => ref
                          .read(dataManagementProvider)
                          .importDataFromPickedFile(),
                    );
                  },
          ),
          _ActionCard(
            title: 'مسح البيانات',
            subtitle:
                'خطر: يمسح بيانات التشغيل المحلية بعد إدخال باسورد الإيميل.',
            icon: Icons.delete_forever,
            danger: true,
            onTap: _busy ? null : _confirmClearData,
          ),
        ],
      ),
    );
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم تنفيذ العملية بنجاح')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ: $error')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmClearData() async {
    final passwordController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final colors = dialogContext.colors;
        return AlertDialog(
          backgroundColor: colors.surface,
          title: const Text('تأكيد مسح البيانات'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'اكتب باسورد الإيميل لتأكيد المسح.',
                style: AppTextStyles.bodyS.copyWith(color: colors.ink2),
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: passwordController,
                label: 'كلمة المرور',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('إلغاء'),
            ),
            AppButton(
              label: 'مسح',
              variant: AppButtonVariant.royal,
              small: true,
              onPressed: () => Navigator.pop(dialogContext, true),
            ),
          ],
        );
      },
    );
    if (confirmed == true && passwordController.text.isNotEmpty) {
      await _run(
        () => ref
            .read(dataManagementProvider)
            .clearAllDataWithPassword(passwordController.text),
      );
    }
    passwordController.dispose();
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final bool danger;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tint = danger ? colors.err : colors.brand;
    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          IconTile(icon: icon, tint: tint),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.title.copyWith(
                    color: danger ? colors.err : colors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.bodyS.copyWith(color: colors.ink2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.arrow_forward_ios, size: 14, color: colors.ink3),
        ],
      ),
    );
  }
}
