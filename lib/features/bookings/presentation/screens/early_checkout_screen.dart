import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/bookings_provider.dart';
import '../providers/bookings_controller.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/widgets.dart';

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
    final bookingsAsync = ref.watch(allSummerBookingsProvider);
    final controllerState = ref.watch(bookingsControllerProvider);
    final colors = context.colors;

    ref.listen<AsyncValue<void>>(bookingsControllerProvider, (_, state) {
      state.whenOrNull(
        data: (_) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/summer_bookings/details/${widget.bookingId}');
          }
        },
        error: (error, _) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $error'))),
      );
    });

    return AppScaffold(
      appBar: AbragAppBar(
        title: 'خروج مبكر',
        showBack: true,
        onBack: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/summer_bookings/details/${widget.bookingId}');
          }
        },
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
              AppCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'النزيل الحالي',
                        style:
                            AppTextStyles.label.copyWith(color: colors.ink2),
                      ),
                      Text(
                        booking.guestName,
                        style: AppTextStyles.h2.copyWith(color: colors.ink),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            size: 16,
                            color: colors.ink3,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'الحجز الأصلي: $originalDays أيام',
                            style: AppTextStyles.body
                                .copyWith(color: colors.ink2),
                          ),
                        ],
                      ),
                      Text(
                        'إجمالي المدفوع: ${booking.totalPriceEgp} ج.م',
                        style: AppTextStyles.tabular(
                          AppTextStyles.title.copyWith(color: colors.accent),
                        ),
                      ),
                    ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'الأيام المستخدمة',
                            style: AppTextStyles.body
                                .copyWith(color: colors.ink2),
                          ),
                          Text(
                            '$usedDays',
                            style: AppTextStyles.label
                                .copyWith(color: colors.ok),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'الأيام المتبقية',
                            style: AppTextStyles.body
                                .copyWith(color: colors.ink2),
                          ),
                          Text(
                            '$remainingDays',
                            style: AppTextStyles.label
                                .copyWith(color: colors.err),
                          ),
                        ],
                      ),
                      Divider(color: colors.border),
                      _CalcLine(
                        label: 'الأيام المتبقية × سعر اليوم',
                        value:
                            '$remainingDays × ${dailyRate.toDouble().toCurrencyFormat()} = ${refundAmount.toDouble().toCurrencyFormat()} ج.م',
                      ),
                      if (brokerCommission > 0)
                        _CalcLine(
                          label: 'فلوس السمسار',
                          value:
                              '- ${brokerCommission.toDouble().toCurrencyFormat()} ج.م',
                          valueColor: colors.err,
                        ),
                      Divider(color: colors.border),
                      _CalcLine(
                        label: 'صافي مبلغ الاسترداد',
                        value:
                            '${visibleNetRefund.toDouble().toCurrencyFormat()} ج.م',
                        valueColor: colors.accent,
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
              const SizedBox(height: 24),
              AppButton(
                label: 'فحص الشقة وتأكيد الخروج',
                icon: Icons.fact_check,
                expand: true,
                loading: controllerState.isLoading,
                onPressed: controllerState.isLoading || remainingDays <= 0
                    ? null
                    : () {
                        context.go(
                          Uri(
                            path: '/inspections/add',
                            queryParameters: {
                              'apartmentId': booking.apartmentId,
                              'earlyCheckoutBookingId': booking.id,
                              'newCheckoutDate': today.toIso8601String(),
                            },
                          ).toString(),
                        );
                      },
              ),
            ],
          );
        },
        loading: () => const LoadingSkeleton(),
        error: (e, st) => ErrorState(
          title: 'تعذر تحميل بيانات الحجز',
          message: 'Error: $e',
          retryLabel: 'إعادة المحاولة',
          onRetry: () => ref.invalidate(allSummerBookingsProvider),
        ),
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
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: (isTitle ? AppTextStyles.title : AppTextStyles.body)
                  .copyWith(color: colors.ink2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.tabular(
                (isTitle ? AppTextStyles.h3 : AppTextStyles.label)
                    .copyWith(color: valueColor ?? colors.ink),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
