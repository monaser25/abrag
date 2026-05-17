import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/database.dart';
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

  void _showTransferSheet({FinancialTransfer? transfer}) {
    if (transfer == null) {
      _amountController.clear();
      _notesController.clear();
      _fromAccount = 'cash';
      _toAccount = 'instapay';
      _transferType = 'internal';
      _season = ref.read(selectedFinancialSeasonProvider);
    } else {
      _amountController.text = transfer.amountEgp.toString();
      _notesController.text = transfer.notes ?? '';
      _fromAccount = transfer.fromAccount;
      _toAccount = transfer.toAccount;
      _transferType = transfer.transferType;
      _season = transfer.season;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.82,
          minChildSize: 0.45,
          maxChildSize: 0.95,
          builder: (context, scrollController) => StatefulBuilder(
            builder: (context, setSheetState) {
              final controllerState = ref.watch(
                financialTransfersControllerProvider,
              );
              final isEditing = transfer != null;
              return SafeArea(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          isEditing ? 'تعديل عملية مالية' : 'عملية مالية جديدة',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'نوع العملية'),
                          initialValue: _transferType,
                          items: const [
                            DropdownMenuItem(
                              value: 'internal',
                              child: Text('تحويل داخلي'),
                            ),
                            DropdownMenuItem(
                              value: 'cash_deposit',
                              child: Text('توريد نقدية لخزنة الشركة'),
                            ),
                          ],
                          onChanged: (value) => setSheetState(() {
                            _transferType = value ?? _transferType;
                            if (_transferType == 'cash_deposit') {
                              _fromAccount = 'cash';
                              _toAccount = 'company_vault';
                            } else {
                              if (!paymentAccounts.containsKey(_toAccount)) {
                                _toAccount = 'instapay';
                              }
                              if (_fromAccount == _toAccount) {
                                _toAccount = paymentAccounts.keys.firstWhere(
                                  (account) => account != _fromAccount,
                                );
                              }
                            }
                          }),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'الموسم'),
                          initialValue: _season,
                          items: const [
                            DropdownMenuItem(
                              value: 'all',
                              child: Text('عام / كل المواسم'),
                            ),
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
                              .map(
                                (entry) => DropdownMenuItem(
                                  value: entry.key,
                                  child: Text(entry.value),
                                ),
                              )
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
                                .map(
                                  (entry) => DropdownMenuItem(
                                    value: entry.key,
                                    child: Text(entry.value),
                                  ),
                                )
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
                          validator: (value) =>
                              value == null || value.trim().isEmpty
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
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: controllerState.isLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    final amount = double.tryParse(
                                          _amountController.text
                                              .replaceAll(',', '')
                                              .trim(),
                                        ) ??
                                        0;
                                    final controller = ref.read(
                                      financialTransfersControllerProvider
                                          .notifier,
                                    );
                                    if (isEditing) {
                                      controller.updateTransfer(
                                        id: transfer.id,
                                        fromAccount: _fromAccount,
                                        toAccount: _toAccount,
                                        amount: amount,
                                        date: transfer.transferDate,
                                        transferType: _transferType,
                                        season: _season,
                                        notes: _notesController.text,
                                      );
                                    } else {
                                      controller.addTransfer(
                                        fromAccount: _fromAccount,
                                        toAccount: _toAccount,
                                        amount: amount,
                                        date: DateTime.now(),
                                        transferType: _transferType,
                                        season: _season,
                                        notes: _notesController.text,
                                      );
                                    }
                                  }
                                },
                          icon: controllerState.isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.save),
                          label: Text(isEditing ? 'حفظ التعديل' : 'حفظ العملية'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _seasonLabel(String season) {
    switch (season) {
      case 'summer':
        return 'الصيف';
      case 'winter':
        return 'الشتاء';
      default:
        return 'كل المواسم';
    }
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
            data: (balances) {
              final total = balances.values.fold<double>(0, (sum, v) => sum + v);
              final entries = [
                const MapEntry('total', 'إجمالي الفلوس'),
                ...treasuryAccounts.entries,
              ];
              return LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth < 520
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 8) / 2;
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: entries.map((entry) {
                      final balance = entry.key == 'total'
                          ? total
                          : balances[entry.key] ?? 0;
                      return SizedBox(
                        width: width,
                        child: _BalanceCard(
                          title: entry.value,
                          value: '${balance.toCurrencyFormat()} ج.م',
                          isTotal: entry.key == 'total',
                        ),
                      );
                    }).toList(),
                  );
                },
              );
            },
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
                        '${transfer.amountEgp.toCurrencyFormat()} ج.م • ${_seasonLabel(transfer.season)}\n${dateFormat.format(transfer.transferDate)}${transfer.notes == null ? '' : '\n${transfer.notes}'}',
                      ),
                      trailing: IconButton(
                        tooltip: 'تعديل',
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showTransferSheet(transfer: transfer),
                      ),
                      onTap: () => _showTransferSheet(transfer: transfer),
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
        onPressed: () => _showTransferSheet(),
        icon: const Icon(Icons.add),
        label: const Text('عملية جديدة'),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final String title;
  final String value;
  final bool isTotal;

  const _BalanceCard({
    required this.title,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isTotal ? Icons.account_balance_wallet : Icons.payments,
              color: isTotal ? theme.colorScheme.primary : Colors.green,
            ),
            const SizedBox(height: 10),
            Text(title, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
