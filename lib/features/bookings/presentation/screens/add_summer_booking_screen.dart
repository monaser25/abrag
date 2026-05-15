import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/bookings_controller.dart';
import '../providers/bookings_provider.dart';
import '../../../buildings/presentation/providers/buildings_controller.dart';
import '../../../apartments/presentation/providers/apartments_controller.dart';
import '../../../users/presentation/providers/users_provider.dart';

class AddSummerBookingScreen extends ConsumerStatefulWidget {
  final String? bookingId;

  const AddSummerBookingScreen({super.key, this.bookingId});

  @override
  ConsumerState<AddSummerBookingScreen> createState() =>
      _AddSummerBookingScreenState();
}

class _AddSummerBookingScreenState
    extends ConsumerState<AddSummerBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _guestNameController = TextEditingController();
  final _guestPhoneController = TextEditingController();
  final _totalPriceController = TextEditingController();
  final _amountPaidController = TextEditingController();
  final _daysController = TextEditingController();
  final _commissionController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _brokerNameController = TextEditingController();

  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  String _paymentMethod = 'cash';
  String _commissionType = 'none';
  File? _idFrontImage;
  File? _idBackImage;
  String? _selectedApartmentId;
  String? _selectedBuildingId;
  String? _selectedBrokerId;
  bool _prefilled = false;

  @override
  void dispose() {
    _guestNameController.dispose();
    _guestPhoneController.dispose();
    _totalPriceController.dispose();
    _amountPaidController.dispose();
    _daysController.dispose();
    _commissionController.dispose();
    _nationalIdController.dispose();
    _brokerNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isFront, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = p.basename(pickedFile.path);
      final savedImage = await File(
        pickedFile.path,
      ).copy('${directory.path}/$fileName');
      setState(() {
        if (isFront) {
          _idFrontImage = savedImage;
        } else {
          _idBackImage = savedImage;
        }
      });
    }
  }

  Future<void> _showImageSourceSheet(bool isFront) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('تصوير بالكاميرا'),
              subtitle: const Text('هيظهر إطار بحجم البطاقة داخل الكاميرا'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('Import من المعرض'),
              subtitle: const Text('اختيار صورة بطاقة محفوظة'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source != null) await _pickImage(isFront, source);
  }

  void _calculateCheckoutDate() {
    if (_checkInDate != null && _daysController.text.isNotEmpty) {
      final days = int.tryParse(_daysController.text);
      if (days != null && days > 0) {
        setState(() {
          final tempDate = _checkInDate!.add(Duration(days: days));
          _checkOutDate = DateTime(
            tempDate.year,
            tempDate.month,
            tempDate.day,
            8,
            0,
          ); // Default to 8 AM
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: isCheckIn
          ? DateTime.now()
          : (_checkInDate ?? DateTime.now()),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (pickedDate != null) {
      if (!context.mounted) return;

      final pickedTime = await showTimePicker(
        context: context,
        initialTime: isCheckIn
            ? TimeOfDay.now()
            : const TimeOfDay(hour: 8, minute: 0),
      );

      if (pickedTime != null) {
        final finalDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() {
          if (isCheckIn) {
            _checkInDate = finalDateTime;
            _calculateCheckoutDate();
          } else {
            _checkOutDate = finalDateTime;
          }
        });
      }
    }
  }

  double _calculateNetAmount() {
    final total = double.tryParse(_totalPriceController.text.replaceAll(',', '')) ?? 0;
    final commissionVal = double.tryParse(_commissionController.text.replaceAll(',', '')) ?? 0;
    if (_commissionType == 'fixed') {
      return total - commissionVal;
    } else if (_commissionType == 'percentage') {
      return total - (total * (commissionVal / 100));
    }
    return total;
  }

  void _submit() {
    if (_formKey.currentState!.validate() &&
        _checkInDate != null &&
        _checkOutDate != null &&
        _selectedApartmentId != null) {
      final args = (
        apartmentId: _selectedApartmentId!,
        guestName: _guestNameController.text.trim(),
        guestPhone: _guestPhoneController.text.trim(),
        checkInDate: _checkInDate!,
        checkOutDate: _checkOutDate!,
        totalPriceEgp: double.tryParse(_totalPriceController.text.replaceAll(',', '').trim()) ?? 0,
        amountPaidEgp: double.tryParse(_amountPaidController.text.replaceAll(',', '').trim()) ?? 0,
        paymentMethod: _paymentMethod,
        brokerId: _selectedBrokerId == 'other' ? null : _selectedBrokerId,
        brokerName: _selectedBrokerId == 'other'
            ? _brokerNameController.text.trim()
            : null,
        brokerCommissionType: _commissionType,
        brokerCommissionFixedEgp: _commissionType == 'fixed'
            ? (double.tryParse(_commissionController.text.replaceAll(',', '')) ?? 0.0)
            : 0.0,
        brokerCommissionPercentage: _commissionType == 'percentage'
            ? (double.tryParse(_commissionController.text.replaceAll(',', '')) ?? 10.0)
            : 10.0,
        nationalId: _nationalIdController.text.trim().isEmpty
            ? null
            : _nationalIdController.text.trim(),
        idFrontImage: _idFrontImage?.path,
        idBackImage: _idBackImage?.path,
      );
      if (widget.bookingId == null) {
        ref
            .read(bookingsControllerProvider.notifier)
            .addBooking(
              apartmentId: args.apartmentId,
              guestName: args.guestName,
              guestPhone: args.guestPhone,
              checkInDate: args.checkInDate,
              checkOutDate: args.checkOutDate,
              totalPriceEgp: args.totalPriceEgp,
              amountPaidEgp: args.amountPaidEgp,
              paymentMethod: args.paymentMethod,
              brokerId: args.brokerId,
              brokerName: args.brokerName,
              brokerCommissionType: args.brokerCommissionType,
              brokerCommissionFixedEgp: args.brokerCommissionFixedEgp,
              brokerCommissionPercentage: args.brokerCommissionPercentage,
              nationalId: args.nationalId,
              idFrontImage: args.idFrontImage,
              idBackImage: args.idBackImage,
            );
      } else {
        ref
            .read(bookingsControllerProvider.notifier)
            .updateBooking(
              id: widget.bookingId!,
              apartmentId: args.apartmentId,
              guestName: args.guestName,
              guestPhone: args.guestPhone,
              checkInDate: args.checkInDate,
              checkOutDate: args.checkOutDate,
              totalPriceEgp: args.totalPriceEgp,
              amountPaidEgp: args.amountPaidEgp,
              paymentMethod: args.paymentMethod,
              brokerId: args.brokerId,
              brokerName: args.brokerName,
              brokerCommissionType: args.brokerCommissionType,
              brokerCommissionFixedEgp: args.brokerCommissionFixedEgp,
              brokerCommissionPercentage: args.brokerCommissionPercentage,
              nationalId: args.nationalId,
              idFrontImage: args.idFrontImage,
              idBackImage: args.idBackImage,
            );
      }
    } else if (_checkInDate == null ||
        _checkOutDate == null ||
        _selectedApartmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء التأكد من التواريخ واختيار الشقة'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controllerState = ref.watch(bookingsControllerProvider);
    final buildingsAsync = ref.watch(buildingsProvider);
    final apartmentsAsync = ref.watch(apartmentsProvider);
    final brokersAsync = ref.watch(brokersProvider);
    final bookingsAsync = ref.watch(summerBookingsProvider);
    final theme = Theme.of(context);

    ref.listen<AsyncValue<void>>(bookingsControllerProvider, (_, state) {
      state.whenOrNull(
        data: (_) {
          if (widget.bookingId != null) {
            context.go('/summer_bookings/details/${widget.bookingId}');
          } else {
            context.go('/summer_bookings/list');
          }
        },
        error: (error, _) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString()))),
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.bookingId == null ? 'إضافة حجز صيفي' : 'تعديل الحجز',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (widget.bookingId != null) {
              context.go('/summer_bookings/details/${widget.bookingId}');
            } else {
              context.go('/summer_bookings/list');
            }
          },
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            if (widget.bookingId != null)
              bookingsAsync.when(
                data: (bookings) {
                  if (!_prefilled) {
                    final matches = bookings
                        .where((b) => b.id == widget.bookingId)
                        .toList();
                    if (matches.isNotEmpty) {
                      final b = matches.first;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted || _prefilled) return;
                        setState(() {
                          _prefilled = true;
                          _selectedApartmentId = b.apartmentId;
                          _guestNameController.text = b.guestName;
                          _guestPhoneController.text = b.guestPhone ?? '';
                          _checkInDate = b.checkInDate;
                          _checkOutDate = b.checkOutDate;
                          _daysController.text = b.checkOutDate
                              .difference(b.checkInDate)
                              .inDays
                              .toString();
                          _totalPriceController.text = b.totalPriceEgp
                              .toString();
                          _amountPaidController.text = b.amountPaidEgp
                              .toString();
                          _paymentMethod = b.paymentMethod;
                          _selectedBrokerId = b.brokerName != null
                              ? 'other'
                              : b.brokerId;
                          _brokerNameController.text = b.brokerName ?? '';
                          _commissionType = b.brokerCommissionType;
                          _commissionController.text =
                              b.brokerCommissionType == 'fixed'
                              ? b.brokerCommissionFixedEgp.toString()
                              : b.brokerCommissionPercentage.toString();
                          _nationalIdController.text = b.nationalId ?? '';
                          if (b.idFrontImage != null) {
                            _idFrontImage = File(b.idFrontImage!);
                          }
                          if (b.idBackImage != null) {
                            _idBackImage = File(b.idBackImage!);
                          }
                        });
                      });
                    }
                  }
                  return const SizedBox.shrink();
                },
                loading: () => const LinearProgressIndicator(),
                error: (error, stack) => const SizedBox.shrink(),
              ),
            buildingsAsync.when(
              data: (buildings) {
                if (buildings.isNotEmpty && _selectedBuildingId == null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted || _selectedBuildingId != null) return;
                    setState(() {
                      _selectedBuildingId = buildings.first.id;
                    });
                  });
                }
                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'اختر المبنى'),
                  value: _selectedBuildingId,
                  items: buildings
                      .map(
                        (b) =>
                            DropdownMenuItem(value: b.id, child: Text(b.name)),
                      )
                      .toList(),
                  onChanged: (v) {
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
                if (_selectedApartmentId != null &&
                    _selectedBuildingId == null) {
                  final matches = apartments
                      .where((a) => a.id == _selectedApartmentId)
                      .toList();
                  if (matches.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted || _selectedBuildingId != null) return;
                      setState(
                        () => _selectedBuildingId = matches.first.buildingId,
                      );
                    });
                  }
                }
                final filteredApts = _selectedBuildingId != null
                    ? apartments
                          .where((a) => a.buildingId == _selectedBuildingId)
                          .toList()
                    : apartments;

                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'اختر الشقة'),
                  value: _selectedApartmentId,
                  items: filteredApts
                      .map(
                        (a) => DropdownMenuItem(
                          value: a.id,
                          child: Text('شقة ${a.apartmentNumber}'),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedApartmentId = v),
                  validator: (v) => v == null ? 'مطلوب' : null,
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (e, st) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _guestNameController,
              decoration: const InputDecoration(labelText: 'اسم الضيف'),
              validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _guestPhoneController,
              decoration: const InputDecoration(labelText: 'رقم الهاتف'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nationalIdController,
              decoration: const InputDecoration(
                labelText: 'الرقم القومي (اختياري)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showImageSourceSheet(true),
                    icon: const Icon(Icons.camera_alt),
                    label: Text(
                      _idFrontImage != null
                          ? 'تم التقاط الأمام'
                          : 'بطاقة (أمام)',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _idFrontImage != null
                          ? Colors.green
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showImageSourceSheet(false),
                    icon: const Icon(Icons.camera_alt),
                    label: Text(
                      _idBackImage != null ? 'تم التقاط الخلف' : 'بطاقة (خلف)',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _idBackImage != null
                          ? Colors.green
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ListTile(
                    title: const Text('تاريخ الدخول'),
                    subtitle: Text(
                      _checkInDate != null
                          ? DateFormat(
                              'EEEE yyyy-MM-dd hh:mm a',
                              'ar',
                            ).format(_checkInDate!)
                          : 'اختر التاريخ',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context, true),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: theme.dividerColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _daysController,
                    decoration: const InputDecoration(labelText: 'عدد الأيام'),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _calculateCheckoutDate(),
                    validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                  ),
                ),
              ],
            ),
            if (_checkOutDate != null) ...[
              const SizedBox(height: 8),
              Text(
                'تاريخ الخروج: ${DateFormat('EEEE yyyy-MM-dd hh:mm a', 'ar').format(_checkOutDate!)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.green,
                ),
              ),
              if (_checkInDate!.isAfter(DateTime.now())) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: const Text(
                    'حجز مستقبلي',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
            const Divider(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _totalPriceController,
                    decoration: const InputDecoration(
                      labelText: 'السعر الإجمالي (ج.م)',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [CurrencyInputFormatter()],
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'مطلوب';
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _amountPaidController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      labelText:
                          _totalPriceController.text.isNotEmpty &&
                              _amountPaidController.text ==
                                  _totalPriceController.text
                          ? 'المبلغ المدفوع بالكامل'
                          : 'المبلغ المدفوع (العربون)',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [CurrencyInputFormatter()],
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'مطلوب';
                      final paid = double.tryParse(v.replaceAll(',', '')) ?? 0;
                      final total =
                          double.tryParse(_totalPriceController.text.replaceAll(',', '')) ?? 0;
                      if (paid > total) {
                        return 'العربون أكبر من الإجمالي';
                      }
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'طريقة الدفع'),
              initialValue: _paymentMethod,
              items: const [
                DropdownMenuItem(value: 'cash', child: Text('نقدي (كاش)')),
                DropdownMenuItem(
                  value: 'vodafone_cash',
                  child: Text('فودافون كاش'),
                ),
                DropdownMenuItem(value: 'instapay', child: Text('إنستاباي')),
              ],
              onChanged: (v) => setState(() => _paymentMethod = v!),
            ),
            const Divider(height: 32),
            brokersAsync.when(
              data: (brokers) {
                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'السمسار'),
                  value: _selectedBrokerId,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('بدون سمسار'),
                    ),
                    ...brokers.map(
                      (b) => DropdownMenuItem(
                        value: b.id,
                        child: Text(b.fullName ?? b.email),
                      ),
                    ),
                    const DropdownMenuItem(
                      value: 'other',
                      child: Text('سمسار آخر (غير مسجل)'),
                    ),
                  ],
                  onChanged: (v) {
                    setState(() {
                      _selectedBrokerId = v;
                      if (v == null) _commissionType = 'none';
                    });
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, st) => const SizedBox.shrink(),
            ),
            if (_selectedBrokerId == 'other') ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _brokerNameController,
                decoration: const InputDecoration(labelText: 'اسم السمسار'),
                validator: (v) =>
                    _selectedBrokerId == 'other' && (v == null || v.isEmpty)
                    ? 'مطلوب'
                    : null,
              ),
            ],
            if (_selectedBrokerId != null) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'نوع العمولة'),
                initialValue: _commissionType,
                items: const [
                  DropdownMenuItem(value: 'none', child: Text('بدون عمولة')),
                  DropdownMenuItem(
                    value: 'percentage',
                    child: Text('نسبة مئوية (%)'),
                  ),
                  DropdownMenuItem(value: 'fixed', child: Text('مبلغ ثابت')),
                ],
                onChanged: (v) => setState(() {
                  _commissionType = v!;
                  _commissionController.clear();
                }),
              ),
            ],
            if (_commissionType != 'none' && _selectedBrokerId != null) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _commissionController,
                decoration: InputDecoration(
                  labelText: _commissionType == 'percentage'
                      ? 'النسبة (%)'
                      : 'المبلغ (ج.م)',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: _commissionType == 'fixed' ? [CurrencyInputFormatter()] : [],
                onChanged: (_) => setState(() {}),
                validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'الصافي بعد العمولة:',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                    Text(
                      '${_calculateNetAmount().toCurrencyFormat()} ج.م',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: controllerState.isLoading ? null : _submit,
              child: controllerState.isLoading
                  ? const CircularProgressIndicator()
                  : Text(
                      widget.bookingId == null ? 'حفظ الحجز' : 'حفظ التعديل',
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
