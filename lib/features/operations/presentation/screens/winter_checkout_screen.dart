import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/apartment_inspections_provider.dart';
import '../../../apartments/presentation/providers/apartments_controller.dart';
import '../../../contracts/presentation/providers/contracts_provider.dart';
import '../../../contracts/presentation/providers/contracts_controller.dart';
import '../../../users/presentation/providers/users_provider.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/widgets.dart';

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
    final colors = context.colors;

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

    return AppScaffold(
      appBar: const AbragAppBar(title: 'تسليم الشقة (عقد شتوي)'),
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
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    AppCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconTile(
                            icon: Icons.key_outlined,
                            tint: colors.winter,
                            size: 48,
                            iconSize: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'بيانات التسليم',
                                  style: AppTextStyles.label.copyWith(
                                    color: colors.ink2,
                                  ),
                                ),
                                Text(
                                  contract.studentName,
                                  style: AppTextStyles.h2.copyWith(
                                    color: colors.ink,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: [
                                    StatusChip(
                                      label: 'شقة ${apt.apartmentNumber}',
                                      kind: StatusChipKind.winter,
                                      icon: Icons.door_front_door_outlined,
                                    ),
                                    StatusChip(
                                      label:
                                          'التأمين: ${contract.depositEgp.toCurrencyFormat()} ج.م',
                                      kind: StatusChipKind.brand,
                                      icon: Icons.shield_outlined,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SectionTitle(title: 'بيانات الفحص'),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AppDateField(
                            label: 'تاريخ التسليم / الفحص',
                            value: _inspectionDate.toLocal().toString().split(
                              ' ',
                            )[0],
                            onTap: _selectDate,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppTextField(
                            label: 'اسم المستلم / الفاحص',
                            prefixIcon: Icons.person_outline,
                            controller: _inspectorNameController,
                            validator: (v) =>
                                v == null || v.isEmpty ? 'مطلوب' : null,
                          ),
                        ),
                      ],
                    ),
                    const SectionTitle(title: 'الخروج المبكر'),
                    AppSwitchRow(
                      title: 'خروج مبكر عن ميعاد العقد؟',
                      icon: Icons.directions_run,
                      tint: colors.warn,
                      value: _isEarlyCheckout,
                      onChanged: (val) => setState(() {
                        _isEarlyCheckout = val;
                        if (!val) _broughtReplacement = false;
                      }),
                    ),
                    if (_isEarlyCheckout) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 16),
                        child: AppSwitchRow(
                          title: 'هل جاب طالب بديل؟',
                          subtitle:
                              'إذا لم يجلب بديل، سيتم مصادرة التأمين بالكامل.',
                          icon: Icons.swap_horiz,
                          value: _broughtReplacement,
                          onChanged: (val) =>
                              setState(() => _broughtReplacement = val),
                        ),
                      ),
                    ],

                    const SectionTitle(title: 'حالة النظافة'),
                    SegmentedTabs(
                      labels: const ['نظيفة', 'تحتاج نظافة'],
                      index: _isClean ? 0 : 1,
                      onChanged: (i) => setState(() => _isClean = i == 0),
                    ),
                    if (!_isClean) ...[
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'خصم نظافة (ج.م)',
                        prefixIcon: Icons.cleaning_services_outlined,
                        controller: _cleaningDeductionController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [CurrencyInputFormatter()],
                        onChanged: (_) => setState(() {}),
                      ),
                    ],

                    const SectionTitle(title: 'فحص العدادات والتسويات'),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'خصم غاز (ج.م)',
                            controller: _gasDeductionController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [CurrencyInputFormatter()],
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppTextField(
                            label: 'خصم كهرباء (ج.م)',
                            controller: _electricityDeductionController,
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
                      AppCard(
                        color: colors.brandSoft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'قائمة الفحص (الجرد):',
                              style: AppTextStyles.title.copyWith(
                                color: colors.brand,
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
                                      style: AppTextStyles.label.copyWith(
                                        color: colors.brand,
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
                      const SizedBox(height: 16),
                    ],
                    const SectionTitle(title: 'التلفيات'),
                    AppSwitchRow(
                      title: 'هل يوجد تلفيات في المحتويات؟',
                      subtitle:
                          'تسجيل الأشياء المكسورة أو التالفة ومين هيتحمل تكلفتها',
                      icon: Icons.report_problem_outlined,
                      tint: colors.warn,
                      value: _hasDamages,
                      onChanged: (val) => setState(() => _hasDamages = val),
                    ),
                    if (_hasDamages) ...[
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'تفاصيل التلفيات',
                        prefixIcon: Icons.notes_outlined,
                        controller: _damagesDescriptionController,
                        maxLines: 3,
                        validator: (v) =>
                            _hasDamages && (v == null || v.isEmpty)
                            ? 'مطلوب'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      AppSwitchRow(
                        title: 'تسجيل التلفيات كطلب صيانة',
                        subtitle: 'لعدم معرفة تكلفة التصليح حتى يراها العامل',
                        icon: Icons.build_outlined,
                        value: _createMaintenanceRequest,
                        onChanged: (val) =>
                            setState(() => _createMaintenanceRequest = val),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'خصم تلفيات (ج.م)',
                              controller: _tenantFineController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [CurrencyInputFormatter()],
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          if (!_createMaintenanceRequest) ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppTextField(
                                label: 'تكلفة تصليح علينا (ج.م)',
                                helperText: 'ستُسجل كمصروف',
                                controller: _ownerCostController,
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
                    AppTextField(
                      label: 'ملاحظات أخرى (اختياري)',
                      prefixIcon: Icons.sticky_note_2_outlined,
                      controller: _notesController,
                      maxLines: 2,
                    ),

                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _isEarlyCheckout && !_broughtReplacement
                            ? colors.errSoft
                            : colors.brandSoft,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: _isEarlyCheckout && !_broughtReplacement
                              ? colors.err.withValues(alpha: 0.5)
                              : colors.brand.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'تسوية التأمين',
                            style: AppTextStyles.title.copyWith(
                              color: colors.ink,
                            ),
                          ),
                          Divider(color: colors.border),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('إجمالي الخصومات:'),
                              Text(
                                '${totalDeduction.toCurrencyFormat()} ج.م',
                                style: AppTextStyles.tabular(
                                  AppTextStyles.title.copyWith(
                                    color: colors.err,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_isEarlyCheckout && !_broughtReplacement)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'تم مصادرة التأمين بالكامل بسبب الخروج المبكر بدون بديل.',
                                style: AppTextStyles.label.copyWith(
                                  color: colors.err,
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
                                style: AppTextStyles.tabular(
                                  AppTextStyles.h3.copyWith(color: colors.ok),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const LoadingSkeleton(),
            error: (e, st) => ErrorState(
              title: 'تعذر تحميل بيانات الشقة',
              message: 'Error: $e',
              retryLabel: 'إعادة المحاولة',
              onRetry: () => ref.invalidate(apartmentsProvider),
            ),
          );
        },
        loading: () => const LoadingSkeleton(),
        error: (e, st) => ErrorState(
          title: 'تعذر تحميل بيانات العقد',
          message: 'Error: $e',
          retryLabel: 'إعادة المحاولة',
          onRetry: () => ref.invalidate(allWinterContractsProvider),
        ),
      ),
      bottomNavigationBar: contractsAsync.maybeWhen(
        data: (contracts) {
          final contract = contracts.firstWhere(
            (c) => c.id == widget.winterContractId,
          );
          return apartmentsAsync.maybeWhen(
            data: (apartments) {
              final apt = apartments.firstWhere(
                (a) => a.id == contract.apartmentId,
              );
              return BottomActionBar(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'تسجيل استلام الشقة وتسوية التأمين',
                      icon: Icons.check_circle,
                      loading: controllerState.isLoading,
                      onPressed: controllerState.isLoading
                          ? null
                          : () => _submit(apt.id, contract.depositEgp),
                    ),
                  ),
                ],
              );
            },
            orElse: () => null,
          );
        },
        orElse: () => null,
      ),
    );
  }
}
