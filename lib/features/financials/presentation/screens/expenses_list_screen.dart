import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/expenses_provider.dart';
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

  String _translateExpenseType(String type) {
    switch (type) {
      case 'maintenance': return 'صيانة / إصلاحات';
      case 'building_rent': return 'إيجار المبنى';
      case 'water': return 'مياه';
      case 'electricity': return 'كهرباء';
      case 'gas': return 'غاز (أنبوبة)';
      case 'cleaning': return 'نظافة';
      default: return 'أخرى';
    }
  }

  String _translatePaymentMethod(String method) {
    return paymentAccounts[method] ?? method;
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.expenses),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_off),
            onPressed: _clearFilters,
            tooltip: 'مسح الفلاتر',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'نوع المصروف',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    initialValue: _selectedType,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('الكل')),
                      ..._types.map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(_translateExpenseType(t)),
                          )),
                    ],
                    onChanged: (val) => setState(() => _selectedType = val),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDateRange(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'التاريخ',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: Text(
                        _startDate != null && _endDate != null
                            ? '${_startDate!.toLocal().toString().split(' ')[0]} - ${_endDate!.toLocal().toString().split(' ')[0]}'
                            : 'اختر الفترة',
                        style: theme.textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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
                  filtered = filtered.where((e) => e.expenseType == _selectedType).toList();
                }
                
                if (_startDate != null && _endDate != null) {
                  filtered = filtered.where((e) {
                    final d = e.expenseDate.toLocal();
                    final start = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
                    final end = DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
                    return d.isAfter(start.subtract(const Duration(seconds: 1))) && 
                           d.isBefore(end.add(const Duration(seconds: 1)));
                  }).toList();
                }

                // Apply sorting
                if (_selectedSort == 'amount_desc') {
                  filtered.sort((a, b) => b.amountEgp.compareTo(a.amountEgp));
                } else if (_selectedSort == 'amount_asc') {
                  filtered.sort((a, b) => a.amountEgp.compareTo(b.amountEgp));
                } else if (_selectedSort == 'date_desc') {
                  filtered.sort((a, b) => b.expenseDate.compareTo(a.expenseDate));
                } else if (_selectedSort == 'date_asc') {
                  filtered.sort((a, b) => a.expenseDate.compareTo(b.expenseDate));
                }

                if (filtered.isEmpty) {
                  return Center(child: Text(l10n.noData));
                }

                final totalAmount = filtered.fold<double>(0, (sum, e) => sum + e.amountEgp);

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('الإجمالي:', style: theme.textTheme.titleMedium),
                          Text(
                            '${totalAmount.toCurrencyFormat()} ج.م',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'ترتيب حسب',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    initialValue: _selectedSort,
                    items: const [
                      DropdownMenuItem(value: 'date_desc', child: Text('الأحدث أولاً')),
                      DropdownMenuItem(value: 'date_asc', child: Text('الأقدم أولاً')),
                      DropdownMenuItem(value: 'amount_desc', child: Text('الأعلى تكلفة')),
                      DropdownMenuItem(value: 'amount_asc', child: Text('الأقل تكلفة')),
                    ],
                    onChanged: (val) => setState(() => _selectedSort = val ?? 'date_desc'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final expense = filtered[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: theme.colorScheme.error.withValues(alpha: 0.1),
                                child: Icon(Icons.money_off, color: theme.colorScheme.error),
                              ),
                              title: Text(
                                _translateExpenseType(expense.expenseType),
                                style: theme.textTheme.titleMedium,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    expense.expenseDate.toLocal().toString().split(' ')[0],
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  if (expense.description != null && expense.description!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        expense.description!,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      'طريقة الدفع: ${_translatePaymentMethod(expense.paymentMethod)}',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${expense.amountEgp.toCurrencyFormat()} ج.م',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: theme.colorScheme.error,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (expense.expenseType != 'maintenance')
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20),
                                      onPressed: () {
                                        if (expense.expenseType == 'building_rent') {
                                          context.go('/building_rent/edit', extra: expense);
                                        } else {
                                          context.go('/expenses/edit', extra: expense);
                                        }
                                      },
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
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
          context.go('/expenses/add');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
