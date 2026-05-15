import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = StreamProvider.autoDispose<List<dynamic>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final db = ref.watch(databaseProvider);

  if (query.isEmpty) return Stream.value([]);

  // This is a simplified search across tables.
  // In a real app, use drift's text search or custom async mapping.
  return Stream.periodic(const Duration(milliseconds: 500)).asyncMap((_) async {
    final results = [];

    // Search Summer Bookings
    final bookings = await db.select(db.summerBookings).get();
    results.addAll(
      bookings.where(
        (b) =>
            b.guestName.toLowerCase().contains(query) ||
            (b.guestPhone?.contains(query) ?? false),
      ),
    );

    // Search Winter Contracts
    final contracts = await db.select(db.winterContracts).get();
    results.addAll(
      contracts.where(
        (c) =>
            c.studentName.toLowerCase().contains(query) ||
            (c.parentPhone?.contains(query) ?? false),
      ),
    );

    return results;
  });
});

class GlobalSearchScreen extends ConsumerWidget {
  const GlobalSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResults = ref.watch(searchResultsProvider);
    final query = ref.watch(searchQueryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'البحث الشامل...',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
          onChanged: (value) {
            ref.read(searchQueryProvider.notifier).state = value;
          },
        ),
      ),
      body: query.isEmpty
          ? const Center(child: Text('اكتب للبحث...'))
          : searchResults.when(
              data: (results) {
                if (results.isEmpty) {
                  return const Center(child: Text('لا توجد نتائج'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final result = results[index];
                    // Dynamic rendering based on type
                    if (result.runtimeType.toString() == 'SummerBooking') {
                      return _buildResultCard(
                        context,
                        title: result.guestName,
                        subtitle: 'حجز صيفي',
                        icon: Icons.calendar_month,
                        color: theme.colorScheme.primary,
                        onTap: () => context.go(
                          '/summer_bookings/guest/${Uri.encodeComponent(result.guestName)}',
                        ),
                      );
                    } else if (result.runtimeType.toString() ==
                        'WinterContract') {
                      return _buildResultCard(
                        context,
                        title: result.studentName,
                        subtitle: 'عقد شتوي',
                        icon: Icons.school,
                        color: theme.colorScheme.secondary,
                        onTap: () => context.go(
                          '/winter_contracts/details/${result.id}',
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
    );
  }

  Widget _buildResultCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
