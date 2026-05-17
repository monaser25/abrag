import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/expenses_controller.dart';
import '../../../buildings/presentation/providers/buildings_controller.dart';
import '../../../apartments/presentation/providers/apartments_controller.dart';

import '../../../../core/database/database.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../providers/financial_transfers_provider.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final Expense? expense;
  const AddExpenseScreen({super.key, this.expense});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;

  DateTime? _date;
  String? _selectedBuildingId;
  String? _selectedApartmentId;
  String _selectedExpenseType = 'cleaning';
  String _selectedPaymentMethod = 'cash';

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.expense?.amountEgp.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.expense?.description ?? '');
    _date = widget.expense?.expenseDate ?? DateTime.now();
    _selectedBuildingId = widget.expense?.buildingId;
    _selectedApartmentId = widget.expense?.apartmentId;
    _selectedExpenseType = widget.expense?.expenseType ?? 'cleaning';
    _selectedPaymentMethod = widget.expense?.paymentMethod ?? 'cash';
  }

  final List<Map<String, String>> _expenseTypes = [
    {'value': 'maintenance', 'label': 'صيانة / إصلاحات'},
    {'value': 'building_rent', 'label': 'إيجار المبنى'},
    {'value': 'water', 'label': 'مياه'},
    {'value': 'electricity', 'label': 'كهرباء'},
    {'value': 'gas', 'label': 'غاز (أنبوبة)'},
    {'value': 'cleaning', 'label': 'نظافة'},
    {'value': 'other', 'label': 'أخرى'},
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _date != null) {
      if (widget.expense == null) {
        ref.read(expensesControllerProvider.notifier).addExpense(
              buildingId: _selectedBuildingId,
              apartmentId: _selectedApartmentId,
              expenseType: _selectedExpenseType,
              amount: double.tryParse(_amountController.text.replaceAll(',', '').trim()) ?? 0,
              paymentMethod: _selectedPaymentMethod,
              date: _date!,
              description: _descriptionController.text.trim(),
            );
      } else {
        ref.read(expensesControllerProvider.notifier).updateExpense(
              id: widget.expense!.id,
              buildingId: _selectedBuildingId,
              apartmentId: _selectedApartmentId,
              expenseType: _selectedExpenseType,
              amount: double.tryParse(_amountController.text.replaceAll(',', '').trim()) ?? 0,
              paymentMethod: _selectedPaymentMethod,
              date: _date!,
              description: _descriptionController.text.trim(),
            );
      }
    } else if (_date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.selectDate)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controllerState = ref.watch(expensesControllerProvider);
    final buildingsAsync = ref.watch(buildingsProvider);
    final apartmentsAsync = ref.watch(apartmentsProvider);

    ref.listen<AsyncValue<void>>(expensesControllerProvider, (_, state) {
      state.whenOrNull(
        data: (_) => context.pop(),
        error: (error, _) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString()))),
      );
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addExpense)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            buildingsAsync.when(
              data: (buildings) {
                if (buildings.isNotEmpty && _selectedBuildingId == null) {
                  // Set default building
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      _selectedBuildingId = buildings.first.id;
                    });
                  });
                }
                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: l10n.buildings),
                  initialValue: _selectedBuildingId,
                  items: buildings
                      .map(
                        (b) =>
                            DropdownMenuItem(value: b.id, child: Text(b.name)),
                      )
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      _selectedBuildingId = v;
                      _selectedApartmentId =
                          null; // Reset apartment when building changes
                    });
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, st) => Text('Error: $e'),
            ),
            const SizedBox(height: 16),
            apartmentsAsync.when(
              data: (apartments) {
                final filteredApts = _selectedBuildingId != null
                    ? apartments
                          .where((a) => a.buildingId == _selectedBuildingId)
                          .toList()
                    : apartments;

                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: l10n.apartments),
                  initialValue: _selectedApartmentId,
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('مصروف عام (بدون شقة)'),
                    ),
                    ...filteredApts.map(
                      (a) => DropdownMenuItem(
                        value: a.id,
                        child: Text('شقة ${a.apartmentNumber}'),
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => _selectedApartmentId = v),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (e, st) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: l10n.expenseType),
              initialValue: _selectedExpenseType,
              items: _expenseTypes
                  .map(
                    (type) => DropdownMenuItem(
                      value: type['value'],
                      child: Text(type['label']!),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedExpenseType = v!),
              validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'طريقة دفع المصروف'),
              initialValue: _selectedPaymentMethod,
              items: paymentAccounts.entries
                  .map(
                    (entry) => DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(
                () => _selectedPaymentMethod = v ?? _selectedPaymentMethod,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(labelText: l10n.amount),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [CurrencyInputFormatter()],
              validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(_date?.toString().split(' ')[0] ?? l10n.selectDate),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: l10n.description),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: controllerState.isLoading ? null : _submit,
              child: controllerState.isLoading
                  ? const CircularProgressIndicator()
                  : const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }
}
