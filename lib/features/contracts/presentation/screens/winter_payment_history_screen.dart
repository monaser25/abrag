import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/contract_payment_controller.dart';
import '../providers/contracts_provider.dart';
import '../../../../core/database/tables.dart';

class WinterPaymentHistoryScreen extends ConsumerStatefulWidget {
  final String contractId;

  const WinterPaymentHistoryScreen({super.key, required this.contractId});

  @override
  ConsumerState<WinterPaymentHistoryScreen> createState() => _WinterPaymentHistoryScreenState();
}

class _WinterPaymentHistoryScreenState extends ConsumerState<WinterPaymentHistoryScreen> {
  final _amountController = TextEditingController();
  String _paymentMethod = 'cash'; // cash, vodafone_cash, instapay

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _addPayment() {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال مبلغ صحيح')),
      );
      return;
    }

    ref.read(contractPaymentControllerProvider.notifier).addPayment(
      contractId: widget.contractId,
      amount: amount,
      date: DateTime.now(),
    );
    _amountController.clear();
    Navigator.of(context).pop();
  }

  void _showAddPaymentDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('تسجيل دفعة جديدة', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'المبلغ (ج.م)'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _paymentMethod,
                decoration: const InputDecoration(labelText: 'طريقة الدفع'),
                items: const [
                  DropdownMenuItem(value: 'cash', child: Text('كاش')),
                  DropdownMenuItem(value: 'vodafone_cash', child: Text('فودافون كاش')),
                  DropdownMenuItem(value: 'instapay', child: Text('إنستاباي')),
                ],
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      _paymentMethod = v;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _addPayment,
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                child: const Text('تسجيل الدفعة'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final paymentsAsync = ref.watch(contractPaymentsProvider(widget.contractId));
    final contractsAsync = ref.watch(winterContractsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل المدفوعات'),
      ),
      body: Column(
        children: [
          // Header summary
          contractsAsync.when(
            data: (contracts) {
              try {
                final contract = contracts.firstWhere((c) => c.id == widget.contractId);
                return Container(
                  padding: const EdgeInsets.all(16),
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('الإيجار المستحق', style: theme.textTheme.labelMedium),
                          Text('${contract.monthlyRentEgp} ج.م / شهر', style: theme.textTheme.titleMedium),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('الطالب', style: theme.textTheme.labelMedium),
                          Text(contract.studentName, style: theme.textTheme.titleMedium),
                        ],
                      ),
                    ],
                  ),
                );
              } catch (e) {
                return const SizedBox.shrink();
              }
            },
            loading: () => const SizedBox.shrink(),
            error: (err, stack) => const SizedBox.shrink(),
          ),

          // Payments list
          Expanded(
            child: paymentsAsync.when(
              data: (payments) {
                if (payments.isEmpty) {
                  return const Center(child: Text('لا توجد مدفوعات مسجلة'));
                }
                
                // Sort newest first
                final sortedPayments = List.of(payments)..sort((a, b) => b.paymentDate.compareTo(a.paymentDate));

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedPayments.length,
                  itemBuilder: (context, index) {
                    final payment = sortedPayments[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.2),
                          child: Icon(Icons.check, color: theme.colorScheme.secondary),
                        ),
                        title: Text('${payment.amountEgp} ج.م'),
                        subtitle: Text(payment.paymentDate.toLocal().toString().split(' ')[0]),
                        trailing: Text(
                          payment.syncStatus == SyncStatus.pendingInsert ? 'جاري المزامنة' : 'تم', // 1 = pendingInsert
                          style: TextStyle(
                            color: payment.syncStatus == SyncStatus.pendingInsert ? theme.colorScheme.error : theme.colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPaymentDialog,
        icon: const Icon(Icons.add_card),
        label: const Text('تسجيل دفعة'),
      ),
    );
  }
}
