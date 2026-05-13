import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/bookings_provider.dart';
import '../providers/bookings_controller.dart';

class OverstayExtensionScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const OverstayExtensionScreen({super.key, required this.bookingId});

  @override
  ConsumerState<OverstayExtensionScreen> createState() => _OverstayExtensionScreenState();
}

class _OverstayExtensionScreenState extends ConsumerState<OverstayExtensionScreen> {
  int _extraDays = 1;

  @override
  Widget build(BuildContext context) {
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
      appBar: AppBar(title: const Text('تمديد الحجز')),
      body: bookingsAsync.when(
        data: (bookings) {
          final booking = bookings.firstWhere((b) => b.id == widget.bookingId);
          final originalDays = booking.checkOutDate.difference(booking.checkInDate).inDays;
          final dailyRate = booking.totalPriceEgp / (originalDays > 0 ? originalDays : 1);
          final additionalFee = dailyRate * _extraDays;
          final newCheckoutDate = booking.checkOutDate.add(Duration(days: _extraDays));

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
                            Icon(Icons.event_busy, size: 16, color: theme.colorScheme.onSurfaceVariant),
                            const SizedBox(width: 8),
                            Text('تاريخ الخروج الحالي: ${booking.checkOutDate.toLocal().toString().split(' ')[0]}', style: theme.textTheme.bodyMedium),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('عدد أيام التمديد', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => setState(() => _extraDays++),
                          icon: const Icon(Icons.add),
                        ),
                        Column(
                          children: [
                            Text('$_extraDays', style: theme.textTheme.headlineMedium),
                            Text('أيام', style: theme.textTheme.labelMedium),
                          ],
                        ),
                        IconButton(
                          onPressed: _extraDays > 1 ? () => setState(() => _extraDays--) : null,
                          icon: const Icon(Icons.remove),
                        ),
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
                            Text('حساب التمديد', style: theme.textTheme.bodyMedium),
                            Text('$_extraDays × ${dailyRate.toStringAsFixed(2)} ج.م', style: theme.textTheme.bodyMedium),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('إجمالي الإضافة', style: theme.textTheme.titleMedium),
                            Text('${additionalFee.toStringAsFixed(2)} ج.م', style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('تاريخ الخروج الجديد', style: theme.textTheme.bodyMedium),
                            Text(newCheckoutDate.toLocal().toString().split(' ')[0], style: theme.textTheme.titleMedium?.copyWith(color: Colors.green)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: controllerState.isLoading
                      ? null
                      : () {
                          ref.read(bookingsControllerProvider.notifier).extendBooking(
                            id: widget.bookingId,
                            newCheckoutDate: newCheckoutDate,
                            overstayDays: _extraDays,
                            additionalFeeEgp: additionalFee,
                          );
                        },
                  icon: const Icon(Icons.check_circle),
                  label: controllerState.isLoading 
                      ? const CircularProgressIndicator() 
                      : const Text('تأكيد التمديد'),
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
