import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/season_utils.dart';
import '../../../../shared/widgets/widgets.dart';
import '../models/report_view_models.dart';
import '../providers/reports_provider.dart';

class ReportStatisticsScreen extends ConsumerWidget {
  final ReportFilterState filters;

  const ReportStatisticsScreen({
    super.key,
    this.filters = const ReportFilterState(),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(financialReportProvider);
    final colors = context.colors;

    return AppScaffold(
      appBar: const AbragAppBar(title: 'ملخص الإحصائيات'),
      body: reportAsync.when(
        data: (report) {
          final rentals = ReportCalculator.filteredRentals(report, filters);
          final apartments = ReportCalculator.apartmentMetrics(rentals);
          final summerApartments = ReportCalculator.apartmentMetrics(
            rentals.where((rental) => seasonMatchesKey(rental.season, 'summer')).toList(),
          );
          final floors = ReportCalculator.floorMetrics(rentals);
          final topSummerApartment = ReportCalculator.topByCount(
            summerApartments,
          );
          final topApartment = ReportCalculator.topByRentalValue(apartments);
          final lowApartment = ReportCalculator.lowByRentalValue(apartments);
          final topFloor = ReportCalculator.topByRentalValue(floors);
          final lowFloor = ReportCalculator.lowByRentalValue(floors);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _StatCard(
                title: 'أكثر شقة سكنت صيفاً',
                value: topSummerApartment == null
                    ? 'لا يوجد'
                    : '${topSummerApartment.label} - تم تأجيرها ${topSummerApartment.count} مرات',
                icon: Icons.beach_access,
                color: colors.summer,
                onTap: () => context.push(
                  '/reports/details/${ReportDetailKind.apartments.key}',
                  extra: filters.copyWith(season: 'summer'),
                ),
              ),
              _StatCard(
                title: 'أعلى شقة إيراداً',
                value: topApartment == null
                    ? 'لا يوجد'
                    : '${topApartment.label} - إجمالي الإيراد ${topApartment.rentalValue.toCurrencyFormat()} ج.م',
                icon: Icons.apartment,
                color: colors.brand,
                onTap: () => context.push(
                  '/reports/details/${ReportDetailKind.apartments.key}',
                  extra: filters,
                ),
              ),
              _StatCard(
                title: 'أقل شقة إيراداً',
                value: lowApartment == null
                    ? 'لا يوجد'
                    : '${lowApartment.label} - إجمالي الإيراد ${lowApartment.rentalValue.toCurrencyFormat()} ج.م',
                icon: Icons.trending_down,
                color: colors.err,
                onTap: () => context.push(
                  '/reports/details/${ReportDetailKind.apartments.key}',
                  extra: filters,
                ),
              ),
              _StatCard(
                title: 'أعلى دور إيراداً',
                value: topFloor == null
                    ? 'لا يوجد'
                    : '${topFloor.label} - إجمالي الإيراد ${topFloor.rentalValue.toCurrencyFormat()} ج.م',
                icon: Icons.layers,
                color: colors.winter,
                onTap: () => context.push(
                  '/reports/details/${ReportDetailKind.floors.key}',
                  extra: filters,
                ),
              ),
              _StatCard(
                title: 'أقل دور إيراداً',
                value: lowFloor == null
                    ? 'لا يوجد'
                    : '${lowFloor.label} - إجمالي الإيراد ${lowFloor.rentalValue.toCurrencyFormat()} ج.م',
                icon: Icons.layers_clear,
                color: colors.warn,
                onTap: () => context.push(
                  '/reports/details/${ReportDetailKind.floors.key}',
                  extra: filters,
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingSkeleton(),
        error: (error, stack) => ErrorState(
          title: 'تعذر تحميل الإحصائيات',
          message: 'Error: $error',
          retryLabel: 'إعادة المحاولة',
          onRetry: () => ref.invalidate(financialReportProvider),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconTile(icon: icon, tint: color, size: 48, iconSize: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.title.copyWith(color: colors.ink),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: AppTextStyles.body.copyWith(color: colors.ink2),
                ),
                const SizedBox(height: 8),
                Text(
                  'اضغط لعرض التقرير التفصيلي',
                  style: AppTextStyles.caption.copyWith(color: colors.brand),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_left, color: colors.ink3),
        ],
      ),
    );
  }
}
