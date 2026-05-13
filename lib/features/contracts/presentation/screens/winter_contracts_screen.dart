import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/contracts_provider.dart';

class WinterContractsScreen extends ConsumerWidget {
  const WinterContractsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final contractsAsync = ref.watch(winterContractsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.winterContracts),
      ),
      body: contractsAsync.when(
        data: (contracts) {
          if (contracts.isEmpty) {
            return Center(child: Text(l10n.noData));
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: contracts.length,
            itemBuilder: (context, index) {
              final contract = contracts[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () {
                    context.go('/winter_contracts/details/${contract.id}');
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                contract.studentName,
                                style: theme.textTheme.titleLarge,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: contract.isActive 
                                    ? theme.colorScheme.secondary.withValues(alpha: 0.2) 
                                    : theme.colorScheme.error.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: contract.isActive 
                                      ? theme.colorScheme.secondary 
                                      : theme.colorScheme.error,
                                )
                              ),
                              child: Text(
                                contract.isActive ? 'نشط' : 'منتهي',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: contract.isActive ? theme.colorScheme.secondary : theme.colorScheme.error,
                                ),
                              ),
                            )
                          ],
                        ),
                        if (contract.university != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.school, size: 16, color: theme.colorScheme.onSurfaceVariant),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  contract.university!,
                                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.monthlyRent,
                                  style: theme.textTheme.labelMedium,
                                ),
                                Text(
                                  '${contract.monthlyRentEgp} ج.م',
                                  style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.apartment, size: 16, color: theme.colorScheme.onSurfaceVariant),
                                const SizedBox(width: 4),
                                Text(
                                  contract.apartmentId, // Will want a join ideally, but okay for now
                                  style: theme.textTheme.labelLarge,
                                )
                              ],
                            )
                          ],
                        )
                      ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/winter_contracts/add');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
