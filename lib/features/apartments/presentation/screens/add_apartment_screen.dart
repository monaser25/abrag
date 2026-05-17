import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/shared_prefs_provider.dart';
import '../../../../core/database/database.dart';
import '../providers/apartments_controller.dart';
import '../../../buildings/presentation/providers/buildings_controller.dart';

class AddApartmentScreen extends ConsumerStatefulWidget {
  final Apartment? apartment;

  const AddApartmentScreen({super.key, this.apartment});

  @override
  ConsumerState<AddApartmentScreen> createState() => _AddApartmentScreenState();
}

class _AddApartmentScreenState extends ConsumerState<AddApartmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _floorController = TextEditingController();
  final _inventoryController = TextEditingController();
  final _landlineNumberController = TextEditingController();
  final _landlineOwnerController = TextEditingController();
  final _landlineNotesController = TextEditingController();
  String? _selectedBuildingId;

  @override
  void initState() {
    super.initState();
    final apartment = widget.apartment;
    if (apartment != null) {
      _numberController.text = apartment.apartmentNumber;
      _floorController.text = apartment.floorNumber?.toString() ?? '';
      _inventoryController.text = apartment.inventory ?? '';
      _landlineNumberController.text = apartment.landlineNumber ?? '';
      _landlineOwnerController.text = apartment.landlineOwnerName ?? '';
      _landlineNotesController.text = apartment.landlineNotes ?? '';
      _selectedBuildingId = apartment.buildingId;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.apartment == null) _loadGlobalTemplate();
    });
  }

  @override
  void dispose() {
    _numberController.dispose();
    _floorController.dispose();
    _inventoryController.dispose();
    _landlineNumberController.dispose();
    _landlineOwnerController.dispose();
    _landlineNotesController.dispose();
    super.dispose();
  }

  void _loadGlobalTemplate() {
    final prefs = ref.read(sharedPreferencesProvider);
    final tmpl = prefs.getString('global_apartment_inventory_template');
    if (tmpl != null && tmpl.isNotEmpty) {
      setState(() {
        _inventoryController.text = tmpl;
      });
    }
  }

  Future<void> _saveAsGlobalTemplate() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(
      'global_apartment_inventory_template',
      _inventoryController.text.trim(),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ الجرد كقالب افتراضي لجميع الشقق')),
      );
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedBuildingId != null) {
      final controller = ref.read(apartmentsControllerProvider.notifier);
      if (widget.apartment == null) {
        controller.addApartment(
            _selectedBuildingId!,
            _numberController.text.trim(),
            int.tryParse(_floorController.text.trim()) ?? 1,
            inventory: _inventoryController.text.trim().isEmpty
                ? null
                : _inventoryController.text.trim(),
            landlineNumber: _landlineNumberController.text.trim().isEmpty
                ? null
                : _landlineNumberController.text.trim(),
            landlineOwnerName: _landlineOwnerController.text.trim().isEmpty
                ? null
                : _landlineOwnerController.text.trim(),
            landlineNotes: _landlineNotesController.text.trim().isEmpty
                ? null
                : _landlineNotesController.text.trim(),
          );
      } else {
        controller.updateApartment(
          id: widget.apartment!.id,
          buildingId: _selectedBuildingId!,
          apartmentNumber: _numberController.text.trim(),
          floorNumber: int.tryParse(_floorController.text.trim()),
          inventory: _inventoryController.text.trim().isEmpty
              ? null
              : _inventoryController.text.trim(),
          landlineNumber: _landlineNumberController.text.trim().isEmpty
              ? null
              : _landlineNumberController.text.trim(),
          landlineOwnerName: _landlineOwnerController.text.trim().isEmpty
              ? null
              : _landlineOwnerController.text.trim(),
          landlineNotes: _landlineNotesController.text.trim().isEmpty
              ? null
              : _landlineNotesController.text.trim(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controllerState = ref.watch(apartmentsControllerProvider);
    final buildingsAsync = ref.watch(buildingsProvider);

    ref.listen<AsyncValue<void>>(apartmentsControllerProvider, (_, state) {
      state.whenOrNull(
        data: (_) => context.pop(),
        error: (error, _) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString()))),
      );
    });

    return Scaffold(
      appBar: AppBar(title: Text(widget.apartment == null ? 'إضافة شقة' : 'تعديل شقة')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            buildingsAsync.when(
              data: (buildings) {
                if (buildings.isEmpty) return const Text('أضف مبنى أولاً');
                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'المبنى'),
                  initialValue: _selectedBuildingId,
                  items: buildings
                      .map(
                        (b) =>
                            DropdownMenuItem(value: b.id, child: Text(b.name)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedBuildingId = v),
                  validator: (v) => v == null ? 'مطلوب' : null,
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, st) => Text('Error: $e'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _numberController,
              decoration: const InputDecoration(labelText: 'رقم الشقة'),
              validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _floorController,
              decoration: const InputDecoration(labelText: 'الدور'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'بيانات الخط الأرضي',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _landlineNumberController,
                      decoration: const InputDecoration(
                        labelText: 'رقم الخط الأرضي',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _landlineOwnerController,
                      decoration: const InputDecoration(
                        labelText: 'اسم صاحب الخط',
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _landlineNotesController,
                      decoration: const InputDecoration(
                        labelText: 'ملاحظات الخط',
                        prefixIcon: Icon(Icons.notes),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'محتويات الشقة (جرد مبدئي)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextButton.icon(
                          onPressed: _saveAsGlobalTemplate,
                          icon: const Icon(Icons.save, size: 18),
                          label: const Text('حفظ كقالب'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'اكتب كل عنصر في سطر. لإنشاء مجموعة (مثل الأجهزة الكهربائية)، اكتب اسم المجموعة في سطر وضع آخره نقطتين (:)',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _inventoryController,
                      decoration: const InputDecoration(
                        hintText:
                            'الأجهزة الكهربائية:\nثلاجة\nغسالة\n\nالأثاث:\nسرير كبير\nدولاب',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 8,
                    ),
                  ],
                ),
              ),
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
