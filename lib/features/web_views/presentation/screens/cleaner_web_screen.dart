import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../apartments/presentation/providers/apartments_controller.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:drift/drift.dart' as drift;
import '../../../../core/database/database.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';

class CleanerWebScreen extends ConsumerWidget {
  const CleanerWebScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apartmentsAsync = ref.watch(apartmentsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('مهام التنظيف'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(loginControllerProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: apartmentsAsync.when(
        data: (apartments) {
          // Cleaner sees apartments that need cleaning
          final dirtyApartments = apartments.where((a) => a.cleaningStatus == 'needs_cleaning').toList();

          if (dirtyApartments.isEmpty) {
            return const Center(child: Text('لا توجد مهام تنظيف حالياً'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: dirtyApartments.length,
            itemBuilder: (context, index) {
              final apt = dirtyApartments[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text('رقم الشقة', style: theme.textTheme.labelMedium),
                      const SizedBox(height: 8),
                      Text(
                        apt.apartmentNumber,
                        style: theme.textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Mark as clean
                          ref.read(databaseProvider).update(ref.read(databaseProvider).apartments)
                            ..where((t) => t.id.equals(apt.id))
                            ..write(const ApartmentsCompanion(cleaningStatus: drift.Value('clean')));
                        },
                        icon: const Icon(Icons.check_circle),
                        label: const Text('تم التنظيف'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
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
