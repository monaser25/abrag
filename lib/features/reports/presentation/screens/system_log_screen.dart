import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/system_log_provider.dart';

class SystemLogScreen extends ConsumerWidget {
  const SystemLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(systemLogsProvider);
    final theme = Theme.of(context);
    final formatter = DateFormat('EEEE yyyy-MM-dd hh:mm a', 'ar');

    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل النظام الشامل'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(systemLogsProvider);
            },
          )
        ],
      ),
      body: logsAsync.when(
        data: (logs) {
          if (logs.isEmpty) {
            return const Center(child: Text('لا توجد نشاطات مسجلة بعد'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(_getIconForType(log.type), color: theme.colorScheme.primary),
                  ),
                  title: Text(log.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(log.description),
                      const SizedBox(height: 4),
                      Text(
                        formatter.format(log.date.toLocal()),
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'expense': return Icons.money_off;
      case 'summer_booking': return Icons.wb_sunny;
      case 'winter_contract': return Icons.ac_unit;
      case 'payment': return Icons.payments;
      case 'maintenance': return Icons.build;
      case 'maintenance_resolved': return Icons.check_circle;
      case 'inspection': return Icons.fact_check;
      case 'cleaning': return Icons.cleaning_services;
      case 'building': return Icons.domain;
      case 'apartment': return Icons.apartment;
      default: return Icons.info;
    }
  }
}
