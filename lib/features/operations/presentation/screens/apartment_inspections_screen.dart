import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/apartment_inspections_provider.dart';
import '../../../apartments/presentation/providers/apartments_controller.dart';
import '../../../../core/utils/currency_formatter.dart';

class ApartmentInspectionsScreen extends ConsumerWidget {
  const ApartmentInspectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inspectionsAsync = ref.watch(apartmentInspectionsProvider);
    final apartmentsAsync = ref.watch(apartmentsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل فحص واستلام الشقق'),
      ),
      body: inspectionsAsync.when(
        data: (inspections) {
          if (inspections.isEmpty) {
            return const Center(child: Text('لا توجد سجلات فحص مسجلة حتى الآن'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: inspections.length,
            itemBuilder: (context, index) {
              final inspection = inspections[index];
              return apartmentsAsync.when(
                data: (apts) {
                  final apt = apts.firstWhere((a) => a.id == inspection.apartmentId, orElse: () => apts.first);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: inspection.hasDamages 
                            ? theme.colorScheme.error.withValues(alpha: 0.2)
                            : (inspection.isClean ? Colors.green.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.2)),
                        child: Icon(
                          inspection.hasDamages ? Icons.warning : (inspection.isClean ? Icons.check_circle : Icons.cleaning_services),
                          color: inspection.hasDamages ? theme.colorScheme.error : (inspection.isClean ? Colors.green : Colors.orange),
                        ),
                      ),
                      title: Text('شقة ${apt.apartmentNumber}'),
                      subtitle: Text(inspection.inspectionDate.toLocal().toString().split(' ')[0]),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('الفاحص:', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                                  Text(inspection.inspectorName),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('حالة النظافة:', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                                  Row(
                                    children: [
                                      Text(
                                        inspection.isClean ? 'نظيفة' : 'تحتاج نظافة',
                                        style: TextStyle(color: inspection.isClean ? Colors.green : Colors.orange, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(width: 8),
                                      TextButton(
                                        onPressed: () {
                                          ref.read(apartmentInspectionsControllerProvider.notifier)
                                              .updateCleaningStatus(inspection.id, inspection.apartmentId, !inspection.isClean);
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: inspection.isClean ? Colors.orange : Colors.green,
                                        ),
                                        child: Text(inspection.isClean ? 'إلغاء: تحتاج إعادة نظافة' : 'تحديث: تم التنظيف'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              if (!inspection.hasDamages)
                                const Text('المحتويات سليمة ولا توجد تلفيات', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                              else ...[
                                const Text('تلفيات في المحتويات:', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(inspection.damagesDescription ?? 'لا يوجد وصف'),
                                const SizedBox(height: 8),
                                if (inspection.tenantFineEgp > 0)
                                  Text('غرامة على المستأجر: ${inspection.tenantFineEgp.toCurrencyFormat()} ج.م', style: const TextStyle(color: Colors.red)),
                                if (inspection.ownerRepairCostEgp > 0)
                                  Text('تكلفة تصليح علينا: ${inspection.ownerRepairCostEgp.toCurrencyFormat()} ج.م', style: const TextStyle(color: Colors.orange)),
                              ],
                              if (inspection.notes != null && inspection.notes!.isNotEmpty) ...[
                                const Divider(height: 24),
                                Text('ملاحظات:', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                                Text(inspection.notes!),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.go('/inspections/add');
        },
        icon: const Icon(Icons.add_task),
        label: const Text('فحص شقة'),
      ),
    );
  }
}
