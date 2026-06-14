import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/widgets.dart';
import '../providers/buildings_controller.dart';

class BuildingListScreen extends ConsumerWidget {
  const BuildingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final buildingsAsync = ref.watch(buildingsProvider);

    return AppScaffold(
      appBar: AbragAppBar(title: l10n.buildings),
      floatingActionButton: AppFab(
        onPressed: () => context.go('/buildings/add'),
        icon: Icons.add,
      ),
      body: buildingsAsync.when(
        data: (buildings) {
          if (buildings.isEmpty) {
            return EmptyState(
              icon: Icons.apartment_outlined,
              title: l10n.noData,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: buildings.length,
            itemBuilder: (context, index) {
              final building = buildings[index];
              return _BuildingRow(building: building, l10n: l10n);
            },
          );
        },
        loading: () => const LoadingSkeleton(),
        error: (error, stack) => ErrorState(
          title: 'تعذّر تحميل المباني',
          message: 'Error: $error',
          retryLabel: 'إعادة المحاولة',
          onRetry: () => ref.invalidate(buildingsProvider),
        ),
      ),
    );
  }
}

/// Building row: building icon tile, name + address, apartment-count chip and
/// an explicit edit action (preserves the original list affordance — the row
/// itself had no tap target; only the edit button navigates to `/buildings/edit`).
class _BuildingRow extends StatelessWidget {
  const _BuildingRow({required this.building, required this.l10n});

  final dynamic building;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final address = (building.address ?? '') as String;
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          IconTile(icon: Icons.apartment, tint: colors.brand),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  building.name,
                  style: AppTextStyles.title.copyWith(color: colors.ink),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (address.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    address,
                    style: AppTextStyles.caption.copyWith(color: colors.ink3),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusChip(
            label: '${building.totalApartments} ${l10n.apartments}',
            kind: StatusChipKind.neutral,
          ),
          const SizedBox(width: 2),
          AppIconButton(
            icon: Icons.edit_outlined,
            onPressed: () => context.go('/buildings/edit', extra: building),
          ),
        ],
      ),
    );
  }
}
