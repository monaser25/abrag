import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/config/app_settings_provider.dart';
import '../../../../core/utils/season_utils.dart';
import '../providers/bookings_provider.dart';
import '../../../apartments/presentation/providers/apartments_controller.dart';
import '../../../../core/utils/currency_formatter.dart';

class BookingListScreen extends ConsumerStatefulWidget {
  const BookingListScreen({super.key});

  @override
  ConsumerState<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends ConsumerState<BookingListScreen> {
  String _selectedFilter =
      'nearest'; // nearest, in_progress, upcoming, finished

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bookingsAsync = ref.watch(summerBookingsProvider);
    final apartmentsAsync = ref.watch(apartmentsProvider);
    final activeSeason = ref.watch(activeSeasonKeyProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.summerBookings), // Reusing translation
      ),
      body: Column(
        children: [
          // Filter Row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: ListTile(
              dense: true,
              leading: const Icon(Icons.event_repeat),
              title: const Text('الموسم المعروض'),
              subtitle: Text(seasonLabel(activeSeason)),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _selectedFilter = 'nearest'),
                  child: _FilterChip(
                    label: 'الأقرب',
                    isSelected: _selectedFilter == 'nearest',
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => _selectedFilter = 'in_progress'),
                  child: _FilterChip(
                    label: 'جارية',
                    isSelected: _selectedFilter == 'in_progress',
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => _selectedFilter = 'upcoming'),
                  child: _FilterChip(
                    label: 'قادمة',
                    isSelected: _selectedFilter == 'upcoming',
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => _selectedFilter = 'finished'),
                  child: _FilterChip(
                    label: 'منتهية',
                    isSelected: _selectedFilter == 'finished',
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: bookingsAsync.when(
              data: (bookings) {
                final now = DateTime.now();
                final filteredBookings =
                    bookings.where((b) {
                      final effectiveEnd =
                          b.earlyCheckoutDate ?? b.checkOutDate;
                      final isFinished =
                          b.status == 'checked_out' ||
                          b.status == 'cancelled' ||
                          effectiveEnd.isBefore(now);
                      final isCurrent =
                          !isFinished &&
                          !b.checkInDate.isAfter(now) &&
                          effectiveEnd.isAfter(now);
                      final isUpcoming =
                          !isFinished && b.checkInDate.isAfter(now);

                      if (_selectedFilter == 'nearest') return !isFinished;
                      if (_selectedFilter == 'in_progress') return isCurrent;
                      if (_selectedFilter == 'upcoming') return isUpcoming;
                      if (_selectedFilter == 'finished') return isFinished;
                      return true;
                    }).toList()..sort((a, b) {
                      if (_selectedFilter == 'finished') {
                        return (b.earlyCheckoutDate ?? b.checkOutDate)
                            .compareTo(a.earlyCheckoutDate ?? a.checkOutDate);
                      }
                      return a.checkInDate.compareTo(b.checkInDate);
                    });

                if (filteredBookings.isEmpty) {
                  return Center(child: Text(l10n.noData));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredBookings.length,
                  itemBuilder: (context, index) {
                    final booking = filteredBookings[index];
                    final apartmentNumber = apartmentsAsync.maybeWhen(
                      data: (apartments) {
                        final matches = apartments
                            .where((a) => a.id == booking.apartmentId)
                            .toList();
                        return matches.isEmpty
                            ? booking.apartmentId
                            : matches.first.apartmentNumber;
                      },
                      orElse: () => booking.apartmentId,
                    );
                    final baseBookingTotal =
                        booking.totalPriceEgp - booking.overstayFeeEgp;
                    final isPaidFull =
                        baseBookingTotal > 0 &&
                        booking.amountPaidEgp >= booking.totalPriceEgp;
                    final statusColor = isPaidFull
                        ? Colors.green
                        : booking.amountPaidEgp > 0
                        ? Colors.orange
                        : Theme.of(context).colorScheme.error;
                    final commissionAmount =
                        booking.brokerCommissionType == 'fixed'
                        ? booking.brokerCommissionFixedEgp
                        : booking.brokerCommissionType == 'percentage'
                        ? booking.totalPriceEgp *
                              (booking.brokerCommissionPercentage / 100)
                        : 0.0;
                    final netAmount = baseBookingTotal - commissionAmount;
                    final daysCount = _calendarDays(
                      booking.checkInDate,
                      booking.earlyCheckoutDate ?? booking.checkOutDate,
                    );
                    final dailyRate = baseBookingTotal / daysCount;
                    final remainingAmount =
                        (baseBookingTotal -
                                (booking.amountPaidEgp -
                                    booking.overstayFeeEgp))
                            .clamp(0, double.infinity);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () {
                          // Navigate to details
                          context.push(
                            '/summer_bookings/details/${booking.id}',
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      booking.guestName,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(
                                        alpha: 0.18,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      isPaidFull
                                          ? 'مدفوع بالكامل'
                                          : _statusLabel(booking.status),
                                      style: TextStyle(
                                        color: statusColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _BookingDateSummary(
                                checkInDate: booking.checkInDate,
                                checkOutDate:
                                    booking.earlyCheckoutDate ??
                                    booking.checkOutDate,
                                daysCount: daysCount,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.apartment,
                                    size: 16,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'رقم الشقة: $apartmentNumber',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'السعر اليومي',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    '${dailyRate.toDouble().toCurrencyFormat()} ج.م',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'الفلوس بعد السمسار',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    '${netAmount.toDouble().toCurrencyFormat()} ج.م',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: isPaidFull
                                              ? Colors.green
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'فلوس السمسار اللي أخدها',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    '${commissionAmount.toDouble().toCurrencyFormat()} ج.م',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              if (booking.overstayDays > 0 ||
                                  booking.overstayFeeEgp > 0) ...[
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'تمديد ${booking.overstayDays} يوم',
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      '${booking.overstayFeeEgp.toDouble().toCurrencyFormat()} ج.م',
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (remainingAmount > 0) ...[
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'المتبقي',
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.error,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      '${remainingAmount.toDouble().toCurrencyFormat()} ج.م',
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.error,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'confirmed':
        return 'مؤكد';
      case 'checked_in':
        return 'داخل الشقة';
      case 'checked_out':
        return 'تم الخروج';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  int _calendarDays(DateTime start, DateTime end) {
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);
    return endDate.difference(startDate).inDays.clamp(1, 10000);
  }
}

class _BookingDateSummary extends StatelessWidget {
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int daysCount;

  const _BookingDateSummary({
    required this.checkInDate,
    required this.checkOutDate,
    required this.daysCount,
  });

  @override
  Widget build(BuildContext context) {
    final mutedColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final formatter = DateFormat('EEEE yyyy-MM-dd', 'ar');

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.login, size: 16, color: mutedColor),
              const SizedBox(width: 6),
              Text('الدخول', style: TextStyle(color: mutedColor, fontSize: 12)),
              const Spacer(),
              Text(
                formatter.format(checkInDate),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.logout, size: 16, color: mutedColor),
              const SizedBox(width: 6),
              Text('الخروج', style: TextStyle(color: mutedColor, fontSize: 12)),
              const Spacer(),
              Text(
                formatter.format(checkOutDate),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const Divider(height: 14),
          Row(
            children: [
              Icon(Icons.nights_stay, size: 16, color: mutedColor),
              const SizedBox(width: 6),
              Text(
                'عدد الأيام',
                style: TextStyle(color: mutedColor, fontSize: 12),
              ),
              const Spacer(),
              Text(
                '$daysCount يوم',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
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
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? Theme.of(context).colorScheme.onPrimaryContainer
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
