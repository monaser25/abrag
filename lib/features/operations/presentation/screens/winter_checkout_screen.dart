import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/apartment_inspections_provider.dart';
import '../../../apartments/presentation/providers/apartments_controller.dart';
import '../../../contracts/presentation/providers/contracts_provider.dart';
import '../../../contracts/presentation/providers/contracts_controller.dart';
import '../../../users/presentation/providers/users_provider.dart';
import '../../../../core/utils/currency_formatter.dart';

class WinterCheckoutScreen extends ConsumerStatefulWidget {
  final String winterContractId;

  const WinterCheckoutScreen({super.key, required this.winterContractId});

  @override
  ConsumerState<WinterCheckoutScreen> createState() =>
      _WinterCheckoutScreenState();
}

class _WinterCheckoutScreenState extends ConsumerState<WinterCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _inspectionDate = DateTime.now();

  bool _isClean = true;
  bool _hasDamages = false;
  bool _createMaintenanceRequest = false;

  bool _isEarlyCheckout = false;
  bool _broughtReplacement = false;

  final Map<String, bool> _inventoryChecks = {};

  final _damagesDescriptionController = TextEditingController();
  final _tenantFineController = TextEditingController(
    text: '0',
  ); // Damages deduction
  final _cleaningDeductionController = TextEditingController(text: '0');
  final _gasDeductionController = TextEditingController(text: '0');
  final _electricityDeductionController = TextEditingController(text: '0');
  final _ownerCostController = TextEditingController(text: '0');
  final _inspectorNameController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(currentUserProfileProvider).value;
      if (profile != null && profile.fullName != null) {
        setState(() {
          _inspectorNameController.text = profile.fullName!;
        });
      }
    });
  }

  @override
  void dispose() {
    _damagesDescriptionController.dispose();
    _tenantFineController.dispose();
    _cleaningDeductionController.dispose();
    _gasDeductionController.dispose();
    _electricityDeductionController.dispose();
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

  void _submit(String apartmentId, double deposit) {
    if (_formKey.currentState!.validate()) {
      double damagesDeduction = _hasDamages
          ? (double.tryParse(_tenantFineController.text.replaceAll(',', '')) ??
                0)
          : 0;
      double cleaningDeduction =
          double.tryParse(
            _cleaningDeductionController.text.replaceAll(',', ''),
          ) ??
          0;
      double gasDeduction =
          double.tryParse(_gasDeductionController.text.replaceAll(',', '')) ??
          0;
      double electricityDeduction =
          double.tryParse(
            _electricityDeductionController.text.replaceAll(',', ''),
          ) ??
          0;

      double totalDeduction =
          damagesDeduction +
          cleaningDeduction +
          gasDeduction +
          electricityDeduction;

      if (_isEarlyCheckout && !_broughtReplacement) {
        totalDeduction = deposit;
      }

      if (totalDeduction > deposit) totalDeduction = deposit;

      // Add inspection
      ref
          .read(apartmentInspectionsControllerProvider.notifier)
          .addInspection(
            apartmentId: apartmentId,
            inspectionDate: _inspectionDate,
            isClean: _isClean,
            hasDamages: _hasDamages,
            damagesDescription: _hasDamages
                ? _damagesDescriptionController.text.trim()
                : null,
            tenantFineEgp: damagesDeduction,
            ownerRepairCostEgp: (_hasDamages && !_createMaintenanceRequest)
                ? (double.tryParse(
                        _ownerCostController.text.replaceAll(',', ''),
                      ) ??
                      0)
                : 0,
            inspectorName: _inspectorNameController.text.trim(),
            notes: _notesController.text.trim(),
            createMaintenanceRequest: _createMaintenanceRequest,
          );

      // Checkout contract
      ref
          .read(contractsControllerProvider.notifier)
          .checkoutContract(
            id: widget.winterContractId,
            depositDeductionEgp: totalDeduction,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final contractsAsync = ref.watch(allWinterContractsProvider);
    final apartmentsAsync = ref.watch(apartmentsProvider);
    final controllerState = ref.watch(apartmentInspectionsControllerProvider);
    final theme = Theme.of(context);

    ref.listen<AsyncValue<void>>(apartmentInspectionsControllerProvider, (
      _,
      state,
    ) {
      state.whenOrNull(
        data: (_) {
          context.pop();
        },
        error: (error, _) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString()))),
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('تسليم الشقة (عقد شتوي)')),
      body: contractsAsync.when(
        data: (contracts) {
          final contract = contracts.firstWhere(
            (c) => c.id == widget.winterContractId,
          );
          return apartmentsAsync.when(
            data: (apartments) {
              final apt = apartments.firstWhere(
                (a) => a.id == contract.apartmentId,
              );

              if (apt.inventory != null && apt.inventory!.isNotEmpty) {
                final isNewFormat =
                    apt.inventory!.contains('\n') ||
                    apt.inventory!.contains(':');
                final separator = isNewFormat ? '\n' : ',';
                final items = apt.inventory!
                    .split(separator)
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();
                for (var item in items) {
                  if (!item.endsWith(':')) {
                    _inventoryChecks.putIfAbsent(item, () => false);
                  }
                }
              }

              double damagesDeduction = _hasDamages
                  ? (double.tryParse(
                          _tenantFineController.text.replaceAll(',', ''),
                        ) ??
                        0)
                  : 0;
              double cleaningDeduction =
                  double.tryParse(
                    _cleaningDeductionController.text.replaceAll(',', ''),
                  ) ??
                  0;
              double gasDeduction =
                  double.tryParse(
                    _gasDeductionController.text.replaceAll(',', ''),
                  ) ??
                  0;
              double electricityDeduction =
                  double.tryParse(
                    _electricityDeductionController.text.replaceAll(',', ''),
                  ) ??
                  0;

              double totalDeduction =
                  damagesDeduction +
                  cleaningDeduction +
                  gasDeduction +
                  electricityDeduction;
              if (_isEarlyCheckout && !_broughtReplacement) {
                totalDeduction = contract.depositEgp;
              }
              if (totalDeduction > contract.depositEgp) {
                totalDeduction = contract.depositEgp;
              }

              double refund = contract.depositEgp - totalDeduction;

              return Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'بيانات التسليم',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('الطالب: ${contract.studentName}'),
                            Text('شقة ${apt.apartmentNumber}'),
                            Text(
                              'التأمين: ${contract.depositEgp.toCurrencyFormat()} ج.م',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('تاريخ التسليم / الفحص'),
                      subtitle: Text(
                        _inspectionDate.toLocal().toString().split(' ')[0],
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: theme.dividerColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      onTap: _selectDate,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _inspectorNameController,
                      decoration: const InputDecoration(
                        labelText: 'اسم المستلم / الفاحص',
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                    ),
                    const SizedBox(height: 16),

                    SwitchListTile(
                      title: const Text(
                        'خروج مبكر عن ميعاد العقد؟',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      value: _isEarlyCheckout,
                      onChanged: (val) => setState(() {
                        _isEarlyCheckout = val;
                        if (!val) _broughtReplacement = false;
                      }),
                    ),
                    if (_isEarlyCheckout)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: SwitchListTile(
                          title: const Text(
                            'هل جاب طالب بديل؟',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text(
                            'إذا لم يجلب بديل، سيتم مصادرة التأمين بالكامل.',
                          ),
                          value: _broughtReplacement,
                          onChanged: (val) =>
                              setState(() => _broughtReplacement = val),
                        ),
                      ),

                    const SizedBox(height: 24),
                    Text('حالة النظافة', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: true,
                          label: Text('نظيفة'),
                          icon: Icon(Icons.cleaning_services),
                        ),
                        ButtonSegment(
                          value: false,
                          label: Text('تحتاج نظافة'),
                          icon: Icon(Icons.warning),
                        ),
                      ],
                      selected: {_isClean},
                      onSelectionChanged: (Set<bool> newSelection) {
                        setState(() => _isClean = newSelection.first);
                      },
                    ),
                    if (!_isClean) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _cleaningDeductionController,
                        decoration: const InputDecoration(
                          labelText: 'خصم نظافة (ج.م)',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [CurrencyInputFormatter()],
                        onChanged: (_) => setState(() {}),
                      ),
                    ],

                    const SizedBox(height: 24),
                    Text(
                      'فحص العدادات والتسويات',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _gasDeductionController,
                            decoration: const InputDecoration(
                              labelText: 'خصم غاز (ج.م)',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [CurrencyInputFormatter()],
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _electricityDeductionController,
                            decoration: const InputDecoration(
                              labelText: 'خصم كهرباء (ج.م)',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [CurrencyInputFormatter()],
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    if (apt.inventory != null &&
                        apt.inventory!.trim().isNotEmpty) ...[
                      Card(
                        color: theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.1,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'قائمة الفحص (الجرد):',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...(() {
                                final isNewFormat =
                                    apt.inventory!.contains('\n') ||
                                    apt.inventory!.contains(':');
                                final separator = isNewFormat ? '\n' : ',';
                                final items = apt.inventory!
                                    .split(separator)
                                    .map((e) => e.trim())
                                    .where((e) => e.isNotEmpty)
                                    .toList();
                                return items.map((item) {
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
                                  return CheckboxListTile(
                                    title: Text(item),
                                    value: _inventoryChecks[item] ?? false,
                                    onChanged: (val) {
                                      setState(() {
                                        _inventoryChecks[item] = val ?? false;
                                      });
                                    },
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    contentPadding: EdgeInsets.zero,
                                    dense: true,
                                  );
                                });
                              })(),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    SwitchListTile(
                      title: const Text(
                        'هل يوجد تلفيات في المحتويات؟',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                        'تسجيل الأشياء المكسورة أو التالفة ومين هيتحمل تكلفتها',
                      ),
                      value: _hasDamages,
                      onChanged: (val) => setState(() => _hasDamages = val),
                    ),
                    if (_hasDamages) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _damagesDescriptionController,
                        decoration: const InputDecoration(
                          labelText: 'تفاصيل التلفيات',
                        ),
                        maxLines: 3,
                        validator: (v) =>
                            _hasDamages && (v == null || v.isEmpty)
                            ? 'مطلوب'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text(
                          'تسجيل التلفيات كطلب صيانة',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text(
                          'لعدم معرفة تكلفة التصليح حتى يراها العامل',
                        ),
                        value: _createMaintenanceRequest,
                        onChanged: (val) =>
                            setState(() => _createMaintenanceRequest = val),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _tenantFineController,
                              decoration: const InputDecoration(
                                labelText: 'خصم تلفيات (ج.م)',
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [CurrencyInputFormatter()],
                              onChanged: (_) => setState(() {}),
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
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
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
                      decoration: const InputDecoration(
                        labelText: 'ملاحظات أخرى (اختياري)',
                      ),
                      maxLines: 2,
                    ),

                    const SizedBox(height: 32),
                    Card(
                      color: _isEarlyCheckout && !_broughtReplacement
                          ? theme.colorScheme.error.withValues(alpha: 0.1)
                          : theme.colorScheme.primaryContainer.withValues(
                              alpha: 0.3,
                            ),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: _isEarlyCheckout && !_broughtReplacement
                              ? theme.colorScheme.error.withValues(alpha: 0.5)
                              : theme.colorScheme.primary.withValues(
                                  alpha: 0.5,
                                ),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              'تسوية التأمين',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('إجمالي الخصومات:'),
                                Text(
                                  '${totalDeduction.toCurrencyFormat()} ج.م',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                              ],
                            ),
                            if (_isEarlyCheckout && !_broughtReplacement)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'تم مصادرة التأمين بالكامل بسبب الخروج المبكر بدون بديل.',
                                  style: TextStyle(
                                    color: theme.colorScheme.error,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('المبلغ المسترد للطالب:'),
                                Text(
                                  '${refund.toCurrencyFormat()} ج.م',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: controllerState.isLoading
                          ? null
                          : () => _submit(apt.id, contract.depositEgp),
                      child: controllerState.isLoading
                          ? const CircularProgressIndicator()
                          : const Text('تسجيل استلام الشقة وتسوية التأمين'),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Error: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
