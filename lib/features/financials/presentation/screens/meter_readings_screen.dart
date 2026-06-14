import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/widgets.dart';
import '../providers/meter_readings_provider.dart';

class MeterReadingsScreen extends ConsumerWidget {
  const MeterReadingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final readingsAsync = ref.watch(meterReadingsProvider);

    return AppScaffold(
      appBar: AbragAppBar(title: l10n.meterReadings),
      floatingActionButton: AppFab(
        onPressed: () => context.go('/meter_readings/add'),
        icon: Icons.add,
      ),
      body: readingsAsync.when(
        data: (readings) {
          if (readings.isEmpty) {
            return EmptyState(
              icon: Icons.speed_outlined,
              title: l10n.noData,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: readings.length,
            itemBuilder: (context, index) {
              final reading = readings[index];
              return _ReadingCard(reading: reading, l10n: l10n);
            },
          );
        },
        loading: () => const LoadingSkeleton(),
        error: (error, stack) => ErrorState(
          title: 'تعذّر تحميل القراءات',
          message: 'Error: $error',
          retryLabel: 'إعادة المحاولة',
          onRetry: () => ref.invalidate(meterReadingsProvider),
        ),
      ),
    );
  }
}

class _ReadingCard extends StatelessWidget {
  const _ReadingCard({required this.reading, required this.l10n});

  final dynamic reading;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shared = reading.isSharedExpense as bool;
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusChip(
                label: shared ? l10n.sharedExpense : l10n.individualExpense,
                kind: shared ? StatusChipKind.brand : StatusChipKind.neutral,
                icon: shared ? Icons.groups : Icons.person,
              ),
              Text(
                reading.readingDate.toLocal().toString().split(' ')[0],
                style: AppTextStyles.caption.copyWith(color: colors.ink3),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ReadingValue(
                  label: l10n.previousReading,
                  value: reading.previousReading.toString(),
                ),
              ),
              Icon(Icons.arrow_forward, size: 18, color: colors.ink3),
              Expanded(
                child: _ReadingValue(
                  label: l10n.currentReading,
                  value: reading.currentReading.toString(),
                  alignEnd: true,
                ),
              ),
            ],
          ),
          Divider(height: 24, color: colors.border),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'التكلفة',
                style: AppTextStyles.body.copyWith(color: colors.ink2),
              ),
              Text(
                '${reading.amountEgp} ج.م',
                style: AppTextStyles.tabular(
                  AppTextStyles.title.copyWith(color: colors.brand),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReadingValue extends StatelessWidget {
  const _ReadingValue({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: colors.ink3),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.tabular(
            AppTextStyles.h3.copyWith(color: colors.ink),
          ),
        ),
      ],
    );
  }
}
