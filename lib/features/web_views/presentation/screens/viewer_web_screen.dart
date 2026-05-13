import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../contracts/presentation/providers/contracts_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ViewerWebScreen extends ConsumerWidget {
  const ViewerWebScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contractsAsync = ref.watch(winterContractsProvider);
    final authState = ref.watch(authStateProvider);
    final currentUserId = authState.value?.session?.user.id;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('بيانات الطالب'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(loginControllerProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: currentUserId == null 
        ? const Center(child: CircularProgressIndicator())
        : contractsAsync.when(
        data: (contracts) {
          // Viewer sees only their linked contracts
          final userContracts = contracts.where((c) => c.viewerUserId == currentUserId).toList();

          if (userContracts.isEmpty) {
            return const Center(child: Text('لا توجد بيانات مرتبطة بحسابك'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: userContracts.length,
            itemBuilder: (context, index) {
              final contract = userContracts[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(contract.studentName, style: theme.textTheme.titleLarge),
                        ],
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(context, 'الوحدة', contract.apartmentId),
                      _buildDetailRow(context, 'الجامعة', contract.university ?? 'غير مسجل'),
                      _buildDetailRow(context, 'الإيجار الشهري', '${contract.monthlyRentEgp} ج.م'),
                      const SizedBox(height: 16),
                      // Would be nice to link to payment history here too, but simple read-only view for now
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
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
