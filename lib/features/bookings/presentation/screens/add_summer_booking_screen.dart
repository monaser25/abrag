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
  final _amountCashController = TextEditingController();
  final _amountVodafoneCashController = TextEditingController();
  final _amountInstapayController = TextEditingController();
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
      if (mounted) {
        setState(() {
          _occupiedApartmentIds = occupiedIds;
        });
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
                                trailing: StatusChip(
                                  label: '$guestBookingsCount حجوزات',
                                  kind: StatusChipKind.brand,
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

        if (selectedBooking.idFrontImage != null &&
            selectedBooking.idFrontImage!.isNotEmpty &&
            File(selectedBooking.idFrontImage!).existsSync()) {
          _idFrontImage = File(selectedBooking.idFrontImage!);
        }
        if (selectedBooking.idBackImage != null &&
            selectedBooking.idBackImage!.isNotEmpty &&
            File(selectedBooking.idBackImage!).existsSync()) {
          _idBackImage = File(selectedBooking.idBackImage!);
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
      'days': _daysController.text,
      'commission': _commissionController.text,
      'nationalId': _nationalIdController.text,
      'brokerName': _brokerNameController.text,
      'checkInDate': _checkInDate?.toIso8601String(),
      'checkOutDate': _checkOutDate?.toIso8601String(),
      'paymentMethod': _paymentMethod,
      'commissionType': _commissionType,
      'selectedApartmentId': _selectedApartmentId,
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
            : const TimeOfDay(hour: 14, minute: 0);
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
    if (_formKey.currentState!.validate() &&
        _checkInDate != null &&
        _checkOutDate != null &&
        _selectedApartmentId != null) {
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

      if (widget.bookingId == null) {
        cashAmt =
            double.tryParse(
              _amountCashController.text.replaceAll(',', '').trim(),
            ) ??
            0;
        vodaAmt =
            double.tryParse(
              _amountVodafoneCashController.text.replaceAll(',', '').trim(),
            ) ??
            0;
        instaAmt =
            double.tryParse(
              _amountInstapayController.text.replaceAll(',', '').trim(),
            ) ??
            0;
        totalPaid = cashAmt + vodaAmt + instaAmt;

        if (vodaAmt > cashAmt && vodaAmt >= instaAmt) {
          dominantMethod = 'vodafone_cash';
        } else if (instaAmt > cashAmt && instaAmt > vodaAmt) {
          dominantMethod = 'instapay';
        } else {
          dominantMethod = 'cash';
        }
      } else {
        totalPaid =
            double.tryParse(
              _amountPaidController.text.replaceAll(',', '').trim(),
            ) ??
            0;
        dominantMethod = _paymentMethod;
      }

      final args = (
        apartmentId: _selectedApartmentId!,
        guestName: _guestNameController.text.trim(),
        guestPhone: _guestPhoneController.text.trim(),
        checkInDate: _checkInDate!,
        checkOutDate: _checkOutDate!,
        totalPriceEgp:
            double.tryParse(
              _totalPriceController.text.replaceAll(',', '').trim(),
            ) ??
            0,
        amountPaidEgp: totalPaid,
        paymentMethod: dominantMethod,
        paymentBreakdown: widget.bookingId == null
            ? {'cash': cashAmt, 'vodafone_cash': vodaAmt, 'instapay': instaAmt}
            : const <String, double>{},
        brokerId: finalBrokerId,
        brokerName: finalBrokerName,
        brokerCommissionType: _commissionType,
        brokerCommissionFixedEgp: _commissionType == 'fixed'
            ? (double.tryParse(
                    _commissionController.text.replaceAll(',', ''),
                  ) ??
                  0.0)
            : 0.0,
        brokerCommissionPercentage: _commissionType == 'percentage'
            ? (double.tryParse(
                    _commissionController.text.replaceAll(',', ''),
                  ) ??
                  10.0)
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
              paymentBreakdown: args.paymentBreakdown,
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
    final bookingsAsync = ref.watch(allSummerBookingsProvider);
    final colors = context.colors;

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
                          _nationalIdController.text = b.nationalId ?? '';
                          if (b.idFrontImage != null) {
                            _idFrontImage = File(b.idFrontImage!);
                          }
                          if (b.idBackImage != null) {
                            _idBackImage = File(b.idBackImage!);
                          }
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
                var filteredApts = _selectedBuildingId != null
                    ? apartments
                          .where((a) => a.buildingId == _selectedBuildingId)
                          .toList()
                    : apartments.toList();

                if (_checkInDate != null && _checkOutDate != null) {
                  filteredApts = filteredApts.where((a) {
                    if (a.id == _selectedApartmentId) return true;
                    return !_occupiedApartmentIds.contains(a.id);
                  }).toList();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'رقم الهاتف',
                    prefixIcon: Icons.phone_outlined,
                    controller: _guestPhoneController,
                    keyboardType: TextInputType.phone,
                    validator: _optionalEgyptianPhoneValidator,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    label: 'الرقم القومي (اختياري)',
                    prefixIcon: Icons.badge_outlined,
                    controller: _nationalIdController,
                    keyboardType: TextInputType.number,
                    validator: _optionalNationalIdValidator,
                  ),
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
                      _idFrontImage != null
                          ? 'تم التقاط الأمام'
                          : 'بطاقة (أمام)',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _idFrontImage != null ? colors.ok : null,
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
                      foregroundColor: _idBackImage != null ? colors.ok : null,
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
                    onChanged: (_) => _calculateCheckoutDate(),
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
                    if (_checkInDate!.isAfter(DateTime.now())) ...[
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
                  if (widget.bookingId == null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'المبلغ المدفوع (العربون)',
                      style: AppTextStyles.label.copyWith(color: colors.ink2),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'مدفوع كاش',
                            controller: _amountCashController,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
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
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AppTextField(
                            label: 'مدفوع فودافون كاش',
                            controller: _amountVodafoneCashController,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
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
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AppTextField(
                            label: 'مدفوع إنستاباي',
                            controller: _amountInstapayController,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
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
                        ),
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
                      if (v == null) _commissionType = 'none';
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
