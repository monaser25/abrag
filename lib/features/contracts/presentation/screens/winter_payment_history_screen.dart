import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/winter_payment_status.dart';
import '../providers/contract_payment_controller.dart';
import '../providers/contracts_provider.dart';
import '../../../../core/database/database.dart';
import '../../../../core/utils/currency_formatter.dart';

class WinterPaymentHistoryScreen extends ConsumerStatefulWidget {
  final String contractId;

  const WinterPaymentHistoryScreen({super.key, required this.contractId});

  @override
  ConsumerState<WinterPaymentHistoryScreen> createState() =>
      _WinterPaymentHistoryScreenState();
}

class _WinterPaymentHistoryScreenState
    extends ConsumerState<WinterPaymentHistoryScreen> {
  final _amountController = TextEditingController();
  String _paymentMethod = 'cash'; // cash, vodafone_cash, instapay

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _showAddPaymentDialog({WinterPayment? payment}) {
    if (payment != null) {
      _amountController.text = payment.amountEgp.toString();
      _paymentMethod = payment.paymentMethod;
    } else {
      _amountController.clear();
      _paymentMethod = 'cash';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                  Text(
                    payment == null ? 'تسجيل دفعة جديدة' : 'تعديل الدفعة',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [CurrencyInputFormatter()],
                    decoration: const InputDecoration(
                      labelText: 'المبلغ (ج.م)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _paymentMethod,
                    decoration: const InputDecoration(labelText: 'طريقة الدفع'),
                    items: const [
                      DropdownMenuItem(value: 'cash', child: Text('كاش')),
                      DropdownMenuItem(
                        value: 'vodafone_cash',
                        child: Text('فودافون كاش'),
                      ),
                      DropdownMenuItem(
                        value: 'instapay',
                        child: Text('إنستاباي'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        setModalState(() {
                          _paymentMethod = v;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      final amount = double.tryParse(
                        _amountController.text.replaceAll(',', '').trim(),
                      );
                      if (amount == null || amount <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('الرجاء إدخال مبلغ صحيح'),
                          ),
                        );
                        return;
                      }

                      if (payment == null) {
                        ref
                            .read(contractPaymentControllerProvider.notifier)
                            .addPayment(
                              contractId: widget.contractId,
                              amount: amount,
                              date: DateTime.now(),
                              paymentMethod: _paymentMethod,
                            );
                      } else {
                        ref
                            .read(contractPaymentControllerProvider.notifier)
                            .updatePayment(
                              id: payment.id,
                              amount: amount,
                              paymentMethod: _paymentMethod,
                            );
                      }
                      _amountController.clear();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: Text(
                      payment == null ? 'تسجيل الدفعة' : 'حفظ التعديل',
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final paymentsAsync = ref.watch(
      contractPaymentsProvider(widget.contractId),
    );
    final contractsAsync = ref.watch(allWinterContractsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('سجل المدفوعات')),
      body: Column(
        children: [
          // Header summary
          contractsAsync.when(
            data: (contracts) {
              try {
                final contract = contracts.firstWhere(
                  (c) => c.id == widget.contractId,
                );
                final payments =
                    ref
                        .watch(contractPaymentsProvider(widget.contractId))
                        .asData
                        ?.value ??
                    const <WinterPayment>[];
                final rentStatus = calculateWinterRentStatus(
                  contract,
                  payments,
                );
                return Container(
                  padding: const EdgeInsets.all(16),
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'الإيجار الشهري',
                                style: theme.textTheme.labelMedium,
                              ),
                              Text(
                                '${contract.monthlyRentEgp.toCurrencyFormat()} ج.م / شهر',
                                style: theme.textTheme.titleMedium,
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'الطالب',
                                style: theme.textTheme.labelMedium,
                              ),
                              Text(
                                contract.studentName,
                                style: theme.textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _InfoChip(
                            label: 'الأقساط المستحقة',
                            value: '${rentStatus.dueInstallments}',
                          ),
                          _InfoChip(
                            label: 'المطلوب حتى الآن',
                            value:
                                '${rentStatus.expectedAmount.toCurrencyFormat()} ج.م',
                          ),
                          if (rentStatus.hasOverdue)
                            _InfoChip(
                              label: rentStatus.statusTitle ?? 'متأخر',
                              value:
                                  '${rentStatus.remainingAmount.toCurrencyFormat()} ج.م',
                              isError: true,
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'ملحوظة: تاريخ الخروج لا يُحسب قسط إيجار.',
                        style: theme.textTheme.bodySmall,
                      ),
                      if (rentStatus.hasOverdue) ...[
                        const SizedBox(height: 12),
                        const Divider(),
                        Text(
                          'الأقساط المتأخرة:',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...rentStatus.unpaidInstallments.map(
                          (installment) => Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.error.withValues(
                                alpha: 0.05,
                              ),
                              border: Border.all(
                                color: theme.colorScheme.error.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                  Text(
                                    'إيجار شهر ${installment.dueDate.month}',
                                    style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                    Text(
                                      installment.isLate
                                          ? 'متأخر ${installment.daysLate} يوم'
                                          : 'مستحق اليوم',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme.colorScheme.error,
                                          ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${installment.remainingAmount.toCurrencyFormat()} ج.م',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: theme.colorScheme.error,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
                WinterContract? contract;
                final contracts = contractsAsync.asData?.value;
                if (contracts != null) {
                  for (final item in contracts) {
                    if (item.id == widget.contractId) {
                      contract = item;
                      break;
                    }
                  }
                }

                if (payments.isEmpty) {
                  return const Center(child: Text('لا توجد مدفوعات مسجلة'));
                }

                // Sort newest first
                final sortedPayments = List.of(payments)
                  ..sort((a, b) => b.paymentDate.compareTo(a.paymentDate));

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedPayments.length,
                  itemBuilder: (context, index) {
                    final payment = sortedPayments[index];
                    final lateInfo = contract == null
                        ? null
                        : lateInfoForWinterPayment(contract, payments, payment);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.secondary
                              .withValues(alpha: 0.2),
                          child: Icon(
                            Icons.check,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        title: Text(
                          '${payment.amountEgp.toCurrencyFormat()} ج.م',
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              payment.paymentDate.toLocal().toString().split(
                                ' ',
                              )[0],
                            ),
                            if (lateInfo != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                lateInfo.label,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: lateInfo.isLate
                                      ? theme.colorScheme.error
                                      : Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'تاريخ الاستحقاق: ${lateInfo.dueDate.toLocal().toString().split(' ')[0]}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'تم الدفع',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () =>
                                  _showAddPaymentDialog(payment: payment),
                            ),
                          ],
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
        onPressed: () => _showAddPaymentDialog(),
        icon: const Icon(Icons.add_card),
        label: const Text('تسجيل دفعة'),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final bool isError;

  const _InfoChip({
    required this.label,
    required this.value,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isError ? theme.colorScheme.error : theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: theme.textTheme.labelSmall),
          Text(
            value,
            style: theme.textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
