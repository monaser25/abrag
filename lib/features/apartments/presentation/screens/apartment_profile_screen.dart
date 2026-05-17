import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/apartment_profile_provider.dart';
import '../providers/apartments_controller.dart';
import '../../../../core/utils/currency_formatter.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('ملف الشقة'),
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

          Color statusColor = Colors.green;
          String statusText = 'متاحة';
          if (isCleaning) {
            statusColor = Colors.orange;
            statusText = 'تحتاج نظافة';
          } else if (isOccupied) {
            statusColor = theme.colorScheme.error;
            statusText = 'مؤجرة';
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.3,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.primaryContainer,
                              width: 3,
                            ),
                            color: theme.colorScheme.surface,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            data.apartment.apartmentNumber,
                            style: theme.textTheme.headlineLarge?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.3),
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: statusColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                statusText,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
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
                                ? Colors.green
                                : Colors.orange,
                            side: BorderSide(
                              color: isCleaning ? Colors.green : Colors.orange,
                            ),
                          ),
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
                                const Text(
                                  'اكتب كل عنصر في سطر. لإنشاء مجموعة (مثل الأجهزة الكهربائية)، اكتب اسم المجموعة في سطر وضع آخره نقطتين (:)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
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
                      final days = _calendarDays(
                        booking.checkInDate,
                        booking.earlyCheckoutDate ?? booking.checkOutDate,
                      );
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
                                    Text(
                                      booking.guestName,
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    Wrap(
                                      spacing: 6,
                                      children: [
                                        _SmallBadge(
                                          label: _statusLabel(booking.status),
                                          color: theme.colorScheme.primary,
                                        ),
                                        _SmallBadge(
                                          label: isCurrentResident
                                              ? 'ساكن'
                                              : 'غير ساكن',
                                          color: isCurrentResident
                                              ? Colors.green
                                              : Colors.grey,
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
                                      '${((booking.totalPriceEgp - booking.overstayFeeEgp) / days).toDouble().toCurrencyFormat()} ج.م',
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
                                  valueColor: Colors.green,
                                ),
                                if (remainingAmount > 0) ...[
                                  const SizedBox(height: 6),
                                  _InfoLine(
                                    icon: Icons.warning_amber,
                                    label: 'عليه باقي',
                                    value:
                                        '${remainingAmount.toDouble().toCurrencyFormat()} ج.م',
                                    valueColor: theme.colorScheme.error,
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to add expense
          // Note: In a real app we might pass the apartmentId as a query param.
          context.go('/expenses/add');
        },
        icon: const Icon(Icons.money_off),
        label: const Text('إضافة مصروف'),
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
                                color: isBooking ? Colors.orange : Colors.blue,
                              ),
                              title: Text(name),
                              subtitle: Text(formatter.format(start)),
                              trailing: Text(
                                '${price.toCurrencyFormat()} ج.م',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
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
                              leading: const Icon(
                                Icons.money_off,
                                color: Colors.red,
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
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
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
    Color color = theme.colorScheme.onSurfaceVariant;
    if (isPrimary) color = theme.colorScheme.primary;
    if (isError) color = theme.colorScheme.error;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Icon(icon, size: 20, color: color),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calendarDays(DateTime start, DateTime end) {
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);
    return endDate.difference(startDate).inDays.clamp(1, 10000);
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(color: valueColor, fontWeight: FontWeight.w600),
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
