import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/widgets.dart';
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
    final colors = context.colors;
    final formatter = DateFormat('EEEE yyyy-MM-dd hh:mm a', 'ar');

    return AppScaffold(
      appBar: AbragAppBar(
        title: 'سجل النظام الشامل',
        actions: [
          AppIconButton(
            icon: Icons.refresh,
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
                child: AppTextField(
                  hint: 'ابحث في السجل باسم المستخدم أو العملية...',
                  prefixIcon: Icons.search,
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
                    ? const EmptyState(
                        icon: Icons.history,
                        title: 'لا توجد نتائج',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final log = filtered[index];
                          return AppCard(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            onTap: () => _showLogDetails(context, log),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                IconTile(
                                  icon: _getIconForType(log.type),
                                  tint: colors.brand,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        log.title,
                                        style: AppTextStyles.title.copyWith(
                                          color: colors.ink,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        log.description,
                                        style: AppTextStyles.bodyS.copyWith(
                                          color: colors.ink2,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'بواسطة: ${log.actorName}',
                                        style: AppTextStyles.bodyS.copyWith(
                                          color: colors.ink2,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        formatter.format(log.date.toLocal()),
                                        style: AppTextStyles.caption.copyWith(
                                          color: colors.ink3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.info_outline,
                                  size: 18,
                                  color: colors.ink3,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const LoadingSkeleton(),
        error: (err, st) => ErrorState(
          title: 'تعذر تحميل السجل',
          message: 'Error: $err',
          retryLabel: 'إعادة المحاولة',
          onRetry: () => ref.invalidate(systemLogsProvider),
        ),
      ),
    );
  }

  void _showLogDetails(BuildContext context, SystemLogEntry log) {
    final colors = context.colors;
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
            Text(
              log.title,
              style: AppTextStyles.h3.copyWith(color: colors.ink),
            ),
            const SizedBox(height: 8),
            Text(
              log.description,
              style: AppTextStyles.body.copyWith(color: colors.ink2),
            ),
            Divider(height: 24, color: colors.border),
            Text(
              'المستخدم: ${log.actorName}',
              style: AppTextStyles.body.copyWith(color: colors.ink),
            ),
            Text(
              'نوع العملية: ${log.action}',
              style: AppTextStyles.body.copyWith(color: colors.ink),
            ),
            Text(
              'القسم: ${_labelForType(log.type)}',
              style: AppTextStyles.body.copyWith(color: colors.ink),
            ),
            if (log.oldValuesJson != null) ...[
              const SizedBox(height: 16),
              Text(
                'قبل التعديل:',
                style: AppTextStyles.title.copyWith(color: colors.ink),
              ),
              Text(
                _prettyJson(log.oldValuesJson!),
                style: AppTextStyles.bodyS.copyWith(color: colors.ink2),
              ),
            ],
            if (log.newValuesJson != null) ...[
              const SizedBox(height: 16),
              Text(
                'بعد التعديل:',
                style: AppTextStyles.title.copyWith(color: colors.ink),
              ),
              Text(
                _prettyJson(log.newValuesJson!),
                style: AppTextStyles.bodyS.copyWith(color: colors.ink2),
              ),
            ],
            const SizedBox(height: 16),
            if (log.route != null)
              AppButton(
                label: 'فتح المكان المرتبط',
                icon: Icons.open_in_new,
                onPressed: () {
                  Navigator.pop(sheetContext);
                  context.push(log.route!);
                },
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
