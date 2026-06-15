import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/widgets.dart';
import '../providers/apartments_controller.dart';

class LandlinesManagementScreen extends ConsumerStatefulWidget {
  const LandlinesManagementScreen({super.key});

  @override
  ConsumerState<LandlinesManagementScreen> createState() =>
      _LandlinesManagementScreenState();
}

class _LandlinesManagementScreenState
    extends ConsumerState<LandlinesManagementScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final apartmentsAsync = ref.watch(apartmentsProvider);
    final colors = context.colors;

    return AppScaffold(
      appBar: const AbragAppBar(title: 'إدارة الخطوط الأرضية'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: AppTextField(
              hint: 'ابحث برقم الشقة، رقم الخط، أو اسم صاحب الخط',
              prefixIcon: Icons.search,
              onChanged: (value) => setState(() => _search = value.trim()),
            ),
          ),
          Expanded(
            child: apartmentsAsync.when(
              data: (apartments) {
                final filtered =
                    apartments.where((apartment) {
                      if (_search.isEmpty) return true;
                      final query = _search.toLowerCase();
                      return apartment.apartmentNumber.toLowerCase().contains(
                            query,
                          ) ||
                          (apartment.landlineNumber ?? '')
                              .toLowerCase()
                              .contains(query) ||
                          (apartment.landlineOwnerName ?? '')
                              .toLowerCase()
                              .contains(query);
                    }).toList()..sort(
                      (a, b) => a.apartmentNumber.compareTo(b.apartmentNumber),
                    );

                final registered = apartments
                    .where(
                      (apartment) =>
                          (apartment.landlineNumber ?? '').trim().isNotEmpty,
                    )
                    .length;

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    AppCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: MiniMetric(
                              icon: Icons.phone_in_talk,
                              value: '$registered',
                              label: 'خطوط مسجلة',
                              tint: colors.ok,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 38,
                            color: colors.border,
                          ),
                          Expanded(
                            child: MiniMetric(
                              icon: Icons.phone_disabled,
                              value: '${apartments.length - registered}',
                              label: 'بدون خط',
                              tint: colors.warn,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (filtered.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 32),
                        child: EmptyState(
                          icon: Icons.phone_outlined,
                          title: 'لا توجد نتائج',
                        ),
                      )
                    else
                      ...filtered.map(
                        (apartment) => _LandlineRow(
                          apartment: apartment,
                          onTap: () => _showEditSheet(apartment),
                        ),
                      ),
                  ],
                );
              },
              loading: () => const LoadingSkeleton(),
              error: (error, _) => ErrorState(
                title: 'تعذّر تحميل الخطوط',
                message: 'حدث خطأ: $error',
                retryLabel: 'إعادة المحاولة',
                onRetry: () => ref.invalidate(apartmentsProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditSheet(dynamic apartment) async {
    final colors = context.colors;
    final numberController = TextEditingController(
      text: apartment.landlineNumber ?? '',
    );
    final ownerController = TextEditingController(
      text: apartment.landlineOwnerName ?? '',
    );
    final notesController = TextEditingController(
      text: apartment.landlineNotes ?? '',
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colors.border2,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'تعديل خط شقة ${apartment.apartmentNumber}',
              style: AppTextStyles.h3.copyWith(color: colors.ink),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'رقم الخط الأرضي',
              prefixIcon: Icons.phone,
              controller: numberController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'اسم صاحب الخط',
              prefixIcon: Icons.person_outline,
              controller: ownerController,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'ملاحظات',
              prefixIcon: Icons.sticky_note_2_outlined,
              controller: notesController,
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            AppButton(
              label: 'حفظ',
              icon: Icons.save_outlined,
              expand: true,
              onPressed: () {
                ref
                    .read(apartmentsControllerProvider.notifier)
                    .updateLandline(
                      id: apartment.id,
                      landlineNumber: numberController.text,
                      ownerName: ownerController.text,
                      notes: notesController.text,
                    );
                Navigator.pop(sheetContext);
              },
            ),
          ],
        ),
      ),
    );

    numberController.dispose();
    ownerController.dispose();
    notesController.dispose();
  }
}

/// Landline row: phone tile, apartment number, line number + owner, edit affordance.
class _LandlineRow extends StatelessWidget {
  const _LandlineRow({required this.apartment, required this.onTap});

  final dynamic apartment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final number = (apartment.landlineNumber ?? '') as String;
    final owner = (apartment.landlineOwnerName ?? '') as String;
    final hasLine = number.isNotEmpty;
    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
      child: Row(
          children: [
            IconTile(
              icon: hasLine ? Icons.phone : Icons.phone_disabled,
              tint: hasLine ? colors.brand : colors.ink3,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'شقة ${apartment.apartmentNumber}',
                    style: AppTextStyles.title.copyWith(color: colors.ink),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasLine ? 'رقم الخط: $number' : 'لا يوجد رقم أرضي مسجل',
                    style: AppTextStyles.caption.copyWith(
                      color: hasLine ? colors.ink2 : colors.ink3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (owner.isNotEmpty)
                    Text(
                      'صاحب الخط: $owner',
                      style:
                          AppTextStyles.caption.copyWith(color: colors.ink3),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.edit_outlined, size: 18, color: colors.ink3),
          ],
        ),
      );
  }
}
