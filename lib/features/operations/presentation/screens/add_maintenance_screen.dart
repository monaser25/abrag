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

    return Scaffold(
      appBar: AppBar(title: Text(widget.request == null ? 'إضافة طلب صيانة' : 'تعديل طلب صيانة')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
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
                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'اختر المبنى'),
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
              loading: () => const CircularProgressIndicator(),
              error: (e, st) => Text('Error: $e'),
            ),
            const SizedBox(height: 16),
            apartmentsAsync.when(
              data: (apartments) {
                final filteredApts = _selectedBuildingId != null 
                    ? apartments.where((a) => a.buildingId == _selectedBuildingId).toList()
                    : apartments;
                
                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'الشقة'),
                  initialValue: _selectedApartmentId,
                  items: filteredApts.map((a) => DropdownMenuItem(value: a.id, child: Text('شقة ${a.apartmentNumber}'))).toList(),
                  onChanged: widget.request != null ? null : (v) => setState(() => _selectedApartmentId = v),
                  validator: (v) => v == null ? 'مطلوب' : null,
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, st) => Text('Error: $e'),
            ),
            const SizedBox(height: 16),
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

                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'الفني / العامل (اختياري)'),
                  initialValue: _selectedTechnicianId,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('بدون فني')),
                    ...activeTechs.map((t) => DropdownMenuItem(value: t.id, child: Text('${t.name} (${t.specialty})'))),
                  ],
                  onChanged: (v) => setState(() => _selectedTechnicianId = v),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, st) => Text('Error: $e'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reportedByController,
              decoration: const InputDecoration(labelText: 'اسم المُبلّغ (اختياري)'),
              // Validator removed to make it optional
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'وصف العطل'),
              maxLines: 4,
              validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
            ),
            if (widget.request?.status == 'resolved') ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _costController,
                decoration: const InputDecoration(labelText: 'التكلفة (ج.م)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [CurrencyInputFormatter()],
                validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: controllerState.isLoading ? null : _submit,
              child: controllerState.isLoading
                  ? const CircularProgressIndicator()
                  : const Text('حفظ الطلب'),
            ),
          ],
        ),
      ),
    );
  }
}
