import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bookings_provider.dart';

class GuestProfileScreen extends ConsumerWidget {
  final String guestName;

  const GuestProfileScreen({super.key, required this.guestName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(summerBookingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('ملف النزيل')),
      body: bookingsAsync.when(
        data: (allBookings) {
          final guestBookings = allBookings.where((b) => b.guestName == guestName).toList();
          
          if (guestBookings.isEmpty) {
            return const Center(child: Text('لا يوجد سجل لهذا النزيل'));
          }

          guestBookings.sort((a, b) => b.checkInDate.compareTo(a.checkInDate));
          
          int totalNights = 0;
          double totalPaid = 0;
          for (var b in guestBookings) {
            final days = b.checkOutDate.difference(b.checkInDate).inDays;
            totalNights += days > 0 ? days : 1;
            totalPaid += b.totalPriceEgp;
          }

          final lastVisit = guestBookings.first.checkInDate;
          final isFrequent = guestBookings.length > 1;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: CustomScrollView(
              slivers: [
              SliverToBoxAdapter(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Text(
                            guestName.isNotEmpty ? guestName[0] : '?',
                            style: theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(guestName, style: theme.textTheme.headlineSmall),
                              if (isFrequent) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.star, size: 14, color: theme.colorScheme.primary),
                                      const SizedBox(width: 4),
                                      Text('نزيل متكرر', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary)),
                                    ],
                                  ),
                                ),
                              ]
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(child: _buildStatCard(context, 'الزيارات', '${guestBookings.length}', Icons.home_work)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildStatCard(context, 'الليالي', '$totalNights', Icons.dark_mode)),
                  ],
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(child: _buildStatCard(context, 'المدفوع', '$totalPaid ج.م', Icons.payments)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildStatCard(context, 'آخر زيارة', lastVisit.toLocal().toString().split(' ')[0], Icons.schedule)),
                  ],
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text('سجل الزيارات', style: theme.textTheme.titleLarge),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final booking = guestBookings[index];
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
                                Text('شقة ${booking.apartmentId}', style: theme.textTheme.titleMedium),
                                Text(booking.status, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.calendar_month, size: 16, color: theme.colorScheme.onSurfaceVariant),
                                const SizedBox(width: 8),
                                Text('${booking.checkInDate.toLocal().toString().split(' ')[0]} - ${booking.checkOutDate.toLocal().toString().split(' ')[0]}'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('${booking.totalPriceEgp} ج.م', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: guestBookings.length,
                ),
              ),
            ],
          ),
        );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: theme.colorScheme.primaryContainer),
            const SizedBox(height: 4),
            Text(title, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text(value, style: theme.textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
