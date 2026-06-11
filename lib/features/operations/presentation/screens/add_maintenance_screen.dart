import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/maintenance_controller.dart';
import '../../../buildings/presentation/providers/buildings_controller.dart';
import '../../../apartments/presentation/providers/apartments_controller.dart';
import '../providers/technicians_provider.dart';

import '../../../../core/database/database.dart';
import '../../../../core/database/tables.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/widgets.dart';

class AddMaintenanceScreen extends ConsumerStatefulWidget {
  final MaintenanceRequest? request;

  const AddMaintenanceScreen({super.key, this.request});

  @override
  ConsumerState<AddMaintenanceScreen> createState() => _AddMaintenanceScreenState();
}

class _AddMaintenanceScreenState extends ConsumerState<AddMaintenanceScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descriptionController;
  late final TextEditingController _reportedByController;
  late final TextEditingController _costController;
  
  String? _selectedBuildingId;
  String? _selectedApartmentId;
  String? _selectedTechnicianId;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.request?.issueDescription ?? '');
    _reportedByController = TextEditingController(text: widget.request?.reportedBy ?? '');
    _costController = TextEditingController(text: widget.request?.costEgp.toString() ?? '');
    _selectedApartmentId = widget.request?.apartmentId;
    _selectedTechnicianId = widget.request?.technicianId;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _reportedByController.dispose();
    _costController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedApartmentId != null) {
      if (widget.request == null) {
        ref.read(maintenanceControllerProvider.notifier).addRequest(
          apartmentId: _selectedApartmentId!,
          reportedBy: _reportedByController.text.trim(),
          description: _descriptionController.text.trim(),
          technicianId: _selectedTechnicianId,
        );
      } else {
        ref.read(maintenanceControllerProvider.notifier).updateRequest(
          id: widget.request!.id,
          reportedBy: _reportedByController.text.trim(),
          description: _descriptionController.text.trim(),
          technicianId: _selectedTechnicianId,
          costEgp: widget.request!.status == 'resolved' ? double.tryParse(_costController.text.replaceAll(',', '').trim()) : null,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controllerState = ref.watch(maintenanceControllerProvider);
    final buildingsAsync = ref.watch(buildingsProvider);
    final apartmentsAsync = ref.watch(apartmentsProvider);
    final techniciansAsync = ref.watch(techniciansProvider);

    ref.listen<AsyncValue<void>>(
      maintenanceControllerProvider,
      (_, state) {
        state.whenOrNull(
          data: (_) => context.pop(),
          error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString())),
          ),
        );
      },
    );

    return AppScaffold(
      appBar: AbragAppBar(
        title: widget.request == null ? 'إضافة طلب صيانة' : 'تعديل طلب صيانة',
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const SectionTitle(title: 'الموقع'),
            buildingsAsync.when(
              data: (buildings) {
                if (widget.request != null && _selectedBuildingId == null) {
                  // We need to find the building ID for the apartment
                  apartmentsAsync.whenData((apts) {
                    final apt = apts.firstWhere((a) => a.id == _selectedApartmentId, orElse: () => apts.first);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      setState(() {
                        _selectedBuildingId = apt.buildingId;
                      });
                    });
                  });
                } else if (buildings.isNotEmpty && _selectedBuildingId == null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted || _selectedBuildingId != null) return;
                    setState(() {
                      _selectedBuildingId = buildings.first.id;
                    });
                  });
                }
                return AppDropdownField<String>(
                  label: 'اختر المبنى',
                  prefixIcon: Icons.apartment,
                  initialValue: _selectedBuildingId,
                  items: buildings.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
                  onChanged: widget.request != null ? null : (v) {
                    setState(() {
                      _selectedBuildingId = v;
                      _selectedApartmentId = null;
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
                    ? apartments.where((a) => a.buildingId == _selectedBuildingId).toList()
                    : apartments;

                return AppDropdownField<String>(
                  label: 'الشقة',
                  prefixIcon: Icons.door_front_door_outlined,
                  initialValue: _selectedApartmentId,
                  items: filteredApts.map((a) => DropdownMenuItem(value: a.id, child: Text('شقة ${a.apartmentNumber}'))).toList(),
                  onChanged: widget.request != null ? null : (v) => setState(() => _selectedApartmentId = v),
                  validator: (v) => v == null ? 'مطلوب' : null,
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, st) => Text('Error: $e'),
            ),
            const SectionTitle(title: 'تفاصيل العطل'),
            techniciansAsync.when(
              data: (technicians) {
                final activeTechs = technicians.where((t) => t.syncStatus != SyncStatus.pendingDelete).toList();

                // Ensure the selected technician is in the list, if not, add it temporarily
                if (_selectedTechnicianId != null && !activeTechs.any((t) => t.id == _selectedTechnicianId)) {
                   final oldTech = technicians.firstWhere((t) => t.id == _selectedTechnicianId, orElse: () => technicians.first);
                   if (oldTech.id == _selectedTechnicianId) {
                     activeTechs.add(oldTech);
                   }
                }

                return AppDropdownField<String>(
                  label: 'الفني / العامل (اختياري)',
                  prefixIcon: Icons.engineering_outlined,
                  initialValue: _selectedTechnicianId,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('بدون فني')),
                    ...activeTechs.map((t) => DropdownMenuItem(value: t.id, child: Text('${t.name} (${t.specialty})'))),
                  ],
                  onChanged: (v) => setState(() => _selectedTechnicianId = v),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, st) => Text('Error: $e'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'اسم المُبلّغ (اختياري)',
              prefixIcon: Icons.person_outline,
              controller: _reportedByController,
              // Validator removed to make it optional
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'وصف العطل',
              prefixIcon: Icons.build_outlined,
              controller: _descriptionController,
              maxLines: 4,
              validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
            ),
            if (widget.request?.status == 'resolved') ...[
              const SizedBox(height: 16),
              AppTextField(
                label: 'التكلفة (ج.م)',
                prefixIcon: Icons.payments_outlined,
                controller: _costController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [CurrencyInputFormatter()],
                validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        children: [
          Expanded(
            child: AppButton(
              label: 'حفظ الطلب',
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
