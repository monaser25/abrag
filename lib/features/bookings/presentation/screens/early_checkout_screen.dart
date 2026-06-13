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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              AppCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconTile(
                      icon: Icons.directions_walk,
                      tint: colors.summer,
                      size: 48,
                      iconSize: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'النزيل الحالي',
                            style: AppTextStyles.label
                                .copyWith(color: colors.ink2),
                          ),
                          Text(
                            booking.guestName,
                            style:
                                AppTextStyles.h2.copyWith(color: colors.ink),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              StatusChip(
                                label: 'الحجز الأصلي: $originalDays أيام',
                                kind: StatusChipKind.neutral,
                                icon: Icons.calendar_month,
                              ),
                              StatusChip(
                                label:
                                    'المدفوع: ${booking.totalPriceEgp} ج.م',
                                kind: StatusChipKind.brand,
                                icon: Icons.payments,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SectionTitle(title: 'حساب الاسترداد'),
              AppCard(
                child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: MiniMetric(
                              icon: Icons.check_circle_outline,
                              value: '$usedDays',
                              label: 'الأيام المستخدمة',
                              tint: colors.ok,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 38,
                            color: colors.border,
                          ),
                          Expanded(
                            child: MiniMetric(
                              icon: Icons.hourglass_bottom,
                              value: '$remainingDays',
                              label: 'الأيام المتبقية',
                              tint: colors.err,
                            ),
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
                      AppSwitchRow(
                        title: 'عدم استرداد نقود',
                        subtitle: 'تسجيل الخروج المبكر بدون رجوع أي مبلغ',
                        icon: Icons.money_off,
                        tint: colors.err,
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
                      const SizedBox(height: 8),
                      AppSwitchRow(
                        title: 'استرداد مخصص',
                        subtitle: 'تعديل مبلغ الاسترداد يدوياً',
                        icon: Icons.tune,
                        value: _customRefund,
                        onChanged: _noRefund
                            ? null
                            : (val) => setState(() => _customRefund = val),
                      ),
                      if (_customRefund) ...[
                        const SizedBox(height: 12),
                        AppTextField(
                          label: 'مبلغ الاسترداد الفعلي (ج.م)',
                          prefixIcon: Icons.payments_outlined,
                          controller: _refundController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ],
                    ],
                ),
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
      bottomNavigationBar: bookingsAsync.maybeWhen(
        data: (bookings) {
          final booking = bookings.firstWhere((b) => b.id == widget.bookingId);
          final today = DateTime.now();
          final originalDays = _calendarDays(
            booking.checkInDate,
            booking.checkOutDate,
          );
          final usedDays = _calendarDays(
            booking.checkInDate,
            today,
          ).clamp(1, originalDays);
          final remainingDays = (originalDays - usedDays).clamp(0, 10000);
          return BottomActionBar(
            children: [
              Expanded(
                child: AppButton(
                  label: 'فحص الشقة وتأكيد الخروج',
                  icon: Icons.fact_check,
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
              ),
            ],
          );
        },
        orElse: () => null,
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
