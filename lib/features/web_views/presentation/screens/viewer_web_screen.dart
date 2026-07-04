import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../contracts/presentation/providers/contracts_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/widgets.dart';

class ViewerWebScreen extends ConsumerWidget {
  const ViewerWebScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contractsAsync = ref.watch(winterContractsProvider);
    final authState = ref.watch(authStateProvider);
    final currentUserId = authState.value?.session?.user.id;
    final colors = context.colors;

    return AppScaffold(
      appBar: HomeAppBar(
        title: 'بيانات الطالب',
        subtitle: 'عرض للقراءة فقط',
        actions: [
          AppIconButton(
            icon: Icons.calendar_month,
            tooltip: 'الأجندة الذكية',
            onPressed: () => context.push('/summer_bookings/calendar'),
          ),
          AppIconButton(
            icon: Icons.logout,
            onPressed: () {
              ref.read(loginControllerProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: currentUserId == null
          ? const LoadingSkeleton()
          : contractsAsync.when(
              data: (contracts) {
                // Viewer sees only their linked contracts
                final userContracts = contracts
                    .where((c) => c.viewerUserId == currentUserId)
                    .toList();

                if (userContracts.isEmpty) {
                  return const EmptyState(
                    icon: Icons.visibility_outlined,
                    title: 'لا توجد بيانات مرتبطة بحسابك',
                  );
                }

                return ListView(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 28),
                  children: [
                    for (final contract in userContracts)
                      AppCard(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: EdgeInsets.zero,
                        child: ClipRRect(
                          borderRadius: AppRadius.rMd,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(18),
                                color: colors.winterSoft,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const StatusChip(
                                          kind: StatusChipKind.winter,
                                          icon: Icons.ac_unit,
                                          label: 'عقد طالب',
                                        ),
                                        Icon(Icons.ac_unit,
                                            size: 22, color: colors.winter),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      contract.studentName,
                                      style: AppTextStyles.h2
                                          .copyWith(color: colors.ink),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    18, 4, 18, 14),
                                child: Column(
                                  children: [
                                    DetailRow(
                                      label: 'الوحدة',
                                      value: contract.apartmentId,
                                      strong: true,
                                    ),
                                    const Divider(),
                                    DetailRow(
                                      label: 'الجامعة',
                                      value:
                                          contract.university ?? 'غير مسجل',
                                    ),
                                    const Divider(),
                                    DetailRow(
                                      label: 'الإيجار الشهري',
                                      value:
                                          '${contract.monthlyRentEgp} ج.م',
                                      strong: true,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 6),
                    Opacity(
                      opacity: 0.6,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.visibility_outlined,
                              size: 13, color: colors.ink3),
                          const SizedBox(width: 6),
                          Text(
                            'عرض للقراءة فقط',
                            style: AppTextStyles.caption
                                .copyWith(color: colors.ink3),
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
                onRetry: () => ref.invalidate(winterContractsProvider),
              ),
            ),
    );
  }
}
