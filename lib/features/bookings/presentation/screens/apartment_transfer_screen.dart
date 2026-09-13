import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/bookings_provider.dart';
import '../providers/bookings_controller.dart';
import '../../../apartments/presentation/providers/apartments_controller.dart';
import '../../../../core/database/database.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/booking_rate_utils.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/occupancy_utils.dart';
import '../../../../shared/widgets/widgets.dart';

/// نقل ضيف من شقة لشقة في نص إقامته.
///
/// الشاشة بتحسب لوحدها: الليالي اللي قعدها في القديمة وتمنها، الرصيد اللي
/// بيترحّل معاه، وسعر باقي المدة في الشقة الجديدة — وتوريه الفرق المطلوب
/// (أو المرتجع) قبل ما يأكد.
class ApartmentTransferScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const ApartmentTransferScreen({super.key, required this.bookingId});

  @override
  ConsumerState<ApartmentTransferScreen> createState() =>
      _ApartmentTransferScreenState();
}

class _ApartmentTransferScreenState
    extends ConsumerState<ApartmentTransferScreen> {
  String? _newApartmentId;
  DateTime? _transferDate;

  /// 0 = نفس سعر الشقة القديمة · 1 = سعر ليلة جديد · 2 = مبلغ إجمالي
  int _priceMode = 0;
  final _priceController = TextEditingController();

  bool _settleNow = true;
  String _paymentMethod = 'cash';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  /// كل حسابات النقل في مكان واحد، عشان الشاشة والزرار ميختلفوش أبدًا.
  _TransferCalc _calculate(SummerBooking booking) {
    final checkIn = dateOnly(booking.checkInDate);
    final checkOut = dateOnly(booking.checkOutDate);
    final transferDay = dateOnly(_transferDate ?? DateTime.now());

    final bookedNights = checkOut.difference(checkIn).inDays;
    final stayedNights = transferDay.difference(checkIn).inDays;
    final remainingNights = checkOut.difference(transferDay).inDays;

    final oldNightlyRate = summerBookingDailyRate(booking);
    final oldNewTotal = oldNightlyRate * stayedNights;
    final carried = booking.amountPaidEgp - oldNewTotal;

    final typed = double.tryParse(_priceController.text) ?? 0;
    final double newTotal;
    final double newNightlyRate;
    switch (_priceMode) {
      case 1:
        newNightlyRate = typed < 0 ? 0 : typed;
        newTotal = newNightlyRate * remainingNights;
      case 2:
        newTotal = typed < 0 ? 0 : typed;
        newNightlyRate = remainingNights > 0 ? newTotal / remainingNights : 0;
      default:
        newNightlyRate = oldNightlyRate;
        newTotal = oldNightlyRate * remainingNights;
    }

    return _TransferCalc(
      transferDay: transferDay,
      bookedNights: bookedNights,
      stayedNights: stayedNights,
      remainingNights: remainingNights,
      oldNightlyRate: oldNightlyRate,
      oldNewTotal: oldNewTotal,
      carried: carried,
      newNightlyRate: newNightlyRate,
      newTotal: newTotal,
      difference: newTotal - carried,
    );
  }

  Future<void> _pickTransferDate(SummerBooking booking) async {
    final checkIn = dateOnly(booking.checkInDate);
    final checkOut = dateOnly(booking.checkOutDate);
    final first = checkIn.add(const Duration(days: 1));
    final last = checkOut.subtract(const Duration(days: 1));
    if (last.isBefore(first)) return;

    var initial = _transferDate ?? dateOnly(DateTime.now());
    if (initial.isBefore(first)) initial = first;
    if (initial.isAfter(last)) initial = last;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      helpText: 'تاريخ النقل',
    );
    if (picked != null) setState(() => _transferDate = dateOnly(picked));
  }

  Future<void> _submit(SummerBooking booking, _TransferCalc calc) async {
    if (_isSubmitting) return;
    if (_newApartmentId == null) return;
    setState(() => _isSubmitting = true);
    try {
      final owed = calc.difference;
      await ref
          .read(bookingsControllerProvider.notifier)
          .transferBooking(
            id: booking.id,
            newApartmentId: _newApartmentId!,
            transferDate: calc.transferDay,
            newBookingTotalEgp: calc.newTotal,
            collectedNowEgp: _settleNow && owed > 0.01 ? owed : 0,
            refundedNowEgp: _settleNow && owed < -0.01 ? -owed : 0,
            paymentMethod: _paymentMethod,
          );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(allSummerBookingsProvider);
    final apartmentsAsync = ref.watch(apartmentsProvider);
    final colors = context.colors;

    ref.listen<AsyncValue<void>>(bookingsControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          if (previous is AsyncLoading) _goBack();
        },
        error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$error'.replaceFirst('Exception: ', '')),
            backgroundColor: colors.err,
          ),
        ),
      );
    });

    return AppScaffold(
      appBar: AbragAppBar(title: 'نقل الشقة', showBack: true, onBack: _goBack),
      body: bookingsAsync.when(
        data: (bookings) {
          final booking = bookings.firstWhere((b) => b.id == widget.bookingId);
          final calc = _calculate(booking);
          final apartments = apartmentsAsync.value ?? const <Apartment>[];
          final currentApartment = apartments
              .where((a) => a.id == booking.apartmentId)
              .firstOrNull;
          final options = apartments
              .where((a) => a.id != booking.apartmentId)
              .toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _GuestCard(
                booking: booking,
                currentApartment: currentApartment,
                calc: calc,
              ),

              const SectionTitle(title: 'تفاصيل النقل'),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppDropdownField<String>(
                      label: 'الشقة الجديدة',
                      prefixIcon: Icons.meeting_room_outlined,
                      initialValue: _newApartmentId,
                      items: [
                        for (final apartment in options)
                          DropdownMenuItem(
                            value: apartment.id,
                            child: Text('شقة ${apartment.apartmentNumber}'),
                          ),
                      ],
                      onChanged: (value) =>
                          setState(() => _newApartmentId = value),
                    ),
                    const SizedBox(height: 12),
                    AppDateField(
                      label: 'تاريخ النقل',
                      value: _formatDay(calc.transferDay),
                      onTap: () => _pickTransferDate(booking),
                    ),
                  ],
                ),
              ),

              const SectionTitle(title: 'سعر الشقة الجديدة'),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SegmentedTabs(
                      labels: const ['نفس السعر', 'سعر الليلة', 'مبلغ إجمالي'],
                      index: _priceMode,
                      onChanged: (value) => setState(() => _priceMode = value),
                    ),
                    if (_priceMode != 0) ...[
                      const SizedBox(height: 12),
                      AppTextField(
                        label: _priceMode == 1
                            ? 'سعر الليلة في الشقة الجديدة (ج.م)'
                            : 'إجمالي باقي المدة (ج.م)',
                        prefixIcon: Icons.payments_outlined,
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*'),
                          ),
                        ],
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                    const SizedBox(height: 4),
                    _CalcLine(
                      label: 'باقي المدة',
                      value:
                          '${calc.remainingNights} ليلة × '
                          '${calc.newNightlyRate.toCurrencyFormat()} ج.م',
                    ),
                    Divider(color: colors.border),
                    _CalcLine(
                      label: 'إجمالي الحجز الجديد',
                      value: '${calc.newTotal.toCurrencyFormat()} ج.م',
                      bold: true,
                    ),
                  ],
                ),
              ),

              const SectionTitle(title: 'الفلوس'),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _CalcLine(
                      label:
                          'المدفوع على الحجز القديم '
                          '(${booking.amountPaidEgp.toCurrencyFormat()}) '
                          'ناقص ${calc.stayedNights} ليلة',
                      value: '${calc.carried.toCurrencyFormat()} ج.م',
                    ),
                    _CalcLine(
                      label: 'إجمالي الحجز الجديد',
                      value: '${calc.newTotal.toCurrencyFormat()} ج.م',
                    ),
                    Divider(color: colors.border),
                    _CalcLine(
                      label: calc.difference >= 0
                          ? 'العميل يدفع فرق'
                          : 'يترجع للعميل',
                      value: '${calc.difference.abs().toCurrencyFormat()} ج.م',
                      bold: true,
                      valueColor: calc.difference.abs() < 0.01
                          ? colors.ok
                          : (calc.difference > 0 ? colors.summer : colors.err),
                    ),
                  ],
                ),
              ),

              if (calc.difference.abs() > 0.01) ...[
                const SizedBox(height: 8),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppSwitchRow(
                        title: calc.difference > 0
                            ? 'العميل دفع الفرق دلوقتي'
                            : 'رجّعت له الفلوس دلوقتي',
                        subtitle: _settleNow
                            ? 'هيتسجل كحركة على الخزنة'
                            : 'مش هيتسجل، وهيفضل باقي على الحجز',
                        icon: Icons.account_balance_wallet_outlined,
                        value: _settleNow,
                        onChanged: (value) =>
                            setState(() => _settleNow = value),
                      ),
                      if (_settleNow) ...[
                        const SizedBox(height: 12),
                        SegmentedTabs(
                          labels: const ['نقدي', 'فودافون كاش', 'إنستا باي'],
                          index: _methodIndex,
                          onChanged: (value) =>
                              setState(() => _paymentMethod = _methods[value]),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12),
              AppCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 18, color: colors.ink3),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'الفلوس اللي دفعها قبل كده بتترحّل معاه للحجز الجديد '
                        'من غير ما تتحسب مرتين. الخزنة هتتأثر بالفرق بس.',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 13,
                          color: colors.ink2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('خطأ: $error')),
      ),
      bottomNavigationBar: bookingsAsync.maybeWhen(
        data: (bookings) {
          final booking = bookings.firstWhere((b) => b.id == widget.bookingId);
          final calc = _calculate(booking);
          final canSubmit =
              _newApartmentId != null &&
              calc.stayedNights > 0 &&
              calc.remainingNights > 0 &&
              calc.newTotal >= 0 &&
              !_isSubmitting;
          return BottomActionBar(
            children: [
              Expanded(
                child: AppButton(
                  label: 'تأكيد النقل',
                  icon: Icons.swap_horiz,
                  expand: true,
                  loading: _isSubmitting,
                  onPressed: canSubmit ? () => _submit(booking, calc) : null,
                ),
              ),
            ],
          );
        },
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }

  static String _formatDay(DateTime value) =>
      '${value.year}/${value.month.toString().padLeft(2, '0')}/'
      '${value.day.toString().padLeft(2, '0')}';

  static const _methods = ['cash', 'vodafone_cash', 'instapay'];
  int get _methodIndex => _methods.indexOf(_paymentMethod).clamp(0, 2);

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/summer_bookings/details/${widget.bookingId}');
    }
  }
}

