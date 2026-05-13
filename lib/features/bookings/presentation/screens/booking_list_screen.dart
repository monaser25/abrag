import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/bookings_provider.dart';

class BookingListScreen extends ConsumerWidget {
  const BookingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final bookingsAsync = ref.watch(summerBookingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.summerBookings), // Reusing translation
      ),
      body: Column(
        children: [
          // Filter Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _FilterChip(label: 'الكل', isSelected: true),
                const SizedBox(width: 8),
                _FilterChip(label: 'جارية', isSelected: false),
                const SizedBox(width: 8),
                _FilterChip(label: 'منتهية', isSelected: false),
              ],
            ),
          ),
          
          Expanded(
            child: bookingsAsync.when(
              data: (bookings) {
                if (bookings.isEmpty) {
                  return Center(child: Text(l10n.noData));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () {
                          // Navigate to details
                          context.go('/summer_bookings/details/${booking.id}');
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      booking.guestName,
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      booking.status,
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.calendar_month, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${booking.checkInDate.toLocal().toString().split(' ')[0]} - ${booking.checkOutDate.toLocal().toString().split(' ')[0]}',
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'إجمالي السعر',
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                  ),
                                  Text(
                                    '${booking.totalPriceEgp} ج.م',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/summer_bookings/add');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _FilterChip({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Theme.of(context).colorScheme.onPrimaryContainer : Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
