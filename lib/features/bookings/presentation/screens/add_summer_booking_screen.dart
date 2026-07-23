import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/config/app_settings_provider.dart';
import '../../../../core/config/shared_prefs_provider.dart';
import '../../../../core/database/database.dart';
import '../../../../shared/widgets/widgets.dart';
import '../providers/bookings_controller.dart';
import '../providers/bookings_provider.dart';
import '../../../buildings/presentation/providers/buildings_controller.dart';
import '../../../apartments/presentation/providers/apartments_controller.dart';
import '../../../apartments/presentation/providers/apartment_occupancy_rules_provider.dart';
import '../../../users/presentation/providers/users_provider.dart';

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

class AddSummerBookingScreen extends ConsumerStatefulWidget {
  final String? bookingId;
  final String? initialApartmentId;

  const AddSummerBookingScreen({
    super.key,
    this.bookingId,
    this.initialApartmentId,
  });

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
  final _amountCashController = TextEditingController();
  final _amountVodafoneCashController = TextEditingController();
  final _amountInstapayController = TextEditingController();
  final _commissionPaidCashController = TextEditingController();
  final _commissionPaidVodafoneController = TextEditingController();
  final _commissionPaidInstapayController = TextEditingController();
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
  String? _existingIdFrontPath;
  String? _existingIdBackPath;
  String? _selectedApartmentId;
  Set<String> _selectedApartmentIds = {};
  String? _selectedBuildingId;
  String? _selectedBrokerId;
  bool _prefilled = false;
  bool _commissionPaymentEdited = false;
  bool _commissionPaymentPrefillScheduled = false;
  bool _initialApartmentSelectionApplied = false;
  Set<String> _occupiedApartmentIds = {};
  static const _draftKey = 'summer_booking_draft_v1';

