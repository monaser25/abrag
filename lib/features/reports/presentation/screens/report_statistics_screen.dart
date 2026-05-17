import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/season_utils.dart';
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

    return Scaffold(
      appBar: AppBar(title: const Text('ملخص الإحصائيات')),
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
                color: Colors.orange,
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
                color: Colors.blue,
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
                color: Theme.of(context).colorScheme.error,
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
                color: Colors.teal,
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
                color: Colors.brown,
                onTap: () => context.push(
                  '/reports/details/${ReportDetailKind.floors.key}',
                  extra: filters,
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
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
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(value, style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 8),
                    Text(
                      'اضغط لعرض التقرير التفصيلي',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left),
            ],
          ),
        ),
      ),
    );
  }
}
