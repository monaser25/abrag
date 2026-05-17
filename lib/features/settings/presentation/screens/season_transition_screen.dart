import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_settings_provider.dart';
import '../../../../core/database/database.dart';
import '../../../../core/utils/season_utils.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';

class SeasonTransitionScreen extends ConsumerWidget {
  const SeasonTransitionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(appSettingsProvider);
    final settingsController = ref.watch(appSettingsControllerProvider);
    final db = ref.watch(databaseProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('إدارة المواسم')),
      body: settingsAsync.when(
        data: (settings) {
          final activeSeason =
              (settings['active_season_key'] as String?) ?? currentSeasonKey();
          final hiddenSeasons = (settings['hidden_season_keys'] as List?)
                  ?.map((item) => item.toString())
                  .toSet() ??
              <String>{};
          final options = seasonOptionsAround(
            pastYears: 5,
            futureYears: 3,
            includeGeneric: false,
          ).where((option) => !hiddenSeasons.contains(option.key)).toList();
          final next = nextSeasonKey(activeSeason);

          Future<void> activateSeason(String key) async {
            final newSettings = Map<String, dynamic>.from(settings);
            final hidden = {...hiddenSeasons}..remove(key);
            newSettings['hidden_season_keys'] = hidden.toList();
            newSettings['active_season_key'] = key;
            newSettings['active_season'] = key.startsWith('summer')
                ? 'summer'
                : key.startsWith('winter')
                ? 'winter'
                : 'all';
            await settingsController.updateSettings(newSettings);
          }

          Future<void> hideSeason(String key) async {
            final usageCount = await _seasonUsageCount(db, key);
            if (!context.mounted) return;
            if (usageCount > 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'مينفعش حذف ${seasonLabel(key)} لأنه يحتوي على $usageCount عملية. يمكن تركه كأرشيف.',
                  ),
                ),
              );
              return;
            }

            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('حذف ${seasonLabel(key)}؟'),
                content: const Text(
                  'سيتم إخفاء الموسم الفارغ من القائمة. لو احتجته لاحقًا يمكن إنشاؤه/تفعيله مرة أخرى من بدء موسم جديد.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('إلغاء'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('حذف'),
                  ),
                ],
              ),
            );
            if (confirmed != true) return;

            final newSettings = Map<String, dynamic>.from(settings);
            final hidden = {...hiddenSeasons, key}.toList();
            newSettings['hidden_season_keys'] = hidden;
            if (key == activeSeason) {
              final fallback = currentSeasonKey();
              newSettings['active_season_key'] = fallback;
              newSettings['active_season'] = fallback.startsWith('summer')
                  ? 'summer'
                  : 'winter';
            }
            await settingsController.updateSettings(newSettings);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            child: Icon(
                              activeSeason.startsWith('summer')
                                  ? Icons.wb_sunny
                                  : Icons.ac_unit,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'الموسم النشط: ${seasonLabel(activeSeason)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'الموسم النشط هو اللي يظهر افتراضيًا في الفلاتر عشان الشغل اليومي ما يتلخبطش. المواسم القديمة لا تُحذف، وتفضل موجودة في التقارير وكشف الحساب وسجل النشاط.',
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () => activateSeason(next),
                        icon: const Icon(Icons.add),
                        label: Text('بدء ${seasonLabel(next)}'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'كل المواسم',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...options.map(
                (option) => FutureBuilder<int>(
                  future: _seasonUsageCount(db, option.key),
                  builder: (context, snapshot) {
                    final count = snapshot.data;
                    final isActive = option.key == activeSeason;
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          option.key.startsWith('summer')
                              ? Icons.wb_sunny
                              : Icons.ac_unit,
                          color: isActive
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                        title: Text(option.label),
                        subtitle: Text(
                          isActive
                              ? 'نشط حاليًا — أي بيانات جديدة ستدخل هنا'
                              : count == null
                                  ? 'جاري فحص بيانات الموسم...'
                                  : count == 0
                                      ? 'فارغ — يمكن حذفه من القائمة'
                                      : 'أرشيف يحتوي على $count عملية',
                        ),
                        trailing: Wrap(
                          spacing: 4,
                          children: [
                            if (isActive)
                              const Icon(Icons.check_circle)
                            else
                              TextButton(
                                onPressed: () => activateSeason(option.key),
                                child: const Text('تفعيل'),
                              ),
                            IconButton(
                              tooltip: 'حذف الموسم الفارغ',
                              onPressed: count == 0 &&
                                      option.key != currentSeasonKey()
                                  ? () => hideSeason(option.key)
                                  : null,
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

Future<int> _seasonUsageCount(AppDatabase db, String seasonKey) async {
  var count = 0;

  final summerBookings = await db.select(db.summerBookings).get();
  count += summerBookings
      .where((booking) => seasonMatchesDate(booking.checkInDate, seasonKey))
      .length;

  final winterContracts = await db.select(db.winterContracts).get();
  count += winterContracts
      .where((contract) => seasonMatchesDate(contract.startDate, seasonKey))
      .length;

  final winterPayments = await db.select(db.winterPayments).get();
  count += winterPayments
      .where((payment) => seasonMatchesDate(payment.paymentDate, seasonKey))
      .length;

  final expenses = await db.select(db.expenses).get();
  count += expenses
      .where(
        (expense) => seasonMatchesKey(
          normalizeStoredSeason(expense.season, expense.expenseDate),
          seasonKey,
        ),
      )
      .length;

  final transfers = await db.select(db.financialTransfers).get();
  count += transfers
      .where(
        (transfer) => seasonMatchesKey(
          normalizeStoredSeason(transfer.season, transfer.transferDate),
          seasonKey,
        ),
      )
      .length;

  return count;
}
