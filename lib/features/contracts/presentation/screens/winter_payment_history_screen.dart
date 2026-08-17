import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/winter_payment_status.dart';
import '../providers/contract_payment_controller.dart';
import '../providers/contracts_provider.dart';
import '../../../../core/database/database.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/widgets.dart';

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

    // يمنع تسجيل نفس الدفعة مرتين لو المستخدم داس "تسجيل" بسرعة مرتين
    // (نفس حماية شاشة تسديد الحجز الصيفي).
    var isSubmitting = false;
    final messenger = ScaffoldMessenger.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
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
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            final amount = double.tryParse(
                              _amountController.text.replaceAll(',', '').trim(),
                            );
                            if (amount == null || amount <= 0) {
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('الرجاء إدخال مبلغ صحيح'),
                                ),
                              );
                              return;
                            }

                            setModalState(() => isSubmitting = true);
                            final controller = ref.read(
                              contractPaymentControllerProvider.notifier,
                            );
                            if (payment == null) {
                              await controller.addPayment(
                                contractId: widget.contractId,
                                amount: amount,
                                date: DateTime.now(),
                                paymentMethod: _paymentMethod,
                              );
                            } else {
                              await controller.updatePayment(
                                id: payment.id,
                                amount: amount,
                                paymentMethod: _paymentMethod,
                              );
                            }
                            if (!sheetContext.mounted) return;
                            final result = ref.read(
                              contractPaymentControllerProvider,
                            );
                            if (result.hasError) {
                              setModalState(() => isSubmitting = false);
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'تعذر حفظ الدفعة: ${result.error.toString().replaceFirst('Exception: ', '')}',
                                  ),
                                ),
                              );
                              return;
                            }
                            _amountController.clear();
                            Navigator.of(sheetContext).pop();
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  payment == null
                                      ? 'تم تسجيل الدفعة بنجاح'
                                      : 'تم حفظ التعديل بنجاح',
                                ),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
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

  /// حذف دفعة اتسجلت بالغلط (تسديد مكرر مثلاً).
  void _confirmDeletePayment(WinterPayment payment) {
    final messenger = ScaffoldMessenger.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف الدفعة'),
        content: Text(
          'سيتم حذف دفعة بقيمة ${payment.amountEgp.toCurrencyFormat()} ج.م '
          'من سجل مدفوعات العقد. هل أنت متأكد؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref
                  .read(contractPaymentControllerProvider.notifier)
                  .deletePayment(payment.id);
              final result = ref.read(contractPaymentControllerProvider);
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    result.hasError
                        ? 'تعذر حذف الدفعة: ${result.error.toString().replaceFirst('Exception: ', '')}'
                        : 'تم حذف الدفعة',
                  ),
                ),
              );
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paymentsAsync = ref.watch(
      contractPaymentsProvider(widget.contractId),
    );
    final contractsAsync = ref.watch(allWinterContractsProvider);
    final theme = Theme.of(context);

    return AppScaffold(
      appBar: const AbragAppBar(title: 'سجل المدفوعات'),
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
                  margin: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 0),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.colors.surface2,
                    borderRadius: BorderRadius.circular(18),
                  ),
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
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
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
                  return const EmptyState(
                    icon: Icons.payments_outlined,
                    title: 'لا توجد مدفوعات مسجلة',
                  );
                }

                // Sort newest first
                final sortedPayments = List.of(payments)
                  ..sort((a, b) => b.paymentDate.compareTo(a.paymentDate));

                final colors = context.colors;
                return ListView(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 90),
                  children: [
                    PaymentTimeline(
                      entries: [
                        for (final payment in sortedPayments)
                          () {
                            final lateInfo = contract == null
                                ? null
                                : lateInfoForWinterPayment(
                                    contract,
                                    payments,
                                    payment,
                                  );
                            final dateText = payment.paymentDate
                                .toLocal()
                                .toString()
                                .split(' ')[0];
                            final subtitle = lateInfo == null
                                ? dateText
                                : '$dateText\n${lateInfo.label}\nتاريخ الاستحقاق: ${lateInfo.dueDate.toLocal().toString().split(' ')[0]}';
                            return PaymentTimelineEntry(
                              title:
                                  '${payment.amountEgp.toCurrencyFormat()} ج.م',
                              subtitle: subtitle,
                              state: TimelineNodeState.paid,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  StatusChip(
                                    kind: lateInfo?.isLate == true
                                        ? StatusChipKind.warn
                                        : StatusChipKind.ok,
                                    icon: Icons.check,
                                    label: 'تم الدفع',
                                  ),
                                  AppIconButton(
                                    icon: Icons.edit_outlined,
                                    onPressed: () =>
                                        _showAddPaymentDialog(payment: payment),
                                  ),
                                  AppIconButton(
                                    icon: Icons.delete_outline,
                                    tooltip: 'حذف الدفعة',
                                    onPressed: () =>
                                        _confirmDeletePayment(payment),
                                  ),
                                ],
                              ),
                            );
                          }(),
                      ],
                    ),
                    if (sortedPayments.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '${sortedPayments.length} دفعة مسجلة',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption.copyWith(
                            color: colors.ink3,
                          ),
                        ),
                      ),
                  ],
                );
              },
              loading: () => const LoadingSkeleton(),
              error: (err, stack) => ErrorState(
                title: 'تعذّر تحميل البيانات',
                message: '$err',
                retryLabel: 'إعادة المحاولة',
                onRetry: () =>
                    ref.invalidate(contractPaymentsProvider(widget.contractId)),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: AppFab(
        icon: Icons.add_card,
        label: 'تسجيل دفعة',
        onPressed: () => _showAddPaymentDialog(),
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
    final colors = context.colors;
    final color = isError ? colors.err : colors.winter;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: colors.ink3),
          ),
          Text(
            value,
            style: AppTextStyles.tabular(
              AppTextStyles.label.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
