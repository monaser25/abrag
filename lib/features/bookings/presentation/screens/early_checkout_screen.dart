import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/bookings_provider.dart';
import '../providers/bookings_controller.dart';

class EarlyCheckoutScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const EarlyCheckoutScreen({super.key, required this.bookingId});

  @override
  ConsumerState<EarlyCheckoutScreen> createState() =>
      _EarlyCheckoutScreenState();
}

class _EarlyCheckoutScreenState extends ConsumerState<EarlyCheckoutScreen> {
  final _refundController = TextEditingController();
  bool _customRefund = false;
  bool _noRefund = false;

  @override
  void dispose() {
    _refundController.dispose();
    super.dispose();
  }

  int _calendarDays(DateTime start, DateTime end) {
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);
    return endDate.difference(startDate).inDays.clamp(1, 10000);
  }

  double _commissionAmount(dynamic booking) {
    if (booking.brokerCommissionType == 'fixed') {
      return booking.brokerCommissionFixedEgp;
    }
    if (booking.brokerCommissionType == 'percentage') {
      final baseBookingTotal = booking.totalPriceEgp - booking.overstayFeeEgp;
      return baseBookingTotal * (booking.brokerCommissionPercentage / 100);
    }
    return booking.brokerCommissionAmountEgp ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(summerBookingsProvider);
    final controllerState = ref.watch(bookingsControllerProvider);
    final theme = Theme.of(context);

    ref.listen<AsyncValue<void>>(bookingsControllerProvider, (_, state) {
      state.whenOrNull(
        data: (_) => context.go('/summer_bookings/details/${widget.bookingId}'),
        error: (error, _) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $error'))),
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('خروج مبكر'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.go('/summer_bookings/details/${widget.bookingId}'),
        ),
      ),
      body: bookingsAsync.when(
        data: (bookings) {
          final booking = bookings.firstWhere((b) => b.id == widget.bookingId);
          final checkIn = booking.checkInDate;
          final checkOut = booking.checkOutDate;
          final today = DateTime.now();
          final originalDays = _calendarDays(checkIn, checkOut);
          final usedDays = _calendarDays(checkIn, today).clamp(1, originalDays);
          final remainingDays = (originalDays - usedDays).clamp(0, 10000);
          final dailyRate =
              (booking.totalPriceEgp - booking.overstayFeeEgp) / originalDays;
          final brokerCommission = _commissionAmount(booking);
          final refundAmount = remainingDays > 0
              ? (dailyRate * remainingDays)
              : 0;
          final defaultNetRefund = refundAmount > brokerCommission
              ? refundAmount - brokerCommission
              : 0;
          final visibleNetRefund = _noRefund ? 0.0 : defaultNetRefund;

          if (!_customRefund && _refundController.text.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _refundController.text = defaultNetRefund.toStringAsFixed(2);
              }
            });
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('النزيل الحالي', style: theme.textTheme.labelMedium),
                      Text(
                        booking.guestName,
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'الحجز الأصلي: $originalDays أيام',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      Text(
                        'إجمالي المدفوع: ${booking.totalPriceEgp} ج.م',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
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
                          Text(
                            'الأيام المستخدمة',
                            style: theme.textTheme.bodyMedium,
                          ),
                          Text(
                            '$usedDays',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'الأيام المتبقية',
                            style: theme.textTheme.bodyMedium,
                          ),
                          Text(
                            '$remainingDays',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      _CalcLine(
                        label: 'الأيام المتبقية × سعر اليوم',
                        value:
                            '$remainingDays × ${dailyRate.toStringAsFixed(2)} = ${refundAmount.toStringAsFixed(2)} ج.م',
                      ),
                      if (brokerCommission > 0)
                        _CalcLine(
                          label: 'فلوس السمسار',
                          value: '- ${brokerCommission.toStringAsFixed(2)} ج.م',
                          valueColor: theme.colorScheme.error,
                        ),
                      const Divider(),
                      _CalcLine(
                        label: 'صافي مبلغ الاسترداد',
                        value: '${visibleNetRefund.toStringAsFixed(2)} ج.م',
                        valueColor: theme.colorScheme.primary,
                        isTitle: true,
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('عدم استرداد نقود'),
                        subtitle: const Text(
                          'تسجيل الخروج المبكر بدون رجوع أي مبلغ',
                        ),
                        value: _noRefund,
                        onChanged: (val) {
                          setState(() {
                            _noRefund = val;
                            if (val) {
                              _customRefund = false;
                              _refundController.text = '0.00';
                            }
                          });
                        },
                      ),
                      SwitchListTile(
                        title: const Text('استرداد مخصص'),
                        subtitle: const Text('تعديل مبلغ الاسترداد يدوياً'),
                        value: _customRefund,
                        onChanged: _noRefund
                            ? null
                            : (val) => setState(() => _customRefund = val),
                      ),
                      if (_customRefund)
                        TextFormField(
                          controller: _refundController,
                          decoration: const InputDecoration(
                            labelText: 'مبلغ الاسترداد الفعلي (ج.م)',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: controllerState.isLoading || remainingDays <= 0
                    ? null
                    : () {
                        ref
                            .read(bookingsControllerProvider.notifier)
                            .earlyCheckoutBooking(
                              id: widget.bookingId,
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _CalcLine extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isTitle;

  const _CalcLine({
    required this.label,
    required this.value,
    this.valueColor,
    this.isTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: isTitle
                  ? theme.textTheme.titleMedium
                  : theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style:
                  (isTitle
                          ? theme.textTheme.titleLarge
                          : theme.textTheme.bodyMedium)
                      ?.copyWith(
                        color: valueColor,
                        fontWeight: isTitle ? FontWeight.bold : FontWeight.w600,
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
