import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/widgets.dart';
import '../providers/apartments_controller.dart';
import '../providers/apartment_profile_provider.dart';

class ApartmentsGridScreen extends ConsumerWidget {
  const ApartmentsGridScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final apartmentsAsync = ref.watch(apartmentsProvider);

    return AppScaffold(
      appBar: AbragAppBar(
        title: l10n.apartments,
        actions: [
          AppIconButton(
            icon: Icons.playlist_add_check,
            tooltip: 'تعميم الجرد',
            onPressed: () => context.push('/apartments/bulk_inventory'),
          ),
        ],
      ),
      body: apartmentsAsync.when(
        data: (apartments) {
          if (apartments.isEmpty) {
            return EmptyState(
              icon: Icons.meeting_room_outlined,
              title: l10n.noData,
            );
          }
          return GridView.builder(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 90),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: apartments.length,
            itemBuilder: (context, index) {
              final apt = apartments[index];
              return Consumer(
                builder: (context, ref, child) {
                  final profileAsync = ref.watch(
                    apartmentProfileProvider(apt.id),
                  );
                  final colors = context.colors;

                  return profileAsync.when(
                    data: (data) {
                      final isCleaning =
                          data.apartment.cleaningStatus == 'needs_cleaning';
                      final isOccupied = data.isOccupied;

                      // Same status semantics as before, token colors.
                      Color statusColor = colors.ok;
                      String statusText = 'متاحة';
                      if (isCleaning) {
                        statusColor = colors.warn;
                        statusText = 'نظافة';
                      } else if (isOccupied) {
                        statusColor = colors.err;
                        statusText = 'مشغولة';
                      }

                      return ApartmentCell(
                        number: apt.apartmentNumber,
                        statusColor: statusColor,
                        onTap: () =>
                            context.push('/apartments/profile/${apt.id}'),
                        footer: Text(
                          statusText,
                          style: AppTextStyles.caption.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                    loading: () => const SkeletonBox(
                      height: double.infinity,
                      radius: 9,
                    ),
                    error: (err, stack) => Container(
                      decoration: BoxDecoration(
                        color: colors.errSoft,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(Icons.error_outline, color: colors.err),
                    ),
                  );
                },
              );
            },
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
      floatingActionButton: AppFab(
        onPressed: () {
          context.go('/apartments/add');
        },
      ),
    );
  }
}
