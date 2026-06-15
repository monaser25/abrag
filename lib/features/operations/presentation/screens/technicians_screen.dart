import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/technicians_provider.dart';
import '../../../../core/database/tables.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/widgets.dart';

class TechniciansScreen extends ConsumerStatefulWidget {
  const TechniciansScreen({super.key});

  @override
  ConsumerState<TechniciansScreen> createState() => _TechniciansScreenState();
}

class _TechniciansScreenState extends ConsumerState<TechniciansScreen> {
  String _search = '';

  static const List<String> _specialties = [
    'سباكة',
    'كهرباء',
    'نجارة',
    'أنابيب وغاز',
    'نظافة',
    'أخرى',
  ];

  Future<void> _confirmDelete(dynamic technician) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final colors = dialogContext.colors;
        return AlertDialog(
          backgroundColor: colors.surface,
          title: const Text('حذف عامل/فني'),
          content: Text(
            'هل تريد حذف "${technician.name}"؟',
            style: AppTextStyles.bodyS.copyWith(color: colors.ink2),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('إلغاء'),
            ),
            AppButton(
              label: 'حذف',
              variant: AppButtonVariant.royal,
              small: true,
              onPressed: () => Navigator.pop(dialogContext, true),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    try {
      await ref
          .read(techniciansControllerProvider.notifier)
          .deleteTechnician(technician.id);
      messenger.showSnackBar(
        SnackBar(content: Text('تم حذف ${technician.name}')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('تعذّر الحذف: $e')));
    }
  }

  void _showAddEditDialog([dynamic technician]) {
    final nameController = TextEditingController(text: technician?.name ?? '');
    final specialtyController = TextEditingController(
      text: technician?.specialty ?? 'سباكة',
    );
    final phoneController = TextEditingController(
      text: technician?.phone ?? '',
    );
    final secondaryController = TextEditingController(
      text: technician?.secondaryPhone ?? '',
    );
    var showSecondary = (technician?.secondaryPhone ?? '').trim().isNotEmpty;
    final notesController = TextEditingController(
      text: technician?.notes ?? '',
    );
    final formKey = GlobalKey<FormState>();
    // Specialty list may include a legacy value (e.g. نقاشة) not in the
    // current options; fall back so the dropdown's initialValue stays valid.
    final initialSpecialty = _specialties.contains(specialtyController.text)
        ? specialtyController.text
        : 'أخرى';

    String? phoneValidator(String? value) {
      final phone = value?.trim() ?? '';
      if (phone.isEmpty) return null;
      return RegExp(r'^01\d{9}$').hasMatch(phone)
          ? null
          : 'رقم الهاتف يجب أن يكون 11 رقم ويبدأ بـ 01';
    }

    showDialog(
      context: context,
      builder: (ctx) {
        final colors = ctx.colors;
        return AlertDialog(
          backgroundColor: colors.surface,
          title: Text(
            technician == null ? 'إضافة فني/عامل' : 'تعديل بيانات العامل',
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (context, setLocalState) => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      controller: nameController,
                      label: 'الاسم',
                      prefixIcon: Icons.person_outline,
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'مطلوب'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    AppDropdownField<String>(
                      label: 'التخصص',
                      prefixIcon: Icons.handyman_outlined,
                      initialValue: initialSpecialty,
                      items: _specialties
                          .map((s) =>
                              DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) => specialtyController.text = v ?? 'أخرى',
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: phoneController,
                      label: 'رقم الهاتف',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      textDirection: TextDirection.ltr,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                      ],
                      validator: phoneValidator,
                    ),
                    if (showSecondary) ...[
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: secondaryController,
                        label: 'رقم هاتف آخر (اختياري)',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        textDirection: TextDirection.ltr,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(11),
                        ],
                        validator: phoneValidator,
                      ),
                    ] else
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TextButton.icon(
                          onPressed: () =>
                              setLocalState(() => showSecondary = true),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('إضافة رقم آخر'),
                        ),
                      ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: notesController,
                      label: 'ملاحظات / تقييم',
                      prefixIcon: Icons.sticky_note_2_outlined,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            AppButton(
              label: 'حفظ',
              small: true,
              onPressed: () {
                if (!formKey.currentState!.validate()) return;

                final secondary = showSecondary
                    ? secondaryController.text.trim()
                    : null;
                if (technician == null) {
                  ref
                      .read(techniciansControllerProvider.notifier)
                      .addTechnician(
                        name: nameController.text.trim(),
                        specialty: specialtyController.text,
                        phone: phoneController.text.trim(),
                        secondaryPhone: secondary,
                        notes: notesController.text.trim(),
                      );
                } else {
                  ref
                      .read(techniciansControllerProvider.notifier)
                      .updateTechnician(
                        technician.id,
                        name: nameController.text.trim(),
                        specialty: specialtyController.text,
                        phone: phoneController.text.trim(),
                        secondaryPhone: secondary,
                        notes: notesController.text.trim(),
                      );
                }
                Navigator.pop(ctx);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final techniciansAsync = ref.watch(techniciansProvider);
    final colors = context.colors;

    return AppScaffold(
      appBar: const AbragAppBar(title: 'العمال والفنيين'),
      floatingActionButton: AppFab(
        onPressed: () => _showAddEditDialog(),
        icon: Icons.add,
      ),
      body: techniciansAsync.when(
        data: (technicians) {
          final activeTechnicians = technicians
              .where((t) => t.syncStatus != SyncStatus.pendingDelete)
              .toList();

          if (activeTechnicians.isEmpty) {
            return const EmptyState(
              icon: Icons.engineering_outlined,
              title: 'لا يوجد فنيين مسجلين',
            );
          }

          final query = _search.toLowerCase();
          final filtered = query.isEmpty
              ? activeTechnicians
              : activeTechnicians.where((t) {
                  final name = t.name.toLowerCase();
                  final specialty = t.specialty.toLowerCase();
                  final phone = (t.phone ?? '').toLowerCase();
                  final phone2 = (t.secondaryPhone ?? '').toLowerCase();
                  return name.contains(query) ||
                      specialty.contains(query) ||
                      phone.contains(query) ||
                      phone2.contains(query);
                }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: AppTextField(
                  hint: 'ابحث بالاسم، التخصص، أو رقم الهاتف...',
                  prefixIcon: Icons.search,
                  onChanged: (value) =>
                      setState(() => _search = value.trim()),
                ),
              ),
              if (filtered.isEmpty)
                const Expanded(
                  child: EmptyState(
                    icon: Icons.search_off,
                    title: 'لا يوجد فني يطابق البحث',
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final tech = filtered[index];
              final hasPhone = tech.phone != null && tech.phone!.isNotEmpty;
              return AppCard(
                onTap: () => context.go('/technicians/details/${tech.id}'),
                margin: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    IconTile(
                      icon: _getIconForSpecialty(tech.specialty),
                      tint: colors.brand,
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tech.name,
                            style: AppTextStyles.title
                                .copyWith(color: colors.ink),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'التخصص: ${tech.specialty}',
                            style: AppTextStyles.caption
                                .copyWith(color: colors.ink2),
                          ),
                          if (hasPhone)
                            Text(
                              'الهاتف: ${tech.phone}',
                              style: AppTextStyles.caption
                                  .copyWith(color: colors.ink3),
                            ),
                        ],
                      ),
                    ),
                    if (hasPhone)
                      AppIconButton(
                        icon: Icons.call,
                        onPressed: () => _makePhoneCall(tech.phone!),
                      ),
                    AppIconButton(
                      icon: Icons.edit_outlined,
                      onPressed: () => _showAddEditDialog(tech),
                    ),
                    AppIconButton(
                      icon: Icons.delete_outline,
                      onPressed: () => _confirmDelete(tech),
                    ),
                  ],
                ),
              );
                    },
                  ),
                ),
            ],
          );
        },
        loading: () => const LoadingSkeleton(),
        error: (e, st) => ErrorState(
          title: 'تعذّر تحميل الفنيين',
          message: 'Error: $e',
          retryLabel: 'إعادة المحاولة',
          onRetry: () => ref.invalidate(techniciansProvider),
        ),
      ),
    );
  }

  IconData _getIconForSpecialty(String specialty) {
    switch (specialty) {
      case 'سباكة':
        return Icons.plumbing;
      case 'كهرباء':
        return Icons.electrical_services;
      case 'نجارة':
        return Icons.handyman;
      case 'نظافة':
        return Icons.cleaning_services;
      case 'أنابيب وغاز':
        return Icons.gas_meter;
      case 'نقاشة':
        return Icons.format_paint;
      default:
        return Icons.person;
    }
  }
}
