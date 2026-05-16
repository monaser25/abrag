import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/bookings_provider.dart';
import '../providers/bookings_controller.dart';
import '../../../apartments/presentation/providers/apartments_controller.dart';
import '../../../users/presentation/providers/users_provider.dart';

import '../../../../core/utils/currency_formatter.dart';

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
                    '${dailyRate.toDouble().toCurrencyFormat()} ج.م',
                  ),
                  if (!isFullyPaid)
                    _buildDetailRow(
                      context,
                      'فلوس الحجز',
                      '${baseBookingTotal.toDouble().toCurrencyFormat()} ج.م',
                      isHighlight: true,
                    ),
                  _buildDetailRow(
                    context,
                    'فلوس السمسار',
                    '${commissionAmount.toDouble().toCurrencyFormat()} ج.م',
                  ),
                  _buildDetailRow(
                    context,
                    'الفلوس الصافية اللي دخلتلك',
                    '${actualReceived.toDouble().toCurrencyFormat()} ج.م',
                    valueColor: Colors.green,
                  ),
                  if (!isFullyPaid)
                    _buildDetailRow(
                      context,
                      'فلوس الحجز',
                      '${baseBookingTotal.toDouble().toCurrencyFormat()} ج.م',
                      isHighlight: true,
                    ),
                  _buildDetailRow(
                    context,
                    'فلوس السمسار',
                    '${commissionAmount.toDouble().toCurrencyFormat()} ج.م',
                  ),
                  _buildDetailRow(
                    context,
                    'الفلوس الصافية اللي دخلتلك',
                    '${actualReceived.toDouble().toCurrencyFormat()} ج.م',
                    valueColor: Colors.green,
                  ),
                  _buildDetailRow(
                    context,
                    'المدفوع',
                    '${booking.amountPaidEgp.toCurrencyFormat()} ج.م',
                    isHighlight: true,
                  ),
                  if (remainingAmount > 0)
                    _buildDetailRow(
                      context,
                      'المتبقي',
                      '${remainingAmount.toCurrencyFormat()} ج.م',
                      valueColor: Theme.of(context).colorScheme.error,
                    ),
                  if (booking.overstayDays > 0 || booking.overstayFeeEgp > 0)
                    _buildDetailRow(
                      context,
                      'تمديد ${booking.overstayDays} يوم',
                      '${booking.overstayFeeEgp.toDouble().toCurrencyFormat()} ج.م',
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
                          ? '${booking.brokerCommissionFixedEgp.toCurrencyFormat()} ج.م'
                          : '${booking.brokerCommissionPercentage} %',
                    ),
                    _buildDetailRow(
                      context,
                      'فلوس السمسار اللي أخدها',
                      '${commissionAmount.toDouble().toCurrencyFormat()} ج.م',
                      valueColor: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 32),

              if (booking.status != 'checked_out') ...[
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
                          context.go('/inspections/add?apartmentId=${booking.apartmentId}&checkoutBookingId=${booking.id}');
                        },
                        child: const Text('تسجيل خروج'),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                ElevatedButton.icon(
                  onPressed: () {
                    context.go('/inspections/add?apartmentId=${booking.apartmentId}');
                  },
                  icon: const Icon(Icons.fact_check),
                  label: const Text('فحص واستلام الشقة'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
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
