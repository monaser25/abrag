import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../apartments/presentation/providers/apartments_controller.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/widgets.dart';

class CleanerWebScreen extends ConsumerWidget {
  const CleanerWebScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apartmentsAsync = ref.watch(apartmentsProvider);
    final colors = context.colors;

    return AppScaffold(
      appBar: HomeAppBar(
        title: 'مهام التنظيف',
        actions: [
          AppIconButton(
            icon: Icons.logout,
            onPressed: () {
              ref.read(loginControllerProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: apartmentsAsync.when(
        data: (apartments) {
          // Cleaner sees apartments that need cleaning
          final dirtyApartments = apartments
              .where((a) => a.cleaningStatus == 'needs_cleaning')
              .toList();

          if (dirtyApartments.isEmpty) {
            return const EmptyState(
              icon: Icons.check_circle_outline,
              title: 'لا توجد مهام تنظيف حالياً',
            );
          }

          return ListView(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 28),
            children: [
              AppCard(
                margin: const EdgeInsets.only(bottom: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'بحاجة تنظيف',
                          style: AppTextStyles.caption.copyWith(
                            color: colors.ink3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${dirtyApartments.length}',
                          style: AppTextStyles.tabular(
                            AppTextStyles.display.copyWith(color: colors.warn),
                          ),
                        ),
                      ],
                    ),
                    IconTile(
                      icon: Icons.cleaning_services_outlined,
                      tint: colors.warn,
                      size: 46,
                      iconSize: 22,
                    ),
                  ],
                ),
              ),
              for (final apt in dirtyApartments)
                AppCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconTile(
                            icon: Icons.cleaning_services_outlined,
                            tint: colors.warn,
                            size: 46,
                            iconSize: 22,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'شقة ${apt.apartmentNumber}',
                                style: AppTextStyles.tabular(
                                  AppTextStyles.h3.copyWith(color: colors.ink),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'بحاجة تنظيف',
                                style: AppTextStyles.caption.copyWith(
                                  color: colors.ink3,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        label: 'تم التنظيف',
                        icon: Icons.check,
                        variant: AppButtonVariant.royal,
                        expand: true,
                        onPressed: () => ref
                            .read(apartmentsControllerProvider.notifier)
                            .updateCleaningStatus(apt.id, 'clean'),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
        loading: () => const LoadingSkeleton(),
        error: (error, stack) => ErrorState(
          title: 'تعذّر تحميل البيانات',
          message: '$error',
          retryLabel: 'إعادة المحاولة',
          onRetry: () => ref.invalidate(apartmentsProvider),
        ),
      ),
    );
  }
}
