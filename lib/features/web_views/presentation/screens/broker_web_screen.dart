import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../apartments/presentation/providers/apartments_controller.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class BrokerWebScreen extends ConsumerWidget {
  const BrokerWebScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apartmentsAsync = ref.watch(apartmentsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الشقق المتاحة'),
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
          // Broker only sees apartments with brokerVisibility == true
          final availableApartments = apartments.where((a) => a.brokerVisibility).toList();

          if (availableApartments.isEmpty) {
            return const Center(child: Text('لا توجد شقق متاحة حالياً'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1,
            ),
            itemCount: availableApartments.length,
            itemBuilder: (context, index) {
              final apt = availableApartments[index];
              return Card(
                color: theme.colorScheme.secondaryContainer,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'شقة',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                      Text(
                        apt.apartmentNumber,
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.bold,
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
