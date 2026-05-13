import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/users_provider.dart';

class BrokersListScreen extends ConsumerWidget {
  const BrokersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brokersAsync = ref.watch(brokersProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة السماسرة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.visibility),
            tooltip: 'التحكم في رؤية الوسطاء',
            onPressed: () {
              context.go('/brokers/visibility');
            },
          ),
        ],
      ),
      body: brokersAsync.when(
        data: (brokers) {
          if (brokers.isEmpty) {
            return const Center(child: Text('لا يوجد سماسرة مسجلين'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: brokers.length,
            itemBuilder: (context, index) {
              final broker = brokers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () {
                    context.go('/brokers/details/${broker.id}');
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                          child: Icon(Icons.person, color: theme.colorScheme.primary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                broker.fullName ?? broker.email,
                                style: theme.textTheme.titleMedium,
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
                        const Icon(Icons.arrow_forward_ios, size: 16),
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
    );
  }
}
