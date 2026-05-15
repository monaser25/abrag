import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/contracts_provider.dart';
import '../../../apartments/presentation/providers/apartments_controller.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/database/database.dart';

class WinterContractsScreen extends ConsumerStatefulWidget {
  const WinterContractsScreen({super.key});

  @override
  ConsumerState<WinterContractsScreen> createState() => _WinterContractsScreenState();
}

class _WinterContractsScreenState extends ConsumerState<WinterContractsScreen> {
  String _filter = 'all'; // all, active, expired, empty

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final contractsAsync = ref.watch(winterContractsProvider);
    final apartmentsAsync = ref.watch(apartmentsProvider);
    final paymentsAsync = ref.watch(allWinterPaymentsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.winterContracts),
      ),
      body: contractsAsync.when(
        data: (contracts) {
          return apartmentsAsync.when(
            data: (apartments) {
              return paymentsAsync.when(
                data: (payments) {
                  final activeContracts = contracts.where((c) => c.isActive).toList();
                  final totalRent = activeContracts.fold(0.0, (sum, c) => sum + c.monthlyRentEgp);
                  final emptyApts = apartments.where((a) => !activeContracts.any((c) => c.apartmentId == a.id)).toList();

                  // Apply Filter
                  List<dynamic> listItems = [];
                  if (_filter == 'all') {
                    listItems.addAll(contracts);
                    listItems.addAll(emptyApts);
                  } else if (_filter == 'active') {
                    listItems.addAll(activeContracts);
                  } else if (_filter == 'expired') {
                    listItems.addAll(contracts.where((c) => !c.isActive));
                  } else if (_filter == 'empty') {
                    listItems.addAll(emptyApts);
                  }

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
                            child: InkWell(
                              onTap: () => setState(() => _filter = 'active'),
                              child: _buildSummaryCard(
                                context,
                                icon: Icons.home_work,
                                title: 'المشغولة',
                                value: '${activeContracts.length}',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() => _filter = 'empty'),
                              child: _buildSummaryCard(
                                context,
                                icon: Icons.key_off,
                                title: 'الفاضية',
                                value: '${emptyApts.length}',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                                                            child: _buildSummaryCard(
                                                              context,
                                                              icon: Icons.payments,
                                                              title: 'إجمالي الإيجارات',
                                                              value: '${totalRent.toCurrencyFormat()} ج.م',
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
                            Text('القائمة', style: theme.textTheme.titleLarge),
                            DropdownButton<String>(
                              value: _filter,
                              items: const [
                                DropdownMenuItem(value: 'all', child: Text('الكل')),
                                DropdownMenuItem(value: 'active', child: Text('نشط')),
                                DropdownMenuItem(value: 'expired', child: Text('منتهي')),
                                DropdownMenuItem(value: 'empty', child: Text('شواغر')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _filter = val);
                              },
                              underline: const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Contracts List
                    if (listItems.isEmpty)
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
                            final item = listItems[index];
                            
                            // If it's an Apartment
                            if (item.runtimeType.toString() == 'Apartment') {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                        child: const Icon(Icons.apartment),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'شقة ${item.apartmentNumber}',
                                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'الدور ${item.floorNumber ?? "-"}',
                                              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.surfaceContainerHighest,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text('شاغرة', style: theme.textTheme.labelMedium),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            // If it's a Contract
                            final contract = item as WinterContract;
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
                                            child: Text(contract.apartmentId.substring(0, 1)), // Placeholder
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
                                                '${contract.monthlyRentEgp.toCurrencyFormat()} ج.م',
                                                style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                                              ),
                                              Text('شهرياً', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 24),
                                        Builder(
                                          builder: (context) {
                                            final contractPayments = payments.where((p) => p.contractId == contract.id).toList();
                                            final totalPaid = contractPayments.fold<double>(0, (sum, p) => sum + p.amountEgp);
                                            final deposit = contract.depositEgp;
                                            
                                            final now = DateTime.now();
                                            int monthsPassed = 0;
                                            DateTime iterDate = contract.startDate;
                                            while (iterDate.isBefore(now) || iterDate.isAtSameMomentAs(now)) {
                                              monthsPassed++;
                                              int nextMonth = iterDate.month + 1;
                                              int nextYear = iterDate.year;
                                              if (nextMonth > 12) {
                                                nextMonth = 1;
                                                nextYear++;
                                              }
                                              iterDate = DateTime(nextYear, nextMonth, contract.startDate.day);
                                            }
                                            
                                            // Max months is the contract duration
                                            int totalContractMonths = 0;
                                            DateTime tempDate = contract.startDate;
                                            while (tempDate.isBefore(contract.endDate)) {
                                              totalContractMonths++;
                                              int nm = tempDate.month + 1;
                                              int ny = tempDate.year;
                                              if (nm > 12) {
                                                nm = 1;
                                                ny++;
                                              }
                                              tempDate = DateTime(ny, nm, contract.startDate.day);
                                            }
                                            
                                            if (monthsPassed > totalContractMonths) monthsPassed = totalContractMonths;
                                            if (monthsPassed < 1) monthsPassed = 1;

                                            final requiredAmount = deposit + (monthsPassed * contract.monthlyRentEgp);
                                            final remainingAmount = requiredAmount - totalPaid;
                                            final isUnpaid = remainingAmount > 0;
                                            
                                            if (!isUnpaid) return const SizedBox.shrink();

                                            // Calculate exactly which payment they missed
                                            DateTime dueForMissing = contract.startDate;
                                            double allocated = totalPaid;
                                            if (allocated < deposit) {
                                              dueForMissing = contract.startDate;
                                            } else {
                                              allocated -= deposit;
                                              int monthsCovered = (allocated / contract.monthlyRentEgp).floor();
                                              int dueYear = contract.startDate.year;
                                              int dueMonth = contract.startDate.month + monthsCovered;
                                              while (dueMonth > 12) {
                                                dueMonth -= 12;
                                                dueYear++;
                                              }
                                              dueForMissing = DateTime(dueYear, dueMonth, contract.startDate.day);
                                            }

                                            int daysLate = now.difference(dueForMissing).inDays;
                                            if (daysLate < 0) daysLate = 0;

                                            return Container(
                                              margin: const EdgeInsets.only(bottom: 16),
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: theme.colorScheme.error.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          'متأخرات: ${remainingAmount.toCurrencyFormat()} ج.م',
                                                          style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.error, fontWeight: FontWeight.bold),
                                                        ),
                                                        if (daysLate > 0)
                                                          Text(
                                                            'متأخر منذ $daysLate يوم (مستحق في ${dueForMissing.toLocal().toString().split(' ')[0]})',
                                                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                        ),
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
                                            child: Text(contract.isElectricityOnStudent ? 'كهرباء: على الطالب' : 'كهرباء: على المبنى', style: theme.textTheme.labelSmall),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: listItems.length,
                        ),
                      ),
                  ],
                ),
              );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Error: $e')),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Error: $e')),
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
