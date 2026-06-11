import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../../../l10n/app_localizations.dart';
import '../../../../core/config/shared_prefs_provider.dart';
import '../providers/contracts_controller.dart';
import '../../../buildings/presentation/providers/buildings_controller.dart';
import '../../../apartments/presentation/providers/apartments_controller.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/widgets.dart';

import '../../../../core/database/database.dart';

class AddWinterContractScreen extends ConsumerStatefulWidget {
  final WinterContract? contract;

  const AddWinterContractScreen({super.key, this.contract});

  @override
  ConsumerState<AddWinterContractScreen> createState() =>
      _AddWinterContractScreenState();
}

class _AddWinterContractScreenState
    extends ConsumerState<AddWinterContractScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _studentNameController;
  late final TextEditingController _studentPhoneController;
  late final TextEditingController _universityController;
  late final TextEditingController _facultyController;
  late final TextEditingController _monthlyRentController;
  late final TextEditingController _depositController;
  late final TextEditingController _nationalIdController;

  // Roommate fields
  bool _hasRoommate = false;
  late final TextEditingController _roommateNameController;
  late final TextEditingController _roommateUniversityController;
  late final TextEditingController _roommateFacultyController;
  late final TextEditingController _roommateNationalIdController;
  File? _roommateIdFrontImage;
  File? _roommateIdBackImage;

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isElectricityOnStudent = true;
  bool _isGasOnStudent = true;
  bool _isWaterOnStudent = false;

  String _contractType = 'student'; // 'student' or 'family'

  String? _selectedBuildingId;
  String? _selectedApartmentId;

  File? _idFrontImage;
  File? _idBackImage;
  File? _contractFrontImage;
  File? _contractBackImage;

  List<String> _customUniversities = const [];
  List<String> _customFaculties = const [];

  static const _universitiesPrefsKey = 'winter_custom_universities';
  static const _facultiesPrefsKey = 'winter_custom_faculties';

  @override
  void initState() {
    super.initState();
    final c = widget.contract;
    _studentNameController = TextEditingController(text: c?.studentName ?? '');
    _studentPhoneController = TextEditingController(text: c?.parentPhone ?? '');
    final academicInfo = _parseAcademicInfo(c?.university);
    _universityController = TextEditingController(text: academicInfo.$1);
    _facultyController = TextEditingController(text: academicInfo.$2);
    _monthlyRentController = TextEditingController(
      text: c?.monthlyRentEgp.toString() ?? '',
    );
    _depositController = TextEditingController(
      text: c?.depositEgp.toString() ?? '',
    );
    _nationalIdController = TextEditingController(text: c?.nationalId ?? '');

    _startDate = c?.startDate ?? DateTime.now();
    _endDate = c?.endDate ?? DateTime.now().add(const Duration(days: 30));
    _isElectricityOnStudent = c?.isElectricityOnStudent ?? true;
    _isGasOnStudent = c?.isGasOnStudent ?? true;
    _isWaterOnStudent = c?.isWaterOnStudent ?? false;
    _contractType = c?.contractType ?? 'student';
    _selectedApartmentId = c?.apartmentId;

    if (c?.idFrontImage != null) {
      _idFrontImage = File(c!.idFrontImage!);
    }
    if (c?.idBackImage != null) {
      _idBackImage = File(c!.idBackImage!);
    }
    if (c?.contractFrontImage != null) {
      _contractFrontImage = File(c!.contractFrontImage!);
    }
    if (c?.contractBackImage != null) {
      _contractBackImage = File(c!.contractBackImage!);
    }

    _roommateNameController = TextEditingController();
    _roommateUniversityController = TextEditingController();
    _roommateFacultyController = TextEditingController();
    _roommateNationalIdController = TextEditingController();

    if (c?.roommates != null && c!.roommates!.isNotEmpty) {
      try {
        final List<dynamic> roommates = jsonDecode(c.roommates!);
        if (roommates.isNotEmpty) {
          _hasRoommate = true;
          final rm = roommates.first;
          _roommateNameController.text = rm['name'] ?? '';
          final roommateAcademic = _parseAcademicInfo(
            rm['university']?.toString(),
          );
          _roommateUniversityController.text = roommateAcademic.$1;
          _roommateFacultyController.text = roommateAcademic.$2;
          _roommateNationalIdController.text = rm['nationalId'] ?? '';
          if (rm['idFrontImage'] != null) {
            _roommateIdFrontImage = File(rm['idFrontImage']);
          }
          if (rm['idBackImage'] != null) {
            _roommateIdBackImage = File(rm['idBackImage']);
          }
        }
      } catch (e) {
        // ignore
      }
    }

    _loadAcademicLists();
  }

  @override
  void dispose() {
    _studentNameController.dispose();
    _studentPhoneController.dispose();
    _universityController.dispose();
    _facultyController.dispose();
    _monthlyRentController.dispose();
    _depositController.dispose();
    _nationalIdController.dispose();
    _roommateNameController.dispose();
    _roommateUniversityController.dispose();
    _roommateFacultyController.dispose();
    _roommateNationalIdController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String target) async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('تصوير بالكاميرا'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('اختيار من المعرض'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = p.basename(pickedFile.path);
        final savedImage = await File(
          pickedFile.path,
        ).copy('${directory.path}/$fileName');

        setState(() {
          switch (target) {
            case 'idFront':
              _idFrontImage = savedImage;
              break;
            case 'idBack':
              _idBackImage = savedImage;
              break;
            case 'contractFront':
              _contractFrontImage = savedImage;
              break;
            case 'contractBack':
              _contractBackImage = savedImage;
              break;
            case 'roommateIdFront':
              _roommateIdFrontImage = savedImage;
              break;
            case 'roommateIdBack':
              _roommateIdBackImage = savedImage;
              break;
          }
        });
      }
    }
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
    if (_formKey.currentState!.validate() &&
        _startDate != null &&
        _endDate != null &&
        _selectedApartmentId != null) {
      String? roommatesJson;
      if (_contractType == 'student' &&
          _hasRoommate &&
          _roommateNameController.text.trim().isNotEmpty) {
        final roommateData = {
          'name': _roommateNameController.text.trim(),
          'university': _formatAcademicInfo(
            _roommateUniversityController.text,
            _roommateFacultyController.text,
          ),
          'faculty': _roommateFacultyController.text.trim(),
          'nationalId': _roommateNationalIdController.text.trim(),
          'idFrontImage': _roommateIdFrontImage?.path,
          'idBackImage': _roommateIdBackImage?.path,
        };
        roommatesJson = jsonEncode([roommateData]);
      }

      if (widget.contract == null) {
        ref
            .read(contractsControllerProvider.notifier)
            .addContract(
              apartmentId: _selectedApartmentId!,
              contractType: _contractType,
              studentName: _studentNameController.text.trim(),
              studentPhone: _studentPhoneController.text.trim(),
              university: _contractType == 'student'
                  ? _formatAcademicInfo(
                      _universityController.text,
                      _facultyController.text,
                    )
                  : null,
              startDate: _startDate!,
              endDate: _endDate!,
              monthlyRentEgp:
                  double.tryParse(
                    _monthlyRentController.text.replaceAll(',', '').trim(),
                  ) ??
                  0,
              depositEgp:
                  double.tryParse(
                    _depositController.text.replaceAll(',', '').trim(),
                  ) ??
                  0,
              isElectricityOnStudent: _isElectricityOnStudent,
              isGasOnStudent: _isGasOnStudent,
              isWaterOnStudent: _isWaterOnStudent,
              roommates: roommatesJson,
              nationalId: _nationalIdController.text.trim().isEmpty
                  ? null
                  : _nationalIdController.text.trim(),
              idFrontImage: _idFrontImage?.path,
              idBackImage: _idBackImage?.path,
              contractFrontImage: _contractFrontImage?.path,
              contractBackImage: _contractBackImage?.path,
            );
      } else {
        ref
            .read(contractsControllerProvider.notifier)
            .updateContract(
              id: widget.contract!.id,
              apartmentId: _selectedApartmentId!,
              contractType: _contractType,
              studentName: _studentNameController.text.trim(),
              studentPhone: _studentPhoneController.text.trim(),
              university: _contractType == 'student'
                  ? _formatAcademicInfo(
                      _universityController.text,
                      _facultyController.text,
                    )
                  : null,
              startDate: _startDate!,
              endDate: _endDate!,
              monthlyRentEgp:
                  double.tryParse(
                    _monthlyRentController.text.replaceAll(',', '').trim(),
                  ) ??
                  0,
              depositEgp:
                  double.tryParse(
                    _depositController.text.replaceAll(',', '').trim(),
                  ) ??
                  0,
              isElectricityOnStudent: _isElectricityOnStudent,
              isGasOnStudent: _isGasOnStudent,
              isWaterOnStudent: _isWaterOnStudent,
              roommates: roommatesJson,
              nationalId: _nationalIdController.text.trim().isEmpty
                  ? null
                  : _nationalIdController.text.trim(),
              idFrontImage: _idFrontImage?.path,
              idBackImage: _idBackImage?.path,
              contractFrontImage: _contractFrontImage?.path,
              contractBackImage: _contractBackImage?.path,
            );
      }
    } else if (_startDate == null ||
        _endDate == null ||
        _selectedApartmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء التأكد من التواريخ واختيار الشقة'),
        ),
      );
    }
  }

  (String, String) _parseAcademicInfo(String? value) {
    if (value == null || value.trim().isEmpty) return ('', '');
    final text = value.trim();
    if (text.contains(' - ')) {
      final parts = text.split(' - ');
      return (parts.first.trim(), parts.skip(1).join(' - ').trim());
    }
    if (text.contains('|')) {
      final parts = text.split('|');
      return (parts.first.trim(), parts.skip(1).join('|').trim());
    }
    return (text, '');
  }

  String _formatAcademicInfo(String university, String faculty) {
    final cleanUniversity = university.trim();
    final cleanFaculty = faculty.trim();
    if (cleanUniversity.isEmpty) return cleanFaculty;
    if (cleanFaculty.isEmpty) return cleanUniversity;
    return '$cleanUniversity - $cleanFaculty';
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

  void _loadAcademicLists() {
    final prefs = ref.read(sharedPreferencesProvider);
    setState(() {
      _customUniversities = prefs.getStringList(_universitiesPrefsKey) ?? [];
      _customFaculties = prefs.getStringList(_facultiesPrefsKey) ?? [];
    });
  }

  Future<void> _saveAcademicLists() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setStringList(_universitiesPrefsKey, _customUniversities);
    await prefs.setStringList(_facultiesPrefsKey, _customFaculties);
  }

  List<String> _optionsWithCurrent(
    List<String> options,
    TextEditingController controller,
  ) {
    final values = {...options};
    final current = controller.text.trim();
    if (current.isNotEmpty) values.add(current);
    return values.toList()..sort();
  }

  Future<void> _showAddAcademicOptionDialog({
    required String title,
    required String label,
    required List<String> currentOptions,
    required ValueChanged<List<String>> onSaved,
    TextEditingController? targetController,
  }) async {
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: label),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
    final cleanValue = value?.trim();
    if (cleanValue == null || cleanValue.isEmpty) return;
    final nextOptions = {...currentOptions, cleanValue}.toList()..sort();
    setState(() {
      onSaved(nextOptions);
      targetController?.text = cleanValue;
    });
    await _saveAcademicLists();
  }

  Future<void> _deleteAcademicOption({
    required String value,
    required List<String> currentOptions,
    required ValueChanged<List<String>> onSaved,
    required List<TextEditingController> controllers,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف من القائمة'),
        content: Text('هل تريد حذف "$value"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final nextOptions = currentOptions.where((item) => item != value).toList();
    setState(() {
      onSaved(nextOptions);
      for (final controller in controllers) {
        if (controller.text == value) controller.clear();
      }
    });
    await _saveAcademicLists();
  }

  Widget _customAcademicDropdown({
    required TextEditingController controller,
    required List<String> options,
    required String label,
    required String addTitle,
    required String addLabel,
    required ValueChanged<List<String>> onSaved,
    required List<TextEditingController> linkedControllers,
  }) {
    final allOptions = _optionsWithCurrent(options, controller);
    final selectedValue = allOptions.contains(controller.text.trim())
        ? controller.text.trim()
        : null;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AppDropdownField<String>(
            label: label,
            prefixIcon: Icons.school_outlined,
            initialValue: selectedValue,
            helperText: allOptions.isEmpty
                ? 'اضغط + لإضافة أول اختيار'
                : 'اختياراتك المخصصة فقط',
            items: allOptions
                .map(
                  (option) =>
                      DropdownMenuItem(value: option, child: Text(option)),
                )
                .toList(),
            onChanged: (value) => setState(() => controller.text = value ?? ''),
          ),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(top: 26),
          child: AppIconButton(
            tooltip: 'إضافة',
            onPressed: () => _showAddAcademicOptionDialog(
              title: addTitle,
              label: addLabel,
              currentOptions: options,
              onSaved: onSaved,
              targetController: controller,
            ),
            icon: Icons.add,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 26),
          child: AppIconButton(
            tooltip: 'حذف الاختيار الحالي',
            onPressed:
                selectedValue == null || !options.contains(selectedValue)
                ? null
                : () => _deleteAcademicOption(
                    value: selectedValue,
                    currentOptions: options,
                    onSaved: onSaved,
                    controllers: linkedControllers,
                  ),
            icon: Icons.delete_outline,
          ),
        ),
      ],
    );
  }

  _NationalIdInfo? _nationalIdInfo(String value) {
    final nationalId = value.trim();
    if (!RegExp(r'^\d{14}$').hasMatch(nationalId)) return null;
    final centuryDigit = nationalId.substring(0, 1);
    final century = centuryDigit == '2'
        ? 1900
        : centuryDigit == '3'
        ? 2000
        : null;
    if (century == null) return null;
    final year = century + int.parse(nationalId.substring(1, 3));
    final month = int.parse(nationalId.substring(3, 5));
    final day = int.parse(nationalId.substring(5, 7));
    final governorateCode = nationalId.substring(7, 9);
    final governorate = _governorates[governorateCode] ?? 'غير معروف';
    final genderDigit = int.parse(nationalId.substring(12, 13));
    final gender = genderDigit.isOdd ? 'ذكر' : 'أنثى';
    try {
      final birthDate = DateTime(year, month, day);
      return _NationalIdInfo(
        birthDate: birthDate,
        governorate: governorate,
        gender: gender,
      );
    } catch (_) {
      return null;
    }
  }

  static const Map<String, String> _governorates = {
    '01': 'القاهرة',
    '02': 'الإسكندرية',
    '03': 'بورسعيد',
    '04': 'السويس',
    '11': 'دمياط',
    '12': 'الدقهلية',
    '13': 'الشرقية',
    '14': 'القليوبية',
    '15': 'كفر الشيخ',
    '16': 'الغربية',
    '17': 'المنوفية',
    '18': 'البحيرة',
    '19': 'الإسماعيلية',
    '21': 'الجيزة',
    '22': 'بني سويف',
    '23': 'الفيوم',
    '24': 'المنيا',
    '25': 'أسيوط',
    '26': 'سوهاج',
    '27': 'قنا',
    '28': 'أسوان',
    '29': 'الأقصر',
    '31': 'البحر الأحمر',
    '32': 'الوادي الجديد',
    '33': 'مطروح',
    '34': 'شمال سيناء',
    '35': 'جنوب سيناء',
    '88': 'خارج الجمهورية',
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controllerState = ref.watch(contractsControllerProvider);
    final buildingsAsync = ref.watch(buildingsProvider);
    final apartmentsAsync = ref.watch(apartmentsProvider);

    ref.listen<AsyncValue<void>>(contractsControllerProvider, (_, state) {
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
    });

    final colors = context.colors;

    return AppScaffold(
      appBar: AbragAppBar(title: l10n.addContract),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const SectionTitle(title: 'الشقة والعقد'),
            buildingsAsync.when(
              data: (buildings) {
                if (buildings.isNotEmpty && _selectedBuildingId == null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      _selectedBuildingId = buildings.first.id;
                    });
                  });
                }
                return AppDropdownField<String>(
                  label: l10n.buildings,
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: apartmentsAsync.when(
                    data: (apartments) {
                      final filteredApts = _selectedBuildingId != null
                          ? apartments
                                .where(
                                  (a) => a.buildingId == _selectedBuildingId,
                                )
                                .toList()
                          : apartments;

                      return AppDropdownField<String>(
                        label: l10n.apartments,
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
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (e, st) => const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppDropdownField<String>(
                    label: 'نوع العقد',
                    initialValue: _contractType,
                    items: const [
                      DropdownMenuItem(
                        value: 'student',
                        child: Text('عقد طلبة (مغتربين)'),
                      ),
                      DropdownMenuItem(
                        value: 'family',
                        child: Text('عقد أسرة'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => _contractType = v);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SectionTitle(title: 'بيانات المستأجر'),
            AppTextField(
              label: _contractType == 'student'
                  ? l10n.studentName
                  : 'اسم المستأجر (رب الأسرة)',
              prefixIcon: Icons.person_outline,
              controller: _studentNameController,
              validator: (v) =>
                  v == null || v.isEmpty ? l10n.requiredField : null,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'رقم الهاتف',
              prefixIcon: Icons.phone_outlined,
              controller: _studentPhoneController,
              keyboardType: TextInputType.phone,
              validator: _optionalEgyptianPhoneValidator,
            ),
            if (_contractType == 'student') ...[
              const SizedBox(height: 16),
              _customAcademicDropdown(
                controller: _universityController,
                options: _customUniversities,
                label: 'الجامعة',
                addTitle: 'إضافة جامعة',
                addLabel: 'اسم الجامعة',
                onSaved: (values) => _customUniversities = values,
                linkedControllers: [
                  _universityController,
                  _roommateUniversityController,
                ],
              ),
              const SizedBox(height: 16),
              _customAcademicDropdown(
                controller: _facultyController,
                options: _customFaculties,
                label: 'الكلية',
                addTitle: 'إضافة كلية',
                addLabel: 'اسم الكلية',
                onSaved: (values) => _customFaculties = values,
                linkedControllers: [
                  _facultyController,
                  _roommateFacultyController,
                ],
              ),
              if (_customUniversities.isEmpty || _customFaculties.isEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'القوائم مخصصة لك فقط. استخدم زر + لإضافة الجامعات والكليات التي تتعامل معها.',
                  style: AppTextStyles.caption.copyWith(color: colors.ink3),
                ),
              ],
            ],
            const SectionTitle(title: 'مدة العقد والمبالغ'),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppDateField(
                    label: l10n.checkInDate,
                    value: _startDate?.toString().split(' ')[0],
                    placeholder: l10n.selectDate,
                    onTap: () => _selectDate(context, true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppDateField(
                    label: l10n.checkOutDate,
                    value: _endDate?.toString().split(' ')[0],
                    placeholder: l10n.selectDate,
                    onTap: () => _selectDate(context, false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(
                    label: l10n.monthlyRent,
                    prefixIcon: Icons.payments_outlined,
                    controller: _monthlyRentController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [CurrencyInputFormatter()],
                    validator: (v) =>
                        v == null || v.isEmpty ? l10n.requiredField : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    label: l10n.deposit,
                    prefixIcon: Icons.shield_outlined,
                    controller: _depositController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [CurrencyInputFormatter()],
                  ),
                ),
              ],
            ),
            if (_contractType == 'student') ...[
              const SectionTitle(title: 'زميل السكن'),
              AppSwitchRow(
                title: 'إضافة بيانات زميل سكن',
                icon: Icons.group_outlined,
                value: _hasRoommate,
                onChanged: (val) => setState(() => _hasRoommate = val),
              ),
              if (_hasRoommate) ...[
                const SizedBox(height: 12),
                AppCard(
                  color: colors.surface2,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextField(
                          label: 'اسم الزميل',
                          prefixIcon: Icons.person_outline,
                          controller: _roommateNameController,
                        ),
                        const SizedBox(height: 8),
                        _customAcademicDropdown(
                          controller: _roommateUniversityController,
                          options: _customUniversities,
                          label: 'جامعة الزميل',
                          addTitle: 'إضافة جامعة',
                          addLabel: 'اسم الجامعة',
                          onSaved: (values) => _customUniversities = values,
                          linkedControllers: [
                            _universityController,
                            _roommateUniversityController,
                          ],
                        ),
                        const SizedBox(height: 8),
                        _customAcademicDropdown(
                          controller: _roommateFacultyController,
                          options: _customFaculties,
                          label: 'كلية الزميل',
                          addTitle: 'إضافة كلية',
                          addLabel: 'اسم الكلية',
                          onSaved: (values) => _customFaculties = values,
                          linkedControllers: [
                            _facultyController,
                            _roommateFacultyController,
                          ],
                        ),
                        if (_customUniversities.isEmpty ||
                            _customFaculties.isEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'أضف اختياراتك من زر + ثم اختار منها.',
                            style: AppTextStyles.caption
                                .copyWith(color: colors.ink3),
                          ),
                        ],
                        const SizedBox(height: 8),
                        AppTextField(
                          label: 'الرقم القومي للزميل',
                          prefixIcon: Icons.badge_outlined,
                          controller: _roommateNationalIdController,
                          keyboardType: TextInputType.number,
                          validator: _optionalNationalIdValidator,
                          onChanged: (_) => setState(() {}),
                        ),
                        _NationalIdInfoCard(
                          info: _nationalIdInfo(
                            _roommateNationalIdController.text,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _pickImage('roommateIdFront'),
                                icon: const Icon(Icons.camera_alt),
                                label: Text(
                                  _roommateIdFrontImage != null
                                      ? 'تم الأمام'
                                      : 'بطاقة الزميل (أمام)',
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _roommateIdFrontImage != null
                                      ? colors.ok
                                      : null,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _pickImage('roommateIdBack'),
                                icon: const Icon(Icons.camera_alt),
                                label: Text(
                                  _roommateIdBackImage != null
                                      ? 'تم الخلف'
                                      : 'بطاقة الزميل (خلف)',
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _roommateIdBackImage != null
                                      ? colors.ok
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                  ),
                ),
              ],
            ],
            const SectionTitle(title: 'الهوية والمستندات'),
            AppTextField(
              label: 'الرقم القومي (المستأجر الأساسي)',
              prefixIcon: Icons.badge_outlined,
              controller: _nationalIdController,
              keyboardType: TextInputType.number,
              validator: _optionalNationalIdValidator,
              onChanged: (_) => setState(() {}),
            ),
            _NationalIdInfoCard(
              info: _nationalIdInfo(_nationalIdController.text),
            ),
            const SizedBox(height: 16),
            Text(
              'صور بطاقة المستأجر الأساسي:',
              style: AppTextStyles.label.copyWith(color: colors.ink2),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage('idFront'),
                    icon: const Icon(Icons.camera_alt),
                    label: Text(
                      _idFrontImage != null
                          ? 'تم التقاط الأمام'
                          : 'بطاقة (أمام)',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _idFrontImage != null
                          ? colors.ok
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage('idBack'),
                    icon: const Icon(Icons.camera_alt),
                    label: Text(
                      _idBackImage != null ? 'تم التقاط الخلف' : 'بطاقة (خلف)',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _idBackImage != null
                          ? colors.ok
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'صور العقد:',
              style: AppTextStyles.label.copyWith(color: colors.ink2),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage('contractFront'),
                    icon: const Icon(Icons.camera_alt),
                    label: Text(
                      _contractFrontImage != null
                          ? 'تم العقد (أمام)'
                          : 'عقد (أمام)',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _contractFrontImage != null
                          ? colors.ok
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage('contractBack'),
                    icon: const Icon(Icons.camera_alt),
                    label: Text(
                      _contractBackImage != null
                          ? 'تم العقد (خلف)'
                          : 'عقد (خلف)',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _contractBackImage != null
                          ? colors.ok
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            const SectionTitle(title: 'المرافق'),
            AppSwitchRow(
              title: 'الكهرباء على الطالب',
              icon: Icons.bolt_outlined,
              tint: colors.warn,
              value: _isElectricityOnStudent,
              onChanged: (val) => setState(() => _isElectricityOnStudent = val),
            ),
            const SizedBox(height: 8),
            AppSwitchRow(
              title: 'الغاز على الطالب',
              icon: Icons.local_fire_department_outlined,
              tint: colors.summer,
              value: _isGasOnStudent,
              onChanged: (val) => setState(() => _isGasOnStudent = val),
            ),
            const SizedBox(height: 8),
            AppSwitchRow(
              title: 'المياه على الطالب',
              icon: Icons.water_drop_outlined,
              tint: colors.winter,
              value: _isWaterOnStudent,
              onChanged: (val) => setState(() => _isWaterOnStudent = val),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        children: [
          Expanded(
            child: AppButton(
              label: l10n.save,
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

class _NationalIdInfo {
  final DateTime birthDate;
  final String governorate;
  final String gender;

  const _NationalIdInfo({
    required this.birthDate,
    required this.governorate,
    required this.gender,
  });

  String get birthDateLabel => birthDate.toLocal().toString().split(' ')[0];

  int get age {
    final today = DateTime.now();
    var years = today.year - birthDate.year;
    final birthdayThisYear = DateTime(
      today.year,
      birthDate.month,
      birthDate.day,
    );
    if (today.isBefore(birthdayThisYear)) years--;
    return years;
  }
}

class _NationalIdInfoCard extends StatelessWidget {
  final _NationalIdInfo? info;

  const _NationalIdInfoCard({required this.info});

  @override
  Widget build(BuildContext context) {
    if (info == null) return const SizedBox.shrink();
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: colors.brandSoft,
          border: Border.all(
            color: colors.brand.withValues(alpha: 0.25),
          ),
        ),
        child: Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _IdChip(label: 'تاريخ الميلاد', value: info!.birthDateLabel),
            _IdChip(label: 'العمر', value: '${info!.age} سنة'),
            _IdChip(label: 'النوع', value: info!.gender),
            _IdChip(label: 'المحافظة', value: info!.governorate),
          ],
        ),
      ),
    );
  }
}

class _IdChip extends StatelessWidget {
  final String label;
  final String value;

  const _IdChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: colors.ink3),
        ),
        Text(
          value,
          style: AppTextStyles.label.copyWith(color: colors.ink),
        ),
      ],
    );
  }
}
