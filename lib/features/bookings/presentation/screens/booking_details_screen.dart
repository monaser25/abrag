import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bookings_provider.dart';

class BookingDetailsScreen extends ConsumerWidget {
  final String bookingId;

  const BookingDetailsScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(summerBookingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الحجز'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Edit booking
            },
          ),
        ],
      ),
      body: bookingsAsync.when(
        data: (bookings) {
          final booking = bookings.firstWhere(
            (b) => b.id == bookingId,
            orElse: () => throw Exception('Booking not found'), // Better to handle this gracefully
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSection(
                context,
                title: 'معلومات الضيف',
                icon: Icons.person,
                children: [
                  _buildDetailRow(context, 'الاسم', booking.guestName),
                  _buildDetailRow(context, 'رقم الهاتف', booking.guestPhone ?? 'غير متوفر'),
                  _buildDetailRow(context, 'حالة المزامنة', booking.syncStatus.toString()), // Debug info
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                title: 'معلومات الإقامة',
                icon: Icons.calendar_month,
                children: [
                  _buildDetailRow(context, 'تاريخ الدخول', booking.checkInDate.toLocal().toString().split(' ')[0]),
                  _buildDetailRow(context, 'تاريخ الخروج', booking.checkOutDate.toLocal().toString().split(' ')[0]),
                  _buildDetailRow(context, 'الإجمالي', '${booking.totalPriceEgp} ج.م', isHighlight: true),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                title: 'معلومات العقار',
                icon: Icons.apartment,
                children: [
                  _buildDetailRow(context, 'معرف العقار', booking.apartmentId),
                ],
              ),
              
              const SizedBox(height: 32),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Checkout early
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                        side: BorderSide(color: Theme.of(context).colorScheme.error),
                      ),
                      child: const Text('تسجيل خروج مبكر'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Confirm checkout
                      },
                      child: const Text('تسجيل خروج'),
                    ),
                  ),
                ],
              )
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required IconData icon, required List<Widget> children}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: isHighlight 
                  ? Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary)
                  : Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
