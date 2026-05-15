import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/bookings_provider.dart';
import '../providers/bookings_controller.dart';
import '../../../apartments/presentation/providers/apartments_controller.dart';
import '../../../users/presentation/providers/users_provider.dart';

class BookingDetailsScreen extends ConsumerWidget {
  final String bookingId;

  const BookingDetailsScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(summerBookingsProvider);
    final apartmentsAsync = ref.watch(apartmentsProvider);
    final brokersAsync = ref.watch(brokersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الحجز'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/summer_bookings/list');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.go('/summer_bookings/edit/$bookingId');
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('تأكيد الحذف'),
                  content: const Text('هل أنت متأكد من حذف هذا الحجز نهائياً؟'),
                  actions: [
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('إلغاء'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                      onPressed: () {
                        ref
                            .read(bookingsControllerProvider.notifier)
                            .deleteBooking(bookingId);
                        context.pop();
                        context.pop();
                      },
                      child: const Text('حذف'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: bookingsAsync.when(
        data: (bookings) {
          final booking = bookings.firstWhere(
            (b) => b.id == bookingId,
            orElse: () => throw Exception(
              'Booking not found',
            ), // Better to handle this gracefully
          );
          final commissionAmount = _commissionAmount(booking);
          final actualReceived = (booking.amountPaidEgp - commissionAmount)
              .clamp(0, double.infinity);
          final baseBookingTotal =
              booking.totalPriceEgp - booking.overstayFeeEgp;
          final bookingDays = _calendarDays(
            booking.checkInDate,
            booking.earlyCheckoutDate ?? booking.checkOutDate,
          );
          final dailyRate = baseBookingTotal / bookingDays;
          final remainingAmount = (baseBookingTotal - booking.amountPaidEgp)
              .clamp(0, double.infinity);
          final isFullyPaid = booking.amountPaidEgp >= baseBookingTotal;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSection(
                context,
                title: 'معلومات الضيف',
                icon: Icons.person,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        booking.guestName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      TextButton(
                        onPressed: () => context.go(
                          '/summer_bookings/guest/${booking.guestName}',
                        ),
                        child: const Text('الملف الشخصي'),
                      ),
                    ],
                  ),
                  const Divider(),
                  _buildDetailRow(
                    context,
                    'رقم الهاتف',
                    booking.guestPhone ?? 'غير متوفر',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                title: 'معلومات الإقامة',
                icon: Icons.calendar_month,
                children: [
                  _buildDetailRow(
                    context,
                    'تاريخ الدخول',
                    DateFormat(
                      'EEEE yyyy-MM-dd hh:mm a',
                      'ar',
                    ).format(booking.checkInDate),
                  ),
                  _buildDetailRow(
                    context,
                    'تاريخ الخروج',
                    DateFormat(
                      'EEEE yyyy-MM-dd hh:mm a',
                      'ar',
                    ).format(booking.checkOutDate),
                  ),
                  _buildDetailRow(context, 'عدد الأيام', '$bookingDays يوم'),
                  _buildDetailRow(
                    context,
                    'السعر اليومي',
                    '${dailyRate.toStringAsFixed(2)} ج.م',
                  ),
                  if (!isFullyPaid)
                    _buildDetailRow(
                      context,
                      'فلوس الحجز',
                      '${baseBookingTotal.toStringAsFixed(2)} ج.م',
                      isHighlight: true,
                    ),
                  _buildDetailRow(
                    context,
                    'فلوس السمسار',
                    '${commissionAmount.toStringAsFixed(2)} ج.م',
                  ),
                  _buildDetailRow(
                    context,
                    'الفلوس الفعلية اللي أخدتها',
                    '${actualReceived.toStringAsFixed(2)} ج.م',
                    valueColor: Colors.green,
                  ),
                  _buildDetailRow(
                    context,
                    'المدفوع',
                    '${booking.amountPaidEgp} ج.م',
                    isHighlight: true,
                  ),
                  if (remainingAmount > 0)
                    _buildDetailRow(
                      context,
                      'المتبقي',
                      '$remainingAmount ج.م',
                      valueColor: Theme.of(context).colorScheme.error,
                    ),
                  if (booking.overstayDays > 0 || booking.overstayFeeEgp > 0)
                    _buildDetailRow(
                      context,
                      'تمديد ${booking.overstayDays} يوم',
                      '${booking.overstayFeeEgp.toStringAsFixed(2)} ج.م',
                      valueColor: Theme.of(context).colorScheme.primary,
                    ),
                  _buildDetailRow(
                    context,
                    'طريقة الدفع',
                    booking.paymentMethod == 'cash'
                        ? 'نقدي'
                        : booking.paymentMethod == 'instapay'
                        ? 'إنستاباي'
                        : 'فودافون كاش',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                title: 'معلومات العقار',
                icon: Icons.apartment,
                children: [
                  apartmentsAsync.when(
                    data: (apts) {
                      try {
                        final apt = apts.firstWhere(
                          (a) => a.id == booking.apartmentId,
                        );
                        return InkWell(
                          onTap: () => context.go(
                            '/apartments/profile/${booking.apartmentId}',
                          ),
                          child: _buildDetailRow(
                            context,
                            'رقم الشقة',
                            apt.apartmentNumber,
                          ),
                        );
                      } catch (_) {
                        return _buildDetailRow(
                          context,
                          'معرف العقار',
                          booking.apartmentId,
                        );
                      }
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (err, stack) => _buildDetailRow(
                      context,
                      'معرف العقار',
                      booking.apartmentId,
                    ),
                  ),
                ],
              ),

              if (booking.brokerId != null || booking.brokerName != null) ...[
                const SizedBox(height: 16),
                _buildSection(
                  context,
                  title: 'السمسار',
                  icon: Icons.handshake,
                  children: [
                    brokersAsync.when(
                      data: (brokers) {
                        final registered = brokers
                            .where((b) => b.id == booking.brokerId)
                            .toList();
                        final brokerName =
                            booking.brokerName ??
                            (registered.isEmpty
                                ? 'سمسار مسجل'
                                : (registered.first.fullName ??
                                      registered.first.email));
                        return InkWell(
                          onTap: () => context.go(
                            '/brokers/details/${booking.brokerId}',
                          ),
                          child: _buildDetailRow(
                            context,
                            'اسم السمسار',
                            brokerName,
                          ),
                        );
                      },
                      loading: () => _buildDetailRow(
                        context,
                        'اسم السمسار',
                        booking.brokerName ?? 'تحميل...',
                      ),
                      error: (error, stack) => _buildDetailRow(
                        context,
                        'اسم السمسار',
                        booking.brokerName ?? 'سمسار مسجل',
                      ),
                    ),
                    _buildDetailRow(
                      context,
                      'نوع العمولة',
                      booking.brokerCommissionType == 'fixed'
                          ? 'مبلغ ثابت'
                          : booking.brokerCommissionType == 'percentage'
                          ? 'نسبة'
                          : 'أخرى',
                    ),
                    _buildDetailRow(
                      context,
                      'قيمة العمولة',
                      booking.brokerCommissionType == 'fixed'
                          ? '${booking.brokerCommissionFixedEgp} ج.م'
                          : '${booking.brokerCommissionPercentage} %',
                    ),
                    _buildDetailRow(
                      context,
                      'فلوس السمسار اللي أخدها',
                      '${commissionAmount.toStringAsFixed(2)} ج.م',
                      valueColor: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        context.go(
                          '/summer_bookings/early_checkout/$bookingId',
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      child: const Text('تسجيل خروج مبكر'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        context.go('/summer_bookings/overstay/$bookingId');
                      },
                      child: const Text('تمديد الحجز'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _showCheckoutDialog(context, ref, booking);
                      },
                      child: const Text('تسجيل خروج'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _showCheckoutDialog(
    BuildContext context,
    WidgetRef ref,
    dynamic booking,
  ) {
    String cleaningStatus = 'clean';
    bool inventoryChecked = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('إجراءات تسجيل الخروج'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('حالة الشقة:'),
                  RadioListTile(
                    title: const Text('نظيفة'),
                    value: 'clean',
                    groupValue: cleaningStatus,
                    onChanged: (val) =>
                        setState(() => cleaningStatus = val.toString()),
                  ),
                  RadioListTile(
                    title: const Text('تحتاج نظافة'),
                    value: 'needs_cleaning',
                    groupValue: cleaningStatus,
                    onChanged: (val) =>
                        setState(() => cleaningStatus = val.toString()),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('تم جرد محتويات الشقة'),
                    value: inventoryChecked,
                    onChanged: (val) => setState(() => inventoryChecked = val),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // We don't have a direct function to update apartment cleaning status in BookingsController
                    // We should do it via apartmentsController or just direct DB update for now.
                    ref
                        .read(bookingsControllerProvider.notifier)
                        .checkoutBooking(
                          booking.id,
                          cleaningStatus: cleaningStatus,
                          apartmentId: booking.apartmentId,
                        );
                    context.pop();
                    context.go('/summer_bookings');
                  },
                  child: const Text('تأكيد وتسجيل الخروج'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  double _commissionAmount(dynamic booking) {
    if (booking.brokerCommissionType == 'fixed') {
      return booking.brokerCommissionFixedEgp;
    }
    if (booking.brokerCommissionType == 'percentage') {
      return booking.totalPriceEgp * (booking.brokerCommissionPercentage / 100);
    }
    return 0;
  }

  int _calendarDays(DateTime start, DateTime end) {
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);
    return endDate.difference(startDate).inDays.clamp(1, 10000);
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
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

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    bool isHighlight = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: isHighlight
                  ? Theme.of(context).textTheme.titleMedium?.copyWith(
                      color:
                          valueColor ?? Theme.of(context).colorScheme.primary,
                    )
                  : Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: valueColor),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