  Future<void> _refreshOccupiedApartments() async {
    if (_checkInDate != null && _checkOutDate != null) {
      final occupancyRules = ref.read(apartmentOccupancyRulesProvider);
      final occupiedIds = await occupancyRules.occupiedApartmentIdsForPeriod(
        checkInDate: _checkInDate!,
        checkOutDate: _checkOutDate!,
        excludingSummerBookingId: widget.bookingId,
      );
      final selectedOccupiedIds = widget.bookingId == null
          ? _selectedApartmentIds.intersection(occupiedIds)
          : <String>{};
      if (mounted) {
        setState(() {
          _occupiedApartmentIds = occupiedIds;
          if (widget.bookingId == null) {
            _selectedApartmentIds.removeWhere(occupiedIds.contains);
          }
        });
        if (selectedOccupiedIds.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'بعض الشقق أصبحت محجوزة في هذه الفترة وتم استبعادها من الاختيار',
              ),
            ),
          );
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _occupiedApartmentIds = {};
        });
      }
    }
  }

  @override
  void dispose() {
    _guestNameController.dispose();
    _guestPhoneController.dispose();
    _totalPriceController.dispose();
    _amountPaidController.dispose();
    _amountCashController.dispose();
    _amountVodafoneCashController.dispose();
    _amountInstapayController.dispose();
    _commissionPaidCashController.dispose();
    _commissionPaidVodafoneController.dispose();
    _commissionPaidInstapayController.dispose();
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
          _existingIdFrontPath = null;
        } else {
          _idBackImage = savedImage;
          _existingIdBackPath = null;
        }
      });
    }
  }

  bool get _hasIdFrontImage =>
      _idFrontImage != null || (_existingIdFrontPath?.isNotEmpty ?? false);

  bool get _hasIdBackImage =>
      _idBackImage != null || (_existingIdBackPath?.isNotEmpty ?? false);

  void _prefillStoredIdImage({required bool isFront, String? path}) {
    final storedPath = path?.trim();
    File? localImage;
    String? existingPath;
    if (storedPath != null && storedPath.isNotEmpty) {
      if (storedPath.startsWith('http')) {
        existingPath = storedPath;
      } else {
        final file = File(storedPath);
        if (file.existsSync()) localImage = file;
      }
    }

    if (isFront) {
      _idFrontImage = localImage;
      _existingIdFrontPath = existingPath;
    } else {
      _idBackImage = localImage;
      _existingIdBackPath = existingPath;
    }
  }

  void _applyInitialApartmentSelection(List<Apartment> apartments) {
    if (widget.bookingId != null || _initialApartmentSelectionApplied) return;
    final apartmentId = widget.initialApartmentId;
    if (apartmentId == null || apartmentId.isEmpty) return;

    final matches = apartments.where((a) => a.id == apartmentId).toList();
    if (matches.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _initialApartmentSelectionApplied) return;
      if (_selectedApartmentIds.isNotEmpty) {
        _initialApartmentSelectionApplied = true;
        return;
      }

      final apartment = matches.first;
      setState(() {
        _initialApartmentSelectionApplied = true;
        _selectedApartmentId = apartment.id;
        _selectedApartmentIds.add(apartment.id);
        _selectedBuildingId = apartment.buildingId;
      });
    });
  }

  Future<void> _showPreviousGuestPicker(List<SummerBooking> bookings) async {
    if (bookings.isEmpty) {
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        builder: (context) => const SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: EmptyState(
              icon: Icons.person_off_outlined,
              title: 'لا يوجد عملاء سابقين',
            ),
          ),
        ),
      );
      return;
    }

    final Map<String, SummerBooking> latestBookingPerGuest = {};
    for (final b in bookings) {
      final name = b.guestName.trim();
      if (name.isEmpty) continue;

      final existing = latestBookingPerGuest[name];
      if (existing == null || b.checkInDate.isAfter(existing.checkInDate)) {
        latestBookingPerGuest[name] = b;
      }
    }

    final uniqueGuests = latestBookingPerGuest.values.toList();
    uniqueGuests.sort((a, b) => b.checkInDate.compareTo(a.checkInDate));

    if (uniqueGuests.isEmpty) {
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        builder: (context) => const SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: EmptyState(
              icon: Icons.person_off_outlined,
              title: 'لا يوجد عملاء سابقين',
            ),
          ),
        ),
      );
      return;
    }

    final selectedBooking = await showModalBottomSheet<SummerBooking>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setState) {
            final filteredGuests = uniqueGuests.where((b) {
              final q = searchQuery.toLowerCase();
              final nameMatch = b.guestName.toLowerCase().contains(q);
              final phoneMatch = (b.guestPhone ?? '').toLowerCase().contains(q);
              return nameMatch || phoneMatch;
            }).toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) => Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: AppTextField(
                      label: 'بحث بالاسم أو رقم الهاتف',
                      prefixIcon: Icons.search,
                      onChanged: (val) =>
                          setState(() => searchQuery = val.trim()),
                    ),
                  ),
                  Expanded(
                    child: filteredGuests.isEmpty
                        ? const EmptyState(
                            icon: Icons.search_off,
                            title: 'لا توجد نتائج',
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: filteredGuests.length,
                            itemBuilder: (context, index) {
                              final b = filteredGuests[index];
                              final guestBookingsCount = bookings
                                  .where(
                                    (x) =>
                                        x.guestName.trim() ==
                                        b.guestName.trim(),
                                  )
                                  .length;
                              return ListTile(
                                leading: AppAvatar(name: b.guestName, size: 40),
                                title: Text(b.guestName),
                                subtitle: Text(
                                  b.guestPhone?.isNotEmpty == true
                                      ? b.guestPhone!
                                      : 'لا يوجد رقم هاتف',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if ((b.idFrontImage != null &&
                                            b.idFrontImage!.isNotEmpty) ||
                                        (b.idBackImage != null &&
                                            b.idBackImage!.isNotEmpty)) ...[
                                      const StatusChip(
                                        label: 'بطاقة',
                                        kind: StatusChipKind.ok,
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    StatusChip(
                                      label: '$guestBookingsCount حجوزات',
                                      kind: StatusChipKind.brand,
                                    ),
                                  ],
                                ),
                                onTap: () => Navigator.pop(context, b),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (selectedBooking != null && mounted) {
      setState(() {
        _guestNameController.text = selectedBooking.guestName;
        _guestPhoneController.text = selectedBooking.guestPhone ?? '';
        _nationalIdController.text = selectedBooking.nationalId ?? '';

        _prefillStoredIdImage(
          isFront: true,
          path: selectedBooking.idFrontImage,
        );
        _prefillStoredIdImage(
          isFront: false,
          path: selectedBooking.idBackImage,
        );
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
        final settings = ref.read(appSettingsProvider).value ?? {};
        final checkoutHour =
            (settings['summer_checkout_hour'] as num?)?.toInt() ?? 8;
        final checkoutMinute =
            (settings['summer_checkout_minute'] as num?)?.toInt() ?? 0;
        setState(() {
          final tempDate = _checkInDate!.add(Duration(days: days));
          _checkOutDate = DateTime(
            tempDate.year,
            tempDate.month,
            tempDate.day,
            checkoutHour,
            checkoutMinute,
          );
        });
        _refreshOccupiedApartments();
      }
    }
  }

  Future<void> _saveDraft() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final draft = {
      'guestName': _guestNameController.text,
      'guestPhone': _guestPhoneController.text,
      'totalPrice': _totalPriceController.text,
      'amountPaid': _amountPaidController.text,
      'amountCash': _amountCashController.text,
      'amountVodafoneCash': _amountVodafoneCashController.text,
      'amountInstapay': _amountInstapayController.text,
      'commissionPaidCash': _commissionPaidCashController.text,
      'commissionPaidVodafone': _commissionPaidVodafoneController.text,
      'commissionPaidInstapay': _commissionPaidInstapayController.text,
      'days': _daysController.text,
      'commission': _commissionController.text,
      'nationalId': _nationalIdController.text,
      'brokerName': _brokerNameController.text,
      'checkInDate': _checkInDate?.toIso8601String(),
      'checkOutDate': _checkOutDate?.toIso8601String(),
      'paymentMethod': _paymentMethod,
      'commissionType': _commissionType,
      'selectedApartmentId': widget.bookingId == null
          ? (_selectedApartmentIds.length == 1
                ? _selectedApartmentIds.first
                : null)
          : _selectedApartmentId,
      'selectedApartmentIds': _selectedApartmentIds.toList(),
      'selectedBuildingId': _selectedBuildingId,
      'selectedBrokerId': _selectedBrokerId,
    };
    await prefs.setString(_draftKey, jsonEncode(draft));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم حفظ الحجز كمسودة')));
  }

  Future<void> _loadDraft() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final raw = prefs.getString(_draftKey);
    if (raw == null || raw.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تحميل مسودة؟'),
        content: const Text('يوجد حجز محفوظ كمسودة. هل تريد تحميله؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('لا'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('تحميل'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final draft = jsonDecode(raw) as Map<String, dynamic>;
    setState(() {
      _guestNameController.text = draft['guestName']?.toString() ?? '';
      _guestPhoneController.text = draft['guestPhone']?.toString() ?? '';
      _totalPriceController.text = draft['totalPrice']?.toString() ?? '';
      _amountPaidController.text = draft['amountPaid']?.toString() ?? '';
      _amountCashController.text = draft['amountCash']?.toString() ?? '';
      _amountVodafoneCashController.text =
          draft['amountVodafoneCash']?.toString() ?? '';
      _amountInstapayController.text =
          draft['amountInstapay']?.toString() ?? '';
      _commissionPaidCashController.text =
          draft['commissionPaidCash']?.toString() ?? '';
      _commissionPaidVodafoneController.text =
          draft['commissionPaidVodafone']?.toString() ?? '';
      _commissionPaidInstapayController.text =
          draft['commissionPaidInstapay']?.toString() ?? '';
      _commissionPaymentEdited = draft.containsKey('commissionPaidCash');
      _daysController.text = draft['days']?.toString() ?? '';
      _commissionController.text = draft['commission']?.toString() ?? '';
      _nationalIdController.text = draft['nationalId']?.toString() ?? '';
      _brokerNameController.text = draft['brokerName']?.toString() ?? '';
      _checkInDate = DateTime.tryParse(draft['checkInDate']?.toString() ?? '');
      _checkOutDate = DateTime.tryParse(
        draft['checkOutDate']?.toString() ?? '',
      );
      _paymentMethod = draft['paymentMethod']?.toString() ?? 'cash';
      _commissionType = draft['commissionType']?.toString() ?? 'none';
      _selectedApartmentId = draft['selectedApartmentId']?.toString();
      final rawSelectedApartmentIds = draft['selectedApartmentIds'];
      if (rawSelectedApartmentIds is List) {
        _selectedApartmentIds = rawSelectedApartmentIds
            .map((id) => id.toString())
            .where((id) => id.isNotEmpty)
            .toSet();
      }
      if (widget.bookingId == null &&
          _selectedApartmentIds.isEmpty &&
          _selectedApartmentId != null) {
        _selectedApartmentIds = {_selectedApartmentId!};
      }
      _selectedBuildingId = draft['selectedBuildingId']?.toString();
      _selectedBrokerId = draft['selectedBrokerId']?.toString();
    });
    _refreshOccupiedApartments();
  }

  Future<void> _clearDraft() async {
    await ref.read(sharedPreferencesProvider).remove(_draftKey);
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: isCheckIn
          ? (_checkInDate ?? DateTime.now())
          : (_checkOutDate ?? DateTime.now()),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (pickedDate != null) {
      if (!context.mounted) return;

      final settings = ref.read(appSettingsProvider).value ?? {};
      final checkoutHour =
          (settings['summer_checkout_hour'] as num?)?.toInt() ?? 8;
      final checkoutMinute =
          (settings['summer_checkout_minute'] as num?)?.toInt() ?? 0;

      final TimeOfDay defaultTime;
      if (isCheckIn) {
        defaultTime = _checkInDate != null
            ? TimeOfDay.fromDateTime(_checkInDate!)
            : TimeOfDay.now();
      } else {
        defaultTime = _checkOutDate != null
            ? TimeOfDay.fromDateTime(_checkOutDate!)
            : TimeOfDay(hour: checkoutHour, minute: checkoutMinute);
      }

      final pickedTime = await showTimePicker(
        context: context,
        initialTime: defaultTime,
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
        _refreshOccupiedApartments();
      }
    }
  }

  double _calculateNetAmount() {
    final total =
        double.tryParse(_totalPriceController.text.replaceAll(',', '')) ?? 0;
    final commissionVal =
        double.tryParse(_commissionController.text.replaceAll(',', '')) ?? 0;
    if (_commissionType == 'fixed') {
      return total - commissionVal;
    } else if (_commissionType == 'percentage') {
      return total - (total * (commissionVal / 100));
    }
    return total;
  }

  double _parseCurrencyText(String text) {
    return double.tryParse(text.replaceAll(',', '').trim()) ?? 0;
  }

  double _commissionAmountValue() {
    final total = _parseCurrencyText(_totalPriceController.text);
    final val = _parseCurrencyText(_commissionController.text);
    if (_commissionType == 'fixed') return val;
    if (_commissionType == 'percentage') return total * val / 100;
    return 0;
  }

  bool get _commissionPaymentFieldsAreEmpty =>
      _commissionPaidCashController.text.trim().isEmpty &&
      _commissionPaidVodafoneController.text.trim().isEmpty &&
      _commissionPaidInstapayController.text.trim().isEmpty;

  bool get _canPrefillCommissionPayment =>
      // Only auto-fill on NEW bookings. On edit, legacy bookings (created before
      // this feature) have empty paid fields on purpose; prefilling cash there
      // would silently move the commission out of its real payment-method pool
      // on save. Empty fields fall back to the booking's primary method.
      widget.bookingId == null &&
      !_commissionPaymentEdited &&
      !_commissionPaymentPrefillScheduled &&
      _selectedBrokerId != null &&
      _commissionType != 'none' &&
      _commissionPaymentFieldsAreEmpty &&
      _commissionAmountValue() > 0;

  void _scheduleCommissionPaymentPrefill() {
    if (!_canPrefillCommissionPayment) return;
    _commissionPaymentPrefillScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _applyCommissionPaymentPrefill(),
    );
  }

  void _applyCommissionPaymentPrefill() {
    _commissionPaymentPrefillScheduled = false;
    if (!mounted || !_canPrefillCommissionPayment) return;
    setState(() {
      _commissionPaidCashController.text = _commissionAmountValue()
          .toCurrencyFormat();
    });
  }

  void _clearCommissionPaymentFields() {
    _commissionPaidCashController.clear();
    _commissionPaidVodafoneController.clear();
    _commissionPaidInstapayController.clear();
    _commissionPaymentEdited = false;
  }

  String _splitPreviewText() {
    final count = _selectedApartmentIds.length;
    final total = _parseCurrencyText(_totalPriceController.text);
    final parts = splitAmountExactly(total, count);
    final firstPart = parts.first.toCurrencyFormat();
    final lastPart = parts.last.toCurrencyFormat();
    if (parts.first == parts.last) {
      return 'هيتقسم على $count شقق - نصيب الشقة $firstPart ج.م';
    }
    return 'هيتقسم على $count شقق - نصيب الشقة $firstPart ج.م، وآخر شقة $lastPart ج.م';
  }

  String? _optionalEgyptianPhoneValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    if (!RegExp(r'^\d{11}$').hasMatch(text)) {
      return 'رقم الهاتف لازم يكون 11 رقم';
    }
    return null;
  }

  String? _optionalNationalIdValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    if (!RegExp(r'^\d{14}$').hasMatch(text)) {
      return 'الرقم القومي لازم يكون 14 رقم';
    }
    return null;
  }

  Future<void> _submit() async {
    final isAddMode = widget.bookingId == null;
    final hasApartment = isAddMode
        ? _selectedApartmentIds.isNotEmpty
        : _selectedApartmentId != null;

    if (_formKey.currentState!.validate() &&
        _checkInDate != null &&
        _checkOutDate != null &&
        hasApartment) {
      String? finalBrokerId = _selectedBrokerId == 'other'
          ? null
          : _selectedBrokerId;
      String? finalBrokerName = _selectedBrokerId == 'other'
          ? _brokerNameController.text.trim()
          : null;

      if (_selectedBrokerId == 'other' &&
          _brokerNameController.text.trim().isNotEmpty) {
        try {
          finalBrokerId = await ref
              .read(brokersControllerProvider.notifier)
              .findOrCreateBrokerByName(_brokerNameController.text.trim());
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('خطأ في إضافة السمسار: $e')));
          return;
        }
      }

      double cashAmt = 0;
      double vodaAmt = 0;
      double instaAmt = 0;
      double totalPaid = 0;
      String dominantMethod = 'cash';

      if (isAddMode) {
        cashAmt = _parseCurrencyText(_amountCashController.text);
        vodaAmt = _parseCurrencyText(_amountVodafoneCashController.text);
        instaAmt = _parseCurrencyText(_amountInstapayController.text);
        totalPaid = cashAmt + vodaAmt + instaAmt;

        if (vodaAmt > cashAmt && vodaAmt >= instaAmt) {
          dominantMethod = 'vodafone_cash';
        } else if (instaAmt > cashAmt && instaAmt > vodaAmt) {
          dominantMethod = 'instapay';
        } else {
          dominantMethod = 'cash';
        }
      } else {
        totalPaid = _parseCurrencyText(_amountPaidController.text);
        dominantMethod = _paymentMethod;
      }

      final guestName = _guestNameController.text.trim();
      final guestPhone = _guestPhoneController.text.trim();
      final totalPriceEgp = _parseCurrencyText(_totalPriceController.text);
      final brokerCommissionFixedEgp = _commissionType == 'fixed'
          ? _parseCurrencyText(_commissionController.text)
          : 0.0;
      final brokerCommissionPercentage = _commissionType == 'percentage'
          ? _parseCurrencyText(_commissionController.text)
          : 10.0;
      final hasBrokerCommission =
          _commissionType != 'none' && _selectedBrokerId != null;
      final brokerCommissionPaidCashEgp = hasBrokerCommission
          ? _parseCurrencyText(_commissionPaidCashController.text)
          : 0.0;
      final brokerCommissionPaidVodafoneEgp = hasBrokerCommission
          ? _parseCurrencyText(_commissionPaidVodafoneController.text)
          : 0.0;
      final brokerCommissionPaidInstapayEgp = hasBrokerCommission
          ? _parseCurrencyText(_commissionPaidInstapayController.text)
          : 0.0;
      final nationalId = _nationalIdController.text.trim().isEmpty
          ? null
          : _nationalIdController.text.trim();

      if (isAddMode) {
        ref
            .read(bookingsControllerProvider.notifier)
            .addBookingsForApartments(
              apartmentIds: _selectedApartmentIds.toList(),
              guestName: guestName,
              guestPhone: guestPhone,
              checkInDate: _checkInDate!,
              checkOutDate: _checkOutDate!,
              totalPriceEgp: totalPriceEgp,
              amountPaidEgp: totalPaid,
              paymentMethod: dominantMethod,
              paymentBreakdown: {
                'cash': cashAmt,
                'vodafone_cash': vodaAmt,
                'instapay': instaAmt,
              },
              brokerId: finalBrokerId,
              brokerName: finalBrokerName,
              brokerCommissionType: _commissionType,
              brokerCommissionFixedEgp: brokerCommissionFixedEgp,
              brokerCommissionPercentage: brokerCommissionPercentage,
              brokerCommissionPaidCashEgp: brokerCommissionPaidCashEgp,
              brokerCommissionPaidVodafoneEgp: brokerCommissionPaidVodafoneEgp,
              brokerCommissionPaidInstapayEgp: brokerCommissionPaidInstapayEgp,
              nationalId: nationalId,
              idFrontImage: _idFrontImage?.path ?? _existingIdFrontPath,
              idBackImage: _idBackImage?.path ?? _existingIdBackPath,
            );
      } else {
        ref
            .read(bookingsControllerProvider.notifier)
            .updateBooking(
              id: widget.bookingId!,
              apartmentId: _selectedApartmentId!,
              guestName: guestName,
              guestPhone: guestPhone,
              checkInDate: _checkInDate!,
              checkOutDate: _checkOutDate!,
              totalPriceEgp: totalPriceEgp,
              amountPaidEgp: totalPaid,
              paymentMethod: dominantMethod,
              brokerId: finalBrokerId,
              brokerName: finalBrokerName,
              brokerCommissionType: _commissionType,
              brokerCommissionFixedEgp: brokerCommissionFixedEgp,
              brokerCommissionPercentage: brokerCommissionPercentage,
              brokerCommissionPaidCashEgp: brokerCommissionPaidCashEgp,
              brokerCommissionPaidVodafoneEgp: brokerCommissionPaidVodafoneEgp,
              brokerCommissionPaidInstapayEgp: brokerCommissionPaidInstapayEgp,
              nationalId: nationalId,
              idFrontImage: _idFrontImage?.path ?? _existingIdFrontPath,
              idBackImage: _idBackImage?.path ?? _existingIdBackPath,
            );
      }
    } else if (_checkInDate == null || _checkOutDate == null || !hasApartment) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            !hasApartment
                ? 'اختر شقة واحدة على الأقل'
                : 'الرجاء التأكد من التواريخ واختيار الشقة',
          ),
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
    final bookingsAsync = ref.watch(allSummerBookingsProvider);
    final colors = context.colors;
    final totalPriceValue = _parseCurrencyText(_totalPriceController.text);
    final stayDays = int.tryParse(_daysController.text) ?? 0;
    final perDayPrice = totalPriceValue > 0 && stayDays > 0
        ? totalPriceValue / stayDays
        : null;
    final commissionAmount = _commissionAmountValue();
    final enteredCommissionPaid =
        _parseCurrencyText(_commissionPaidCashController.text) +
        _parseCurrencyText(_commissionPaidVodafoneController.text) +
        _parseCurrencyText(_commissionPaidInstapayController.text);
    final commissionPaymentMismatch =
        (enteredCommissionPaid - commissionAmount).abs() > 1;
    _scheduleCommissionPaymentPrefill();

    ref.listen<AsyncValue<void>>(bookingsControllerProvider, (_, state) {
      state.whenOrNull(
        data: (_) {
          _clearDraft();
          if (context.canPop()) {
            context.pop();
          } else if (widget.bookingId != null) {
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

    return AppScaffold(
      appBar: AbragAppBar(
        title: widget.bookingId == null ? 'إضافة حجز صيفي' : 'تعديل الحجز',
        showBack: true,
        onBack: () {
          if (context.canPop()) {
            context.pop();
          } else if (widget.bookingId != null) {
            context.go('/summer_bookings/details/${widget.bookingId}');
          } else {
            context.go('/summer_bookings/list');
          }
        },
        actions: [
          AppIconButton(
            tooltip: 'تحميل مسودة',
            onPressed: widget.bookingId == null ? _loadDraft : null,
            icon: Icons.restore_page,
          ),
          AppIconButton(
            tooltip: 'حفظ كمسودة',
            onPressed: widget.bookingId == null ? _saveDraft : null,
            icon: Icons.save_as,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
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
                          _commissionPaidCashController.text =
                              b.brokerCommissionPaidCashEgp > 0
                              ? b.brokerCommissionPaidCashEgp.toCurrencyFormat()
                              : '';
                          _commissionPaidVodafoneController.text =
                              b.brokerCommissionPaidVodafoneEgp > 0
                              ? b.brokerCommissionPaidVodafoneEgp
                                    .toCurrencyFormat()
                              : '';
                          _commissionPaidInstapayController.text =
                              b.brokerCommissionPaidInstapayEgp > 0
                              ? b.brokerCommissionPaidInstapayEgp
                                    .toCurrencyFormat()
                              : '';
                          _nationalIdController.text = b.nationalId ?? '';
                          _prefillStoredIdImage(
                            isFront: true,
                            path: b.idFrontImage,
                          );
                          _prefillStoredIdImage(
                            isFront: false,
                            path: b.idBackImage,
                          );
                        });
                        _refreshOccupiedApartments();
                      });
                    }
                  }
                  return const SizedBox.shrink();
                },
                loading: () => const LinearProgressIndicator(),
                error: (error, stack) => const SizedBox.shrink(),
              ),
            const SectionTitle(title: 'الشقة'),
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
                return AppDropdownField<String>(
                  label: 'اختر المبنى',
                  prefixIcon: Icons.apartment,
                  initialValue: _selectedBuildingId,
                  items: buildings
                      .map(
                        (b) =>
                            DropdownMenuItem(value: b.id, child: Text(b.name)),
                      )
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      _selectedBuildingId = v;
                      if (widget.bookingId == null) {
                        _selectedApartmentId = null;
                        _selectedApartmentIds.clear();
                      } else {
                        _selectedApartmentId = null;
                      }
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
                _applyInitialApartmentSelection(apartments);
                final isAddMode = widget.bookingId == null;
                final selectedApartmentForBuilding = isAddMode
                    ? (_selectedApartmentIds.length == 1
                          ? _selectedApartmentIds.first
                          : null)
                    : _selectedApartmentId;

                if (selectedApartmentForBuilding != null &&
                    _selectedBuildingId == null) {
                  final matches = apartments
                      .where((a) => a.id == selectedApartmentForBuilding)
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
                var filteredApts = _selectedBuildingId != null
                    ? apartments
                          .where((a) => a.buildingId == _selectedBuildingId)
                          .toList()
                    : apartments.toList();

                if (_checkInDate != null && _checkOutDate != null) {
                  filteredApts = filteredApts.where((a) {
                    if (!isAddMode && a.id == _selectedApartmentId) {
                      return true;
                    }
                    return !_occupiedApartmentIds.contains(a.id);
                  }).toList();
                }

                if (isAddMode && _selectedApartmentIds.isNotEmpty) {
                  final filteredIds = filteredApts.map((a) => a.id).toSet();
                  if (!_selectedApartmentIds.every(filteredIds.contains)) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      setState(() {
                        _selectedApartmentIds.removeWhere(
                          (id) => !filteredIds.contains(id),
                        );
                      });
                    });
                  }
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isAddMode)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'اختر الشقة',
                            style: AppTextStyles.label.copyWith(
                              color: colors.ink2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (filteredApts.isEmpty)
                            EmptyState(
                              icon: Icons.door_front_door_outlined,
                              title:
                                  _checkInDate == null || _checkOutDate == null
                                  ? 'اختر التواريخ أولًا'
                                  : 'لا توجد شقق متاحة',
                            )
                          else
                            AppCard(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Column(
                                children: filteredApts.map((a) {
                                  final selected = _selectedApartmentIds
                                      .contains(a.id);
                                  return CheckboxListTile(
                                    value: selected,
                                    dense: true,
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    title: Text('شقة ${a.apartmentNumber}'),
                                    onChanged: (checked) {
                                      setState(() {
                                        if (checked == true) {
                                          _selectedApartmentIds.add(a.id);
                                        } else {
                                          _selectedApartmentIds.remove(a.id);
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      )
                    else
                      AppDropdownField<String>(
                        label: 'اختر الشقة',
                        prefixIcon: Icons.door_front_door_outlined,
                        initialValue: _selectedApartmentId,
                        items: filteredApts
                            .map(
                              (a) => DropdownMenuItem(
                                value: a.id,
                                child: Text('شقة ${a.apartmentNumber}'),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedApartmentId = v),
                        validator: (v) => v == null ? 'مطلوب' : null,
                      ),
                    if (_checkInDate == null || _checkOutDate == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, right: 12),
                        child: Text(
                          'اختر تاريخ الدخول والخروج لعرض الشقق المتاحة فقط',
                          style: AppTextStyles.bodyS.copyWith(
                            color: colors.ink2,
                          ),
                        ),
                      ),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (e, st) => const SizedBox.shrink(),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(child: SectionTitle(title: 'بيانات الضيف')),
                if (widget.bookingId == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
                    child: OutlinedButton.icon(
                      onPressed: () => _showPreviousGuestPicker(
                        bookingsAsync.valueOrNull ?? const [],
                      ),
                      icon: const Icon(Icons.person_search, size: 18),
                      label: const Text('عميل سابق'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            AppTextField(
              label: 'اسم الضيف',
              prefixIcon: Icons.person_outline,
              controller: _guestNameController,
              validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  label: 'رقم الهاتف',
                  prefixIcon: Icons.phone_outlined,
                  controller: _guestPhoneController,
                  keyboardType: TextInputType.phone,
                  validator: _optionalEgyptianPhoneValidator,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'الرقم القومي (اختياري)',
                  prefixIcon: Icons.badge_outlined,
                  controller: _nationalIdController,
                  keyboardType: TextInputType.number,
                  validator: _optionalNationalIdValidator,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showImageSourceSheet(true),
                    icon: const Icon(Icons.camera_alt),
                    label: Text(
                      _hasIdFrontImage ? 'تم التقاط الأمام' : 'بطاقة (أمام)',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _hasIdFrontImage ? colors.ok : null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showImageSourceSheet(false),
                    icon: const Icon(Icons.camera_alt),
                    label: Text(
                      _hasIdBackImage ? 'تم التقاط الخلف' : 'بطاقة (خلف)',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _hasIdBackImage ? colors.ok : null,
                    ),
                  ),
                ),
              ],
            ),
            const SectionTitle(title: 'الإقامة'),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: AppDateField(
                    label: 'تاريخ الدخول',
                    value: _checkInDate != null
                        ? DateFormat(
                            'EEEE yyyy-MM-dd hh:mm a',
                            'ar',
                          ).format(_checkInDate!)
                        : null,
                    placeholder: 'اختر التاريخ',
                    onTap: () => _selectDate(context, true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: AppTextField(
                    label: 'عدد الأيام',
                    controller: _daysController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) {
                      setState(() {});
                      _calculateCheckoutDate();
                    },
                    validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                  ),
                ),
              ],
            ),
            if (_checkOutDate != null) ...[
              const SizedBox(height: 12),
              AppCard(
                color: colors.okSoft,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Icon(Icons.event_available, size: 18, color: colors.ok),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'تاريخ الخروج: ${DateFormat('EEEE yyyy-MM-dd hh:mm a', 'ar').format(_checkOutDate!)}',
                        style: AppTextStyles.bodyS.copyWith(color: colors.ink),
                      ),
                    ),
                    if (_checkInDate != null &&
                        _dateOnly(
                          _checkInDate!,
                        ).isAfter(_dateOnly(DateTime.now()))) ...[
                      const SizedBox(width: 8),
                      const StatusChip(
                        label: 'حجز مستقبلي',
                        kind: StatusChipKind.warn,
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SectionTitle(title: 'المبلغ والدفع'),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'السعر الإجمالي (ج.م)',
                          controller: _totalPriceController,
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
                      const SizedBox(width: 12),
                      if (widget.bookingId != null)
                        Expanded(
                          child: AppTextField(
                            label:
                                _totalPriceController.text.isNotEmpty &&
                                    _amountPaidController.text ==
                                        _totalPriceController.text
                                ? 'المبلغ المدفوع بالكامل'
                                : 'المبلغ المدفوع (العربون)',
                            controller: _amountPaidController,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [CurrencyInputFormatter()],
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'مطلوب';
                              final paid =
                                  double.tryParse(v.replaceAll(',', '')) ?? 0;
                              final total =
                                  double.tryParse(
                                    _totalPriceController.text.replaceAll(
                                      ',',
                                      '',
                                    ),
                                  ) ??
                                  0;
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
                  if (perDayPrice != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'سعر اليوم: ${perDayPrice.toCurrencyFormat()} ج.م',
                      style: AppTextStyles.bodyS.copyWith(color: colors.ink2),
                    ),
                  ],
                  if (widget.bookingId == null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'المبلغ المدفوع (العربون)',
                      style: AppTextStyles.label.copyWith(color: colors.ink2),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextField(
                          label: 'مدفوع كاش',
                          controller: _amountCashController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [CurrencyInputFormatter()],
                          validator: (v) {
                            final cash =
                                double.tryParse(
                                  (_amountCashController.text).replaceAll(
                                    ',',
                                    '',
                                  ),
                                ) ??
                                0;
                            final voda =
                                double.tryParse(
                                  (_amountVodafoneCashController.text)
                                      .replaceAll(',', ''),
                                ) ??
                                0;
                            final insta =
                                double.tryParse(
                                  (_amountInstapayController.text).replaceAll(
                                    ',',
                                    '',
                                  ),
                                ) ??
                                0;
                            final total =
                                double.tryParse(
                                  _totalPriceController.text.replaceAll(
                                    ',',
                                    '',
                                  ),
                                ) ??
                                0;
                            if (cash + voda + insta > total) {
                              return 'العربون أكبر من الإجمالي';
                            }
                            return null;
                          },
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          label: 'مدفوع فودافون كاش',
                          controller: _amountVodafoneCashController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [CurrencyInputFormatter()],
                          validator: (v) {
                            final cash =
                                double.tryParse(
                                  (_amountCashController.text).replaceAll(
                                    ',',
                                    '',
                                  ),
                                ) ??
                                0;
                            final voda =
                                double.tryParse(
                                  (_amountVodafoneCashController.text)
                                      .replaceAll(',', ''),
                                ) ??
                                0;
                            final insta =
                                double.tryParse(
                                  (_amountInstapayController.text).replaceAll(
                                    ',',
                                    '',
                                  ),
                                ) ??
                                0;
                            final total =
                                double.tryParse(
                                  _totalPriceController.text.replaceAll(
                                    ',',
                                    '',
                                  ),
                                ) ??
                                0;
                            if (cash + voda + insta > total) {
                              return 'العربون أكبر من الإجمالي';
                            }
                            return null;
                          },
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          label: 'مدفوع إنستاباي',
                          controller: _amountInstapayController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [CurrencyInputFormatter()],
                          validator: (v) {
                            final cash =
                                double.tryParse(
                                  (_amountCashController.text).replaceAll(
                                    ',',
                                    '',
                                  ),
                                ) ??
                                0;
                            final voda =
                                double.tryParse(
                                  (_amountVodafoneCashController.text)
                                      .replaceAll(',', ''),
                                ) ??
                                0;
                            final insta =
                                double.tryParse(
                                  (_amountInstapayController.text).replaceAll(
                                    ',',
                                    '',
                                  ),
                                ) ??
                                0;
                            final total =
                                double.tryParse(
                                  _totalPriceController.text.replaceAll(
                                    ',',
                                    '',
                                  ),
                                ) ??
                                0;
                            if (cash + voda + insta > total) {
                              return 'العربون أكبر من الإجمالي';
                            }
                            return null;
                          },
                          onChanged: (_) => setState(() {}),
                        ),
                        if (_selectedApartmentIds.length > 1) ...[
                          const SizedBox(height: 12),
                          Text(
                            _splitPreviewText(),
                            style: AppTextStyles.bodyS.copyWith(
                              color: colors.ink2,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                  if (widget.bookingId != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'طريقة الدفع',
                      style: AppTextStyles.label.copyWith(color: colors.ink2),
                    ),
                    const SizedBox(height: 8),
                    SegmentedTabs(
                      labels: const ['نقدي (كاش)', 'فودافون كاش', 'إنستاباي'],
                      index: _paymentMethod == 'vodafone_cash'
                          ? 1
                          : _paymentMethod == 'instapay'
                          ? 2
                          : 0,
                      onChanged: (i) => setState(
                        () => _paymentMethod = const [
                          'cash',
                          'vodafone_cash',
                          'instapay',
                        ][i],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SectionTitle(title: 'السمسار والعمولة'),
            brokersAsync.when(
              data: (brokers) {
                return AppDropdownField<String>(
                  label: 'السمسار',
                  prefixIcon: Icons.handshake_outlined,
                  initialValue: _selectedBrokerId,
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
                      if (v == null) {
                        _commissionType = 'none';
                        _commissionController.clear();
                        _clearCommissionPaymentFields();
                      }
                    });
                  },
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, st) => const SizedBox.shrink(),
            ),
            if (_selectedBrokerId == 'other') ...[
              const SizedBox(height: 16),
              AppTextField(
                label: 'اسم السمسار',
                prefixIcon: Icons.person_outline,
                controller: _brokerNameController,
                validator: (v) =>
                    _selectedBrokerId == 'other' && (v == null || v.isEmpty)
                    ? 'مطلوب'
                    : null,
              ),
            ],
            if (_selectedBrokerId != null) ...[
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppDropdownField<String>(
                      label: 'نوع العمولة',
                      initialValue: _commissionType,
                      items: const [
                        DropdownMenuItem(
                          value: 'none',
                          child: Text('بدون عمولة'),
                        ),
                        DropdownMenuItem(
                          value: 'percentage',
                          child: Text('نسبة مئوية (%)'),
                        ),
                        DropdownMenuItem(
                          value: 'fixed',
                          child: Text('مبلغ ثابت'),
                        ),
                      ],
                      onChanged: (v) => setState(() {
                        _commissionType = v!;
                        _commissionController.clear();
                        _clearCommissionPaymentFields();
                      }),
                    ),
                  ),
                  if (_commissionType != 'none') ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        label: _commissionType == 'percentage'
                            ? 'النسبة (%)'
                            : 'المبلغ (ج.م)',
                        controller: _commissionController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: _commissionType == 'fixed'
                            ? [CurrencyInputFormatter()]
                            : [],
                        onChanged: (_) => setState(() {}),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'مطلوب' : null,
                      ),
                    ),
                  ],
                ],
              ),
            ],
            if (_commissionType != 'none' && _selectedBrokerId != null) ...[
              const SizedBox(height: 16),
              AppCard(
                color: colors.accentSoft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'الصافي بعد العمولة:',
                      style: AppTextStyles.title.copyWith(color: colors.ink),
                    ),
                    Text(
                      '${_calculateNetAmount().toCurrencyFormat()} ج.م',
                      style: AppTextStyles.tabular(
                        AppTextStyles.h2.copyWith(color: colors.accent),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'طريقة دفع العمولة للسمسار',
                style: AppTextStyles.label.copyWith(color: colors.ink2),
              ),
              const SizedBox(height: 8),
              AppTextField(
                label: 'كاش',
                controller: _commissionPaidCashController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [CurrencyInputFormatter()],
                onChanged: (_) => setState(() {
                  _commissionPaymentEdited = true;
                }),
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'فودافون كاش',
                controller: _commissionPaidVodafoneController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [CurrencyInputFormatter()],
                onChanged: (_) => setState(() {
                  _commissionPaymentEdited = true;
                }),
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'إنستاباي',
                controller: _commissionPaidInstapayController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [CurrencyInputFormatter()],
                onChanged: (_) => setState(() {
                  _commissionPaymentEdited = true;
                }),
              ),
              const SizedBox(height: 8),
              Text(
                'العمولة: ${commissionAmount.toCurrencyFormat()} ج.م · المُدخل: ${enteredCommissionPaid.toCurrencyFormat()} ج.م',
                style: AppTextStyles.bodyS.copyWith(
                  color: commissionPaymentMismatch ? colors.warn : colors.ink2,
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        children: [
          Expanded(
            child: AppButton(
              label: widget.bookingId == null ? 'حفظ الحجز' : 'حفظ التعديل',
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
