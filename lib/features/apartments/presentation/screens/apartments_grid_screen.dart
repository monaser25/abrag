import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/widgets.dart';
import '../providers/apartments_status_provider.dart';

final availableOnlyFilterProvider = StateProvider.autoDispose<bool>((ref) => false);

class ApartmentsGridScreen extends ConsumerWidget {
  const ApartmentsGridScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final statusesAsync = ref.watch(apartmentsWithStatusProvider);
    final availableOnly = ref.watch(availableOnlyFilterProvider);

    return AppScaffold(
      appBar: AbragAppBar(
        title: l10n.apartments,
        actions: [
          AppIconButton(
            icon: availableOnly ? Icons.filter_alt : Icons.filter_alt_off,
            tooltip: availableOnly ? 'عرض الكل' : 'المتاحة فقط',
            onPressed: () {
              ref.read(availableOnlyFilterProvider.notifier).state = !availableOnly;
            },
          ),
          AppIconButton(
            icon: Icons.playlist_add_check,
            tooltip: 'تعميم الجرد',
            onPressed: () => context.push('/apartments/bulk_inventory'),
          ),
        ],
      ),
      body: statusesAsync.when(
        data: (statuses) {
          var filteredStatuses = statuses;
          if (availableOnly) {
            filteredStatuses = filteredStatuses
                .where((s) => !s.isOccupied && !s.needsCleaning)
                .toList();
          }

          if (filteredStatuses.isEmpty) {
            return EmptyState(
              icon: Icons.meeting_room_outlined,
              title: l10n.noData,
            );
          }

          final buildingGroups = <String, List<ApartmentStatus>>{};
          for (final s in filteredStatuses) {
            buildingGroups.putIfAbsent(s.buildingName, () => []).add(s);
          }

          final sortedBuildings = buildingGroups.keys.toList()..sort();

          return ListView.builder(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 90),
            itemCount: sortedBuildings.length,
            itemBuilder: (context, index) {
              final bName = sortedBuildings[index];
              final bApartments = buildingGroups[bName]!;

              bApartments.sort((a, b) {
                final numA = int.tryParse(a.apartment.apartmentNumber);
                final numB = int.tryParse(b.apartment.apartmentNumber);
                if (numA != null && numB != null) return numA.compareTo(numB);
                if (numA != null) return -1;
                if (numB != null) return 1;
                return a.apartment.apartmentNumber
                    .compareTo(b.apartment.apartmentNumber);
              });

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(title: bName),
                  GridView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: bApartments.length,
                    itemBuilder: (context, i) {
                      final aptStatus = bApartments[i];
                      final colors = context.colors;

                      Color statusColor = colors.ok;
                      String statusText = 'متاحة';
                      if (aptStatus.needsCleaning) {
                        statusColor = colors.warn;
                        statusText = 'نظافة';
                      } else if (aptStatus.isOccupied) {
                        statusColor = colors.err;
                        statusText = 'مشغولة';
                      }

                      return ApartmentCell(
                        number: aptStatus.apartment.apartmentNumber,
                        statusColor: statusColor,
                        onTap: () => context.push(
                            '/apartments/profile/${aptStatus.apartment.id}'),
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
                  ),
                ],
              );
            },
          );
        },
        loading: () => const LoadingSkeleton(),
        error: (error, stack) => ErrorState(
          title: 'تعذّر تحميل البيانات',
          message: '$error',
          retryLabel: 'إعادة المحاولة',
          onRetry: () => ref.invalidate(apartmentsWithStatusProvider),
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
