import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/bookings_provider.dart';
import '../providers/bookings_controller.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/widgets.dart';

class OverstayExtensionScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const OverstayExtensionScreen({super.key, required this.bookingId});

  @override
  ConsumerState<OverstayExtensionScreen> createState() =>
      _OverstayExtensionScreenState();
}

class _OverstayExtensionScreenState
    extends ConsumerState<OverstayExtensionScreen> {
  int _extraDays = 1;
  final _customPriceController = TextEditingController();
  bool _useCustomPrice = false;
  DateTime? _customCheckoutDate;

  @override
  void dispose() {
    _customPriceController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(
    BuildContext context,
    DateTime initialDate,
  ) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate == null || !context.mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    if (pickedTime == null) return;

    setState(() {
      _customCheckoutDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      final existingCheckout = ref
          .read(allSummerBookingsProvider)
          .value
          ?.where((b) => b.id == widget.bookingId)
          .firstOrNull
          ?.checkOutDate;
      if (existingCheckout != null) {
        _extraDays = _customCheckoutDate!
            .difference(existingCheckout)
            .inDays
            .clamp(1, 10000);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(allSummerBookingsProvider);
    final controllerState = ref.watch(bookingsControllerProvider);
    final colors = context.colors;
    final formatter = DateFormat('EEEE yyyy-MM-dd hh:mm a', 'ar');

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
        title: 'تمديد الحجز',
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
          final originalDays = booking.checkOutDate
              .difference(booking.checkInDate)
              .inDays
              .clamp(1, 10000);
          final automaticDailyRate = booking.totalPriceEgp / originalDays;
          final dailyRate = _useCustomPrice
              ? (double.tryParse(_customPriceController.text) ?? 0)
              : automaticDailyRate;
          final additionalFee = dailyRate * _extraDays;
          final newCheckoutDate =
              _customCheckoutDate ??
              booking.checkOutDate.add(Duration(days: _extraDays));

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
                      const SizedBox(height: 12),
                      _InfoLine(
                        icon: Icons.event_busy,
                        label: 'الخروج الحالي',
                        value: formatter.format(booking.checkOutDate),
                      ),
                      const SizedBox(height: 8),
                      _InfoLine(
                        icon: Icons.event_available,
                        label: 'الخروج الجديد',
                        value: formatter.format(newCheckoutDate),
                      ),
                    ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'عدد أيام التمديد',
                style: AppTextStyles.title.copyWith(color: colors.ink),
              ),
              const SizedBox(height: 8),
              AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppIconButton(
                        onPressed: () => setState(() {
                          _extraDays++;
                          _customCheckoutDate = null;
                        }),
                        icon: Icons.add,
                      ),
                      Column(
                        children: [
                          Text(
                            '$_extraDays',
                            style: AppTextStyles.tabular(
                              AppTextStyles.h1.copyWith(color: colors.ink),
                            ),
                          ),
                          Text(
                            'أيام',
                            style: AppTextStyles.label
                                .copyWith(color: colors.ink2),
                          ),
                        ],
                      ),
                      AppIconButton(
                        onPressed: _extraDays > 1
                            ? () => setState(() {
                                _extraDays--;
                                _customCheckoutDate = null;
                              })
                            : null,
                        icon: Icons.remove,
                      ),
                    ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('تخصيص سعر الليلة'),
                        subtitle: Text(
                          'السعر التلقائي: ${automaticDailyRate.toDouble().toCurrencyFormat()} ج.م',
                        ),
                        value: _useCustomPrice,
                        onChanged: (val) =>
                            setState(() => _useCustomPrice = val),
                      ),
                      if (_useCustomPrice) ...[
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _customPriceController,
                          decoration: const InputDecoration(
                            labelText: 'سعر الليلة (ج.م)',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                      const SizedBox(height: 16),
                      _InfoLine(
                        icon: Icons.calculate,
                        label: 'حساب التمديد',
                        value:
                            '$_extraDays × ${dailyRate.toDouble().toCurrencyFormat()} ج.م',
                      ),
                      Divider(color: colors.border),
                      _InfoLine(
                        icon: Icons.payments,
                        label: 'تمديد $_extraDays يوم',
                        value:
                            '${additionalFee.toDouble().toCurrencyFormat()} ج.م',
                        valueColor: colors.accent,
                        bold: true,
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        label: 'تغيير تاريخ الخروج الجديد',
                        icon: Icons.edit_calendar,
                        variant: AppButtonVariant.outline,
                        onPressed: () =>
                            _selectDateTime(context, newCheckoutDate),
                      ),
                    ],
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'تأكيد التمديد',
                icon: Icons.check_circle,
                expand: true,
                loading: controllerState.isLoading,
                onPressed: controllerState.isLoading
                    ? null
                    : () {
                        ref
                            .read(bookingsControllerProvider.notifier)
                            .extendBooking(
                              id: widget.bookingId,
                              newCheckoutDate: newCheckoutDate,
                              overstayDays: _extraDays,
                              additionalFeeEgp: additionalFee,
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

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: colors.ink3),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(color: colors.ink2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: (bold ? AppTextStyles.title : AppTextStyles.label)
                .copyWith(color: valueColor ?? colors.ink),
          ),
        ),
      ],
    );
  }
}
