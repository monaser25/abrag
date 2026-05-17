import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/shared_prefs_provider.dart';
import '../providers/apartments_controller.dart';

class BulkInventoryScreen extends ConsumerStatefulWidget {
  const BulkInventoryScreen({super.key});

  @override
  ConsumerState<BulkInventoryScreen> createState() =>
      _BulkInventoryScreenState();
}

class _BulkInventoryScreenState extends ConsumerState<BulkInventoryScreen> {
  final _inventoryController = TextEditingController();
  final Set<String> _selectedApartmentIds = {};
  bool _selectAll = false;
  bool _appendMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGlobalTemplate();
    });
  }

  @override
  void dispose() {
    _inventoryController.dispose();
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
        const SnackBar(content: Text('تم حفظ الجرد كقالب افتراضي')),
      );
    }
  }

  void _submit() {
    if (_selectedApartmentIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء تحديد شقة واحدة على الأقل')),
      );
      return;
    }

    final inventory = _inventoryController.text.trim();
    if (inventory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء كتابة محتويات الجرد')),
      );
      return;
    }

    ref
        .read(apartmentsControllerProvider.notifier)
        .applyInventoryToApartments(
          _selectedApartmentIds.toList(),
          inventory,
          append: _appendMode,
        );
  }

  @override
  Widget build(BuildContext context) {
    final apartmentsAsync = ref.watch(apartmentsProvider);
    final controllerState = ref.watch(apartmentsControllerProvider);

    ref.listen<AsyncValue<void>>(apartmentsControllerProvider, (_, state) {
      state.whenOrNull(
        data: (_) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('تم تعميم الجرد بنجاح')));
          context.pop();
        },
        error: (error, _) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString()))),
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('تعميم الجرد على الشقق')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
                        'محتويات الجرد',
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
          const SizedBox(height: 16),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  RadioGroup<bool>(
                    groupValue: _appendMode,
                    onChanged: (val) =>
                        setState(() => _appendMode = val ?? _appendMode),
                    child: Column(
                      children: [
                        RadioListTile<bool>(
                          title: const Text('إضافة الجرد الجديد (الاحتفاظ بالقديم)'),
                          subtitle: const Text(
                            'سيتم إضافة المحتويات الجديدة فوق الجرد الموجود في كل شقة.',
                          ),
                          value: true,
                        ),
                        RadioListTile<bool>(
                          title: const Text('استبدال الجرد (حذف القديم)'),
                          subtitle: const Text(
                            'تحذير: سيتم مسح أي جرد قديم بالشقق واستبداله بالكامل.',
                          ),
                          value: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'تحديد الشقق لتطبيق الجرد عليها:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          apartmentsAsync.when(
            data: (apartments) {
              if (apartments.isEmpty) {
                return const Text('لا توجد شقق مسجلة.');
              }

              return Card(
                child: Column(
                  children: [
                    CheckboxListTile(
                      title: const Text(
                        'تحديد كل الشقق',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      value: _selectAll,
                      onChanged: (val) {
                        setState(() {
                          _selectAll = val ?? false;
                          if (_selectAll) {
                            _selectedApartmentIds.addAll(
                              apartments.map((a) => a.id),
                            );
                          } else {
                            _selectedApartmentIds.clear();
                          }
                        });
                      },
                    ),
                    const Divider(height: 1),
                    ...apartments.map((apt) {
                      return CheckboxListTile(
                        title: Text(
                          'شقة ${apt.apartmentNumber} (الدور ${apt.floorNumber ?? "-"})',
                        ),
                        value: _selectedApartmentIds.contains(apt.id),
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _selectedApartmentIds.add(apt.id);
                            } else {
                              _selectedApartmentIds.remove(apt.id);
                              _selectAll = false;
                            }
                            if (_selectedApartmentIds.length ==
                                apartments.length) {
                              _selectAll = true;
                            }
                          });
                        },
                      );
                    }),
                  ],
                ),
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (e, st) => Text('Error: $e'),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: controllerState.isLoading ? null : _submit,
            icon: const Icon(Icons.playlist_add_check),
            label: controllerState.isLoading
                ? const CircularProgressIndicator()
                : const Text('تعميم الجرد الآن'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
