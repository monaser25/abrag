import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/apartment_profile_provider.dart';
import '../providers/apartments_controller.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/booking_rate_utils.dart';
import '../../../../shared/widgets/widgets.dart';

class ApartmentProfileScreen extends ConsumerStatefulWidget {
  final String apartmentId;

  const ApartmentProfileScreen({super.key, required this.apartmentId});

  @override
  ConsumerState<ApartmentProfileScreen> createState() =>
      _ApartmentProfileScreenState();
}

class _ApartmentProfileScreenState
    extends ConsumerState<ApartmentProfileScreen> {
  final _inventoryController = TextEditingController();
  final _landlineNumberController = TextEditingController();
  final _landlineOwnerController = TextEditingController();
  final _landlineNotesController = TextEditingController();
  bool _isEditingInventory = false;
  bool _isEditingLandline = false;

  @override
  void dispose() {
    _inventoryController.dispose();
    _landlineNumberController.dispose();
    _landlineOwnerController.dispose();
    _landlineNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(
      apartmentProfileProvider(widget.apartmentId),
    );
    final apartmentsControllerState = ref.watch(apartmentsControllerProvider);
    final theme = Theme.of(context);
    final formatter = DateFormat('EEEE yyyy-MM-dd', 'ar');

    return AppScaffold(
      appBar: AbragAppBar(
        title: 'ملف الشقة',
        actions: [
          profileAsync.maybeWhen(
            data: (data) => PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'edit') {
                  context.push('/apartments/edit', extra: data.apartment);
                } else if (value == 'delete') {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('حذف الشقة؟'),
                      content: const Text(
                        'سيتم الحذف فقط لو الشقة ليس عليها حجوزات أو عقود محفوظة.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('إلغاء'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('حذف'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    await ref
                        .read(apartmentsControllerProvider.notifier)
                        .deleteApartment(widget.apartmentId);
                    if (context.mounted) context.pop();
                  }
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('تعديل الشقة')),
                PopupMenuItem(value: 'delete', child: Text('حذف الشقة')),
              ],
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: profileAsync.when(
        data: (data) {
          final isCleaning = data.apartment.cleaningStatus == 'needs_cleaning';
          final isOccupied = data.isOccupied;
          final isCheckingOutToday = data.isCheckingOutToday;
          final colors = context.colors;

          // Same status semantics as before, token colors.
          Color statusColor = colors.ok;
          String statusText = 'متاحة';
          var statusKind = StatusChipKind.ok;
          if (isCleaning) {
            statusColor = colors.warn;
            statusText = 'تحتاج نظافة';
            statusKind = StatusChipKind.warn;
          } else if (data.hasOverdueCheckout) {
            statusColor = colors.warn;
            statusText = 'الخروج مش متسجل';
            statusKind = StatusChipKind.warn;
          } else if (isCheckingOutToday) {
            statusColor = colors.summer;
            statusText = 'هتخرج النهاردة';
            statusKind = StatusChipKind.summer;
          } else if (isOccupied) {
            statusColor = colors.err;
            statusText = 'مؤجرة';
            statusKind = StatusChipKind.err;
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      // Prototype status header: surface tinted by the
                      // apartment's status color.
                      color: Color.alphaBlend(
                        statusColor.withValues(alpha: 0.14),
                        colors.surface,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: colors.border),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: statusColor.withValues(alpha: 0.18),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            data.apartment.apartmentNumber,
                            style: AppTextStyles.tabular(
                              AppTextStyles.display.copyWith(
                                color: statusColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        StatusChip(kind: statusKind, label: statusText),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () {
                            ref
                                .read(apartmentsControllerProvider.notifier)
                                .updateCleaningStatus(
                                  widget.apartmentId,
                                  isCleaning ? 'clean' : 'needs_cleaning',
                                );
                          },
                          icon: Icon(
                            isCleaning
                                ? Icons.cleaning_services
                                : Icons.warning_amber,
                          ),
                          label: Text(
                            isCleaning
                                ? 'تأكيد إتمام النظافة'
                                : 'تغيير الحالة إلى: تحتاج نظافة',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isCleaning
                                ? colors.ok
                                : colors.warn,
                            side: BorderSide(
                              color: isCleaning ? colors.ok : colors.warn,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () => context.push(
                            '/summer_bookings/add?apartmentId=${Uri.encodeComponent(widget.apartmentId)}',
                          ),
                          icon: const Icon(Icons.beach_access_outlined),
                          label: const Text('احجز هذه الشقة'),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildMiniStat(
                              theme,
                              'المبنى',
                              data.building?.name ?? 'غير محدد',
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: theme.colorScheme.outlineVariant
                                  .withValues(alpha: 0.3),
                            ),
                            _buildMiniStat(
                              theme,
                              'الطابق',
                              data.apartment.floorNumber?.toString() ?? '-',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _showRevenuesDialog(
                            context,
                            data.bookings,
                            data.totalRevenue,
                          ),
                          child: _buildStatCard(
                            theme,
                            'الإيرادات',
                            '${data.totalRevenue.toCurrencyFormat()} ج.م',
                            Icons.account_balance_wallet,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () =>
                              _showExpensesDialog(context, data.expenses),
                          child: _buildStatCard(
                            theme,
                            'المصروفات',
                            '${data.totalExpenses.toCurrencyFormat()} ج.م',
                            Icons.money_off,
                            isError: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
                SliverToBoxAdapter(
                  child: _buildStatCard(
                    theme,
                    'صافي الربح',
                    '${(data.totalRevenue - data.totalExpenses).toCurrencyFormat()} ج.م',
                    Icons.assessment,
                    isPrimary: true,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                SliverToBoxAdapter(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'محتويات الشقة',
                                style: theme.textTheme.titleMedium,
                              ),
                              IconButton(
                                icon: Icon(
                                  _isEditingInventory
                                      ? Icons.check
                                      : Icons.edit,
                                ),
                                color: theme.colorScheme.primary,
                                onPressed: apartmentsControllerState.isLoading
                                    ? null
                                    : () {
                                        if (_isEditingInventory) {
                                          ref
                                              .read(
                                                apartmentsControllerProvider
                                                    .notifier,
                                              )
                                              .updateInventory(
                                                widget.apartmentId,
                                                _inventoryController.text
                                                    .trim(),
                                              );
                                        } else {
                                          _inventoryController.text =
                                              data.apartment.inventory ?? '';
                                        }
                                        setState(() {
                                          _isEditingInventory =
                                              !_isEditingInventory;
                                        });
                                      },
                              ),
                            ],
                          ),
                          if (_isEditingInventory)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'اكتب كل عنصر في سطر. لإنشاء مجموعة (مثل الأجهزة الكهربائية)، اكتب اسم المجموعة في سطر وضع آخره نقطتين (:)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: context.colors.ink3,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _inventoryController,
                                  decoration: const InputDecoration(
                                    hintText:
                                        'الأجهزة الكهربائية:\nثلاجة\nغسالة\n\nالأثاث:\nسرير كبير\nدولاب',
                                    border: OutlineInputBorder(),
                                  ),
                                  maxLines: 8,
                                ),
                              ],
                            )
                          else ...[
                            if (data.apartment.inventory == null ||
                                data.apartment.inventory!.trim().isEmpty)
                              const Text('لم يتم تسجيل محتويات')
                            else
                              ...(data.apartment.inventory!
                                      .split('\n')
                                      .map((s) => s.trim())
                                      .where((s) => s.isNotEmpty))
                                  .map((item) {
                                    if (item.endsWith(':')) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          top: 12.0,
                                          bottom: 4.0,
                                        ),
                                        child: Text(
                                          item,
                                          style: TextStyle(
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    }
                                    return ListTile(
                                      dense: true,
                                      contentPadding: EdgeInsets.zero,
                                      leading: Icon(
                                        Icons.inventory,
                                        color: theme.colorScheme.primary,
                                        size: 20,
                                      ),
                                      title: Text(item),
                                    );
                                  }),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                SliverToBoxAdapter(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'الخط الأرضي',
                                style: theme.textTheme.titleMedium,
                              ),
                              IconButton(
                                icon: Icon(
                                  _isEditingLandline ? Icons.check : Icons.edit,
                                ),
                                color: theme.colorScheme.primary,
                                onPressed: apartmentsControllerState.isLoading
                                    ? null
                                    : () {
                                        if (_isEditingLandline) {
                                          ref
                                              .read(
                                                apartmentsControllerProvider
                                                    .notifier,
                                              )
                                              .updateLandline(
                                                id: widget.apartmentId,
                                                landlineNumber:
                                                    _landlineNumberController
                                                        .text,
                                                ownerName:
                                                    _landlineOwnerController
                                                        .text,
                                                notes: _landlineNotesController
                                                    .text,
                                              );
                                        } else {
                                          _landlineNumberController.text =
                                              data.apartment.landlineNumber ??
                                              '';
                                          _landlineOwnerController.text =
                                              data
                                                  .apartment
                                                  .landlineOwnerName ??
                                              '';
                                          _landlineNotesController.text =
                                              data.apartment.landlineNotes ??
                                              '';
                                        }
                                        setState(() {
                                          _isEditingLandline =
                                              !_isEditingLandline;
                                        });
                                      },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (_isEditingLandline) ...[
                            TextField(
                              controller: _landlineNumberController,
                              decoration: const InputDecoration(
                                labelText: 'رقم الخط الأرضي',
                                prefixIcon: Icon(Icons.phone),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _landlineOwnerController,
                              decoration: const InputDecoration(
                                labelText: 'اسم صاحب الخط',
                                prefixIcon: Icon(Icons.person),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _landlineNotesController,
                              decoration: const InputDecoration(
                                labelText: 'ملاحظات',
                                prefixIcon: Icon(Icons.notes),
                              ),
                              maxLines: 2,
                            ),
                          ] else if ((data.apartment.landlineNumber ?? '')
                                  .trim()
                                  .isEmpty &&
                              (data.apartment.landlineOwnerName ?? '')
                                  .trim()
                                  .isEmpty) ...[
                            Text(
                              'لا يوجد خط أرضي مسجل للشقة',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ] else ...[
                            _InfoLine(
                              icon: Icons.phone,
                              label: 'رقم الخط',
                              value: data.apartment.landlineNumber ?? '-',
                            ),
                            const SizedBox(height: 6),
                            _InfoLine(
                              icon: Icons.person,
                              label: 'صاحب الخط',
                              value: data.apartment.landlineOwnerName ?? '-',
                            ),
                            if ((data.apartment.landlineNotes ?? '')
                                .trim()
                                .isNotEmpty) ...[
                              const SizedBox(height: 6),
                              _InfoLine(
                                icon: Icons.notes,
                                label: 'ملاحظات',
                                value: data.apartment.landlineNotes!,
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                SliverToBoxAdapter(
                  child: Text(
                    'سجل الحجوزات',
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                if (data.bookings.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          'لا يوجد سجل حجوزات',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final booking = data.bookings[index];
                      final now = DateTime.now();
                      final days = summerBookingStayDays(booking);
                      final effectiveCheckout =
                          booking.earlyCheckoutDate ?? booking.checkOutDate;
                      final isCurrentResident =
                          booking.status != 'checked_out' &&
                          booking.status != 'cancelled' &&
                          !now.isBefore(booking.checkInDate) &&
                          now.isBefore(effectiveCheckout);
                      final remainingAmount =
                          ((booking.totalPriceEgp - booking.overstayFeeEgp) -
                                  booking.amountPaidEgp)
                              .clamp(0, double.infinity);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () => context.push(
                            '/summer_bookings/details/${booking.id}',
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
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
                                        style: theme.textTheme.titleMedium,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Wrap(
                                      spacing: 6,
                                      children: [
                                        _SmallBadge(
                                          label: _statusLabel(booking.status),
                                          color: colors.brand,
                                        ),
                                        _SmallBadge(
                                          label: isCurrentResident
                                              ? 'ساكن'
                                              : 'غير ساكن',
                                          color: isCurrentResident
                                              ? colors.ok
                                              : colors.ink3,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _InfoLine(
                                  icon: Icons.login,
                                  label: 'الدخول',
                                  value: formatter.format(booking.checkInDate),
                                ),
                                const SizedBox(height: 6),
                                _InfoLine(
                                  icon: Icons.logout,
                                  label: 'الخروج',
                                  value: formatter.format(
                                    booking.earlyCheckoutDate ??
                                        booking.checkOutDate,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                _InfoLine(
                                  icon: Icons.nights_stay,
                                  label: 'عدد الأيام',
                                  value: '$days يوم',
                                ),
                                const SizedBox(height: 6),
                                _InfoLine(
                                  icon: Icons.price_change,
                                  label: 'السعر اليومي',
                                  value:
                                      '${summerBookingDailyRate(booking).toDouble().toCurrencyFormat()} ج.م',
                                ),
                                if (booking.brokerName != null &&
                                    booking.brokerName!.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  _InfoLine(
                                    icon: Icons.handshake,
                                    label: 'السمسار',
                                    value: booking.brokerName!,
                                  ),
                                ],
                                const Divider(),
                                _InfoLine(
                                  icon: Icons.payments,
                                  label: 'المدفوع',
                                  value:
                                      '${booking.amountPaidEgp.toDouble().toCurrencyFormat()} ج.م',
                                  valueColor: colors.ok,
                                ),
                                if (remainingAmount > 0) ...[
                                  const SizedBox(height: 6),
                                  _InfoLine(
                                    icon: Icons.warning_amber,
                                    label: 'عليه باقي',
                                    value:
                                        '${remainingAmount.toDouble().toCurrencyFormat()} ج.م',
                                    valueColor: colors.err,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    }, childCount: data.bookings.length),
                  ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
              ],
            ),
          );
        },
        loading: () => const LoadingSkeleton(),
        error: (err, stack) => ErrorState(
          title: 'تعذّر تحميل البيانات',
          message: '$err',
          retryLabel: 'إعادة المحاولة',
          onRetry: () =>
              ref.invalidate(apartmentProfileProvider(widget.apartmentId)),
        ),
      ),
      floatingActionButton: AppFab(
        icon: Icons.money_off,
        label: 'إضافة مصروف',
        onPressed: () {
          // Navigate to add expense
          // Note: In a real app we might pass the apartmentId as a query param.
          context.go('/expenses/add');
        },
      ),
    );
  }

  void _showRevenuesDialog(
    BuildContext context,
    List<dynamic> bookings,
    double totalRevenue,
  ) {
    final formatter = DateFormat('EEEE yyyy-MM-dd', 'ar');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (_, controller) {
            return Column(
              children: [
                AppBar(
                  title: Text(
                    'إجمالي الإيرادات: ${totalRevenue.toCurrencyFormat()} ج.م',
                  ),
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                Expanded(
                  child: bookings.isEmpty
                      ? const Center(child: Text('لا توجد حجوزات'))
                      : ListView.builder(
                          controller: controller,
                          padding: const EdgeInsets.all(16),
                          itemCount: bookings.length,
                          itemBuilder: (context, index) {
                            final booking = bookings[index];
                            final isBooking =
                                booking.runtimeType.toString() ==
                                'SummerBooking';
                            final name = isBooking
                                ? booking.guestName
                                : booking.studentName;
                            final price =
                                (isBooking
                                        ? booking.totalPriceEgp
                                        : booking.monthlyRentEgp)
                                    as double;
                            final start = isBooking
                                ? booking.checkInDate
                                : booking.startDate;

                            return ListTile(
                              leading: Icon(
                                isBooking ? Icons.wb_sunny : Icons.ac_unit,
                                color: isBooking
                                    ? context.colors.summer
                                    : context.colors.winter,
                              ),
                              title: Text(name),
                              subtitle: Text(formatter.format(start)),
                              trailing: Text(
                                '${price.toCurrencyFormat()} ج.م',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: context.colors.ok,
                                ),
                              ),
                              onTap: () {
                                Navigator.pop(ctx);
                                if (isBooking) {
                                  context.push(
                                    '/summer_bookings/details/${booking.id}',
                                  );
                                } else {
                                  context.push(
                                    '/winter_contracts/details/${booking.id}',
                                  );
                                }
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showExpensesDialog(BuildContext context, List<dynamic> expenses) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (_, controller) {
            return Column(
              children: [
                AppBar(
                  title: const Text('تفاصيل المصروفات'),
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                Expanded(
                  child: expenses.isEmpty
                      ? const Center(child: Text('لا يوجد مصروفات'))
                      : ListView.builder(
                          controller: controller,
                          padding: const EdgeInsets.all(16),
                          itemCount: expenses.length,
                          itemBuilder: (context, index) {
                            final expense = expenses[index];
                            return ListTile(
                              leading: Icon(
                                Icons.money_off,
                                color: context.colors.err,
                              ),
                              title: Text(
                                _translateExpenseType(expense.expenseType),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    expense.expenseDate
                                        .toLocal()
                                        .toString()
                                        .split(' ')[0],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.colors.ink3,
                                    ),
                                  ),
                                  Text(expense.description ?? 'بدون تفاصيل'),
                                ],
                              ),
                              trailing: Text(
                                '${(expense.amountEgp as double).toCurrencyFormat()} ج.م',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMiniStat(ThemeData theme, String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.titleMedium),
      ],
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String title,
    String value,
    IconData icon, {
    bool isPrimary = false,
    bool isError = false,
  }) {
    return Builder(
      builder: (context) {
        final colors = context.colors;
        Color color = colors.ink2;
        if (isPrimary) color = colors.accent;
        if (isError) color = colors.err;

        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.caption.copyWith(color: colors.ink3),
                  ),
                  Icon(icon, size: 20, color: color),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: AppTextStyles.tabular(
                  AppTextStyles.h2.copyWith(color: color),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'confirmed':
        return 'مؤكد';
      case 'checked_out':
        return 'تم الخروج';
      case 'cancelled':
        return 'ملغي';
      case 'pending':
        return 'قيد الانتظار';
      default:
        return status;
    }
  }

  String _translateExpenseType(String type) {
    switch (type) {
      case 'maintenance':
        return 'صيانة / إصلاحات';
      case 'building_rent':
        return 'إيجار المبنى';
      case 'water':
        return 'مياه';
      case 'electricity':
        return 'كهرباء';
      case 'gas':
        return 'غاز (أنبوبة)';
      case 'cleaning':
        return 'نظافة';
      default:
        return 'أخرى';
    }
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: colors.ink3),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.bodyS.copyWith(color: colors.ink2)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppTextStyles.tabular(
              AppTextStyles.bodyS.copyWith(
                color: valueColor ?? colors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SmallBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _SmallBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}
