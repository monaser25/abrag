import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../providers/system_log_provider.dart';

class SystemLogScreen extends ConsumerStatefulWidget {
  const SystemLogScreen({super.key});

  @override
  ConsumerState<SystemLogScreen> createState() => _SystemLogScreenState();
}

class _SystemLogScreenState extends ConsumerState<SystemLogScreen> {
  String _query = '';
  String _type = 'all';

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(systemLogsProvider);
    final theme = Theme.of(context);
    final formatter = DateFormat('EEEE yyyy-MM-dd hh:mm a', 'ar');

    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل النظام الشامل'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(systemLogsProvider),
          ),
        ],
      ),
      body: logsAsync.when(
        data: (logs) {
          final types = ['all', ...logs.map((log) => log.type).toSet()];
          var filtered = logs;
          if (_type != 'all') {
            filtered = filtered.where((log) => log.type == _type).toList();
          }
          if (_query.trim().isNotEmpty) {
            final q = _query.trim().toLowerCase();
            filtered = filtered.where((log) {
              return log.title.toLowerCase().contains(q) ||
                  log.description.toLowerCase().contains(q) ||
                  log.actorName.toLowerCase().contains(q);
            }).toList();
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'ابحث في السجل باسم المستخدم أو العملية...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: types
                      .map(
                        (type) => Padding(
                          padding: const EdgeInsetsDirectional.only(end: 8),
                          child: ChoiceChip(
                            label: Text(
                              type == 'all' ? 'الكل' : _labelForType(type),
                            ),
                            selected: _type == type,
                            onSelected: (_) => setState(() => _type = type),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('لا توجد نتائج'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final log = filtered[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    theme.colorScheme.primaryContainer,
                                child: Icon(
                                  _getIconForType(log.type),
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              title: Text(
                                log.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(log.description),
                                  const SizedBox(height: 4),
                                  Text('بواسطة: ${log.actorName}'),
                                  const SizedBox(height: 4),
                                  Text(
                                    formatter.format(log.date.toLocal()),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: const Icon(
                                Icons.info_outline,
                                size: 18,
                              ),
                              onTap: () => _showLogDetails(context, log),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _showLogDetails(BuildContext context, SystemLogEntry log) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(16),
          children: [
            Text(log.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(log.description),
            const Divider(height: 24),
            Text('المستخدم: ${log.actorName}'),
            Text('نوع العملية: ${log.action}'),
            Text('القسم: ${_labelForType(log.type)}'),
            if (log.oldValuesJson != null) ...[
              const SizedBox(height: 16),
              const Text(
                'قبل التعديل:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(_prettyJson(log.oldValuesJson!)),
            ],
            if (log.newValuesJson != null) ...[
              const SizedBox(height: 16),
              const Text(
                'بعد التعديل:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(_prettyJson(log.newValuesJson!)),
            ],
            const SizedBox(height: 16),
            if (log.route != null)
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  context.push(log.route!);
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('فتح المكان المرتبط'),
              ),
          ],
        ),
      ),
    );
  }

  String _prettyJson(String jsonText) {
    try {
      return const JsonEncoder.withIndent('  ').convert(jsonDecode(jsonText));
    } catch (_) {
      return jsonText;
    }
  }

  String _labelForType(String type) {
    switch (type) {
      case 'summer_booking':
        return 'حجوزات الصيف';
      case 'winter_contract':
        return 'عقود الشتاء';
      case 'payment':
        return 'دفعات';
      case 'expense':
        return 'مصروفات';
      case 'financial_transfer':
        return 'الخزنة والتحويلات';
      case 'report':
        return 'التقارير والطباعة';
      case 'maintenance':
        return 'صيانة';
      case 'inspection':
        return 'فحص/تلفيات';
      case 'apartment':
        return 'شقق';
      case 'customer':
        return 'عملاء';
      case 'user':
        return 'مستخدمين';
      case 'meter_reading':
        return 'قراءات العدادات';
      case 'settings':
        return 'الإعدادات';
      case 'cleaning_supply':
      case 'cleaning_transaction':
        return 'النظافة والمخزون';
      default:
        return type;
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'summer_booking':
        return Icons.wb_sunny;
      case 'winter_contract':
        return Icons.ac_unit;
      case 'payment':
        return Icons.payments;
      case 'expense':
        return Icons.money_off;
      case 'financial_transfer':
        return Icons.account_balance_wallet;
      case 'report':
        return Icons.picture_as_pdf;
      case 'maintenance':
        return Icons.build;
      case 'inspection':
        return Icons.fact_check;
      case 'apartment':
        return Icons.apartment;
      case 'customer':
        return Icons.people;
      case 'user':
        return Icons.manage_accounts;
      case 'meter_reading':
        return Icons.electric_meter;
      case 'settings':
        return Icons.settings;
      case 'cleaning_supply':
      case 'cleaning_transaction':
        return Icons.cleaning_services;
      default:
        return Icons.history;
    }
  }
}
