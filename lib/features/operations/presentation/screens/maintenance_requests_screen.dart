import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/maintenance_provider.dart';

class MaintenanceRequestsScreen extends ConsumerWidget {
  const MaintenanceRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final maintenanceAsync = ref.watch(maintenanceProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.maintenance),
      ),
      body: maintenanceAsync.when(
        data: (requests) {
          if (requests.isEmpty) {
            return Center(child: Text(l10n.noData));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              final isOpen = req.status == 'open';
              
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
                              color: isOpen 
                                  ? theme.colorScheme.error.withValues(alpha: 0.1) 
                                  : Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isOpen ? 'مفتوح' : 'مغلق',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: isOpen ? theme.colorScheme.error : Colors.green,
                              ),
                            ),
                          ),
                          Text(
                            req.createdAt.toLocal().toString().split(' ')[0],
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        req.issueDescription,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.apartment, size: 16, color: theme.colorScheme.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Text(req.apartmentId, style: theme.textTheme.labelMedium),
                            ],
                          ),
                          if (!isOpen)
                            Text(
                              '${req.costEgp} ج.م',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
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
          // Navigate to add maintenance request
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
