import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_settings_provider.dart';
import '../../../../core/database/database.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/season_utils.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';
import '../../../../shared/widgets/widgets.dart';

class SeasonTransitionScreen extends ConsumerWidget {
  const SeasonTransitionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(appSettingsProvider);
    final settingsController = ref.watch(appSettingsControllerProvider);
    final db = ref.watch(databaseProvider);
    final colors = context.colors;

    return AppScaffold(
      appBar: const AbragAppBar(title: 'إدارة المواسم'),
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
                backgroundColor: context.colors.surface,
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

          final isSummerActive = activeSeason.startsWith('summer');

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              AppCard(
                color: colors.brandSoft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconTile(
                          icon: isSummerActive
                              ? Icons.wb_sunny
                              : Icons.ac_unit,
                          tint: isSummerActive ? colors.summer : colors.winter,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'الموسم النشط: ${seasonLabel(activeSeason)}',
                            style:
                                AppTextStyles.h3.copyWith(color: colors.ink),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'الموسم النشط هو اللي يظهر افتراضيًا في الفلاتر عشان الشغل اليومي ما يتلخبطش. المواسم القديمة لا تُحذف، وتفضل موجودة في التقارير وكشف الحساب وسجل النشاط.',
                      style: AppTextStyles.bodyS.copyWith(color: colors.ink2),
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: 'بدء ${seasonLabel(next)}',
                      icon: Icons.add,
                      variant: AppButtonVariant.royal,
                      onPressed: () => activateSeason(next),
                    ),
                  ],
                ),
              ),
              const SectionTitle(title: 'كل المواسم'),
              ...options.map(
                (option) => FutureBuilder<int>(
                  future: _seasonUsageCount(db, option.key),
                  builder: (context, snapshot) {
                    final count = snapshot.data;
                    final isActive = option.key == activeSeason;
                    final isSummer = option.key.startsWith('summer');
                    return AppCard(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          IconTile(
                            icon: isSummer ? Icons.wb_sunny : Icons.ac_unit,
                            tint: isActive
                                ? colors.brand
                                : (isSummer ? colors.summer : colors.winter),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  option.label,
                                  style: AppTextStyles.title
                                      .copyWith(color: colors.ink),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isActive
                                      ? 'نشط حاليًا — أي بيانات جديدة ستدخل هنا'
                                      : count == null
                                          ? 'جاري فحص بيانات الموسم...'
                                          : count == 0
                                              ? 'فارغ — يمكن حذفه من القائمة'
                                              : 'أرشيف يحتوي على $count عملية',
                                  style: AppTextStyles.caption
                                      .copyWith(color: colors.ink3),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isActive)
                            StatusChip(
                              label: 'نشط',
                              kind: StatusChipKind.ok,
                              icon: Icons.check_circle,
                            )
                          else
                            AppButton(
                              label: 'تفعيل',
                              variant: AppButtonVariant.ghost,
                              small: true,
                              onPressed: () => activateSeason(option.key),
                            ),
                          AppIconButton(
                            tooltip: 'حذف الموسم الفارغ',
                            icon: Icons.delete_outline,
                            onPressed:
                                count == 0 && option.key != currentSeasonKey()
                                    ? () => hideSeason(option.key)
                                    : null,
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
        error: (e, st) => ErrorState(
          title: 'تعذّر تحميل المواسم',
          message: 'Error: $e',
          retryLabel: 'إعادة المحاولة',
          onRetry: () => ref.invalidate(appSettingsProvider),
        ),
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
