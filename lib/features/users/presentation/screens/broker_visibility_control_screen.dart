import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../apartments/presentation/providers/apartments_controller.dart';
import '../../../../core/database/database.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/widgets.dart';

class BrokerVisibilityControlScreen extends ConsumerWidget {
  const BrokerVisibilityControlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apartmentsAsync = ref.watch(apartmentsProvider);
    final colors = context.colors;

    return AppScaffold(
      appBar: const AbragAppBar(title: 'إدارة رؤية الوسطاء'),
      body: apartmentsAsync.when(
        data: (apartments) {
          if (apartments.isEmpty) {
            return const EmptyState(
              icon: Icons.visibility_off_outlined,
              title: 'لا توجد شقق مسجلة',
            );
          }

          // Filter for empty apartments if needed. For now, showing all.
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: apartments.length,
            itemBuilder: (context, index) {
              final apt = apartments[index];
              return AppCard(
                margin: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    IconTile(
                      icon: apt.brokerVisibility
                          ? Icons.visibility
                          : Icons.visibility_off,
                      tint: apt.brokerVisibility ? colors.ok : colors.ink3,
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'شقة ${apt.apartmentNumber}',
                            style: AppTextStyles.title.copyWith(color: colors.ink),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'الدور: ${apt.floorNumber ?? "-"}',
                            style: AppTextStyles.caption
                                .copyWith(color: colors.ink3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusChip(
                      label: apt.brokerVisibility ? 'ظاهرة للوسطاء' : 'مخفية',
                      kind: apt.brokerVisibility
                          ? StatusChipKind.ok
                          : StatusChipKind.neutral,
                    ),
                    Switch(
                      value: apt.brokerVisibility,
                      onChanged: (val) {
                        // Directly updating DB for toggle
                        // In real app, create a controller method
                        ref.read(databaseProvider).update(ref.read(databaseProvider).apartments)
                          ..where((t) => t.id.equals(apt.id))
                          ..write(ApartmentsCompanion(brokerVisibility: drift.Value(val)));
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const LoadingSkeleton(),
        error: (error, stack) => ErrorState(
          title: 'تعذّر تحميل الشقق',
          message: 'Error: $error',
          retryLabel: 'إعادة المحاولة',
          onRetry: () => ref.invalidate(apartmentsProvider),
        ),
      ),
    );
  }
}
