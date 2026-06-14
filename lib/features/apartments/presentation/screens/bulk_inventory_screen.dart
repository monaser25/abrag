import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/shared_prefs_provider.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/widgets.dart';
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
    final colors = context.colors;

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

    return AppScaffold(
      appBar: const AbragAppBar(title: 'تعميم الجرد على الشقق'),
      bottomNavigationBar: BottomActionBar(
        children: [
          Expanded(
            child: AppButton(
              label: 'تعميم الجرد الآن',
              icon: Icons.playlist_add_check,
              loading: controllerState.isLoading,
              onPressed: controllerState.isLoading ? null : _submit,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          SectionTitle(
            title: 'محتويات الجرد',
            action: AppButton(
              label: 'حفظ كقالب',
              icon: Icons.bookmark_add_outlined,
              variant: AppButtonVariant.ghost,
              small: true,
              onPressed: _saveAsGlobalTemplate,
            ),
          ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اكتب كل عنصر في سطر. لإنشاء مجموعة (مثل الأجهزة الكهربائية)، اكتب اسم المجموعة في سطر وضع آخره نقطتين (:)',
                  style: AppTextStyles.caption.copyWith(color: colors.ink3),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _inventoryController,
                  hint:
                      'الأجهزة الكهربائية:\nثلاجة\nغسالة\n\nالأثاث:\nسرير كبير\nدولاب',
                  maxLines: 8,
                ),
              ],
            ),
          ),
          const SectionTitle(title: 'طريقة التطبيق'),
          _ModeOption(
            icon: Icons.playlist_add,
            title: 'إضافة الجرد الجديد (الاحتفاظ بالقديم)',
            subtitle:
                'سيتم إضافة المحتويات الجديدة فوق الجرد الموجود في كل شقة.',
            selected: _appendMode,
            onTap: () => setState(() => _appendMode = true),
          ),
          const SizedBox(height: 8),
          _ModeOption(
            icon: Icons.delete_sweep_outlined,
            title: 'استبدال الجرد (حذف القديم)',
            subtitle: 'تحذير: سيتم مسح أي جرد قديم بالشقق واستبداله بالكامل.',
            tint: colors.warn,
            selected: !_appendMode,
            onTap: () => setState(() => _appendMode = false),
          ),
          const SectionTitle(title: 'تحديد الشقق لتطبيق الجرد عليها'),
          apartmentsAsync.when(
            data: (apartments) {
              if (apartments.isEmpty) {
                return AppCard(
                  child: Text(
                    'لا توجد شقق مسجلة.',
                    style: AppTextStyles.body.copyWith(color: colors.ink2),
                  ),
                );
              }

              return AppCard(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: [
                    _CheckRow(
                      title: 'تحديد كل الشقق',
                      strong: true,
                      selected: _selectAll,
                      onTap: () {
                        setState(() {
                          _selectAll = !_selectAll;
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
                    Divider(height: 1, color: colors.border),
                    ...apartments.map((apt) {
                      final selected = _selectedApartmentIds.contains(apt.id);
                      return _CheckRow(
                        title:
                            'شقة ${apt.apartmentNumber} (الدور ${apt.floorNumber ?? "-"})',
                        selected: selected,
                        onTap: () {
                          setState(() {
                            if (!selected) {
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
            loading: () => const LoadingSkeleton(),
            error: (e, st) => Text(
              'Error: $e',
              style: AppTextStyles.body.copyWith(color: colors.err),
            ),
          ),
        ],
      ),
    );
  }
}

/// Radio-style option card (append vs. replace). Mirrors the original
/// [RadioListTile] choice: tapping selects this mode.
class _ModeOption extends StatelessWidget {
  const _ModeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.tint,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveTint = tint ?? colors.brand;
    return Tappable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? effectiveTint.withValues(alpha: 0.10) : colors.surface,
          borderRadius: AppRadius.rMd,
          border: Border.all(
            color: selected ? effectiveTint : colors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 22,
              color: selected ? effectiveTint : colors.ink3,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.title.copyWith(color: colors.ink),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(color: colors.ink2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Selectable apartment / select-all row with a trailing check indicator.
class _CheckRow extends StatelessWidget {
  const _CheckRow({
    required this.title,
    required this.selected,
    required this.onTap,
    this.strong = false,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Tappable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: (strong ? AppTextStyles.title : AppTextStyles.body)
                    .copyWith(color: colors.ink),
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              size: 22,
              color: selected ? colors.brand : colors.ink3,
            ),
          ],
        ),
      ),
    );
  }
}
