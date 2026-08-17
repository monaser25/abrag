import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/widgets.dart';
import '../providers/maintenance_provider.dart';
import '../providers/maintenance_controller.dart';
import '../providers/technicians_provider.dart';
import '../../../apartments/presentation/providers/apartments_controller.dart';

import '../../../../core/utils/currency_formatter.dart';

class MaintenanceRequestsScreen extends ConsumerStatefulWidget {
  const MaintenanceRequestsScreen({super.key});

  @override
  ConsumerState<MaintenanceRequestsScreen> createState() =>
      _MaintenanceRequestsScreenState();
}

class _MaintenanceRequestsScreenState
    extends ConsumerState<MaintenanceRequestsScreen> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final maintenanceAsync = ref.watch(maintenanceProvider);
    final apartmentsAsync = ref.watch(apartmentsProvider);
    final techniciansAsync = ref.watch(techniciansProvider);

    return AppScaffold(
      appBar: AbragAppBar(title: l10n.maintenance),
      floatingActionButton: AppFab(
        onPressed: () => context.go('/maintenance/add'),
        icon: Icons.add,
      ),
      body: maintenanceAsync.when(
        data: (requests) {
          if (requests.isEmpty) {
            return EmptyState(icon: Icons.build_outlined, title: l10n.noData);
          }

          final now = DateTime.now();
          final filteredRequests = requests.where((req) {
            if (_selectedFilter == 'open') return req.status == 'open';
            if (_selectedFilter == 'closed') return req.status != 'open';
            if (_selectedFilter == 'this_month') {
              return req.createdAt.year == now.year &&
                  req.createdAt.month == now.month;
            }
            return true;
          }).toList();

          return Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    _FilterPill(
                      label: 'الكل',
                      isSelected: _selectedFilter == 'all',
                      onTap: () => setState(() => _selectedFilter = 'all'),
                    ),
                    const SizedBox(width: 8),
                    _FilterPill(
                      label: 'مفتوح',
                      isSelected: _selectedFilter == 'open',
                      onTap: () => setState(() => _selectedFilter = 'open'),
                    ),
                    const SizedBox(width: 8),
                    _FilterPill(
                      label: 'مغلق',
                      isSelected: _selectedFilter == 'closed',
                      onTap: () => setState(() => _selectedFilter = 'closed'),
                    ),
                    const SizedBox(width: 8),
                    _FilterPill(
                      label: 'خلال الشهر',
                      isSelected: _selectedFilter == 'this_month',
                      onTap: () =>
                          setState(() => _selectedFilter = 'this_month'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filteredRequests.isEmpty
                    ? EmptyState(icon: Icons.build_outlined, title: l10n.noData)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                        itemCount: filteredRequests.length,
                        itemBuilder: (context, index) {
                          final req = filteredRequests[index];
                          final isOpen = req.status == 'open';
                          final apartmentNumber = apartmentsAsync.maybeWhen(
                            data: (apts) {
                              final matches = apts
                                  .where((a) => a.id == req.apartmentId)
                                  .toList();
                              return matches.isEmpty
                                  ? req.apartmentId
                                  : matches.first.apartmentNumber;
                            },
                            orElse: () => req.apartmentId,
                          );
                          final techName = req.technicianId != null
                              ? techniciansAsync.maybeWhen(
                                  data: (techs) => techs
                                      .where((t) => t.id == req.technicianId)
                                      .map((t) => t.name)
                                      .firstOrNull,
                                  orElse: () => null,
                                )
                              : null;

                          return _RequestCard(
                            isOpen: isOpen,
                            date: req.createdAt.toLocal().toString().split(
                              ' ',
                            )[0],
                            issue: req.issueDescription,
                            techName: techName,
                            apartmentNumber: apartmentNumber,
                            cost: '${req.costEgp.toCurrencyFormat()} ج.م',
                            onTap: isOpen
                                ? () => _showResolveDialog(context, ref, req)
                                : null,
                            onEdit: isOpen
                                ? () => context.go(
                                    '/maintenance/edit',
                                    extra: req,
                                  )
                                : null,
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const LoadingSkeleton(),
        error: (error, stack) => ErrorState(
          title: 'تعذّر تحميل طلبات الصيانة',
          message: 'Error: $error',
          retryLabel: 'إعادة المحاولة',
          onRetry: () => ref.invalidate(maintenanceProvider),
        ),
      ),
    );
  }

  void _showResolveDialog(BuildContext context, WidgetRef ref, dynamic req) {
    final costController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        final colors = ctx.colors;
        return AlertDialog(
          backgroundColor: colors.surface,
          title: const Text('إغلاق طلب الصيانة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'قم بإدخال تكلفة الصيانة (إن وجدت). سيتم تسجيلها كمصروف تلقائياً.',
                style: AppTextStyles.bodyS.copyWith(color: colors.ink2),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: costController,
                label: 'التكلفة (ج.م)',
                prefixIcon: Icons.payments_outlined,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [CurrencyInputFormatter()],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            AppButton(
              label: 'حفظ وإغلاق',
              small: true,
              onPressed: () {
                final cost =
                    double.tryParse(costController.text.replaceAll(',', '')) ??
                    0.0;
                ref
                    .read(maintenanceControllerProvider.notifier)
                    .updateStatus(req.id, 'resolved', cost: cost);
                Navigator.pop(ctx);
              },
            ),
          ],
        );
      },
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.isOpen,
    required this.date,
    required this.issue,
    required this.techName,
    required this.apartmentNumber,
    required this.cost,
    required this.onTap,
    required this.onEdit,
  });

  final bool isOpen;
  final String date;
  final String issue;
  final String? techName;
  final String apartmentNumber;
  final String cost;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (onEdit != null) ...[
                AppIconButton(icon: Icons.edit_outlined, onPressed: onEdit),
                const SizedBox(width: 4),
              ],
              StatusChip(
                label: isOpen ? 'مفتوح (اضغط للإغلاق)' : 'مغلق',
                kind: isOpen ? StatusChipKind.err : StatusChipKind.ok,
              ),
              const Spacer(),
              Text(
                date,
                style: AppTextStyles.caption.copyWith(color: colors.ink3),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(issue, style: AppTextStyles.body.copyWith(color: colors.ink)),
          if (techName != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.engineering, size: 16, color: colors.ink3),
                const SizedBox(width: 4),
                Text(
                  'الفني: $techName',
                  style: AppTextStyles.caption.copyWith(color: colors.ink2),
                ),
              ],
            ),
          ],
          Divider(height: 24, color: colors.border),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.apartment, size: 16, color: colors.ink3),
                  const SizedBox(width: 4),
                  Text(
                    'شقة $apartmentNumber',
                    style: AppTextStyles.label.copyWith(color: colors.ink2),
                  ),
                ],
              ),
              if (!isOpen)
                Text(
                  cost,
                  style: AppTextStyles.tabular(
                    AppTextStyles.title.copyWith(color: colors.ink),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Tappable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? colors.brandSoft : colors.surface,
          borderRadius: AppRadius.rPill,
          border: Border.all(color: isSelected ? colors.brand : colors.border),
        ),
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: isSelected ? colors.brand : colors.ink2,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
