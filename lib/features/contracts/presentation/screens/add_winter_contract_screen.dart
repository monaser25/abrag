import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../../../l10n/app_localizations.dart';
import '../providers/contracts_controller.dart';
import '../providers/contracts_provider.dart';
import '../../../buildings/presentation/providers/buildings_controller.dart';
import '../../../apartments/presentation/providers/apartments_controller.dart';
import '../../../../core/utils/currency_formatter.dart';

import '../../../../core/database/database.dart';

class AddWinterContractScreen extends ConsumerStatefulWidget {
  final WinterContract? contract;

  const AddWinterContractScreen({super.key, this.contract});

  @override
  ConsumerState<AddWinterContractScreen> createState() => _AddWinterContractScreenState();
}

class _AddWinterContractScreenState extends ConsumerState<AddWinterContractScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _studentNameController;
  late final TextEditingController _studentPhoneController;
  late final TextEditingController _universityController; // acts as University and Faculty
  late final TextEditingController _monthlyRentController;
  late final TextEditingController _depositController;
  late final TextEditingController _nationalIdController;
  
  // Roommate fields
  bool _hasRoommate = false;
  late final TextEditingController _roommateNameController;
  late final TextEditingController _roommateUniversityController;
  late final TextEditingController _roommateNationalIdController;
  File? _roommateIdFrontImage;
  File? _roommateIdBackImage;

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isElectricityOnStudent = true;
  bool _isGasOnStudent = false;
  bool _isWaterOnStudent = false;
  
  String _contractType = 'student'; // 'student' or 'family'
  
  String? _selectedBuildingId;
  String? _selectedApartmentId;
  
  File? _idFrontImage;
  File? _idBackImage;
  File? _contractFrontImage;
  File? _contractBackImage;

  @override
  void initState() {
    super.initState();
    final c = widget.contract;
    _studentNameController = TextEditingController(text: c?.studentName ?? '');
    _studentPhoneController = TextEditingController(text: c?.parentPhone ?? '');
    _universityController = TextEditingController(text: c?.university ?? '');
    _monthlyRentController = TextEditingController(text: c?.monthlyRentEgp.toString() ?? '');
    _depositController = TextEditingController(text: c?.depositEgp.toString() ?? '');
    _nationalIdController = TextEditingController(text: c?.nationalId ?? '');
    
    _startDate = c?.startDate ?? DateTime.now();
    _endDate = c?.endDate ?? DateTime.now().add(const Duration(days: 30));
    _isElectricityOnStudent = c?.isElectricityOnStudent ?? true;
    _isGasOnStudent = c?.isGasOnStudent ?? false;
    _isWaterOnStudent = c?.isWaterOnStudent ?? false;
    _contractType = c?.contractType ?? 'student';
    _selectedApartmentId = c?.apartmentId;

    if (c?.idFrontImage != null) _idFrontImage = File(c!.idFrontImage!);
    if (c?.idBackImage != null) _idBackImage = File(c!.idBackImage!);
    if (c?.contractFrontImage != null) _contractFrontImage = File(c!.contractFrontImage!);
    if (c?.contractBackImage != null) _contractBackImage = File(c!.contractBackImage!);

    _roommateNameController = TextEditingController();
    _roommateUniversityController = TextEditingController();
    _roommateNationalIdController = TextEditingController();

    if (c?.roommates != null && c!.roommates!.isNotEmpty) {
      try {
        final List<dynamic> roommates = jsonDecode(c.roommates!);
        if (roommates.isNotEmpty) {
          _hasRoommate = true;
          final rm = roommates.first;
          _roommateNameController.text = rm['name'] ?? '';
          _roommateUniversityController.text = rm['university'] ?? '';
          _roommateNationalIdController.text = rm['nationalId'] ?? '';
          if (rm['idFrontImage'] != null) _roommateIdFrontImage = File(rm['idFrontImage']);
          if (rm['idBackImage'] != null) _roommateIdBackImage = File(rm['idBackImage']);
        }
      } catch (e) {
        // ignore
      }
    }
  }

  @override
  void dispose() {
    _studentNameController.dispose();
    _studentPhoneController.dispose();
    _universityController.dispose();
    _monthlyRentController.dispose();
    _depositController.dispose();
    _nationalIdController.dispose();
    _roommateNameController.dispose();
    _roommateUniversityController.dispose();
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
        final savedImage = await File(pickedFile.path).copy('${directory.path}/$fileName');
        
        setState(() {
          switch (target) {
            case 'idFront': _idFrontImage = savedImage; break;
            case 'idBack': _idBackImage = savedImage; break;
            case 'contractFront': _contractFrontImage = savedImage; break;
            case 'contractBack': _contractBackImage = savedImage; break;
            case 'roommateIdFront': _roommateIdFrontImage = savedImage; break;
            case 'roommateIdBack': _roommateIdBackImage = savedImage; break;
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
    if (_formKey.currentState!.validate() && _startDate != null && _endDate != null && _selectedApartmentId != null) {
      String? roommatesJson;
      if (_contractType == 'student' && _hasRoommate && _roommateNameController.text.trim().isNotEmpty) {
        final roommateData = {
          'name': _roommateNameController.text.trim(),
          'university': _roommateUniversityController.text.trim(),
          'nationalId': _roommateNationalIdController.text.trim(),
          'idFrontImage': _roommateIdFrontImage?.path,
          'idBackImage': _roommateIdBackImage?.path,
        };
        roommatesJson = jsonEncode([roommateData]);
      }

      if (widget.contract == null) {
        ref.read(contractsControllerProvider.notifier).addContract(
          apartmentId: _selectedApartmentId!,
          contractType: _contractType,
          studentName: _studentNameController.text.trim(),
          studentPhone: _studentPhoneController.text.trim(),
          university: _contractType == 'student' ? _universityController.text.trim() : null,
          startDate: _startDate!,
          endDate: _endDate!,
          monthlyRentEgp: double.tryParse(_monthlyRentController.text.replaceAll(',', '').trim()) ?? 0,
          depositEgp: double.tryParse(_depositController.text.replaceAll(',', '').trim()) ?? 0,
          isElectricityOnStudent: _isElectricityOnStudent,
          isGasOnStudent: _isGasOnStudent,
          isWaterOnStudent: _isWaterOnStudent,
          roommates: roommatesJson,
          nationalId: _nationalIdController.text.trim().isEmpty ? null : _nationalIdController.text.trim(),
          idFrontImage: _idFrontImage?.path,
          idBackImage: _idBackImage?.path,
          contractFrontImage: _contractFrontImage?.path,
          contractBackImage: _contractBackImage?.path,
        );
      } else {
        ref.read(contractsControllerProvider.notifier).updateContract(
          id: widget.contract!.id,
          apartmentId: _selectedApartmentId!,
          contractType: _contractType,
          studentName: _studentNameController.text.trim(),
          studentPhone: _studentPhoneController.text.trim(),
          university: _contractType == 'student' ? _universityController.text.trim() : null,
          startDate: _startDate!,
          endDate: _endDate!,
          monthlyRentEgp: double.tryParse(_monthlyRentController.text.replaceAll(',', '').trim()) ?? 0,
          depositEgp: double.tryParse(_depositController.text.replaceAll(',', '').trim()) ?? 0,
          isElectricityOnStudent: _isElectricityOnStudent,
          isGasOnStudent: _isGasOnStudent,
          isWaterOnStudent: _isWaterOnStudent,
          roommates: roommatesJson,
          nationalId: _nationalIdController.text.trim().isEmpty ? null : _nationalIdController.text.trim(),
          idFrontImage: _idFrontImage?.path,
          idBackImage: _idBackImage?.path,
          contractFrontImage: _contractFrontImage?.path,
          contractBackImage: _contractBackImage?.path,
        );
      }
    } else if (_startDate == null || _endDate == null || _selectedApartmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء التأكد من التواريخ واختيار الشقة')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controllerState = ref.watch(contractsControllerProvider);
    final buildingsAsync = ref.watch(buildingsProvider);
    final apartmentsAsync = ref.watch(apartmentsProvider);
    final contractsAsync = ref.watch(winterContractsProvider);

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
            buildingsAsync.when(
              data: (buildings) {
                if (buildings.isNotEmpty && _selectedBuildingId == null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      _selectedBuildingId = buildings.first.id;
                    });
                  });
                }
                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: l10n.buildings),
                  value: _selectedBuildingId,
                  items: buildings.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
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
                final filteredApts = _selectedBuildingId != null 
                    ? apartments.where((a) => a.buildingId == _selectedBuildingId).toList()
                    : apartments;
                    
                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: l10n.apartments),
                  value: _selectedApartmentId,
                  items: filteredApts.map((a) => DropdownMenuItem(value: a.id, child: Text('شقة ${a.apartmentNumber}'))).toList(),
                  onChanged: (v) => setState(() => _selectedApartmentId = v),
                  validator: (v) => v == null ? 'مطلوب' : null,
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (e, st) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'نوع العقد'),
              value: _contractType,
              items: const [
                DropdownMenuItem(value: 'student', child: Text('عقد طلبة (مغتربين)')),
                DropdownMenuItem(value: 'family', child: Text('عقد أسرة')),
              ],
              onChanged: (v) {
                if (v != null) {
                  setState(() => _contractType = v);
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _studentNameController,
              decoration: InputDecoration(labelText: _contractType == 'student' ? l10n.studentName : 'اسم المستأجر (رب الأسرة)'),
              validator: (v) => v == null || v.isEmpty ? l10n.requiredField : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _studentPhoneController,
              decoration: const InputDecoration(labelText: 'رقم الهاتف'),
              keyboardType: TextInputType.phone,
            ),
            if (_contractType == 'student') ...[
              const SizedBox(height: 16),
              contractsAsync.when(
                data: (contracts) {
                  final universities = contracts
                      .map((c) => c.university)
                      .where((u) => u != null && u.isNotEmpty)
                      .cast<String>()
                      .toSet()
                      .toList();
                      
                  return Autocomplete<String>(
                    initialValue: TextEditingValue(text: _universityController.text),
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return universities;
                      }
                      return universities.where((String option) {
                        return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (String selection) {
                      _universityController.text = selection;
                    },
                    fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                      // Keep our controller in sync if user types something not in the list
                      textEditingController.addListener(() {
                        _universityController.text = textEditingController.text;
                      });
                      
                      return TextFormField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'الجامعة والكلية',
                          hintText: 'اختر أو اكتب جامعة جديدة',
                        ),
                      );
                    },
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => TextFormField(
                  controller: _universityController,
                  decoration: const InputDecoration(labelText: 'الجامعة والكلية'),
                ),
              ),
            ],
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
              inputFormatters: [CurrencyInputFormatter()],
              validator: (v) => v == null || v.isEmpty ? l10n.requiredField : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _depositController,
              decoration: InputDecoration(labelText: l10n.deposit),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [CurrencyInputFormatter()],
            ),
            const SizedBox(height: 16),
            if (_contractType == 'student') ...[
              SwitchListTile(
                title: const Text('إضافة بيانات زميل سكن'),
                value: _hasRoommate,
                onChanged: (val) => setState(() => _hasRoommate = val),
              ),
              if (_hasRoommate)
                Card(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('بيانات الزميل', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _roommateNameController,
                          decoration: const InputDecoration(labelText: 'اسم الزميل'),
                        ),
                        const SizedBox(height: 8),
                        contractsAsync.when(
                          data: (contracts) {
                            final universities = contracts
                                .map((c) => c.university)
                                .where((u) => u != null && u.isNotEmpty)
                                .cast<String>()
                                .toSet()
                                .toList();
                                
                            return Autocomplete<String>(
                              initialValue: TextEditingValue(text: _roommateUniversityController.text),
                              optionsBuilder: (TextEditingValue textEditingValue) {
                                if (textEditingValue.text.isEmpty) {
                                  return universities;
                                }
                                return universities.where((String option) {
                                  return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                                });
                              },
                              onSelected: (String selection) {
                                _roommateUniversityController.text = selection;
                              },
                              fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                                textEditingController.addListener(() {
                                  _roommateUniversityController.text = textEditingController.text;
                                });
                                
                                return TextFormField(
                                  controller: textEditingController,
                                  focusNode: focusNode,
                                  decoration: const InputDecoration(
                                    labelText: 'الجامعة والكلية',
                                    hintText: 'اختر أو اكتب جامعة جديدة',
                                  ),
                                );
                              },
                            );
                          },
                          loading: () => const CircularProgressIndicator(),
                          error: (_, __) => TextFormField(
                            controller: _roommateUniversityController,
                            decoration: const InputDecoration(labelText: 'الجامعة والكلية'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _roommateNationalIdController,
                          decoration: const InputDecoration(labelText: 'الرقم القومي للزميل'),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _pickImage('roommateIdFront'),
                                icon: const Icon(Icons.camera_alt),
                                label: Text(_roommateIdFrontImage != null ? 'تم الأمام' : 'بطاقة الزميل (أمام)'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _roommateIdFrontImage != null ? Colors.green : null,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _pickImage('roommateIdBack'),
                                icon: const Icon(Icons.camera_alt),
                                label: Text(_roommateIdBackImage != null ? 'تم الخلف' : 'بطاقة الزميل (خلف)'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _roommateIdBackImage != null ? Colors.green : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _nationalIdController,
              decoration: const InputDecoration(labelText: 'الرقم القومي (المستأجر الأساسي)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            const Text('صور بطاقة المستأجر الأساسي:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage('idFront'),
                    icon: const Icon(Icons.camera_alt),
                    label: Text(_idFrontImage != null ? 'تم التقاط الأمام' : 'بطاقة (أمام)'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _idFrontImage != null ? Colors.green : null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage('idBack'),
                    icon: const Icon(Icons.camera_alt),
                    label: Text(_idBackImage != null ? 'تم التقاط الخلف' : 'بطاقة (خلف)'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _idBackImage != null ? Colors.green : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('صور العقد:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage('contractFront'),
                    icon: const Icon(Icons.camera_alt),
                    label: Text(_contractFrontImage != null ? 'تم العقد (أمام)' : 'عقد (أمام)'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _contractFrontImage != null ? Colors.green : null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage('contractBack'),
                    icon: const Icon(Icons.camera_alt),
                    label: Text(_contractBackImage != null ? 'تم العقد (خلف)' : 'عقد (خلف)'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _contractBackImage != null ? Colors.green : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('الكهرباء على الطالب'),
              value: _isElectricityOnStudent,
              onChanged: (val) => setState(() => _isElectricityOnStudent = val),
            ),
            SwitchListTile(
              title: const Text('الغاز على الطالب'),
              value: _isGasOnStudent,
              onChanged: (val) => setState(() => _isGasOnStudent = val),
            ),
            SwitchListTile(
              title: const Text('المياه على الطالب'),
              value: _isWaterOnStudent,
              onChanged: (val) => setState(() => _isWaterOnStudent = val),
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
