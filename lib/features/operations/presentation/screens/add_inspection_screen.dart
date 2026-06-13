import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/apartment_inspections_provider.dart';
import '../../../apartments/presentation/providers/apartments_controller.dart';
import '../../../bookings/presentation/providers/bookings_controller.dart';
import '../../../users/presentation/providers/users_provider.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/widgets.dart';

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
  ConsumerState<AddInspectionScreen> createState() =>
      _AddInspectionScreenState();
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
      ref
          .read(apartmentInspectionsControllerProvider.notifier)
          .addInspection(
            apartmentId: _selectedApartmentId!,
            inspectionDate: _inspectionDate,
            isClean: _isClean,
            hasDamages: _hasDamages,
            damagesDescription: _hasDamages
                ? _damagesDescriptionController.text.trim()
                : null,
            tenantFineEgp: _hasDamages
                ? (double.tryParse(
                        _tenantFineController.text.replaceAll(',', ''),
                      ) ??
                      0)
                : 0,
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
    } else if (_selectedApartmentId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('برجاء اختيار الشقة')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final apartmentsAsync = ref.watch(apartmentsProvider);
    final controllerState = ref.watch(apartmentInspectionsControllerProvider);

    ref.listen<AsyncValue<void>>(apartmentInspectionsControllerProvider, (
      _,
      state,
    ) {
      state.whenOrNull(
        data: (_) {
          if (widget.checkoutBookingId != null) {
            ref
                .read(bookingsControllerProvider.notifier)
                .checkoutBooking(widget.checkoutBookingId!);
          } else if (widget.earlyCheckoutBookingId != null &&
              widget.newCheckoutDate != null) {
            ref
                .read(bookingsControllerProvider.notifier)
                .earlyCheckoutBooking(
                  id: widget.earlyCheckoutBookingId!,
                  newCheckoutDate: DateTime.parse(widget.newCheckoutDate!),
                );
          }
          context.pop();
        },
        error: (error, _) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString()))),
      );
    });

    final colors = context.colors;

    return AppScaffold(
      appBar: const AbragAppBar(title: 'تسجيل فحص شقة'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const SectionTitle(title: 'الشقة'),
            apartmentsAsync.when(
              data: (apartments) {
                return AppDropdownField<String>(
                  label: 'الشقة المُراد فحصها',
                  prefixIcon: Icons.door_front_door_outlined,
                  initialValue: _selectedApartmentId,
                  items: apartments
                      .map(
                        (a) => DropdownMenuItem(
                          value: a.id,
                          child: Text('شقة ${a.apartmentNumber}'),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      _selectedApartmentId = v;
                    });
                  },
                  validator: (v) => v == null ? 'مطلوب' : null,
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, st) => Text('Error: $e'),
            ),
            const SizedBox(height: 16),
            if (_selectedApartmentId != null)
              apartmentsAsync.maybeWhen(
                data: (apartments) {
                  final apt = apartments.firstWhere(
                    (a) => a.id == _selectedApartmentId,
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
                    // Initialize checks if not set
                    for (var item in items) {
                      if (!item.endsWith(':')) {
                        _inventoryChecks.putIfAbsent(item, () => false);
                      }
                    }

                    return AppCard(
                      color: colors.brandSoft,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'قائمة الفحص (الجرد):',
                              style: AppTextStyles.title
                                  .copyWith(color: colors.brand),
                            ),
                            const SizedBox(height: 8),
                            ...items.map((item) {
                              if (item.endsWith(':')) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    top: 12.0,
                                    bottom: 4.0,
                                  ),
                                  child: Text(
                                    item,
                                    style: AppTextStyles.label
                                        .copyWith(color: colors.brand),
                                  ),
                                );
                              }
                              return CheckboxListTile(
                                title: Text(item),
                                value: _inventoryChecks[item],
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
                            }),
                            const SizedBox(height: 8),
                            Text(
                              'يرجى مراجعة هذه المحتويات وتحديد التالف منها بالأسفل.',
                              style: AppTextStyles.caption
                                  .copyWith(color: colors.ink3),
                            ),
                          ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
                orElse: () => const SizedBox.shrink(),
              ),
            const SectionTitle(title: 'بيانات الفحص'),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppDateField(
                    label: 'تاريخ الفحص',
                    value: _inspectionDate.toLocal().toString().split(' ')[0],
                    onTap: _selectDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    label: 'اسم الفاحص / المُستلم',
                    prefixIcon: Icons.person_outline,
                    controller: _inspectorNameController,
                    validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                  ),
                ),
              ],
            ),
            const SectionTitle(title: 'حالة النظافة'),
            SegmentedTabs(
              labels: const ['نظيفة', 'تحتاج نظافة'],
              index: _isClean ? 0 : 1,
              onChanged: (i) => setState(() => _isClean = i == 0),
            ),
            const SectionTitle(title: 'التلفيات'),
            AppSwitchRow(
              title: 'هل يوجد تلفيات في المحتويات؟',
              subtitle: 'تسجيل الأشياء المكسورة أو التالفة ومين هيتحمل تكلفتها',
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
                    _hasDamages && (v == null || v.isEmpty) ? 'مطلوب' : null,
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
                      label: 'غرامة المستأجر (ج.م)',
                      controller: _tenantFineController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [CurrencyInputFormatter()],
                    ),
                  ),
                  if (!_createMaintenanceRequest) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        label: 'تكلفة تصليح علينا (ج.م)',
                        helperText: 'ستُسجل كمصروف',
                        controller: _ownerCostController,
                        keyboardType: const TextInputType.numberWithOptions(
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
          ],
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        children: [
          Expanded(
            child: AppButton(
              label: 'حفظ الفحص',
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
