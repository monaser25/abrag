import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/apartment_inspections_provider.dart';
import '../../../apartments/presentation/providers/apartments_controller.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/widgets.dart';

class ApartmentInspectionsScreen extends ConsumerWidget {
  const ApartmentInspectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inspectionsAsync = ref.watch(apartmentInspectionsProvider);
    final apartmentsAsync = ref.watch(apartmentsProvider);

    return AppScaffold(
      appBar: const AbragAppBar(title: 'سجل فحص واستلام الشقق'),
      floatingActionButton: AppFab(
        onPressed: () => context.go('/inspections/add'),
        icon: Icons.add_task,
        label: 'فحص شقة',
      ),
      body: inspectionsAsync.when(
        data: (inspections) {
          if (inspections.isEmpty) {
            return const EmptyState(
              icon: Icons.fact_check_outlined,
              title: 'لا توجد سجلات فحص مسجلة حتى الآن',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: inspections.length,
            itemBuilder: (context, index) {
              final inspection = inspections[index];
              return apartmentsAsync.when(
                data: (apts) {
                  final apt = apts.firstWhere(
                    (a) => a.id == inspection.apartmentId,
                    orElse: () => apts.first,
                  );
                  final notes = inspection.notes;
                  return _InspectionCard(
                    apartmentNumber: apt.apartmentNumber,
                    inspectorName: inspection.inspectorName,
                    dateStr: inspection.inspectionDate
                        .toLocal()
                        .toString()
                        .split(' ')[0],
                    hasDamages: inspection.hasDamages,
                    isClean: inspection.isClean,
                    damagesDescription:
                        inspection.damagesDescription ?? 'لا يوجد وصف',
                    tenantFine: inspection.tenantFineEgp > 0
                        ? 'غرامة على المستأجر: ${inspection.tenantFineEgp.toCurrencyFormat()} ج.م'
                        : null,
                    ownerRepairCost: inspection.ownerRepairCostEgp > 0
                        ? 'تكلفة تصليح علينا: ${inspection.ownerRepairCostEgp.toCurrencyFormat()} ج.م'
                        : null,
                    notes: (notes != null && notes.isNotEmpty) ? notes : null,
                    onToggleCleaning: () => ref
                        .read(apartmentInspectionsControllerProvider.notifier)
                        .updateCleaningStatus(
                          inspection.id,
                          inspection.apartmentId,
                          !inspection.isClean,
                        ),
                  );
                },
                loading: () => const LoadingSkeleton(),
                error: (_, _) => const SizedBox.shrink(),
              );
            },
          );
        },
        loading: () => const LoadingSkeleton(),
        error: (e, st) => ErrorState(
          title: 'تعذّر تحميل سجلات الفحص',
          message: 'Error: $e',
          retryLabel: 'إعادة المحاولة',
          onRetry: () => ref.invalidate(apartmentInspectionsProvider),
        ),
      ),
    );
  }
}

class _InspectionCard extends StatelessWidget {
  const _InspectionCard({
    required this.apartmentNumber,
    required this.inspectorName,
    required this.dateStr,
    required this.hasDamages,
    required this.isClean,
    required this.damagesDescription,
    required this.tenantFine,
    required this.ownerRepairCost,
    required this.notes,
    required this.onToggleCleaning,
  });

  final String apartmentNumber;
  final String inspectorName;
  final String dateStr;
  final bool hasDamages;
  final bool isClean;
  final String damagesDescription;
  final String? tenantFine;
  final String? ownerRepairCost;
  final String? notes;
  final VoidCallback onToggleCleaning;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tint = hasDamages
        ? colors.err
        : (isClean ? colors.ok : colors.warn);
    final icon = hasDamages
        ? Icons.warning_amber_rounded
        : (isClean ? Icons.check_circle : Icons.cleaning_services);

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: IconTile(icon: icon, tint: tint),
          title: Text(
            'شقة $apartmentNumber',
            style: AppTextStyles.title.copyWith(color: colors.ink),
          ),
          subtitle: Text(
            dateStr,
            style: AppTextStyles.caption.copyWith(color: colors.ink3),
          ),
          iconColor: colors.ink2,
          collapsedIconColor: colors.ink3,
          children: [
            _row(context, 'الفاحص', inspectorName),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'حالة النظافة',
                  style: AppTextStyles.body.copyWith(color: colors.ink2),
                ),
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StatusChip(
                        label: isClean ? 'نظيفة' : 'تحتاج نظافة',
                        kind: isClean
                            ? StatusChipKind.ok
                            : StatusChipKind.warn,
                      ),
                      const SizedBox(width: 8),
                      AppButton(
                        label: isClean
                            ? 'إلغاء: تحتاج إعادة نظافة'
                            : 'تحديث: تم التنظيف',
                        variant: AppButtonVariant.ghost,
                        small: true,
                        onPressed: onToggleCleaning,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(height: 24, color: colors.border),
            if (!hasDamages)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  'المحتويات سليمة ولا توجد تلفيات',
                  style: AppTextStyles.title.copyWith(color: colors.ok),
                ),
              )
            else ...[
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  'تلفيات في المحتويات:',
                  style: AppTextStyles.title.copyWith(color: colors.err),
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  damagesDescription,
                  style: AppTextStyles.body.copyWith(color: colors.ink),
                ),
              ),
              const SizedBox(height: 8),
              if (tenantFine != null)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    tenantFine!,
                    style: AppTextStyles.body.copyWith(color: colors.err),
                  ),
                ),
              if (ownerRepairCost != null)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    ownerRepairCost!,
                    style: AppTextStyles.body.copyWith(color: colors.warn),
                  ),
                ),
            ],
            if (notes != null) ...[
              Divider(height: 24, color: colors.border),
              _row(context, 'ملاحظات', notes!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: AppTextStyles.body.copyWith(color: colors.ink2),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppTextStyles.body.copyWith(color: colors.ink),
          ),
        ),
      ],
    );
  }
}
