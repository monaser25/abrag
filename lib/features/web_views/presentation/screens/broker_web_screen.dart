import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../apartments/presentation/providers/apartments_controller.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/widgets.dart';

class BrokerWebScreen extends ConsumerWidget {
  const BrokerWebScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apartmentsAsync = ref.watch(apartmentsProvider);
    final colors = context.colors;

    return AppScaffold(
      appBar: HomeAppBar(
        title: 'الشقق المتاحة',
        subtitle: 'بوابة السمسار · عرض فقط',
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
          // Broker only sees apartments with brokerVisibility == true
          final availableApartments =
              apartments.where((a) => a.brokerVisibility).toList();

          if (availableApartments.isEmpty) {
            return const EmptyState(
              icon: Icons.meeting_room_outlined,
              title: 'لا توجد شقق متاحة حالياً',
            );
          }

          return ListView(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 28),
            children: [
              AppCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'شقق متاحة للعرض',
                          style: AppTextStyles.caption
                              .copyWith(color: colors.ink3),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${availableApartments.length}',
                          style: AppTextStyles.tabular(
                            AppTextStyles.display
                                .copyWith(color: colors.ink),
                          ),
                        ),
                      ],
                    ),
                    IconTile(
                      icon: Icons.handshake_outlined,
                      tint: colors.accent,
                      size: 46,
                      iconSize: 24,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(4, 12, 4, 12),
                child: Text(
                  'تُعرض أرقام الشقق فقط — الأسعار والحجوزات يديرها المالك.',
                  style: AppTextStyles.bodyS.copyWith(color: colors.ink2),
                ),
              ),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: [
                  for (final apt in availableApartments)
                    Container(
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: AppRadius.rSm,
                        border: Border.all(color: colors.border),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.meeting_room_outlined,
                              size: 20, color: colors.accent),
                          const SizedBox(height: 6),
                          Text(
                            apt.apartmentNumber,
                            style: AppTextStyles.tabular(
                              TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: colors.ink,
                              ),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                ],
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
