import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/meter_readings_controller.dart';
import '../../../buildings/presentation/providers/buildings_controller.dart';
import '../../../apartments/presentation/providers/apartments_controller.dart';

class AddMeterReadingScreen extends ConsumerStatefulWidget {
  const AddMeterReadingScreen({super.key});

  @override
  ConsumerState<AddMeterReadingScreen> createState() =>
      _AddMeterReadingScreenState();
}

class _AddMeterReadingScreenState extends ConsumerState<AddMeterReadingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _previousReadingController = TextEditingController();
  final _currentReadingController = TextEditingController();
  final _amountController = TextEditingController();

  DateTime? _date;
  String? _selectedBuildingId;
  String? _selectedApartmentId;
  bool _isSharedExpense = false;

  @override
  void dispose() {
    _previousReadingController.dispose();
    _currentReadingController.dispose();
    _amountController.dispose();
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
      final previousReading =
          double.tryParse(_previousReadingController.text.trim()) ?? 0;
      final currentReading =
          double.tryParse(_currentReadingController.text.trim()) ?? 0;
      ref
          .read(meterReadingsControllerProvider.notifier)
          .addReading(
            buildingId: _selectedBuildingId,
            apartmentId: _selectedApartmentId,
            date: _date!,
            previousReading: previousReading,
            currentReading: currentReading,
            amount: double.tryParse(_amountController.text.trim()) ?? 0,
            isSharedExpense: _isSharedExpense,
          );
    } else if (_date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.selectDate)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controllerState = ref.watch(meterReadingsControllerProvider);
    final buildingsAsync = ref.watch(buildingsProvider);
    final apartmentsAsync = ref.watch(apartmentsProvider);

    ref.listen<AsyncValue<void>>(meterReadingsControllerProvider, (_, state) {
      state.whenOrNull(
        data: (_) => context.pop(),
        error: (error, _) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString()))),
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('إضافة قراءة عداد')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            SwitchListTile(
              title: const Text('مصروف مشترك (للمبنى بالكامل)'),
              value: _isSharedExpense,
              onChanged: (val) {
                setState(() {
                  _isSharedExpense = val;
                  if (val) {
                    _selectedApartmentId = null;
                  }
                });
              },
            ),
            const SizedBox(height: 16),
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
                  items: buildings
                      .map(
                        (b) =>
                            DropdownMenuItem(value: b.id, child: Text(b.name)),
                      )
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      _selectedBuildingId = v;
                      _selectedApartmentId = null;
                    });
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, st) => Text('Error: $e'),
            ),
            if (!_isSharedExpense) ...[
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
                    items: filteredApts
                        .map(
                          (a) => DropdownMenuItem(
                            value: a.id,
                            child: Text('شقة ${a.apartmentNumber}'),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedApartmentId = v),
                    validator: (v) =>
                        v == null && !_isSharedExpense ? 'مطلوب' : null,
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (e, st) => const SizedBox.shrink(),
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
            const SizedBox(height: 16),
            TextFormField(
              controller: _previousReadingController,
              decoration: InputDecoration(labelText: l10n.previousReading),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) {
                final value = double.tryParse(v?.trim() ?? '');
                if (value == null) return 'مطلوب';
                if (value < 0) return 'القراءة لا يمكن أن تكون سالبة';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _currentReadingController,
              decoration: InputDecoration(labelText: l10n.currentReading),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) {
                final current = double.tryParse(v?.trim() ?? '');
                final previous = double.tryParse(
                  _previousReadingController.text.trim(),
                );
                if (current == null) return 'مطلوب';
                if (current < 0) return 'القراءة لا يمكن أن تكون سالبة';
                if (previous != null && current < previous) {
                  return 'القراءة الحالية لازم تكون أكبر من أو تساوي السابقة';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(labelText: l10n.amount),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) {
                final value = double.tryParse(v?.trim() ?? '');
                if (value == null) return 'مطلوب';
                if (value < 0) return 'المبلغ لا يمكن أن يكون سالب';
                return null;
              },
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
