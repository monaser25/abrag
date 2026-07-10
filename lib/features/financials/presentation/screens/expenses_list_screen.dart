import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../apartments/presentation/providers/apartments_controller.dart';
import '../providers/expenses_provider.dart';
import '../providers/expenses_controller.dart';
import '../providers/financial_transfers_provider.dart';

import '../../../../core/utils/currency_formatter.dart';

class ExpensesListScreen extends ConsumerStatefulWidget {
  const ExpensesListScreen({super.key});

  @override
  ConsumerState<ExpensesListScreen> createState() => _ExpensesListScreenState();
}

class _ExpensesListScreenState extends ConsumerState<ExpensesListScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedType;
  String _selectedSort = 'date_desc';

  final List<String> _types = [
    'maintenance',
    'building_rent',
    'water',
    'electricity',
    'gas',
    'cleaning',
    'other',
  ];

  void _confirmDeleteExpense(String id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا المصروف؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () {
              ref.read(expensesControllerProvider.notifier).deleteExpense(id);
              Navigator.pop(dialogContext);
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
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

  String _translatePaymentMethod(String method) {
    return paymentAccounts[method] ?? method;
  }

  String _translateSeason(String season) {
    switch (season) {
      case 'summer':
        return 'الصيف';
      case 'winter':
        return 'الشتاء';
      default:
        return 'عام';
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _selectedType = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final expensesAsync = ref.watch(expensesProvider);
    final apartmentsAsync = ref.watch(apartmentsProvider);
    final apartmentNumberById = {
      for (final apartment in apartmentsAsync.value ?? [])
        apartment.id: apartment.apartmentNumber,
    };
    final colors = context.colors;

    final dateLabel = _startDate != null && _endDate != null
        ? '${_startDate!.toLocal().toString().split(' ')[0]} - ${_endDate!.toLocal().toString().split(' ')[0]}'
        : null;

    return AppScaffold(
      appBar: AbragAppBar(
        title: l10n.expenses,
        actions: [
          AppIconButton(
            icon: Icons.filter_alt_off,
            onPressed: _clearFilters,
            tooltip: 'مسح الفلاتر',
          ),
        ],
      ),
      floatingActionButton: AppFab(
        onPressed: () => context.go('/expenses/add'),
        icon: Icons.add,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppDropdownField<String?>(
                    label: 'نوع المصروف',
                    initialValue: _selectedType,
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('الكل'),
                      ),
                      ..._types.map(
                        (t) => DropdownMenuItem<String?>(
                          value: t,
                          child: Text(_translateExpenseType(t)),
                        ),
                      ),
                    ],
                    onChanged: (val) => setState(() => _selectedType = val),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppDateField(
                    label: 'التاريخ',
                    value: dateLabel,
                    placeholder: 'اختر الفترة',
                    icon: Icons.date_range,
                    onTap: () => _selectDateRange(context),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: expensesAsync.when(
              data: (expenses) {
                var filtered = expenses.toList();

                if (_selectedType != null) {
                  filtered = filtered
                      .where((e) => e.expenseType == _selectedType)
                      .toList();
                }

                if (_startDate != null && _endDate != null) {
                  filtered = filtered.where((e) {
                    final d = e.expenseDate.toLocal();
                    final start = DateTime(
                      _startDate!.year,
                      _startDate!.month,
                      _startDate!.day,
                    );
                    final end = DateTime(
                      _endDate!.year,
                      _endDate!.month,
                      _endDate!.day,
                      23,
                      59,
                      59,
                    );
                    return d.isAfter(
                          start.subtract(const Duration(seconds: 1)),
                        ) &&
                        d.isBefore(end.add(const Duration(seconds: 1)));
                  }).toList();
                }

                // Apply sorting
                if (_selectedSort == 'amount_desc') {
                  filtered.sort((a, b) => b.amountEgp.compareTo(a.amountEgp));
                } else if (_selectedSort == 'amount_asc') {
                  filtered.sort((a, b) => a.amountEgp.compareTo(b.amountEgp));
                } else if (_selectedSort == 'date_desc') {
                  filtered.sort(
                    (a, b) => b.expenseDate.compareTo(a.expenseDate),
                  );
                } else if (_selectedSort == 'date_asc') {
                  filtered.sort(
                    (a, b) => a.expenseDate.compareTo(b.expenseDate),
                  );
                }

                if (filtered.isEmpty) {
                  return EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: l10n.noData,
                  );
                }

                final totalAmount = filtered.fold<double>(
                  0,
                  (sum, e) => sum + e.amountEgp,
                );

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: AppCard(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'الإجمالي',
                                    style: AppTextStyles.title.copyWith(
                                      color: colors.ink2,
                                    ),
                                  ),
                                  Text(
                                    '${totalAmount.toCurrencyFormat()} ج.م',
                                    style: AppTextStyles.tabular(
                                      AppTextStyles.h3.copyWith(
                                        color: colors.ink,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 150,
                            child: AppDropdownField<String>(
                              initialValue: _selectedSort,
                              prefixIcon: Icons.sort,
                              items: const [
                                DropdownMenuItem(
                                  value: 'date_desc',
                                  child: Text('الأحدث أولاً'),
                                ),
                                DropdownMenuItem(
                                  value: 'date_asc',
                                  child: Text('الأقدم أولاً'),
                                ),
                                DropdownMenuItem(
                                  value: 'amount_desc',
                                  child: Text('الأعلى تكلفة'),
                                ),
                                DropdownMenuItem(
                                  value: 'amount_asc',
                                  child: Text('الأقل تكلفة'),
                                ),
                              ],
                              onChanged: (val) => setState(
                                () => _selectedSort = val ?? 'date_desc',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final expense = filtered[index];
                          final apartmentNumber = expense.apartmentId == null
                              ? null
                              : apartmentNumberById[expense.apartmentId];
                          return _ExpenseRow(
                            type: _translateExpenseType(expense.expenseType),
                            date: expense.expenseDate
                                .toLocal()
                                .toString()
                                .split(' ')[0],
                            description: expense.description,
                            paymentMethod: _translatePaymentMethod(
                              expense.paymentMethod,
                            ),
                            apartmentLabel:
                                apartmentNumber == null ||
                                    apartmentNumber.isEmpty
                                ? null
                                : 'شقة $apartmentNumber',
                            season: _translateSeason(expense.season),
                            amount:
                                '${expense.amountEgp.toCurrencyFormat()} ج.م',
                            onEdit: expense.expenseType != 'maintenance'
                                ? () {
                                    if (expense.expenseType ==
                                        'building_rent') {
                                      context.go(
                                        '/building_rent/edit',
                                        extra: expense,
                                      );
                                    } else {
                                      context.go(
                                        '/expenses/edit',
                                        extra: expense,
                                      );
                                    }
                                  }
                                : null,
                            onDelete: expense.expenseType != 'maintenance'
                                ? () => _confirmDeleteExpense(expense.id)
                                : null,
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
              loading: () => const LoadingSkeleton(),
              error: (error, stack) => ErrorState(
                title: 'تعذّر تحميل المصروفات',
                message: 'Error: $error',
                retryLabel: 'إعادة المحاولة',
                onRetry: () => ref.invalidate(expensesProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseRow extends StatelessWidget {
  const _ExpenseRow({
    required this.type,
    required this.date,
    required this.description,
    required this.paymentMethod,
    this.apartmentLabel,
    required this.season,
    required this.amount,
    this.onEdit,
    this.onDelete,
  });

  final String type;
  final String date;
  final String? description;
  final String paymentMethod;
  final String? apartmentLabel;
  final String season;
  final String amount;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconTile(icon: Icons.money_off, tint: colors.err),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: AppTextStyles.title.copyWith(color: colors.ink),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: AppTextStyles.caption.copyWith(color: colors.ink3),
                ),
                if (description != null && description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description!,
                    style: AppTextStyles.bodyS.copyWith(color: colors.ink2),
                  ),
                ],
                const SizedBox(height: 4),
                if (apartmentLabel != null) ...[
                  Row(
                    children: [
                      Icon(Icons.apartment, size: 14, color: colors.ink3),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          apartmentLabel!,
                          style: AppTextStyles.caption.copyWith(
                            color: colors.ink3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  'طريقة الدفع: $paymentMethod',
                  style: AppTextStyles.caption.copyWith(color: colors.brand),
                ),
                Text(
                  'الموسم: $season',
                  style: AppTextStyles.caption.copyWith(color: colors.ink3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: AppTextStyles.tabular(
                  AppTextStyles.title.copyWith(color: colors.err),
                ),
              ),
              if (onEdit != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: AppIconButton(
                    icon: Icons.edit_outlined,
                    onPressed: onEdit,
                  ),
                ),
              if (onDelete != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: AppIconButton(
                    icon: Icons.delete_outline,
                    onPressed: onDelete,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
