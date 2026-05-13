import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/bookings_provider.dart';
import '../providers/bookings_controller.dart';

class EarlyCheckoutScreen extends ConsumerWidget {
  final String bookingId;

  const EarlyCheckoutScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(summerBookingsProvider);
    final controllerState = ref.watch(bookingsControllerProvider);
    final theme = Theme.of(context);

    ref.listen<AsyncValue<void>>(
      bookingsControllerProvider,
      (_, state) {
        state.whenOrNull(
          data: (_) => context.go('/summer_bookings'),
          error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error')),
          ),
        );
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text('خروج مبكر')),
      body: bookingsAsync.when(
        data: (bookings) {
          final booking = bookings.firstWhere((b) => b.id == bookingId);
          final checkIn = booking.checkInDate;
          final checkOut = booking.checkOutDate;
          final today = DateTime.now();
          final originalDays = checkOut.difference(checkIn).inDays;
          final usedDays = today.difference(checkIn).inDays > 0 ? today.difference(checkIn).inDays : 1;
          final remainingDays = originalDays - usedDays;
          final dailyRate = booking.totalPriceEgp / (originalDays > 0 ? originalDays : 1);
          final refundAmount = remainingDays > 0 ? (dailyRate * remainingDays) : 0;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('النزيل الحالي', style: theme.textTheme.labelMedium),
                        Text(booking.guestName, style: theme.textTheme.headlineSmall),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.calendar_month, size: 16, color: theme.colorScheme.onSurfaceVariant),
                            const SizedBox(width: 8),
                            Text('الحجز الأصلي: $originalDays أيام', style: theme.textTheme.bodyMedium),
                          ],
                        ),
                        Text('إجمالي المدفوع: ${booking.totalPriceEgp} ج.م', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('الأيام المستخدمة', style: theme.textTheme.bodyMedium),
                            Text('$usedDays', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.green, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('الأيام المتبقية', style: theme.textTheme.bodyMedium),
                            Text('$remainingDays', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('مبلغ الاسترداد', style: theme.textTheme.titleMedium),
                            Text('$refundAmount ج.م', style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.primary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: controllerState.isLoading || remainingDays <= 0
                      ? null
                      : () {
                          ref.read(bookingsControllerProvider.notifier).earlyCheckoutBooking(
                            id: bookingId,
                            newCheckoutDate: today,
                          );
                        },
                  icon: const Icon(Icons.check_circle),
                  label: controllerState.isLoading 
                      ? const CircularProgressIndicator() 
                      : const Text('تأكيد الخروج المبكر'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
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
}
