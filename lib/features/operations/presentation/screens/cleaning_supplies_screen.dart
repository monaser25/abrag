import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cleaning_supplies_provider.dart';
import '../../../../core/database/database.dart';
import '../../../../core/utils/currency_formatter.dart';

class CleaningSuppliesScreen extends ConsumerStatefulWidget {
  const CleaningSuppliesScreen({super.key});

  @override
  ConsumerState<CleaningSuppliesScreen> createState() => _CleaningSuppliesScreenState();
}

class _CleaningSuppliesScreenState extends ConsumerState<CleaningSuppliesScreen> {
  void _showAddEditSupplyDialog([CleaningSupply? supply]) {
    final nameController = TextEditingController(text: supply?.name ?? '');
    final unitController = TextEditingController(text: supply?.unit ?? 'عبوة');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(supply == null ? 'إضافة صنف جديد' : 'تعديل صنف'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'اسم الصنف (كلور، معطر، صابون)'),
                validator: (v) => v == null || v.trim().isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: unitController.text,
                decoration: const InputDecoration(labelText: 'وحدة القياس'),
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
          ElevatedButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              if (supply == null) {
                ref.read(cleaningSuppliesControllerProvider.notifier).addSupply(
                  nameController.text.trim(),
                  unitController.text,
                );
              } else {
                ref.read(cleaningSuppliesControllerProvider.notifier).updateSupply(
                  supply.id,
                  nameController.text.trim(),
                  unitController.text,
                );
              }
              Navigator.pop(ctx);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showTransactionDialog(CleaningSupply supply) {
    final quantityController = TextEditingController();
    final costController = TextEditingController();
    final notesController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تسجيل عملية شراء جديدة'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('الصنف: ${supply.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextFormField(
                  controller: quantityController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: 'الكمية (${supply.unit})'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'مطلوب';
                    final qty = double.tryParse(v);
                    if (qty == null || qty <= 0) return 'كمية غير صحيحة';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: costController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [CurrencyInputFormatter()],
                  decoration: const InputDecoration(labelText: 'التكلفة الإجمالية (ج.م)'),
                  validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text('سيتم تسجيل التكلفة تلقائياً في المصروفات', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'ملاحظات (مثل اسم المحل، أو اسم العامل المُستلم)'),
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
          ElevatedButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              ref.read(cleaningSuppliesControllerProvider.notifier).logTransaction(
                supplyId: supply.id,
                type: 'purchase',
                quantity: double.parse(quantityController.text.trim()),
                costEgp: double.tryParse(costController.text.replaceAll(',', '').trim()) ?? 0.0,
                notes: notesController.text.trim(),
              );
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('تأكيد الشراء'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final suppliesAsync = ref.watch(cleaningSuppliesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('أدوات ومواد النظافة'),
      ),
      body: suppliesAsync.when(
        data: (supplies) {
          if (supplies.isEmpty) {
            return const Center(child: Text('لا توجد أصناف مسجلة. اضغط + لإضافة صنف.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: supplies.length,
            itemBuilder: (context, index) {
              final supply = supplies[index];
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
                                backgroundColor: theme.colorScheme.primaryContainer,
                                child: Icon(Icons.cleaning_services, color: theme.colorScheme.primary),
                              ),
                              const SizedBox(width: 12),
                              Text(supply.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showAddEditSupplyDialog(supply),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('وحدة القياس: ${supply.unit}', style: theme.textTheme.labelMedium),
                          ElevatedButton.icon(
                            onPressed: () => _showTransactionDialog(supply),
                            icon: const Icon(Icons.shopping_cart, size: 16),
                            label: const Text('تسجيل شراء'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditSupplyDialog(),
        icon: const Icon(Icons.add),
        label: const Text('صنف جديد'),
      ),
    );
  }
}
