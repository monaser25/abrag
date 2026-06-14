import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/widgets.dart';
import '../providers/expenses_provider.dart';
import '../../../buildings/presentation/providers/buildings_controller.dart';

import '../../../../core/utils/currency_formatter.dart';

class BuildingRentScreen extends ConsumerWidget {
  const BuildingRentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final rentAsync = ref.watch(buildingRentProvider);
    final buildingsAsync = ref.watch(buildingsProvider);
    final colors = context.colors;

    return AppScaffold(
      appBar: AbragAppBar(
        title: l10n.buildingRent,
        actions: [
          AppIconButton(
            icon: Icons.settings_outlined,
            tooltip: 'إعدادات الإيجار',
            onPressed: () => _showRentSettingsDialog(context, ref),
          ),
        ],
      ),
      floatingActionButton: AppFab(
        onPressed: () => context.go('/building_rent/add'),
        icon: Icons.add,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          buildingsAsync.when(
            data: (buildings) {
              if (buildings.isEmpty) return const SizedBox.shrink();
              final b = buildings.first;
              final annualRent = b.annualRentEgp;
              final rawDates = b.rentInstallmentsDates ?? '';
              String formattedDates = 'غير محدد';
              if (rawDates.isNotEmpty) {
                try {
                  final d = rawDates
                      .split(',')
                      .map((e) => DateTime.parse(e.trim()))
                      .toList();
                  d.sort();
                  formattedDates = d
                      .asMap()
                      .entries
                      .map(
                        (e) =>
                            'القسط ${e.key + 1}: ${e.value.toLocal().toString().split(' ')[0]}',
                      )
                      .join('\n');
                } catch (e) {
                  formattedDates = rawDates; // fallback to old format
                }
              }

              final totalPaid = rentAsync.maybeWhen(
                data: (rents) => rents.fold<double>(
                  0,
                  (sum, r) => sum + (r.amountEgp - r.discountEgp),
                ),
                orElse: () => 0.0,
              );
              final remaining = (annualRent - totalPaid).clamp(
                0,
                double.infinity,
              );

              return AppCard(
                color: colors.brandSoft,
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconTile(icon: Icons.home_work, tint: colors.brand),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'إيجار المبنى',
                            style: AppTextStyles.h3.copyWith(color: colors.ink),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DetailRow(
                      label: 'الإيجار السنوي',
                      value: '${annualRent.toCurrencyFormat()} ج.م',
                      strong: true,
                    ),
                    DetailRow(
                      label: 'المدفوع',
                      value: '${totalPaid.toCurrencyFormat()} ج.م',
                      valueColor: colors.ok,
                    ),
                    DetailRow(
                      label: 'المتبقي',
                      value: '${remaining.toDouble().toCurrencyFormat()} ج.م',
                      valueColor: colors.err,
                    ),
                    Divider(color: colors.border2),
                    Text(
                      'مواعيد الأقساط المتفق عليها:',
                      style: AppTextStyles.label.copyWith(color: colors.ink2),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDates,
                      style: AppTextStyles.body.copyWith(color: colors.ink),
                      softWrap: true,
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
          rentAsync.when(
            data: (rents) {
              if (rents.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: EmptyState(
                    icon: Icons.home_work_outlined,
                    title: l10n.noData,
                  ),
                );
              }

              return Column(
                children: [
                  for (final rent in rents)
                    _RentRow(
                      title:
                          'دفعة إيجار المبنى (القسط ${rent.installmentNumber ?? "-"})',
                      date: rent.expenseDate.toLocal().toString().split(' ')[0],
                      amount:
                          '${(rent.amountEgp - rent.discountEgp).toCurrencyFormat()} ج.م',
                      discount: rent.discountEgp > 0
                          ? 'خصم: ${rent.discountReason ?? "بدون سبب"}'
                          : null,
                      discountAmount: rent.discountEgp > 0
                          ? '${rent.discountEgp.toCurrencyFormat()} ج.م'
                          : null,
                      onEdit: () =>
                          context.go('/building_rent/edit', extra: rent),
                    ),
                ],
              );
            },
            loading: () => const LoadingSkeleton(),
            error: (error, stack) => ErrorState(
              title: 'تعذّر تحميل الأقساط',
              message: 'Error: $error',
              retryLabel: 'إعادة المحاولة',
              onRetry: () => ref.invalidate(buildingRentProvider),
            ),
          ),
        ],
      ),
    );
  }

  void _showRentSettingsDialog(BuildContext context, WidgetRef ref) {
    final buildingsAsync = ref.read(buildingsProvider);
    if (buildingsAsync.value == null || buildingsAsync.value!.isEmpty) return;

    final building = buildingsAsync.value!.first;
    final rentController = TextEditingController(
      text: building.annualRentEgp.toString(),
    );

    // Parse existing dates
    final existingDatesText = building.rentInstallmentsDates ?? '';
    List<DateTime> selectedDates = [];
    if (existingDatesText.isNotEmpty) {
      try {
        selectedDates = existingDatesText
            .split(',')
            .map((e) => DateTime.parse(e.trim()))
            .toList();
      } catch (e) {
        // If it was the old free text format, keep it empty or try to handle
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          final colors = context.colors;
          return AlertDialog(
            backgroundColor: colors.surface,
            title: const Text('إعدادات الإيجار'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextField(
                    controller: rentController,
                    label: 'قيمة الإيجار السنوي (ج.م)',
                    prefixIcon: Icons.payments_outlined,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [CurrencyInputFormatter()],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'مواعيد الأقساط:',
                        style:
                            AppTextStyles.label.copyWith(color: colors.ink2),
                      ),
                      AppButton(
                        label: 'إضافة موعد',
                        icon: Icons.add,
                        variant: AppButtonVariant.ghost,
                        small: true,
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now().add(
                              const Duration(days: 1000),
                            ),
                          );
                          if (picked != null) {
                            setState(() {
                              selectedDates.add(picked);
                              selectedDates.sort();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (selectedDates.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'لم يتم تحديد مواعيد',
                        style:
                            AppTextStyles.bodyS.copyWith(color: colors.ink3),
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: selectedDates.length,
                        itemBuilder: (context, index) {
                          final date = selectedDates[index];
                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              'القسط ${index + 1}: ${date.toLocal().toString().split(' ')[0]}',
                              style: AppTextStyles.body
                                  .copyWith(color: colors.ink),
                            ),
                            trailing: AppIconButton(
                              icon: Icons.delete_outline,
                              onPressed: () {
                                setState(() {
                                  selectedDates.removeAt(index);
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إلغاء'),
              ),
              AppButton(
                label: 'حفظ',
                small: true,
                onPressed: () {
                  final datesString = selectedDates
                      .map((d) => d.toIso8601String())
                      .join(',');
                  ref
                      .read(buildingsControllerProvider.notifier)
                      .updateRentSettings(
                        building.id,
                        double.tryParse(
                              rentController.text.replaceAll(',', ''),
                            ) ??
                            0.0,
                        datesString,
                      );
                  Navigator.pop(ctx);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RentRow extends StatelessWidget {
  const _RentRow({
    required this.title,
    required this.date,
    required this.amount,
    required this.onEdit,
    this.discount,
    this.discountAmount,
  });

  final String title;
  final String date;
  final String amount;
  final VoidCallback onEdit;
  final String? discount;
  final String? discountAmount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconTile(icon: Icons.home_work, tint: colors.brand),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.title.copyWith(color: colors.ink),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      date,
                      style:
                          AppTextStyles.caption.copyWith(color: colors.ink3),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount,
                    style: AppTextStyles.tabular(
                      AppTextStyles.title.copyWith(color: colors.ink),
                    ),
                  ),
                  AppIconButton(icon: Icons.edit_outlined, onPressed: onEdit),
                ],
              ),
            ],
          ),
          if (discount != null) ...[
            Divider(height: 20, color: colors.border),
            Row(
              children: [
                Expanded(
                  child: Text(
                    discount!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyS.copyWith(color: colors.ink2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  discountAmount ?? '',
                  style: AppTextStyles.bodyS.copyWith(color: colors.ink2),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
