import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/database/tables.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../shared/widgets/widgets.dart';
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
    final bookings =
        await (db.select(db.summerBookings)
              ..where((t) => t.status.isNotIn(['deleted']))
              ..where(
                (t) => t.syncStatus.isNotIn([SyncStatus.pendingDelete.index]),
              ))
            .get();
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
    final colors = context.colors;

    return AppScaffold(
      appBar: AbragAppBar(
        title: 'البحث الشامل',
        showBack: true,
        onBack: () => context.go('/'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: AppTextField(
              hint: 'البحث الشامل...',
              prefixIcon: Icons.search,
              autofocus: true,
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
            ),
          ),
          Expanded(
            child: query.isEmpty
                ? const EmptyState(icon: Icons.search, title: 'اكتب للبحث...')
                : searchResults.when(
                    data: (results) {
                      if (results.isEmpty) {
                        return const EmptyState(
                          icon: Icons.search_off,
                          title: 'لا توجد نتائج',
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final result = results[index];
                          // Dynamic rendering based on type
                          if (result.runtimeType.toString() ==
                              'SummerBooking') {
                            return NavRow(
                              icon: Icons.calendar_month,
                              title: result.guestName,
                              sub: 'حجز صيفي',
                              tint: colors.summer,
                              onTap: () => context.go(
                                '/summer_bookings/guest/${Uri.encodeComponent(result.guestName)}',
                              ),
                            );
                          } else if (result.runtimeType.toString() ==
                              'WinterContract') {
                            return NavRow(
                              icon: Icons.school,
                              title: result.studentName,
                              sub: 'عقد شتوي',
                              tint: colors.winter,
                              onTap: () => context.go(
                                '/winter_contracts/details/${result.id}',
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      );
                    },
                    loading: () => const LoadingSkeleton(),
                    error: (err, stack) => ErrorState(
                      title: 'تعذر تحميل النتائج',
                      message: '$err',
                      retryLabel: 'إعادة المحاولة',
                      onRetry: () => ref.invalidate(searchResultsProvider),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
