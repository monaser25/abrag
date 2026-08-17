import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/buildings_controller.dart';

import '../../../../core/database/database.dart';
import '../../../../shared/widgets/widgets.dart';

class AddBuildingScreen extends ConsumerStatefulWidget {
  final Building? building;

  const AddBuildingScreen({super.key, this.building});

  @override
  ConsumerState<AddBuildingScreen> createState() => _AddBuildingScreenState();
}

class _AddBuildingScreenState extends ConsumerState<AddBuildingScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _totalApartmentsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.building?.name ?? '');
    _addressController = TextEditingController(
      text: widget.building?.address ?? '',
    );
    _totalApartmentsController = TextEditingController(
      text: widget.building?.totalApartments.toString() ?? '15',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _totalApartmentsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (widget.building == null) {
        ref
            .read(buildingsControllerProvider.notifier)
            .addBuilding(
              _nameController.text.trim(),
              _addressController.text.trim(),
              int.tryParse(_totalApartmentsController.text.trim()) ?? 15,
            );
      } else {
        ref
            .read(buildingsControllerProvider.notifier)
            .updateBuilding(
              widget.building!.id,
              _nameController.text.trim(),
              _addressController.text.trim(),
              int.tryParse(_totalApartmentsController.text.trim()) ?? 15,
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controllerState = ref.watch(buildingsControllerProvider);

    ref.listen<AsyncValue<void>>(buildingsControllerProvider, (_, state) {
      state.whenOrNull(
        data: (_) => context.pop(),
        error: (error, _) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString()))),
      );
    });

    return AppScaffold(
      appBar: AbragAppBar(
        title: widget.building == null ? 'إضافة مبنى' : 'تعديل بيانات المبنى',
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const SectionTitle(title: 'بيانات المبنى'),
            AppTextField(
              label: 'اسم المبنى',
              prefixIcon: Icons.apartment,
              controller: _nameController,
              validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'العنوان',
              prefixIcon: Icons.place_outlined,
              controller: _addressController,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'عدد الشقق',
              prefixIcon: Icons.grid_view_outlined,
              controller: _totalApartmentsController,
              keyboardType: TextInputType.number,
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
