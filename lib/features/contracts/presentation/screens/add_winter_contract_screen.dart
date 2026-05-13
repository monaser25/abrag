import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/contracts_controller.dart';

class AddWinterContractScreen extends ConsumerStatefulWidget {
  const AddWinterContractScreen({super.key});

  @override
  ConsumerState<AddWinterContractScreen> createState() => _AddWinterContractScreenState();
}

class _AddWinterContractScreenState extends ConsumerState<AddWinterContractScreen> {
  final _formKey = GlobalKey<FormState>();
  final _studentNameController = TextEditingController();
  final _universityController = TextEditingController();
  final _monthlyRentController = TextEditingController();
  final _depositController = TextEditingController();
  
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _studentNameController.dispose();
    _universityController.dispose();
    _monthlyRentController.dispose();
    _depositController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _startDate != null && _endDate != null) {
      ref.read(contractsControllerProvider.notifier).addContract(
        studentName: _studentNameController.text.trim(),
        university: _universityController.text.trim(),
        startDate: _startDate!,
        endDate: _endDate!,
        monthlyRentEgp: double.tryParse(_monthlyRentController.text.trim()) ?? 0,
        depositEgp: double.tryParse(_depositController.text.trim()) ?? 0,
      );
    } else if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.selectDate)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controllerState = ref.watch(contractsControllerProvider);

    ref.listen<AsyncValue<void>>(
      contractsControllerProvider,
      (_, state) {
        state.whenOrNull(
          data: (_) {
            context.pop();
          },
          error: (error, _) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error.toString()),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          },
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addContract),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _studentNameController,
              decoration: InputDecoration(labelText: l10n.studentName),
              validator: (v) => v == null || v.isEmpty ? l10n.requiredField : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _universityController,
              decoration: InputDecoration(labelText: l10n.university),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(l10n.checkInDate), // Reusing checkInDate translation for simplicity, could add startDate
              subtitle: Text(_startDate?.toString().split(' ')[0] ?? l10n.selectDate),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, true),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(l10n.checkOutDate), // Reusing
              subtitle: Text(_endDate?.toString().split(' ')[0] ?? l10n.selectDate),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, false),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _monthlyRentController,
              decoration: InputDecoration(labelText: l10n.monthlyRent),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => v == null || v.isEmpty ? l10n.requiredField : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _depositController,
              decoration: InputDecoration(labelText: l10n.deposit),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: controllerState.isLoading ? null : _submit,
              child: controllerState.isLoading
                  ? const CircularProgressIndicator()
                  : Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
