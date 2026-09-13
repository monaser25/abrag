import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_settings_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/contracts_provider.dart';
import '../models/winter_payment_status.dart';
import '../../../apartments/presentation/providers/apartments_controller.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/season_utils.dart';
import '../../../../core/database/database.dart';
import '../../../../shared/widgets/widgets.dart';

class WinterContractsScreen extends ConsumerStatefulWidget {
  const WinterContractsScreen({super.key});

  @override
  ConsumerState<WinterContractsScreen> createState() =>
      _WinterContractsScreenState();
}

class _WinterContractsScreenState extends ConsumerState<WinterContractsScreen> {
  String _filter = 'all'; // all, active, expired, empty

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final contractsAsync = ref.watch(winterContractsProvider);
    final apartmentsAsync = ref.watch(apartmentsProvider);
    final paymentsAsync = ref.watch(allWinterPaymentsProvider);
    final activeSeason = ref.watch(activeSeasonKeyProvider);
    final theme = Theme.of(context);

    return AppScaffold(
      appBar: AbragAppBar(
        title: l10n.winterContracts,
        subtitle: seasonLabel(activeSeason),
      ),
      body: contractsAsync.when(
        data: (contracts) {
          return apartmentsAsync.when(
            data: (apartments) {
              return paymentsAsync.when(
                data: (payments) {
                  final seasonContracts = contracts;

                  final activeContracts = seasonContracts
                      .where((c) => c.isActive)
                      .toList();
                  final totalRent = activeContracts.fold(
                    0.0,
                    (sum, c) => sum + c.monthlyRentEgp,
                  );
                  final emptyApts = apartments
                      .where(
                        (a) =>
                            !activeContracts.any((c) => c.apartmentId == a.id),
                      )
                      .toList();

                  // Apply Filter
                  List<dynamic> listItems = [];
                  if (_filter == 'all') {
                    listItems.addAll(seasonContracts);
                    listItems.addAll(emptyApts);
                  } else if (_filter == 'active') {
                    listItems.addAll(activeContracts);
                  } else if (_filter == 'expired') {
                    listItems.addAll(seasonContracts.where((c) => !c.isActive));
                  } else if (_filter == 'empty') {
                    listItems.addAll(emptyApts);
                  }

                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: CustomScrollView(
                      slivers: [
                        // Season Indicator (winter hero)
                        SliverToBoxAdapter(
                          child: SeasonHero(
                            season: Season.winter,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                StatusChip(
                                  kind: StatusChipKind.winter,
                                  icon: Icons.ac_unit,
                                  label: seasonLabel(activeSeason),
                                ),
                                Text(
                                  '${activeContracts.length} عقد نشط',
                                  style: AppTextStyles.tabular(
                                    AppTextStyles.bodyS.copyWith(
                                      color: context.colors.ink2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 16)),

                        // Summary Row
                        SliverToBoxAdapter(
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () =>
                                      setState(() => _filter = 'active'),
                                  child: _buildSummaryCard(
                                    context,
                                    icon: Icons.home_work,
                                    title: 'المشغولة',
                                    value: '${activeContracts.length}',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: InkWell(
                                  onTap: () =>
                                      setState(() => _filter = 'empty'),
                                  child: _buildSummaryCard(
                                    context,
                                    icon: Icons.key_off,
                                    title: 'الفاضية',
                                    value: '${emptyApts.length}',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: _buildSummaryCard(
                                  context,
                                  icon: Icons.payments,
                                  title: 'إجمالي الإيجارات',
                                  value: '${totalRent.toCurrencyFormat()} ج.م',
                                  isHighlight: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 32)),

                        // Section Title + filter
                        const SliverToBoxAdapter(
                          child: SectionTitle(title: 'القائمة'),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: SegmentedTabs(
                              labels: const ['الكل', 'نشط', 'منتهي', 'شواغر'],
                              index: const [
                                'all',
                                'active',
                                'expired',
                                'empty',
                              ].indexOf(_filter),
                              onChanged: (i) => setState(
                                () => _filter = const [
                                  'all',
                                  'active',
                                  'expired',
                                  'empty',
                                ][i],
                              ),
                            ),
                          ),
                        ),

                        // Contracts List
                        if (listItems.isEmpty)
                          SliverToBoxAdapter(
                            child: EmptyState(
                              icon: Icons.ac_unit,
                              title: l10n.noData,
                              sub: 'بدّل التصفية أو أضف عقدًا جديدًا.',
                            ),
                          )
                        else
                          SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final item = listItems[index];

                              // If it's an Apartment
                              if (item.runtimeType.toString() == 'Apartment') {
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: theme.colorScheme.outlineVariant
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        IconTile(
                                          icon: Icons.apartment,
                                          tint: context.colors.ink2,
                                          size: 44,
                                          iconSize: 21,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'شقة ${item.apartmentNumber}',
                                                style: theme
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'الدور ${item.floorNumber ?? "-"}',
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                      color: theme
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const StatusChip(
                                          kind: StatusChipKind.neutral,
                                          label: 'شاغرة',
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              // If it's a Contract
                              final contract = item as WinterContract;
                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () => context.go(
                                    '/winter_contracts/details/${contract.id}',
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            IconTile(
                                              icon: Icons.person_outline,
                                              tint: context.colors.winter,
                                              size: 44,
                                              iconSize: 22,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    contract.studentName,
                                                    style: theme
                                                        .textTheme
                                                        .titleMedium
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.calendar_month,
                                                        size: 14,
                                                        color: theme
                                                            .colorScheme
                                                            .onSurfaceVariant,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        'من ${contract.startDate.month}/${contract.startDate.year} إلى ${contract.endDate.month}/${contract.endDate.year}',
                                                        style: theme
                                                            .textTheme
                                                            .bodySmall
                                                            ?.copyWith(
                                                              color: theme
                                                                  .colorScheme
                                                                  .onSurfaceVariant,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '${contract.monthlyRentEgp.toCurrencyFormat()} ج.م',
                                                  style: theme
                                                      .textTheme
                                                      .titleMedium
                                                      ?.copyWith(
                                                        color: theme
                                                            .colorScheme
                                                            .primary,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                                Text(
                                                  'شهرياً',
                                                  style: theme
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: theme
                                                            .colorScheme
                                                            .onSurfaceVariant,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const Divider(height: 24),
                                        Builder(
                                          builder: (context) {
                                            final contractPayments = payments
                                                .where(
                                                  (p) =>
                                                      p.contractId ==
                                                      contract.id,
                                                )
                                                .toList();
                                            final rentStatus =
                                                calculateWinterRentStatus(
                                                  contract,
                                                  contractPayments,
                                                );

                                            if (!rentStatus.hasOverdue) {
                                              return const SizedBox.shrink();
                                            }

                                            return Container(
                                              margin: const EdgeInsets.only(
                                                bottom: 16,
                                              ),
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: theme.colorScheme.error
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.warning_amber_rounded,
                                                    color:
                                                        theme.colorScheme.error,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          rentStatus
                                                                  .statusTitle ??
                                                              'متأخرات',
                                                          style: theme
                                                              .textTheme
                                                              .titleSmall
                                                              ?.copyWith(
                                                                color: theme
                                                                    .colorScheme
                                                                    .error,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                        Text(
                                                          'المتبقي: ${rentStatus.remainingAmount.toCurrencyFormat()} ج.م',
                                                          style: theme
                                                              .textTheme
                                                              .bodySmall
                                                              ?.copyWith(
                                                                color: theme
                                                                    .colorScheme
                                                                    .error,
                                                              ),
                                                        ),
                                                        if (rentStatus
                                                                .statusDetails !=
                                                            null)
                                                          Text(
                                                            rentStatus
                                                                .statusDetails!,
                                                            style: theme
                                                                .textTheme
                                                                .bodySmall
                                                                ?.copyWith(
                                                                  color: theme
                                                                      .colorScheme
                                                                      .error,
                                                                ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            StatusChip(
                                              kind: contract.isActive
                                                  ? StatusChipKind.ok
                                                  : StatusChipKind.err,
                                              icon: contract.isActive
                                                  ? Icons.check_circle_outline
                                                  : Icons.cancel_outlined,
                                              label: contract.isActive
                                                  ? 'نشط'
                                                  : 'منتهي',
                                            ),
                                            StatusChip(
                                              kind: StatusChipKind.neutral,
                                              icon: Icons.bolt,
                                              label:
                                                  contract
                                                      .isElectricityOnStudent
                                                  ? 'كهرباء: على الطالب'
                                                  : 'كهرباء: على المبنى',
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }, childCount: listItems.length),
                          ),
                      ],
                    ),
                  );
                },
                loading: () => const LoadingSkeleton(),
                error: (e, st) => ErrorState(
                  title: 'تعذّر تحميل البيانات',
                  message: '$e',
                  retryLabel: 'إعادة المحاولة',
                  onRetry: () => ref.invalidate(allWinterPaymentsProvider),
                ),
              );
            },
            loading: () => const LoadingSkeleton(),
            error: (e, st) => ErrorState(
              title: 'تعذّر تحميل البيانات',
              message: '$e',
              retryLabel: 'إعادة المحاولة',
              onRetry: () => ref.invalidate(apartmentsProvider),
            ),
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
      floatingActionButton: AppFab(
        label: 'عقد جديد',
        onPressed: () {
          context.go('/winter_contracts/add');
        },
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    bool isHighlight = false,
  }) {
    final colors = context.colors;
    final tint = isHighlight ? colors.winter : colors.ink2;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isHighlight
              ? colors.winter.withValues(alpha: 0.4)
              : colors.border,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: tint),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(color: colors.ink3),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.tabular(
              AppTextStyles.title.copyWith(
                color: isHighlight ? colors.winter : colors.ink,
              ),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
