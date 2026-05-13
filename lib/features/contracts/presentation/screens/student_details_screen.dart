import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/contracts_provider.dart';

class StudentDetailsScreen extends ConsumerWidget {
  final String contractId;

  const StudentDetailsScreen({super.key, required this.contractId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contractsAsync = ref.watch(winterContractsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الطالب'),
      ),
      body: contractsAsync.when(
        data: (contracts) {
          final contract = contracts.firstWhere(
            (c) => c.id == contractId,
            orElse: () => throw Exception('Contract not found'),
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Profile Header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(Icons.person, size: 32, color: theme.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              contract.studentName,
                              style: theme.textTheme.titleLarge,
                            ),
                            if (contract.university != null)
                              Text(
                                contract.university!,
                                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Contract Details
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.description, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text('العقد الحالي', style: theme.textTheme.titleMedium),
                        ],
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(context, 'الوحدة', contract.apartmentId),
                      _buildDetailRow(context, 'فترة العقد', '${contract.startDate.toLocal().toString().split(' ')[0]} إلى ${contract.endDate.toLocal().toString().split(' ')[0]}'),
                      _buildDetailRow(context, 'الإيجار الشهري', '${contract.monthlyRentEgp} ج.م', isHighlight: true),
                      _buildDetailRow(context, 'التأمين', '${contract.depositEgp} ج.م'),
                      
                      const Divider(height: 24),
                      Row(
                        children: [
                          Icon(Icons.bolt, color: theme.colorScheme.secondary, size: 16),
                          const SizedBox(width: 8),
                          Text('الكهرباء: على الطالب', style: theme.textTheme.bodyMedium),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.water_drop, color: theme.colorScheme.secondary, size: 16),
                          const SizedBox(width: 8),
                          Text('المياه: على المبنى', style: theme.textTheme.bodyMedium),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Actions
              ElevatedButton.icon(
                onPressed: () {
                  context.go('/winter_contracts/payments/$contractId');
                },
                icon: const Icon(Icons.payments),
                label: const Text('سجل المدفوعات'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          Text(
            value,
            style: isHighlight 
                ? Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary)
                : Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
