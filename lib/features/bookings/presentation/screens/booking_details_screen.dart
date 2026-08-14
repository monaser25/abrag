import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../../core/database/database.dart';
import '../providers/bookings_provider.dart';
import '../providers/bookings_controller.dart';
import '../../../apartments/presentation/providers/apartments_controller.dart';
import '../../../users/presentation/providers/users_provider.dart';
import '../../../settings/presentation/providers/permissions_provider.dart';

import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/input_formatters.dart';
import '../../../../core/utils/booking_rate_utils.dart';
import '../../../../shared/widgets/widgets.dart';

class BookingDetailsScreen extends ConsumerWidget {
  final String bookingId;

  const BookingDetailsScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(allSummerBookingsProvider);
    final apartmentsAsync = ref.watch(apartmentsProvider);
    final brokersAsync = ref.watch(brokersProvider);
    final isViewer = !ref.watch(canManageBookingsProvider);

    return AppScaffold(
      appBar: AbragAppBar(
        title: 'تفاصيل الحجز',
        showBack: true,
        onBack: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/summer_bookings/list');
          }
        },
        actions: [
          if (!isViewer) ...[
            AppIconButton(
              icon: Icons.edit_outlined,
              onPressed: () {
                context.go('/summer_bookings/edit/$bookingId');
              },
            ),
            AppIconButton(
              icon: Icons.delete_outline,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('تأكيد الحذف'),
                    content: const Text(
                      'هل أنت متأكد من حذف هذا الحجز نهائياً؟',
                    ),
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
          // السعر اليومي = سعر الإقامة الأصلية ÷ ليالي الإقامة الأصلية.
          // كان بيقسم سعر الأصل على **كل** الليالي (الأصلية + التمديد)، فحجز
          // ٢٤٠٠ لأربع ليالي (٦٠٠ لليلة) بعد تمديد ٦ أيام كان بيبان ٢٤٠ لليلة.
          final bookingDays = summerBookingStayDays(booking);
          final dailyRate = summerBookingBaseDailyRate(booking);
          // اللي على العميل = الإجمالي كله (شامل رسوم التمديد) ناقص المدفوع.
          final remainingAmount =
              (booking.totalPriceEgp - booking.amountPaidEgp).clamp(
                0,
                double.infinity,
              );
          final isFullyPaid = booking.amountPaidEgp >= booking.totalPriceEgp;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (remainingAmount > 0) ...[
                Builder(
                  builder: (context) {
                    final colors = context.colors;
                    return AppCard(
                      color: Color.alphaBlend(colors.errSoft, colors.surface),
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber, color: colors.err),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'العميل عليه باقي فلوس',
                                  style: AppTextStyles.title.copyWith(
                                    color: colors.err,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'المتبقي ${remainingAmount.toCurrencyFormat()} ج.م. الرجاء تسديدها قبل التسليم.',
                                  style: AppTextStyles.bodyS.copyWith(
                                    color: colors.ink2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isViewer) ...[
                            const SizedBox(width: 8),
                            AppButton(
                              label: 'تسديد',
                              small: true,
                              onPressed: () => _showPaymentSheet(
                                context,
                                ref,
                                bookingId: booking.id,
                                currentPaid: booking.amountPaidEgp,
                                remainingAmount: remainingAmount.toDouble(),
                                totalAmount: booking.totalPriceEgp,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
              _buildSection(
                context,
                title: 'معلومات الضيف',
                icon: Icons.person,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          booking.guestName,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push(
                          '/summer_bookings/guest/${Uri.encodeComponent(booking.guestName)}',
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
                  if ((booking.nationalId ?? '').isNotEmpty)
                    _buildDetailRow(
                      context,
                      'الرقم القومي',
                      booking.nationalId!,
                    ),
                  if (booking.idFrontImage != null ||
                      booking.idBackImage != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (booking.idFrontImage != null)
                          Expanded(
                            child: _buildImageCard(
                              context,
                              booking.idFrontImage!,
                              'بطاقة أمام',
                            ),
                          ),
                        if (booking.idBackImage != null)
                          Expanded(
                            child: _buildImageCard(
                              context,
                              booking.idBackImage!,
                              'بطاقة خلف',
                            ),
                          ),
                      ],
                    ),
                  ],
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
                  if (booking.overstayFeeEgp > 0)
                    _buildDetailRow(
                      context,
                      'رسوم تمديد ${booking.overstayDays} يوم',
                      '${booking.overstayFeeEgp.toCurrencyFormat()} ج.م',
                    ),
                  if (!isFullyPaid)
                    _buildDetailRow(
                      context,
                      'فلوس الحجز',
                      '${booking.totalPriceEgp.toCurrencyFormat()} ج.م',
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
                    valueColor: context.colors.ok,
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
              ref
                  .watch(bookingPaymentsProvider(booking.id))
                  .when(
                    data: (payments) {
                      return _buildSection(
                        context,
                        title: 'تفاصيل الدفعات',
                        icon: Icons.payments_outlined,
                        children: payments.isEmpty
                            ? [
                                Text(
                                  'لا توجد دفعات مسجلة',
                                  style: AppTextStyles.bodyS.copyWith(
                                    color: context.colors.ink2,
                                  ),
                                ),
                              ]
                            : payments.map((p) {
                                final methodLabel = p.paymentMethod == 'cash'
                                    ? 'نقدي'
                                    : p.paymentMethod == 'instapay'
                                    ? 'إنستاباي'
                                    : 'فودافون كاش';
                                final dateStr = DateFormat(
                                  'yyyy-MM-dd',
                                  'ar',
                                ).format(p.paymentDate);
                                final row = _buildDetailRow(
                                  context,
                                  '$methodLabel - $dateStr',
                                  '${p.amountEgp.toCurrencyFormat()} ج.م',
                                );
                                if (isViewer) return row;
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: row),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        size: 18,
                                      ),
                                      color: context.colors.err,
                                      visualDensity: VisualDensity.compact,
                                      tooltip: 'حذف الدفعة',
                                      onPressed: () => _confirmDeletePayment(
                                        context,
                                        ref,
                                        payment: p,
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, st) => const SizedBox.shrink(),
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
                          onTap: () => context.push(
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
                          onTap: () => context.push(
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

              if (booking.status != 'checked_out' && !isViewer) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          context.push(
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
                          context.push('/summer_bookings/overstay/$bookingId');
                        },
                        child: const Text('تمديد الحجز'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (remainingAmount > 0) {
                            _showUnpaidCheckoutDialog(
                              context,
                              ref,
                              bookingId: booking.id,
                              currentPaid: booking.amountPaidEgp,
                              remainingAmount: remainingAmount.toDouble(),
                              totalAmount: booking.totalPriceEgp,
                            );
                            return;
                          }
                          context.push(
                            Uri(
                              path: '/inspections/add',
                              queryParameters: {
                                'apartmentId': booking.apartmentId,
                                'checkoutBookingId': booking.id,
                              },
                            ).toString(),
                          );
                        },
                        child: const Text('تسجيل خروج'),
                      ),
                    ),
                  ],
                ),
              ] else if (booking.status == 'checked_out' && !isViewer) ...[
                ElevatedButton.icon(
                  onPressed: () {
                    context.push(
                      Uri(
                        path: '/inspections/add',
                        queryParameters: {'apartmentId': booking.apartmentId},
                      ).toString(),
                    );
                  },
                  icon: const Icon(Icons.fact_check),
                  label: const Text('فحص واستلام الشقة'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    foregroundColor: Theme.of(
                      context,
                    ).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ],
          );
        },
        loading: () => const LoadingSkeleton(),
        error: (err, stack) => ErrorState(
          title: 'تعذّر تحميل البيانات',
          message: '$err',
          retryLabel: 'إعادة المحاولة',
          onRetry: () => ref.invalidate(allSummerBookingsProvider),
        ),
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
    // 'none' => the broker took no commission at all.
    return 0;
  }

  Widget _buildImageCard(BuildContext context, String imagePath, String label) {
    final normalizedPath = imagePath.trim();
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => Dialog(
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  InteractiveViewer(child: _buildImagePreview(normalizedPath)),
                  IconButton(
                    icon: Icon(Icons.close, color: context.colors.err),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          );
        },
        child: Column(
          children: [
            _buildImageThumbnail(normalizedPath),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text(label, style: Theme.of(context).textTheme.bodySmall),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: BoxFit.contain,
        placeholder: (context, url) => const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) =>
            const _MissingImageBox(message: 'تعذر تحميل الصورة من السيرفر'),
      );
    }
    return Image.file(
      File(path),
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          const _MissingImageBox(message: 'الصورة غير موجودة على هذا الجهاز'),
    );
  }

  Widget _buildImageThumbnail(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: path,
        height: 100,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => const SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (context, url, error) =>
            const _MissingImageBox(height: 100, message: 'تعذر تحميل الصورة'),
      );
    }
    return Image.file(
      File(path),
      height: 100,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const _MissingImageBox(height: 100, message: 'الصورة على جهاز آخر'),
    );
  }

  void _showUnpaidCheckoutDialog(
    BuildContext context,
    WidgetRef ref, {
    required String bookingId,
    required double currentPaid,
    required double remainingAmount,
    required double totalAmount,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('لا يمكن التسليم قبل التسديد'),
        content: Text(
          'العميل عليه ${remainingAmount.toCurrencyFormat()} ج.م. الرجاء تسديد المبلغ قبل تسجيل الخروج.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _showPaymentSheet(
                context,
                ref,
                bookingId: bookingId,
                currentPaid: currentPaid,
                remainingAmount: remainingAmount,
                totalAmount: totalAmount,
              );
            },
            child: const Text('تسديد الآن'),
          ),
        ],
      ),
    );
  }

  void _showPaymentSheet(
    BuildContext context,
    WidgetRef ref, {
    required String bookingId,
    required double currentPaid,
    required double remainingAmount,
    required double totalAmount,
  }) {
    final controller = TextEditingController(
      text: remainingAmount.toStringAsFixed(0),
    );
    String selectedMethod = 'cash';
    // يمنع تسجيل نفس التسديد مرتين لو المستخدم داس "حفظ" بسرعة مرتين.
    bool isSubmitting = false;
    String? errorText;
    final messenger = ScaffoldMessenger.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'تسديد باقي الحجز',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text('المتبقي: ${remainingAmount.toCurrencyFormat()} ج.م'),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textDirection: TextDirection.ltr,
                inputFormatters: const [ArabicDigitsInputFormatter()],
                decoration: InputDecoration(
                  labelText: 'المبلغ اللي هيتسدد الآن',
                  errorText: errorText,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'طريقة الدفع',
                style: AppTextStyles.label.copyWith(color: context.colors.ink2),
              ),
              const SizedBox(height: 8),
              SegmentedTabs(
                labels: const ['نقدي', 'فودافون كاش', 'إنستاباي'],
                index: selectedMethod == 'vodafone_cash'
                    ? 1
                    : selectedMethod == 'instapay'
                    ? 2
                    : 0,
                onChanged: (i) => setState(() {
                  selectedMethod = const [
                    'cash',
                    'vodafone_cash',
                    'instapay',
                  ][i];
                }),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        controller.text = remainingAmount.toStringAsFixed(0);
                      },
                      child: const Text('تسديد الكل'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              final paidNow =
                                  double.tryParse(
                                    controller.text.replaceAll(',', '').trim(),
                                  ) ??
                                  0;
                              if (paidNow <= 0) {
                                setState(
                                  () => errorText = 'أدخل مبلغًا أكبر من صفر',
                                );
                                return;
                              }
                              if (paidNow > remainingAmount + 0.01) {
                                setState(
                                  () => errorText =
                                      'المبلغ أكبر من المتبقي (${remainingAmount.toCurrencyFormat()} ج.م)',
                                );
                                return;
                              }
                              setState(() {
                                errorText = null;
                                isSubmitting = true;
                              });
                              await ref
                                  .read(bookingsControllerProvider.notifier)
                                  .addBookingPayment(
                                    bookingId: bookingId,
                                    amount: paidNow,
                                    paymentMethod: selectedMethod,
                                  );
                              if (!sheetContext.mounted) return;
                              final result = ref.read(
                                bookingsControllerProvider,
                              );
                              if (result.hasError) {
                                setState(() {
                                  isSubmitting = false;
                                  errorText = result.error
                                      .toString()
                                      .replaceFirst('Exception: ', '');
                                });
                                return;
                              }
                              Navigator.pop(sheetContext);
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('تم تسجيل التسديد بنجاح'),
                                ),
                              );
                            },
                      child: isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('حفظ التسديد'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// تأكيد حذف دفعة مسجلة بالغلط (مثلاً تسديد اتسجل مرتين): بيشيل صف
  /// الدفعة وبيخصم قيمتها من إجمالي المدفوع في نفس العملية.
  void _confirmDeletePayment(
    BuildContext context,
    WidgetRef ref, {
    required BookingPayment payment,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف الدفعة'),
        content: Text(
          'سيتم حذف دفعة بقيمة ${payment.amountEgp.toCurrencyFormat()} ج.م '
          'وخصمها من إجمالي المدفوع للحجز. هل أنت متأكد؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref
                  .read(bookingsControllerProvider.notifier)
                  .deleteBookingPayment(paymentId: payment.id);
              final result = ref.read(bookingsControllerProvider);
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    result.hasError
                        ? 'تعذر حذف الدفعة: ${result.error.toString().replaceFirst('Exception: ', '')}'
                        : 'تم حذف الدفعة وتحديث إجمالي المدفوع',
                  ),
                ),
              );
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final colors = context.colors;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconTile(icon: icon, tint: colors.brand, size: 34, iconSize: 17),
              const SizedBox(width: 10),
              Text(title, style: AppTextStyles.h3.copyWith(color: colors.ink)),
            ],
          ),
          const Divider(height: 24),
          ...children,
        ],
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
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.bodyS.copyWith(color: colors.ink2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: AppTextStyles.tabular(
                (isHighlight ? AppTextStyles.title : AppTextStyles.body)
                    .copyWith(
                      color:
                          valueColor ??
                          (isHighlight ? colors.accent : colors.ink),
                    ),
              ),
              textAlign: TextAlign.end,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _MissingImageBox extends StatelessWidget {
  final double? height;
  final String message;

  const _MissingImageBox({this.height, required this.message});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off, color: context.colors.ink3),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