class _TransferCalc {
  final DateTime transferDay;
  final int bookedNights;
  final int stayedNights;
  final int remainingNights;
  final double oldNightlyRate;
  final double oldNewTotal;
  final double carried;
  final double newNightlyRate;
  final double newTotal;
  final double difference;

  const _TransferCalc({
    required this.transferDay,
    required this.bookedNights,
    required this.stayedNights,
    required this.remainingNights,
    required this.oldNightlyRate,
    required this.oldNewTotal,
    required this.carried,
    required this.newNightlyRate,
    required this.newTotal,
    required this.difference,
  });
}

class _GuestCard extends StatelessWidget {
  final SummerBooking booking;
  final Apartment? currentApartment;
  final _TransferCalc calc;

  const _GuestCard({
    required this.booking,
    required this.currentApartment,
    required this.calc,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconTile(
            icon: Icons.swap_horiz,
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
                  currentApartment == null
                      ? 'الضيف'
                      : 'شقة ${currentApartment!.apartmentNumber}',
                  style: AppTextStyles.label.copyWith(color: colors.ink2),
                ),
                Text(
                  booking.guestName,
                  style: AppTextStyles.h2.copyWith(color: colors.ink),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    StatusChip(
                      label: 'قعد ${calc.stayedNights} من ${calc.bookedNights}',
                      kind: StatusChipKind.neutral,
                      icon: Icons.hotel,
                    ),
                    StatusChip(
                      label:
                          'سعر الليلة: '
                          '${calc.oldNightlyRate.toCurrencyFormat()} ج.م',
                      kind: StatusChipKind.brand,
                      icon: Icons.price_change,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CalcLine extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  const _CalcLine({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(
                fontSize: 13,
                color: colors.ink2,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: (bold ? AppTextStyles.h3 : AppTextStyles.body).copyWith(
              fontSize: bold ? 15 : 14,
              color: valueColor ?? colors.ink,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
