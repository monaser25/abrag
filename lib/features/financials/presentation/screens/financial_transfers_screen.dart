import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../providers/financial_transfers_provider.dart';

class FinancialTransfersScreen extends ConsumerStatefulWidget {
  const FinancialTransfersScreen({super.key});

  @override
  ConsumerState<FinancialTransfersScreen> createState() =>
      _FinancialTransfersScreenState();
}

class _FinancialTransfersScreenState
    extends ConsumerState<FinancialTransfersScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  String _fromAccount = 'cash';
  String _toAccount = 'instapay';
  String _transferType = 'internal';
  String _season = 'all';

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showAddTransferSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final controllerState = ref.watch(financialTransfersControllerProvider);
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _transferType == 'cash_deposit'
                          ? 'توريد نقدية لخزنة الشركة'
                          : 'تحويل داخلي',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'internal',
                          label: Text('تحويل داخلي'),
                          icon: Icon(Icons.swap_horiz),
                        ),
                        ButtonSegment(
                          value: 'cash_deposit',
                          label: Text('توريد نقدية'),
                          icon: Icon(Icons.account_balance),
                        ),
                      ],
                      selected: {_transferType},
                      onSelectionChanged: (values) => setSheetState(() {
                        _transferType = values.first;
                        if (_transferType == 'cash_deposit') {
                          _fromAccount = 'cash';
                          _toAccount = 'company_vault';
                        }
                      }),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'الموسم'),
                      initialValue: _season,
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('عام / كل المواسم')),
                        DropdownMenuItem(value: 'summer', child: Text('الصيف')),
                        DropdownMenuItem(value: 'winter', child: Text('الشتاء')),
                      ],
                      onChanged: (value) => setSheetState(
                        () => _season = value ?? _season,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'من'),
                      initialValue: _fromAccount,
                      items: paymentAccounts.entries
                          .map((entry) => DropdownMenuItem(
                                value: entry.key,
                                child: Text(entry.value),
                              ))
                          .toList(),
                      onChanged: _transferType == 'cash_deposit'
                          ? null
                          : (value) => setSheetState(
                        () => _fromAccount = value ?? _fromAccount,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_transferType == 'internal')
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'إلى'),
                        initialValue: _toAccount,
                        items: paymentAccounts.entries
                            .map((entry) => DropdownMenuItem(
                                  value: entry.key,
                                  child: Text(entry.value),
                                ))
                            .toList(),
                        onChanged: (value) => setSheetState(
                          () => _toAccount = value ?? _toAccount,
                        ),
                      )
                    else
                      const InputDecorator(
                        decoration: InputDecoration(labelText: 'إلى'),
                        child: Text('خزنة الشركة'),
                      ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(labelText: 'المبلغ'),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [CurrencyInputFormatter()],
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'مطلوب'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'ملاحظات / مكان نقل النقدية',
                        hintText: 'مثال: تم نقل النقدية للخزنة الرئيسية',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: controllerState.isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                ref
                                    .read(
                                      financialTransfersControllerProvider
                                          .notifier,
                                    )
                                    .addTransfer(
                                      fromAccount: _fromAccount,
                                      toAccount: _toAccount,
                                      amount: double.tryParse(_amountController
                                              .text
                                              .replaceAll(',', '')
                                              .trim()) ??
                                          0,
                                      date: DateTime.now(),
                                      transferType: _transferType,
                                      season: _season,
                                      notes: _notesController.text,
                                    );
                              }
                            },
                      icon: controllerState.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.swap_horiz),
                      label: const Text('حفظ التحويل'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final balancesAsync = ref.watch(accountBalancesProvider);
    final transfersAsync = ref.watch(financialTransfersProvider);
    final theme = Theme.of(context);
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm', 'ar');

    ref.listen<AsyncValue<void>>(financialTransfersControllerProvider, (_, state) {
      state.whenOrNull(
        data: (_) {
          if (Navigator.of(context).canPop()) Navigator.of(context).pop();
          _amountController.clear();
          _notesController.clear();
        },
        error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('الخزنة والتحويلات')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'all', label: Text('الكل')),
              ButtonSegment(value: 'summer', label: Text('الصيف')),
              ButtonSegment(value: 'winter', label: Text('الشتاء')),
            ],
            selected: {ref.watch(selectedFinancialSeasonProvider)},
            onSelectionChanged: (values) => ref
                .read(selectedFinancialSeasonProvider.notifier)
                .state = values.first,
          ),
          const SizedBox(height: 16),
          balancesAsync.when(
            data: (balances) => GridView.count(
              crossAxisCount: 3,
              childAspectRatio: 1.05,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: paymentAccounts.entries.map((entry) {
                final balance = balances[entry.key] ?? 0;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(entry.value, textAlign: TextAlign.center),
                        const SizedBox(height: 8),
                        Text(
                          '${balance.toCurrencyFormat()} ج.م',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text('حدث خطأ: $error'),
          ),
          const SizedBox(height: 16),
          Text('سجل التحويلات', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          transfersAsync.when(
            data: (transfers) {
              if (transfers.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('لا توجد تحويلات حتى الآن')),
                  ),
                );
              }
              return Column(
                children: transfers.map((transfer) {
                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.swap_horiz)),
                      title: Text(
                        transfer.transferType == 'cash_deposit'
                            ? 'توريد نقدية إلى خزنة الشركة'
                            : '${paymentAccounts[transfer.fromAccount] ?? transfer.fromAccount} ← ${paymentAccounts[transfer.toAccount] ?? transfer.toAccount}',
                      ),
                      subtitle: Text(
                        '${dateFormat.format(transfer.transferDate)}${transfer.notes == null ? '' : '\n${transfer.notes}'}',
                      ),
                      trailing: Text(
                        '${transfer.amountEgp.toCurrencyFormat()} ج.م',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text('حدث خطأ: $error'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTransferSheet,
        icon: const Icon(Icons.add),
        label: const Text('تحويل'),
      ),
    );
  }
}
