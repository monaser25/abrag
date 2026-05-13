import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/users_provider.dart';

class BrokerDetailsScreen extends ConsumerWidget {
  final String brokerId;

  const BrokerDetailsScreen({super.key, required this.brokerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brokersAsync = ref.watch(brokersProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل السمسار'),
      ),
      body: brokersAsync.when(
        data: (brokers) {
          final broker = brokers.firstWhere(
            (b) => b.id == brokerId,
            orElse: () => throw Exception('Broker not found'),
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                        child: Icon(Icons.person, size: 40, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        broker.fullName ?? broker.email,
                        style: theme.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        broker.email,
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                      if (broker.phoneNumber != null)
                        Text(
                          broker.phoneNumber!,
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          textDirection: TextDirection.ltr,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('الإحصائيات', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.green),
                  title: const Text('عدد الحجوزات الناجحة'),
                  trailing: Text('0', style: theme.textTheme.titleMedium), // Needs aggregation logic
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.money, color: theme.colorScheme.primary),
                  title: const Text('إجمالي العمولات'),
                  trailing: Text('0 ج.م', style: theme.textTheme.titleMedium), // Needs aggregation logic
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
