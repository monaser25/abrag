import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cleaning_supplies_provider.dart';
import '../../../../core/database/database.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/widgets.dart';

class CleaningSuppliesScreen extends ConsumerStatefulWidget {
  const CleaningSuppliesScreen({super.key});

  @override
  ConsumerState<CleaningSuppliesScreen> createState() =>
      _CleaningSuppliesScreenState();
}

class _CleaningSuppliesScreenState
    extends ConsumerState<CleaningSuppliesScreen> {
  void _showAddEditSupplyDialog([CleaningSupply? supply]) {
    final nameController = TextEditingController(text: supply?.name ?? '');
    final unitController = TextEditingController(text: supply?.unit ?? 'عبوة');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        final colors = ctx.colors;
        return AlertDialog(
          backgroundColor: colors.surface,
          title: Text(supply == null ? 'إضافة صنف جديد' : 'تعديل صنف'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  controller: nameController,
                  label: 'اسم الصنف (كلور، معطر، صابون)',
                  prefixIcon: Icons.inventory_2_outlined,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 12),
                AppDropdownField<String>(
                  label: 'وحدة القياس',
                  prefixIcon: Icons.straighten,
                  initialValue: unitController.text,
                  items: const [
                    DropdownMenuItem(value: 'لتر', child: Text('لتر')),
                    DropdownMenuItem(value: 'كيلو', child: Text('كيلو')),
                    DropdownMenuItem(value: 'عبوة', child: Text('عبوة / كيس')),
                    DropdownMenuItem(value: 'قطعة', child: Text('قطعة')),
                  ],
                  onChanged: (v) {
                    if (v != null) unitController.text = v;
                  },
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
                if (!formKey.currentState!.validate()) return;
                if (supply == null) {
                  ref
                      .read(cleaningSuppliesControllerProvider.notifier)
                      .addSupply(
                        nameController.text.trim(),
                        unitController.text,
                      );
                } else {
                  ref
                      .read(cleaningSuppliesControllerProvider.notifier)
                      .updateSupply(
                        supply.id,
                        nameController.text.trim(),
                        unitController.text,
                      );
                }
                Navigator.pop(ctx);
              },
            ),
          ],
        );
      },
    );
  }

  void _showTransactionDialog(CleaningSupply supply) {
    final quantityController = TextEditingController();
    final costController = TextEditingController();
    final notesController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        final colors = ctx.colors;
        return AlertDialog(
          backgroundColor: colors.surface,
          title: const Text('تسجيل عملية شراء جديدة'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'الصنف: ${supply.name}',
                    style: AppTextStyles.title.copyWith(color: colors.ink),
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: quantityController,
                    label: 'الكمية (${supply.unit})',
                    prefixIcon: Icons.numbers,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'مطلوب';
                      final qty = double.tryParse(v);
                      if (qty == null || qty <= 0) return 'كمية غير صحيحة';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: costController,
                    label: 'التكلفة الإجمالية (ج.م)',
                    prefixIcon: Icons.payments_outlined,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [CurrencyInputFormatter()],
                    helperText: 'سيتم تسجيل التكلفة تلقائياً في المصروفات',
                    validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: notesController,
                    label: 'ملاحظات (مثل اسم المحل، أو اسم العامل المُستلم)',
                    prefixIcon: Icons.sticky_note_2_outlined,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            AppButton(
              label: 'تأكيد الشراء',
              icon: Icons.shopping_cart,
              small: true,
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                ref
                    .read(cleaningSuppliesControllerProvider.notifier)
                    .logTransaction(
                      supplyId: supply.id,
                      type: 'purchase',
                      quantity: double.parse(quantityController.text.trim()),
                      costEgp:
                          double.tryParse(
                            costController.text.replaceAll(',', '').trim(),
                          ) ??
                          0.0,
                      notes: notesController.text.trim(),
                    );
                Navigator.pop(ctx);
              },
            ),
          ],
        );
      },
    );
  }

  void _showConsumptionDialog(CleaningSupply supply) {
    final quantityController = TextEditingController();
    final notesController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        final colors = ctx.colors;
        return AlertDialog(
          backgroundColor: colors.surface,
          title: const Text('تسجيل استهلاك'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'الصنف: ${supply.name}',
                    style: AppTextStyles.title.copyWith(color: colors.ink),
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: quantityController,
                    label: 'الكمية المستهلكة (${supply.unit})',
                    prefixIcon: Icons.numbers,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'مطلوب';
                      final qty = double.tryParse(v);
                      if (qty == null || qty <= 0) return 'كمية غير صحيحة';
                      if (qty > supply.stockQuantity) {
                        final available =
                            supply.stockQuantity.truncateToDouble() ==
                                supply.stockQuantity
                            ? supply.stockQuantity.toInt().toString()
                            : supply.stockQuantity.toString();
                        return 'الكمية تتجاوز المتاح ($available)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: notesController,
                    label: 'ملاحظات (مثل: الشقة، أو اسم العامل)',
                    prefixIcon: Icons.sticky_note_2_outlined,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            AppButton(
              label: 'تأكيد الاستهلاك',
              icon: Icons.remove_circle_outline,
              small: true,
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                ref
                    .read(cleaningSuppliesControllerProvider.notifier)
                    .logTransaction(
                      supplyId: supply.id,
                      type: 'consumption',
                      quantity: double.parse(quantityController.text.trim()),
                      notes: notesController.text.trim(),
                    );
                Navigator.pop(ctx);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final suppliesAsync = ref.watch(cleaningSuppliesProvider);
    final colors = context.colors;

    return AppScaffold(
      appBar: const AbragAppBar(title: 'أدوات ومواد النظافة'),
      floatingActionButton: AppFab(
        onPressed: () => _showAddEditSupplyDialog(),
        icon: Icons.add,
        label: 'صنف جديد',
      ),
      body: suppliesAsync.when(
        data: (supplies) {
          if (supplies.isEmpty) {
            return const EmptyState(
              icon: Icons.cleaning_services_outlined,
              title: 'لا توجد أصناف مسجلة. اضغط + لإضافة صنف.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: supplies.length,
            itemBuilder: (context, index) {
              final supply = supplies[index];
              final formattedCount =
                  supply.stockQuantity.truncateToDouble() ==
                      supply.stockQuantity
                  ? supply.stockQuantity.toInt().toString()
                  : supply.stockQuantity.toString();

              return AppCard(
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconTile(
                          icon: Icons.cleaning_services,
                          tint: colors.brand,
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Text(
                            supply.name,
                            style: AppTextStyles.title.copyWith(
                              color: colors.ink,
                            ),
                          ),
                        ),
                        AppIconButton(
                          icon: Icons.edit_outlined,
                          onPressed: () => _showAddEditSupplyDialog(supply),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'المتبقي: $formattedCount ${supply.unit}',
                                style: AppTextStyles.title.copyWith(
                                  color: colors.brand,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'وحدة القياس: ${supply.unit}',
                                style: AppTextStyles.label.copyWith(
                                  color: colors.ink2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        AppButton(
                          label: 'تسجيل استهلاك',
                          icon: Icons.remove_circle_outline,
                          small: true,
                          onPressed: () => _showConsumptionDialog(supply),
                        ),
                        AppButton(
                          label: 'تسجيل شراء',
                          icon: Icons.shopping_cart,
                          variant: AppButtonVariant.royal,
                          small: true,
                          onPressed: () => _showTransactionDialog(supply),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const LoadingSkeleton(),
        error: (e, st) => ErrorState(
          title: 'تعذّر تحميل الأصناف',
          message: 'Error: $e',
          retryLabel: 'إعادة المحاولة',
          onRetry: () => ref.invalidate(cleaningSuppliesProvider),
        ),
      ),
    );
  }
}
