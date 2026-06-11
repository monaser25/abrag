import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/config/app_settings_provider.dart';
import '../../../../core/utils/season_utils.dart';
import '../providers/expenses_controller.dart';
import '../../../buildings/presentation/providers/buildings_controller.dart';
import '../../../apartments/presentation/providers/apartments_controller.dart';

import '../../../../core/database/database.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/widgets.dart';
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
  String _selectedSeason = currentSeasonKey();
  bool _didApplyActiveSeason = false;

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
    _selectedSeason = widget.expense == null
        ? currentSeasonKey()
        : normalizeStoredSeason(
            widget.expense!.season,
            widget.expense!.expenseDate,
          );
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
              season: _selectedSeason,
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
              season: _selectedSeason,
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
    final settingsAsync = ref.watch(appSettingsProvider);
    final activeSeason = ref.watch(activeSeasonKeyProvider);

    if (widget.expense == null && !_didApplyActiveSeason && settingsAsync.hasValue) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _didApplyActiveSeason) return;
        setState(() {
          _selectedSeason = activeSeason;
          _didApplyActiveSeason = true;
        });
      });
    }

    ref.listen<AsyncValue<void>>(expensesControllerProvider, (_, state) {
      state.whenOrNull(
        data: (_) => context.pop(),
        error: (error, _) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString()))),
      );
    });

    return AppScaffold(
      appBar: AbragAppBar(title: l10n.addExpense),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const SectionTitle(title: 'الموقع'),
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
                return AppDropdownField<String>(
                  label: l10n.buildings,
                  prefixIcon: Icons.apartment,
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
              loading: () => const LinearProgressIndicator(),
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

                return AppDropdownField<String>(
                  label: l10n.apartments,
                  prefixIcon: Icons.door_front_door_outlined,
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
            const SectionTitle(title: 'تفاصيل المصروف'),
            AppDropdownField<String>(
              label: l10n.expenseType,
              prefixIcon: Icons.category_outlined,
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppDropdownField<String>(
                    label: 'طريقة دفع المصروف',
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
                      () =>
                          _selectedPaymentMethod = v ?? _selectedPaymentMethod,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppDropdownField<String>(
                    label: 'الموسم',
                    initialValue: _selectedSeason,
                    items: seasonOptionsAround(includeGeneric: false)
                        .map(
                          (option) => DropdownMenuItem(
                            value: option.key,
                            child: Text(option.label),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(
                      () => _selectedSeason = v ?? _selectedSeason,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(
                    label: l10n.amount,
                    prefixIcon: Icons.payments_outlined,
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [CurrencyInputFormatter()],
                    validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppDateField(
                    label: 'التاريخ',
                    value: _date?.toString().split(' ')[0],
                    placeholder: l10n.selectDate,
                    onTap: () => _selectDate(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: l10n.description,
              prefixIcon: Icons.notes_outlined,
              controller: _descriptionController,
              maxLines: 3,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        children: [
          Expanded(
            child: AppButton(
              label: 'حفظ',
              icon: Icons.check,
              loading: controllerState.isLoading,
              onPressed: controllerState.isLoading ? null : _submit,
            ),
          ),
        ],
      ),
    );
  }
}
