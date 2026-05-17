import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/data_management_provider.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة البيانات')),
      body: ListView(
        padding: const EdgeInsets.all(16),
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
      builder: (dialogContext) => AlertDialog(
        title: const Text('تأكيد مسح البيانات'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('اكتب باسورد الإيميل لتأكيد المسح.'),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'كلمة المرور'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('مسح'),
          ),
        ],
      ),
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
    final color = danger
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.14),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(subtitle),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
