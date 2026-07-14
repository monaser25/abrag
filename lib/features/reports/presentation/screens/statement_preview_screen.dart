import 'dart:typed_data';

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

class StatementPreviewScreen extends ConsumerStatefulWidget {
  final ReportFilterState filters;

  const StatementPreviewScreen({
    super.key,
    this.filters = const ReportFilterState(),
  });

  @override
  ConsumerState<StatementPreviewScreen> createState() =>
      _StatementPreviewScreenState();
}

class _StatementPreviewScreenState
    extends ConsumerState<StatementPreviewScreen> {
  FinancialSummary? _snapshot;
  Future<Uint8List>? _pdfFuture;

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(financialReportProvider);

    if (_snapshot == null && reportAsync.hasValue) {
      _snapshot = reportAsync.value;
      _pdfFuture = _buildPdfBytes(_snapshot!);
    }

    return AppScaffold(
      appBar: const AbragAppBar(title: 'معاينة كشف الحساب PDF'),
      body: _pdfFuture == null
          ? reportAsync.when(
              data: (_) => const LoadingSkeleton(),
              loading: () => const LoadingSkeleton(),
              error: (error, stack) => ErrorState(
                title: 'تعذر تحميل كشف الحساب',
                message: 'Error: $error',
                retryLabel: 'إعادة المحاولة',
                onRetry: () => ref.invalidate(financialReportProvider),
              ),
            )
          : FutureBuilder<Uint8List>(
              future: _pdfFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const LoadingSkeleton();
                }
                if (snapshot.hasError) {
                  // Surface the real generation error instead of an endless
                  // spinner inside PdfPreview (which swallows build errors).
                  return ErrorState(
                    title: 'تعذر إنشاء كشف الحساب PDF',
                    message: 'Error: ${snapshot.error}',
                    retryLabel: 'إعادة المحاولة',
                    onRetry: () {
                      final report = _snapshot;
                      if (report != null) {
                        setState(() => _pdfFuture = _buildPdfBytes(report));
                      }
                    },
                  );
                }
                return _buildPreview(snapshot.data!);
              },
            ),
    );
  }

  /// Builds the PDF bytes once, up front, so any generation error surfaces as a
  /// visible error (via the FutureBuilder) rather than being swallowed by
  /// PdfPreview's internal build (which otherwise spins forever).
  Future<Uint8List> _buildPdfBytes(FinancialSummary report) {
    final filtered = ReportCalculator.filteredTransactions(
      report,
      widget.filters,
      technicianWorkAsTransactions: true,
    );
    final totalRev = filtered
        .where((t) => t.isRevenue)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalExp = filtered
        .where((t) => !t.isRevenue)
        .fold(0.0, (sum, t) => sum + t.amount);
    // Broker commission is cash that leaves the business, so it is deducted
    // from the net just like an expense (keeps the statement in sync with the
    // treasury/cash cards, which are net of commission).
    final totalCommission = filtered
        .where((t) => t.isRevenue)
        .fold(0.0, (sum, t) => sum + t.brokerCommission);
    final profit = totalRev - totalCommission - totalExp;
    final baseTitle = widget.filters.partyType == 'all'
        ? 'كشف حساب'
        : 'كشف حساب ${_partyLabel(report)}';
    final filtersLabel = _filtersLabel(report);
    final title = filtersLabel.isEmpty
        ? baseTitle
        : '$baseTitle - $filtersLabel';

    final revenueBreakdown = _breakdownByMethod(filtered, revenue: true);
    final expenseBreakdown = _breakdownByMethod(filtered, revenue: false);
    final commissionBreakdown = _commissionBreakdownByMethod(filtered);
    final netBreakdown = _netBreakdownByMethod(filtered);

    return PdfExportService.generateStatementPdf(
      title: title,
      dateRange: widget.filters.dateRangeLabel,
      totalRevenue: totalRev,
      totalCommission: totalCommission,
      totalExpenses: totalExp,
      netProfit: profit,
      revenueBreakdown: revenueBreakdown,
      commissionBreakdown: commissionBreakdown,
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
                if (t.technicianName != null && t.technicianName!.isNotEmpty)
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
    );
  }

  Widget _buildPreview(Uint8List bytes) {
    final report = _snapshot;
    final filtersLabel = report == null ? '' : _filtersLabel(report);
    return PdfPreview(
      // Hand PdfPreview the already-generated bytes so it only rasterizes;
      // it never re-runs generation on rebuild.
      build: (format) => bytes,
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
          newValues: {'filters': filtersLabel},
        );
      },
      onShared: (_) {
        AuditLogService(ref.read(databaseProvider)).log(
          action: 'share_pdf',
          entityType: 'report',
          title: 'مشاركة كشف حساب',
          description: 'تمت مشاركة كشف الحساب PDF',
          route: '/reports/statement',
          newValues: {'filters': filtersLabel},
        );
      },
    );
  }

  String _partyLabel(FinancialSummary report) {
    final options = ReportCalculator.partyOptions(
      report,
      widget.filters.partyType,
    );
    return options[widget.filters.selectedPartyKey] ?? 'كل الحسابات';
  }

  String _filtersLabel(FinancialSummary report) {
    final labels = <String>[];
    if (widget.filters.transactionType == 'revenue') {
      labels.add('إيرادات فقط');
    }
    if (widget.filters.transactionType == 'expense') {
      labels.add('مصروفات فقط');
    }
    if (widget.filters.paymentMethod != 'all') {
      labels.add(_paymentMethodLabel(widget.filters.paymentMethod));
    }
    if (widget.filters.season != 'all') {
      labels.add(seasonLabel(widget.filters.season));
    }
    if (widget.filters.expenseType != 'all') {
      labels.add(expenseTypeLabel(widget.filters.expenseType));
    }
    if (widget.filters.personQuery.isNotEmpty) {
      labels.add('بحث: ${widget.filters.personQuery}');
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
      final methodAmounts = revenue
          ? _revenuePaymentBreakdown(t)
          : {t.paymentMethod: t.amount};
      for (final entry in methodAmounts.entries) {
        totals[entry.key] = (totals[entry.key] ?? 0) + entry.value;
      }
    }
    return [
      for (final m in _methodOrder)
        if ((totals[m] ?? 0) != 0)
          [_paymentMethodLabel(m), totals[m]!.toCurrencyFormat()],
    ];
  }

  /// Total broker commission per payment method (revenue side), ordered,
  /// non-zero only — shown as a deduction under the commission total.
  List<List<String>> _commissionBreakdownByMethod(
    List<Transaction> transactions,
  ) {
    final totals = <String, double>{};
    for (final t in transactions.where((t) => t.isRevenue)) {
      if (t.brokerCommission > 0) {
        totals[t.paymentMethod] =
            (totals[t.paymentMethod] ?? 0) + t.brokerCommission;
      }
    }
    return [
      for (final m in _methodOrder)
        if ((totals[m] ?? 0) != 0)
          [_paymentMethodLabel(m), totals[m]!.toCurrencyFormat()],
    ];
  }

  /// Net (revenue − commission − expense) per payment method, ordered,
  /// non-zero only.
  List<List<String>> _netBreakdownByMethod(List<Transaction> transactions) {
    final rev = <String, double>{};
    final exp = <String, double>{};
    final comm = <String, double>{};
    for (final t in transactions) {
      if (t.isRevenue) {
        for (final entry in _revenuePaymentBreakdown(t).entries) {
          rev[entry.key] = (rev[entry.key] ?? 0) + entry.value;
        }
        comm[t.paymentMethod] =
            (comm[t.paymentMethod] ?? 0) + t.brokerCommission;
      } else {
        exp[t.paymentMethod] = (exp[t.paymentMethod] ?? 0) + t.amount;
      }
    }
    double net(String m) => (rev[m] ?? 0) - (comm[m] ?? 0) - (exp[m] ?? 0);
    return [
      for (final m in _methodOrder)
        if (net(m) != 0) [_paymentMethodLabel(m), net(m).toCurrencyFormat()],
    ];
  }

  Map<String, double> _revenuePaymentBreakdown(Transaction transaction) {
    if (transaction.paymentBreakdown.isNotEmpty) {
      return transaction.paymentBreakdown;
    }
    return {transaction.paymentMethod: transaction.amount};
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
