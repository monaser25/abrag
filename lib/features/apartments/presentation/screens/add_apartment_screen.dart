import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/apartments_controller.dart';
import '../../../buildings/presentation/providers/buildings_controller.dart';

class AddApartmentScreen extends ConsumerStatefulWidget {
  const AddApartmentScreen({super.key});

  @override
  ConsumerState<AddApartmentScreen> createState() => _AddApartmentScreenState();
}

class _AddApartmentScreenState extends ConsumerState<AddApartmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _floorController = TextEditingController();
  final _inventoryController = TextEditingController();
  String? _selectedBuildingId;

  @override
  void dispose() {
    _numberController.dispose();
    _floorController.dispose();
    _inventoryController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedBuildingId != null) {
      ref.read(apartmentsControllerProvider.notifier).addApartment(
        _selectedBuildingId!,
        _numberController.text.trim(),
        int.tryParse(_floorController.text.trim()) ?? 1,
        inventory: _inventoryController.text.trim().isEmpty ? null : _inventoryController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controllerState = ref.watch(apartmentsControllerProvider);
    final buildingsAsync = ref.watch(buildingsProvider);

    ref.listen<AsyncValue<void>>(
      apartmentsControllerProvider,
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
      appBar: AppBar(title: const Text('إضافة شقة')),
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
                  items: buildings.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
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
            TextFormField(
              controller: _inventoryController,
              decoration: const InputDecoration(
                labelText: 'محتويات الشقة (جرد مبدئي)',
                hintText: 'مثال: ثلاجة, غسالة, بوتاجاز, ...',
              ),
              maxLines: 3,
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
