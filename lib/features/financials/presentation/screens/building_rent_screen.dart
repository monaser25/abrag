import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.buildingRent),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showRentSettingsDialog(context, ref),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: buildingsAsync.when(
              data: (buildings) {
                if (buildings.isEmpty) return const SizedBox.shrink();
                final b = buildings.first;
                final annualRent = b.annualRentEgp;
                final rawDates = b.rentInstallmentsDates ?? '';
                String formattedDates = 'غير محدد';
                if (rawDates.isNotEmpty) {
                  try {
                    final d = rawDates.split(',').map((e) => DateTime.parse(e.trim())).toList();
                    d.sort();
                    formattedDates = d.asMap().entries.map((e) => 'القسط ${e.key + 1}: ${e.value.toLocal().toString().split(' ')[0]}').join('\n');
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

                return Card(
                  margin: const EdgeInsets.all(16),
                  color: theme.colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'الإيجار السنوي:',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            Text(
                              '${annualRent.toCurrencyFormat()} ج.م',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'المدفوع:',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            Text(
                              '${totalPaid.toCurrencyFormat()} ج.م',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'المتبقي:',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            Text(
                              '${remaining.toDouble().toCurrencyFormat()} ج.م',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        Text(
                          'مواعيد الأقساط المتفق عليها:',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        Text(
                          formattedDates,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ),
          SliverFillRemaining(
            child: rentAsync.when(
              data: (rents) {
                if (rents.isEmpty) {
                  return Center(child: Text(l10n.noData));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: rents.length,
                  itemBuilder: (context, index) {
                    final rent = rents[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                          backgroundColor: theme.colorScheme.primary
                                              .withValues(alpha: 0.1),
                                          child: Icon(
                                            Icons.home_work,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'دفعة إيجار المبنى (القسط ${rent.installmentNumber ?? "-"})',
                                              style: theme.textTheme.titleMedium,
                                            ),
                                            Text(
                                              rent.expenseDate
                                                  .toLocal()
                                                  .toString()
                                                  .split(' ')[0],
                                              style: theme.textTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          '${(rent.amountEgp - rent.discountEgp).toCurrencyFormat()} ج.م',
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit, size: 20),
                                          onPressed: () {
                                            context.go('/building_rent/edit', extra: rent);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                if (rent.discountEgp > 0) ...[
                                  const Divider(height: 24),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'خصم: ${rent.discountReason ?? "بدون سبب"}',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      Text(
                                        '${rent.discountEgp.toCurrencyFormat()} ج.م',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            context.go('/building_rent/add');
          },
          child: const Icon(Icons.add),
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
          return AlertDialog(
            title: const Text('إعدادات الإيجار'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: rentController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [CurrencyInputFormatter()],
                    decoration: const InputDecoration(
                      labelText: 'قيمة الإيجار السنوي (ج.م)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('مواعيد الأقساط:'),
                      TextButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('إضافة موعد'),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now().add(const Duration(days: 1000)),
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
                  if (selectedDates.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('لم يتم تحديد مواعيد'),
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
                            title: Text('القسط ${index + 1}: ${date.toLocal().toString().split(' ')[0]}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
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
              ElevatedButton(
                onPressed: () {
                  final datesString = selectedDates.map((d) => d.toIso8601String()).join(',');
                  ref
                      .read(buildingsControllerProvider.notifier)
                      .updateRentSettings(
                        building.id,
                        double.tryParse(rentController.text.replaceAll(',', '')) ?? 0.0,
                        datesString,
                      );
                  Navigator.pop(ctx);
                },
                child: const Text('حفظ'),
              ),
            ],
          );
        }
      ),
    );
  }
}
