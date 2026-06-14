import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../../../core/services/audit_log_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/season_utils.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';
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

    return AppScaffold(
      appBar: const AbragAppBar(title: 'معاينة كشف الحساب PDF'),
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

          final revenueBreakdown = _breakdownByMethod(filtered, revenue: true);
          final expenseBreakdown = _breakdownByMethod(filtered, revenue: false);
          final netBreakdown = _netBreakdownByMethod(filtered);

          return PdfPreview(
            build: (format) => PdfExportService.generateStatementPdf(
              title: title,
              dateRange: filters.dateRangeLabel,
              totalRevenue: totalRev,
              totalExpenses: totalExp,
              netProfit: profit,
              revenueBreakdown: revenueBreakdown,
              expenseBreakdown: expenseBreakdown,
              netBreakdown: netBreakdown,
              transactions: filtered
                  .map(
                    (t) => {
                      'date': t.date.toLocal().toString().split(' ')[0],
                      'unit': t.apartmentNumber != null
                          ? 'شقة ${t.apartmentNumber}'
                          : '—',
                      'description': [
                        t.description,
                        if (t.buildingName != null) t.buildingName,
                        if (t.technicianName != null &&
                            t.technicianName!.isNotEmpty)
                          'عامل: ${t.technicianName}',
                      ].join(' - '),
                      'broker': (t.brokerName != null && t.brokerName!.isNotEmpty)
                          ? t.brokerName
                          : '—',
                      'commission': t.brokerCommission > 0
                          ? t.brokerCommission.toCurrencyFormat()
                          : '—',
                      'payment': _paymentMethodLabel(t.paymentMethod),
                      // Sign sits to the right of the number (RTL reading).
                      'amount': t.isRevenue
                          ? '${t.amount.toCurrencyFormat()} +'
                          : '${t.amount.toCurrencyFormat()} -',
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
            onPrinted: (_) {
              AuditLogService(ref.read(databaseProvider)).log(
                action: 'print_pdf',
                entityType: 'report',
                title: 'طباعة كشف حساب',
                description: 'تمت طباعة/حفظ كشف الحساب PDF',
                route: '/reports/statement',
                newValues: {'filters': _filtersLabel(report)},
              );
            },
            onShared: (_) {
              AuditLogService(ref.read(databaseProvider)).log(
                action: 'share_pdf',
                entityType: 'report',
                title: 'مشاركة كشف حساب',
                description: 'تمت مشاركة كشف الحساب PDF',
                route: '/reports/statement',
                newValues: {'filters': _filtersLabel(report)},
              );
            },
          );
        },
        loading: () => const LoadingSkeleton(),
        error: (error, stack) => ErrorState(
          title: 'تعذر تحميل كشف الحساب',
          message: 'Error: $error',
          retryLabel: 'إعادة المحاولة',
          onRetry: () => ref.invalidate(financialReportProvider),
        ),
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
    if (filters.season != 'all') labels.add(seasonLabel(filters.season));
    if (filters.expenseType != 'all') {
      labels.add(expenseTypeLabel(filters.expenseType));
    }
    if (filters.personQuery.isNotEmpty) {
      labels.add('بحث: ${filters.personQuery}');
    }
    return labels.join(' - ');
  }

  static const List<String> _methodOrder = [
    'cash',
    'vodafone_cash',
    'instapay',
    'deposit_deduction',
  ];

  /// Sum of revenue (or expense) transactions grouped by payment method,
  /// returned as ordered `[label, amount]` rows for non-zero methods.
  List<List<String>> _breakdownByMethod(
    List<Transaction> transactions, {
    required bool revenue,
  }) {
    final totals = <String, double>{};
    for (final t in transactions.where((t) => t.isRevenue == revenue)) {
      totals[t.paymentMethod] = (totals[t.paymentMethod] ?? 0) + t.amount;
    }
    return [
      for (final m in _methodOrder)
        if ((totals[m] ?? 0) != 0)
          [_paymentMethodLabel(m), totals[m]!.toCurrencyFormat()],
    ];
  }

  /// Net (revenue − expense) per payment method, ordered, non-zero only.
  List<List<String>> _netBreakdownByMethod(List<Transaction> transactions) {
    final rev = <String, double>{};
    final exp = <String, double>{};
    for (final t in transactions) {
      final map = t.isRevenue ? rev : exp;
      map[t.paymentMethod] = (map[t.paymentMethod] ?? 0) + t.amount;
    }
    return [
      for (final m in _methodOrder)
        if (((rev[m] ?? 0) - (exp[m] ?? 0)) != 0)
          [
            _paymentMethodLabel(m),
            ((rev[m] ?? 0) - (exp[m] ?? 0)).toCurrencyFormat(),
          ],
    ];
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
