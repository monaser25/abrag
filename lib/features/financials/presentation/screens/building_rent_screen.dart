import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/expenses_provider.dart';

class BuildingRentScreen extends ConsumerWidget {
  const BuildingRentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final rentAsync = ref.watch(buildingRentProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.buildingRent),
      ),
      body: rentAsync.when(
        data: (rents) {
          if (rents.isEmpty) {
            return Center(child: Text(l10n.noData));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rents.length,
            itemBuilder: (context, index) {
              final rent = rents[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                    child: Icon(Icons.home_work, color: theme.colorScheme.primary),
                  ),
                  title: Text(
                    'دفعة إيجار المبنى (القسط ${rent.installmentNumber ?? "-"})',
                    style: theme.textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    rent.expenseDate.toLocal().toString().split(' ')[0],
                    style: theme.textTheme.bodySmall,
                  ),
                  trailing: Text(
                    '${rent.amountEgp} ج.م',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
