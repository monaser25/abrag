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
  void _showAddEditDialog([dynamic technician]) {
    final nameController = TextEditingController(text: technician?.name ?? '');
    final specialtyController = TextEditingController(
      text: technician?.specialty ?? 'سباكة',
    );
    final phoneController = TextEditingController(
      text: technician?.phone ?? '',
    );
    final notesController = TextEditingController(
      text: technician?.notes ?? '',
    );
    final formKey = GlobalKey<FormState>();

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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextField(
                    controller: nameController,
                    label: 'الاسم',
                    prefixIcon: Icons.person_outline,
                    validator: (value) =>
                        value == null || value.trim().isEmpty ? 'مطلوب' : null,
                  ),
                  const SizedBox(height: 12),
                  AppDropdownField<String>(
                    label: 'التخصص',
                    prefixIcon: Icons.handyman_outlined,
                    initialValue: specialtyController.text.isNotEmpty
                        ? specialtyController.text
                        : 'سباكة',
                    items: const ['سباكة', 'كهرباء', 'نجارة', 'نقاشة', 'نظافة', 'أخرى']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
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
                    validator: (value) {
                      final phone = value?.trim() ?? '';
                      if (phone.isEmpty) return null;
                      return RegExp(r'^01\d{9}$').hasMatch(phone)
                          ? null
                          : 'رقم الهاتف يجب أن يكون 11 رقم ويبدأ بـ 01';
                    },
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

                if (technician == null) {
                  ref
                      .read(techniciansControllerProvider.notifier)
                      .addTechnician(
                        name: nameController.text.trim(),
                        specialty: specialtyController.text,
                        phone: phoneController.text.trim(),
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

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: activeTechnicians.length,
            itemBuilder: (context, index) {
              final tech = activeTechnicians[index];
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
                  ],
                ),
              );
            },
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
      case 'نقاشة':
        return Icons.format_paint;
      default:
        return Icons.person;
    }
  }
}
