import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../domain/services/pdf_export_service.dart';
import '../models/report_view_models.dart';
import '../providers/reports_provider.dart';

class StatementPreviewScreen extends ConsumerWidget {
  final ReportFilterState filters;

  const StatementPreviewScreen({
    super.key,
    this.filters = const ReportFilterState(),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(financialReportProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('معاينة كشف الحساب PDF')),
      body: reportAsync.when(
        data: (report) {
          final filtered = ReportCalculator.filteredTransactions(
            report,
            filters,
            technicianWorkAsTransactions: true,
          );
          final totalRev = filtered
              .where((t) => t.isRevenue)
              .fold(0.0, (sum, t) => sum + t.amount);
          final totalExp = filtered
              .where((t) => !t.isRevenue)
              .fold(0.0, (sum, t) => sum + t.amount);
          final profit = totalRev - totalExp;
          final baseTitle = filters.partyType == 'all'
              ? 'كشف حساب'
              : 'كشف حساب ${_partyLabel(report)}';
          final filtersLabel = _filtersLabel(report);
          final title = filtersLabel.isEmpty
              ? baseTitle
              : '$baseTitle - $filtersLabel';

          return PdfPreview(
            build: (format) => PdfExportService.generateStatementPdf(
              title: title,
              dateRange: filters.dateRangeLabel,
              totalRevenue: totalRev,
              totalExpenses: totalExp,
              netProfit: profit,
              transactions: filtered
                  .map(
                    (t) => {
                      'date': t.date.toLocal().toString().split(' ')[0],
                      'description': [
                        t.description,
                        if (t.apartmentNumber != null)
                          'شقة ${t.apartmentNumber}',
                        if (t.buildingName != null) t.buildingName,
                        if (t.brokerName != null && t.brokerName!.isNotEmpty)
                          'سمسار: ${t.brokerName}',
                        if (t.technicianName != null &&
                            t.technicianName!.isNotEmpty)
                          'عامل: ${t.technicianName}',
                        'طريقة الدفع: ${_paymentMethodLabel(t.paymentMethod)}',
                        if (t.brokerCommission > 0)
                          'عمولة السمسار: ${t.brokerCommission.toCurrencyFormat()} ج.م',
                      ].join(' - '),
                      'amount': t.isRevenue
                          ? '+ ${t.amount.toCurrencyFormat()}'
                          : '- ${t.amount.toCurrencyFormat()}',
                      'isRevenue': t.isRevenue,
                    },
                  )
                  .toList(),
            ),
            allowPrinting: true,
            allowSharing: true,
            canChangeOrientation: false,
            canChangePageFormat: false,
            canDebug: false,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  String _partyLabel(FinancialSummary report) {
    final options = ReportCalculator.partyOptions(report, filters.partyType);
    return options[filters.selectedPartyKey] ?? 'كل الحسابات';
  }

  String _filtersLabel(FinancialSummary report) {
    final labels = <String>[];
    if (filters.transactionType == 'revenue') labels.add('إيرادات فقط');
    if (filters.transactionType == 'expense') labels.add('مصروفات فقط');
    if (filters.paymentMethod != 'all') {
      labels.add(_paymentMethodLabel(filters.paymentMethod));
    }
    if (filters.season == 'summer') labels.add('موسم الصيف');
    if (filters.season == 'winter') labels.add('موسم الشتاء');
    if (filters.expenseType != 'all') {
      labels.add(expenseTypeLabel(filters.expenseType));
    }
    if (filters.personQuery.isNotEmpty) {
      labels.add('بحث: ${filters.personQuery}');
    }
    return labels.join(' - ');
  }

  String _paymentMethodLabel(String method) {
    switch (method) {
      case 'cash':
        return 'نقدي';
      case 'vodafone_cash':
        return 'فودافون كاش';
      case 'instapay':
        return 'إنستاباي';
      case 'deposit_deduction':
        return 'خصم من التأمين';
      default:
        return 'كل طرق الدفع';
    }
  }
}
