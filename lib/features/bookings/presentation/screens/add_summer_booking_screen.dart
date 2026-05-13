import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/bookings_controller.dart';

class AddSummerBookingScreen extends ConsumerStatefulWidget {
  const AddSummerBookingScreen({super.key});

  @override
  ConsumerState<AddSummerBookingScreen> createState() => _AddSummerBookingScreenState();
}

class _AddSummerBookingScreenState extends ConsumerState<AddSummerBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _guestNameController = TextEditingController();
  final _guestPhoneController = TextEditingController();
  final _totalPriceController = TextEditingController();
  
  DateTime? _checkInDate;
  DateTime? _checkOutDate;

  @override
  void dispose() {
    _guestNameController.dispose();
    _guestPhoneController.dispose();
    _totalPriceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
        } else {
          _checkOutDate = picked;
        }
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _checkInDate != null && _checkOutDate != null) {
      ref.read(bookingsControllerProvider.notifier).addBooking(
        guestName: _guestNameController.text.trim(),
        guestPhone: _guestPhoneController.text.trim(),
        checkInDate: _checkInDate!,
        checkOutDate: _checkOutDate!,
        totalPriceEgp: double.tryParse(_totalPriceController.text.trim()) ?? 0,
      );
    } else if (_checkInDate == null || _checkOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.selectDate)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controllerState = ref.watch(bookingsControllerProvider);

    ref.listen<AsyncValue<void>>(
      bookingsControllerProvider,
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
        title: Text(l10n.addBooking),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _guestNameController,
              decoration: InputDecoration(labelText: l10n.guestName),
              validator: (v) => v == null || v.isEmpty ? l10n.requiredField : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _guestPhoneController,
              decoration: InputDecoration(labelText: l10n.guestPhone),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(l10n.checkInDate),
              subtitle: Text(_checkInDate?.toString().split(' ')[0] ?? l10n.selectDate),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, true),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(l10n.checkOutDate),
              subtitle: Text(_checkOutDate?.toString().split(' ')[0] ?? l10n.selectDate),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, false),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _totalPriceController,
              decoration: InputDecoration(labelText: l10n.totalPrice),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => v == null || v.isEmpty ? l10n.requiredField : null,
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
