import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/technicians_provider.dart';
import '../providers/maintenance_provider.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/widgets.dart';

class TechnicianDetailsScreen extends ConsumerWidget {
  final String technicianId;

  const TechnicianDetailsScreen({super.key, required this.technicianId});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final techniciansAsync = ref.watch(techniciansProvider);
    final maintenanceAsync = ref.watch(maintenanceProvider);
    final colors = context.colors;

    return AppScaffold(
      appBar: const AbragAppBar(title: 'تفاصيل العامل'),
      body: techniciansAsync.when(
        data: (technicians) {
          final tech = technicians.firstWhere(
            (t) => t.id == technicianId,
            orElse: () => throw Exception('العامل غير موجود'),
          );
          final hasPhone = tech.phone != null && tech.phone!.isNotEmpty;
          final hasSecondary =
              tech.secondaryPhone != null && tech.secondaryPhone!.isNotEmpty;
          final hasNotes = tech.notes != null && tech.notes!.isNotEmpty;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              // Technician Info Card
              AppCard(
                child: Column(
                  children: [
                    IconTile(
                      icon: Icons.engineering,
                      tint: colors.brand,
                      size: 72,
                      iconSize: 34,
                      radius: 36,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      tech.name,
                      style: AppTextStyles.h2.copyWith(color: colors.ink),
                    ),
                    const SizedBox(height: 6),
                    StatusChip(label: tech.specialty, kind: StatusChipKind.brand),
                    if (hasPhone) ...[
                      const SizedBox(height: 16),
                      AppButton(
                        label: tech.phone!,
                        icon: Icons.call,
                        onPressed: () => _makePhoneCall(tech.phone!),
                      ),
                    ],
                    if (hasSecondary) ...[
                      const SizedBox(height: 10),
                      AppButton(
                        label: tech.secondaryPhone!,
                        icon: Icons.call_outlined,
                        variant: AppButtonVariant.outline,
                        onPressed: () => _makePhoneCall(tech.secondaryPhone!),
                      ),
                    ],
                    if (hasNotes) ...[
                      Divider(height: 32, color: colors.border),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          'تقييم / ملاحظات:',
                          style:
                              AppTextStyles.label.copyWith(color: colors.ink2),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          tech.notes!,
                          style: AppTextStyles.body.copyWith(color: colors.ink),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SectionTitle(title: 'سجل أعمال الصيانة'),

              // Maintenance History
              maintenanceAsync.when(
                data: (requests) {
                  final techRequests = requests
                      .where((r) => r.technicianId == technicianId)
                      .toList();
                  final totalSystemRequestsCount = requests.length;

                  if (techRequests.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: EmptyState(
                        icon: Icons.history,
                        title: 'لم يقم بأي أعمال صيانة مسجلة حتى الآن',
                      ),
                    );
                  }

                  techRequests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                  final completedRequests = techRequests
                      .where((r) => r.status == 'resolved')
                      .toList();
                  final sharePercentage = totalSystemRequestsCount == 0
                      ? 0.0
                      : (techRequests.length / totalSystemRequestsCount) * 100;
                  final totalCost = completedRequests.fold<double>(
                    0,
                    (sum, r) => sum + r.costEgp,
                  );

                  return Column(
                    children: [
                      AppCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: _StatCol(
                                label: 'إجمالي طلباته',
                                value: '${techRequests.length}',
                                tint: colors.brand,
                              ),
                            ),
                            _divider(colors.border),
                            Expanded(
                              child: _StatCol(
                                label: 'نسبته من الشغل',
                                value:
                                    '${sharePercentage.toStringAsFixed(1)}%',
                                tint: colors.ok,
                              ),
                            ),
                            _divider(colors.border),
                            Expanded(
                              child: _StatCol(
                                label: 'إجمالي ما تقاضاه',
                                value: '${totalCost.toCurrencyFormat()} ج',
                                tint: colors.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (final req in techRequests)
                        _HistoryRow(
                          issue: req.issueDescription,
                          date: req.createdAt
                              .toLocal()
                              .toString()
                              .split(' ')[0],
                          isResolved: req.status == 'resolved',
                          cost: req.costEgp > 0
                              ? '${req.costEgp.toCurrencyFormat()} ج.م'
                              : null,
                        ),
                    ],
                  );
                },
                loading: () => const LoadingSkeleton(),
                error: (e, st) => Text(
                  'خطأ: $e',
                  style: AppTextStyles.body.copyWith(color: colors.err),
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingSkeleton(),
        error: (e, st) => ErrorState(
          title: 'تعذّر تحميل بيانات العامل',
          message: 'خطأ: $e',
          retryLabel: 'إعادة المحاولة',
          onRetry: () => ref.invalidate(techniciansProvider),
        ),
      ),
    );
  }

  Widget _divider(Color color) =>
      Container(width: 1, height: 40, color: color);
}

class _StatCol extends StatelessWidget {
  const _StatCol({required this.label, required this.value, required this.tint});

  final String label;
  final String value;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.tabular(
            AppTextStyles.h3.copyWith(color: tint),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption.copyWith(color: colors.ink3),
        ),
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.issue,
    required this.date,
    required this.isResolved,
    required this.cost,
  });

  final String issue;
  final String date;
  final bool isResolved;
  final String? cost;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  issue,
                  style: AppTextStyles.body.copyWith(color: colors.ink),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: AppTextStyles.caption.copyWith(color: colors.ink3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusChip(
                label: isResolved ? 'مكتمل' : 'مفتوح',
                kind: isResolved ? StatusChipKind.ok : StatusChipKind.err,
              ),
              if (isResolved && cost != null) ...[
                const SizedBox(height: 4),
                Text(
                  cost!,
                  style: AppTextStyles.tabular(
                    AppTextStyles.label.copyWith(color: colors.ink),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
