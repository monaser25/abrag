import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/expenses_controller.dart';
import '../../../buildings/presentation/providers/buildings_controller.dart';

import '../../../../core/database/database.dart';
import '../../../../core/utils/currency_formatter.dart';

class AddBuildingRentScreen extends ConsumerStatefulWidget {
  final Expense? expense;
  const AddBuildingRentScreen({super.key, this.expense});

  @override
  ConsumerState<AddBuildingRentScreen> createState() => _AddBuildingRentScreenState();
}

class _AddBuildingRentScreenState extends ConsumerState<AddBuildingRentScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _discountController;
  late final TextEditingController _discountReasonController;
  
  DateTime? _date;
  String? _selectedBuildingId;
  int _installmentNumber = 1;
  bool _hasDiscount = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.expense?.amountEgp.toString() ?? '');
    _discountController = TextEditingController(text: widget.expense?.discountEgp.toString() ?? '0');
    _discountReasonController = TextEditingController(text: widget.expense?.discountReason ?? '');
    _date = widget.expense?.expenseDate ?? DateTime.now();
    _selectedBuildingId = widget.expense?.buildingId;
    _installmentNumber = widget.expense?.installmentNumber ?? 1;
    _hasDiscount = (widget.expense?.discountEgp ?? 0) > 0;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _discountController.dispose();
    _discountReasonController.dispose();
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
          expenseType: 'building_rent',
          amount: double.tryParse(_amountController.text.replaceAll(',', '').trim()) ?? 0,
          date: _date!,
          description: 'القسط $_installmentNumber لإيجار المبنى',
          installmentNumber: _installmentNumber,
          discountEgp: _hasDiscount ? (double.tryParse(_discountController.text.replaceAll(',', '').trim()) ?? 0) : 0,
          discountReason: _hasDiscount ? _discountReasonController.text.trim() : null,
        );
      } else {
        ref.read(expensesControllerProvider.notifier).updateExpense(
          id: widget.expense!.id,
          buildingId: _selectedBuildingId,
          expenseType: 'building_rent',
          amount: double.tryParse(_amountController.text.replaceAll(',', '').trim()) ?? 0,
          date: _date!,
          description: 'القسط $_installmentNumber لإيجار المبنى',
          installmentNumber: _installmentNumber,
          discountEgp: _hasDiscount ? (double.tryParse(_discountController.text.replaceAll(',', '').trim()) ?? 0) : 0,
          discountReason: _hasDiscount ? _discountReasonController.text.trim() : null,
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

    ref.listen<AsyncValue<void>>(
      expensesControllerProvider,
      (_, state) {
        state.whenOrNull(
          data: (_) => context.pop(),
          error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString())),
          ),
        );
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل قسط إيجار')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            buildingsAsync.when(
              data: (buildings) {
                if (buildings.isNotEmpty && _selectedBuildingId == null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      _selectedBuildingId = buildings.first.id;
                    });
                  });
                }
                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: l10n.buildings),
                  initialValue: _selectedBuildingId,
                  items: buildings.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
                  onChanged: (v) {
                    setState(() {
                      _selectedBuildingId = v;
                    });
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, st) => Text('Error: $e'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'رقم القسط'),
              initialValue: _installmentNumber,
              items: const [
                DropdownMenuItem(value: 1, child: Text('القسط الأول')),
                DropdownMenuItem(value: 2, child: Text('القسط الثاني')),
                DropdownMenuItem(value: 3, child: Text('القسط الثالث')),
                DropdownMenuItem(value: 4, child: Text('القسط الرابع')),
              ],
              onChanged: (v) => setState(() => _installmentNumber = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(labelText: l10n.amount),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [CurrencyInputFormatter()],
              validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
              onChanged: (_) => setState((){}),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('هل يوجد خصم من المالك؟'),
              subtitle: const Text('مثل شراء غرض للعمارة'),
              value: _hasDiscount,
              onChanged: (val) => setState(() => _hasDiscount = val),
            ),
            if (_hasDiscount) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _discountController,
                decoration: const InputDecoration(labelText: 'قيمة الخصم (ج.م)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [CurrencyInputFormatter()],
                validator: (v) => _hasDiscount && (v == null || v.isEmpty) ? 'مطلوب' : null,
                onChanged: (_) => setState((){}),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _discountReasonController,
                decoration: const InputDecoration(labelText: 'سبب الخصم'),
                validator: (v) => _hasDiscount && (v == null || v.isEmpty) ? 'مطلوب' : null,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('الصافي المدفوع', style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      '${((double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0) - (double.tryParse(_discountController.text.replaceAll(',', '')) ?? 0)).toCurrencyFormat()} ج.م',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: controllerState.isLoading ? null : _submit,
              child: controllerState.isLoading
                  ? const CircularProgressIndicator()
                  : const Text('حفظ القسط'),
            ),
          ],
        ),
      ),
    );
  }
}
