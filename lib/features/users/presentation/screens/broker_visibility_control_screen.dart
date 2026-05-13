import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../apartments/presentation/providers/apartments_controller.dart';
import '../../../../core/database/database.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';

class BrokerVisibilityControlScreen extends ConsumerWidget {
  const BrokerVisibilityControlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apartmentsAsync = ref.watch(apartmentsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة رؤية الوسطاء'),
      ),
      body: apartmentsAsync.when(
        data: (apartments) {
          if (apartments.isEmpty) {
            return const Center(child: Text('لا توجد شقق مسجلة'));
          }

          // Filter for empty apartments if needed. For now, showing all.
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: apartments.length,
            itemBuilder: (context, index) {
              final apt = apartments[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('شقة ${apt.apartmentNumber}', style: theme.textTheme.titleMedium),
                          Text('الدور: ${apt.floorNumber ?? "-"}', style: theme.textTheme.bodySmall),
                        ],
                      ),
                      Row(
                        children: [
                          Text(apt.brokerVisibility ? 'ظاهرة للوسطاء' : 'مخفية', style: theme.textTheme.labelMedium),
                          Switch(
                            value: apt.brokerVisibility,
                            onChanged: (val) {
                              // Directly updating DB for toggle
                              // In real app, create a controller method
                              ref.read(databaseProvider).update(ref.read(databaseProvider).apartments)
                                ..where((t) => t.id.equals(apt.id))
                                ..write(ApartmentsCompanion(brokerVisibility: drift.Value(val)));
                            },
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
    );
  }
}
