import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/contracts_provider.dart';
import '../../../dashboard/presentation/providers/sync_provider.dart';

class WinterContractsScreen extends ConsumerWidget {
  const WinterContractsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final contractsAsync = ref.watch(winterContractsProvider);
    final apartmentsCountAsync = ref.watch(apartmentsCountProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.winterContracts),
      ),
      body: contractsAsync.when(
        data: (contracts) {
          final activeContracts = contracts.where((c) => c.isActive).toList();
          final totalRent = activeContracts.fold(0.0, (sum, c) => sum + c.monthlyRentEgp);
          
          final totalApts = apartmentsCountAsync.value ?? 15;
          final emptyApts = totalApts - activeContracts.length;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: CustomScrollView(
              slivers: [
              // Season Indicator
              SliverToBoxAdapter(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.ac_unit, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'موسم الشتاء 2024-2025',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Summary Row
              SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        context,
                        icon: Icons.home_work,
                        title: 'المشغولة',
                        value: '${activeContracts.length}',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSummaryCard(
                        context,
                        icon: Icons.key_off,
                        title: 'الفاضية',
                        value: '${emptyApts > 0 ? emptyApts : 0}',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: _buildSummaryCard(
                        context,
                        icon: Icons.payments,
                        title: 'إجمالي الإيجارات',
                        value: '$totalRent ج.م',
                        isHighlight: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),

              // Section Title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('قائمة المستأجرين', style: theme.textTheme.titleLarge),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.filter_list),
                        label: const Text('تصفية'),
                      ),
                    ],
                  ),
                ),
              ),

              // Contracts List
              if (contracts.isEmpty)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(l10n.noData),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final contract = contracts[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                        ),
                        child: InkWell(
                          onTap: () => context.go('/winter_contracts/details/${contract.id}'),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                      child: Text(contract.apartmentId.substring(0, 1)), // Just placeholder
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            contract.studentName,
                                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(Icons.calendar_month, size: 14, color: theme.colorScheme.onSurfaceVariant),
                                              const SizedBox(width: 4),
                                              Text(
                                                'من ${contract.startDate.month}/${contract.startDate.year} إلى ${contract.endDate.month}/${contract.endDate.year}',
                                                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${contract.monthlyRentEgp} ج.م',
                                          style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                                        ),
                                        Text('شهرياً', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                                      ],
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: contract.isActive 
                                            ? Colors.green.withValues(alpha: 0.1) 
                                            : theme.colorScheme.error.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: contract.isActive ? Colors.green.withValues(alpha: 0.5) : theme.colorScheme.error.withValues(alpha: 0.5),
                                        )
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(contract.isActive ? Icons.check_circle : Icons.cancel, 
                                               size: 14, 
                                               color: contract.isActive ? Colors.green : theme.colorScheme.error),
                                          const SizedBox(width: 4),
                                          Text(
                                            contract.isActive ? 'نشط' : 'منتهي',
                                            style: theme.textTheme.labelSmall?.copyWith(
                                              color: contract.isActive ? Colors.green : theme.colorScheme.error,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text('كهرباء: على الطالب', style: theme.textTheme.labelSmall),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: contracts.length,
                  ),
                ),
            ],
          ),
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

  Widget _buildSummaryCard(BuildContext context, {
    required IconData icon, 
    required String title, 
    required String value, 
    bool isHighlight = false
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: isHighlight ? 0.4 : 0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: isHighlight ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(title, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(
            value, 
            style: theme.textTheme.titleMedium?.copyWith(
              color: isHighlight ? theme.colorScheme.primary : theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
