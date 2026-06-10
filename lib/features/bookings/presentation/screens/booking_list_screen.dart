import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/config/app_settings_provider.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/season_utils.dart';
import '../../../../shared/widgets/widgets.dart';
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

  static const _filterKeys = ['nearest', 'in_progress', 'upcoming', 'finished'];
  static const _filterLabels = ['الأقرب', 'جارية', 'قادمة', 'منتهية'];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bookingsAsync = ref.watch(summerBookingsProvider);
    final apartmentsAsync = ref.watch(apartmentsProvider);
    final activeSeason = ref.watch(activeSeasonKeyProvider);
    final colors = context.colors;

    return AppScaffold(
      appBar: AbragAppBar(
        title: l10n.summerBookings, // Reusing translation
        subtitle: 'الموسم المعروض: ${seasonLabel(activeSeason)}',
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 14),
            child: SegmentedTabs(
              labels: _filterLabels,
              index: _filterKeys.indexOf(_selectedFilter),
              onChanged: (i) =>
                  setState(() => _selectedFilter = _filterKeys[i]),
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
                  return EmptyState(
                    icon: Icons.calendar_today_outlined,
                    title: l10n.noData,
                    sub: 'غيّر التصفية أو أضف حجزًا جديدًا.',
                  );
                }
                return ListView.builder(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 90),
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
                        ? colors.ok
                        : booking.amountPaidEgp > 0
                        ? colors.warn
                        : colors.err;
                    final statusKind = isPaidFull
                        ? StatusChipKind.ok
                        : booking.amountPaidEgp > 0
                        ? StatusChipKind.warn
                        : StatusChipKind.err;
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
                    return AppCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      onTap: () {
                        // Navigate to details
                        context.push(
                          '/summer_bookings/details/${booking.id}',
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              AppAvatar(
                                name: booking.guestName,
                                tint: colors.summer,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  booking.guestName,
                                  style: AppTextStyles.title
                                      .copyWith(color: colors.ink),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              StatusChip(
                                kind: statusKind,
                                label: isPaidFull
                                    ? 'مدفوع بالكامل'
                                    : _statusLabel(booking.status),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _BookingDateSummary(
                            checkInDate: booking.checkInDate,
                            checkOutDate:
                                booking.earlyCheckoutDate ??
                                booking.checkOutDate,
                            daysCount: daysCount,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.apartment,
                                size: 14,
                                color: colors.ink3,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'رقم الشقة: $apartmentNumber',
                                style: AppTextStyles.caption
                                    .copyWith(color: colors.ink3),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          _MoneyRow(
                            label: 'السعر اليومي',
                            value:
                                '${dailyRate.toDouble().toCurrencyFormat()} ج.م',
                          ),
                          const SizedBox(height: 6),
                          _MoneyRow(
                            label: 'الفلوس بعد السمسار',
                            value:
                                '${netAmount.toDouble().toCurrencyFormat()} ج.م',
                            emphasize: true,
                            valueColor:
                                isPaidFull ? colors.ok : colors.accent,
                          ),
                          const SizedBox(height: 6),
                          _MoneyRow(
                            label: 'فلوس السمسار اللي أخدها',
                            value:
                                '${commissionAmount.toDouble().toCurrencyFormat()} ج.م',
                          ),
                          if (booking.overstayDays > 0 ||
                              booking.overstayFeeEgp > 0) ...[
                            const SizedBox(height: 6),
                            _MoneyRow(
                              label: 'تمديد ${booking.overstayDays} يوم',
                              value:
                                  '${booking.overstayFeeEgp.toDouble().toCurrencyFormat()} ج.م',
                              valueColor: colors.accent,
                            ),
                          ],
                          if (remainingAmount > 0) ...[
                            const SizedBox(height: 6),
                            _MoneyRow(
                              label: 'المتبقي',
                              value:
                                  '${remainingAmount.toDouble().toCurrencyFormat()} ج.م',
                              labelColor: statusColor == colors.ok
                                  ? colors.ink2
                                  : colors.err,
                              valueColor: colors.err,
                              emphasize: true,
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const LoadingSkeleton(),
              error: (error, stack) => ErrorState(
                title: 'تعذّر تحميل البيانات',
                message: '$error',
                retryLabel: 'إعادة المحاولة',
                onRetry: () => ref.invalidate(summerBookingsProvider),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: AppFab(
        onPressed: () {
          context.go('/summer_bookings/add');
        },
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

/// Label/value money line with tabular figures.
class _MoneyRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? labelColor;
  final Color? valueColor;
  final bool emphasize;

  const _MoneyRow({
    required this.label,
    required this.value,
    this.labelColor,
    this.valueColor,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyS
              .copyWith(color: labelColor ?? colors.ink2),
        ),
        Text(
          value,
          style: AppTextStyles.tabular(
            (emphasize ? AppTextStyles.title : AppTextStyles.bodyS).copyWith(
              color: valueColor ?? colors.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
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
    final colors = context.colors;
    final formatter = DateFormat('EEEE yyyy-MM-dd', 'ar');

    Widget line(IconData icon, String label, String value, {bool bold = false}) {
      return Row(
        children: [
          Icon(icon, size: 15, color: colors.ink3),
          const SizedBox(width: 6),
          Text(label,
              style: AppTextStyles.caption.copyWith(color: colors.ink3)),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.tabular(
              AppTextStyles.bodyS.copyWith(
                color: colors.ink,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.surface3.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          line(Icons.login, 'الدخول', formatter.format(checkInDate)),
          const SizedBox(height: 6),
          line(Icons.logout, 'الخروج', formatter.format(checkOutDate)),
          const Divider(height: 14),
          line(Icons.nights_stay_outlined, 'عدد الأيام', '$daysCount يوم',
              bold: true),
        ],
      ),
    );
  }
}
