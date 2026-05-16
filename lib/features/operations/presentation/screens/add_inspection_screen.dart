import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/apartment_inspections_provider.dart';
import '../../../apartments/presentation/providers/apartments_controller.dart';
import '../../../bookings/presentation/providers/bookings_controller.dart';
import '../../../../core/utils/currency_formatter.dart';

class AddInspectionScreen extends ConsumerStatefulWidget {
  final String? apartmentId;
  final String? checkoutBookingId;
  final String? earlyCheckoutBookingId;
  final String? newCheckoutDate;

  const AddInspectionScreen({
    super.key,
    this.apartmentId,
    this.checkoutBookingId,
    this.earlyCheckoutBookingId,
    this.newCheckoutDate,
  });

  @override
  ConsumerState<AddInspectionScreen> createState() => _AddInspectionScreenState();
}

class _AddInspectionScreenState extends ConsumerState<AddInspectionScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedApartmentId;
  DateTime _inspectionDate = DateTime.now();
  
  bool _isClean = true;
  bool _hasDamages = false;
  bool _createMaintenanceRequest = false;
  
  final Map<String, bool> _inventoryChecks = {};

  final _damagesDescriptionController = TextEditingController();
  final _tenantFineController = TextEditingController(text: '0');
  final _ownerCostController = TextEditingController(text: '0');
  final _inspectorNameController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedApartmentId = widget.apartmentId;
  }

  @override
  void dispose() {
    _damagesDescriptionController.dispose();
    _tenantFineController.dispose();
    _ownerCostController.dispose();
    _inspectorNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _inspectionDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _inspectionDate = picked);
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedApartmentId != null) {
      ref.read(apartmentInspectionsControllerProvider.notifier).addInspection(
        apartmentId: _selectedApartmentId!,
        inspectionDate: _inspectionDate,
        isClean: _isClean,
        hasDamages: _hasDamages,
        damagesDescription: _hasDamages ? _damagesDescriptionController.text.trim() : null,
        tenantFineEgp: _hasDamages ? (double.tryParse(_tenantFineController.text.replaceAll(',', '')) ?? 0) : 0,
        ownerRepairCostEgp: (_hasDamages && !_createMaintenanceRequest) ? (double.tryParse(_ownerCostController.text.replaceAll(',', '')) ?? 0) : 0,
        inspectorName: _inspectorNameController.text.trim(),
        notes: _notesController.text.trim(),
        createMaintenanceRequest: _createMaintenanceRequest,
      );
    } else if (_selectedApartmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('برجاء اختيار الشقة')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final apartmentsAsync = ref.watch(apartmentsProvider);
    final controllerState = ref.watch(apartmentInspectionsControllerProvider);

    ref.listen<AsyncValue<void>>(
      apartmentInspectionsControllerProvider,
      (_, state) {
        state.whenOrNull(
          data: (_) {
            if (widget.checkoutBookingId != null) {
              ref.read(bookingsControllerProvider.notifier).checkoutBooking(widget.checkoutBookingId!);
            } else if (widget.earlyCheckoutBookingId != null && widget.newCheckoutDate != null) {
              ref.read(bookingsControllerProvider.notifier).earlyCheckoutBooking(
                id: widget.earlyCheckoutBookingId!,
                newCheckoutDate: DateTime.parse(widget.newCheckoutDate!),
              );
            }
            context.pop();
          },
          error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString())),
          ),
        );
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل فحص شقة')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            apartmentsAsync.when(
              data: (apartments) {
                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'الشقة المُراد فحصها'),
                  value: _selectedApartmentId,
                  items: apartments.map((a) => DropdownMenuItem(value: a.id, child: Text('شقة ${a.apartmentNumber}'))).toList(),
                  onChanged: (v) {
                    setState(() {
                      _selectedApartmentId = v;
                    });
                  },
                  validator: (v) => v == null ? 'مطلوب' : null,
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, st) => Text('Error: $e'),
            ),
            const SizedBox(height: 16),
            if (_selectedApartmentId != null)
              apartmentsAsync.maybeWhen(
                data: (apartments) {
                  final apt = apartments.firstWhere((a) => a.id == _selectedApartmentId);
                  if (apt.inventory != null && apt.inventory!.isNotEmpty) {
                    final items = apt.inventory!.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                    // Initialize checks if not set
                    for (var item in items) {
                      _inventoryChecks.putIfAbsent(item, () => false);
                    }
                    
                    return Card(
                      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('قائمة الفحص (الجرد):', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
                            const SizedBox(height: 8),
                            ...items.map((item) => CheckboxListTile(
                              title: Text(item),
                              value: _inventoryChecks[item],
                              onChanged: (val) {
                                setState(() {
                                  _inventoryChecks[item] = val ?? false;
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            )),
                            const SizedBox(height: 8),
                            const Text('يرجى مراجعة هذه المحتويات وتحديد التالف منها بالأسفل.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
                orElse: () => const SizedBox.shrink(),
              ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('تاريخ الفحص'),
              subtitle: Text(_inspectionDate.toLocal().toString().split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              onTap: _selectDate,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _inspectorNameController,
              decoration: const InputDecoration(labelText: 'اسم الفاحص / المُستلم'),
              validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
            ),
            const SizedBox(height: 24),
            Text('حالة النظافة', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('نظيفة'), icon: Icon(Icons.cleaning_services)),
                ButtonSegment(value: false, label: Text('تحتاج نظافة'), icon: Icon(Icons.warning)),
              ],
              selected: {_isClean},
              onSelectionChanged: (Set<bool> newSelection) {
                setState(() => _isClean = newSelection.first);
              },
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('هل يوجد تلفيات في المحتويات؟', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('تسجيل الأشياء المكسورة أو التالفة ومين هيتحمل تكلفتها'),
              value: _hasDamages,
              onChanged: (val) => setState(() => _hasDamages = val),
            ),
            if (_hasDamages) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _damagesDescriptionController,
                decoration: const InputDecoration(labelText: 'تفاصيل التلفيات'),
                maxLines: 3,
                validator: (v) => _hasDamages && (v == null || v.isEmpty) ? 'مطلوب' : null,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('تسجيل التلفيات كطلب صيانة', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('لعدم معرفة تكلفة التصليح حتى يراها العامل'),
                value: _createMaintenanceRequest,
                onChanged: (val) => setState(() => _createMaintenanceRequest = val),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _tenantFineController,
                      decoration: const InputDecoration(labelText: 'غرامة المستأجر (ج.م)'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [CurrencyInputFormatter()],
                    ),
                  ),
                  if (!_createMaintenanceRequest) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _ownerCostController,
                        decoration: const InputDecoration(
                          labelText: 'تكلفة تصليح علينا (ج.م)',
                          helperText: 'ستُسجل كمصروف',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [CurrencyInputFormatter()],
                      ),
                    ),
                  ],
                ],
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'ملاحظات أخرى (اختياري)'),
              maxLines: 2,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: controllerState.isLoading ? null : _submit,
              child: controllerState.isLoading
                  ? const CircularProgressIndicator()
                  : const Text('حفظ الفحص'),
            ),
          ],
        ),
      ),
    );
  }
}
