import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/meter_readings_provider.dart';

class MeterReadingsScreen extends ConsumerWidget {
  const MeterReadingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final readingsAsync = ref.watch(meterReadingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.meterReadings),
      ),
      body: readingsAsync.when(
        data: (readings) {
          if (readings.isEmpty) {
            return Center(child: Text(l10n.noData));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: readings.length,
            itemBuilder: (context, index) {
              final reading = readings[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: reading.isSharedExpense 
                                  ? theme.colorScheme.secondaryContainer 
                                  : theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              reading.isSharedExpense ? l10n.sharedExpense : l10n.individualExpense,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: reading.isSharedExpense 
                                    ? theme.colorScheme.onSecondaryContainer 
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          Text(
                            reading.readingDate.toLocal().toString().split(' ')[0],
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.previousReading, style: theme.textTheme.labelSmall),
                              Text(reading.previousReading.toString(), style: theme.textTheme.titleMedium),
                            ],
                          ),
                          const Icon(Icons.arrow_forward),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(l10n.currentReading, style: theme.textTheme.labelSmall),
                              Text(reading.currentReading.toString(), style: theme.textTheme.titleMedium),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('التكلفة', style: theme.textTheme.bodyMedium),
                          Text(
                            '${reading.amountEgp} ج.م',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add reading screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
