import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/services/audit_log_service.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';
import '../../domain/services/pdf_export_service.dart';
import '../models/report_view_models.dart';
import '../providers/reports_provider.dart';

class ReportMetricDetailScreen extends ConsumerWidget {
  final ReportDetailKind kind;
  final String metricKey;
  final ReportFilterState filters;

  const ReportMetricDetailScreen({
    super.key,
    required this.kind,
    required this.metricKey,
    this.filters = const ReportFilterState(),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(financialReportProvider);

    return Scaffold(
      appBar: AppBar(title: Text('تفاصيل ${kind.title}')),
      body: reportAsync.when(
        data: (report) {
          final rentals = _rentals(report);
          final transactions = _transactions(report);
          final works = _works(report);
          final title = _title(rentals, transactions, works);
          final paid = rentals.fold<double>(
            0,
            (sum, item) => sum + item.paidRevenue,
          );
          final rentalValue = rentals.fold<double>(0, (sum, item) {
            return sum +
                (item.rentalValue > 0 ? item.rentalValue : item.paidRevenue);
          });
          final commission = rentals.fold<double>(
            0,
            (sum, item) => sum + item.brokerCommission,
          );
          final revenue = transactions
              .where((t) => t.isRevenue)
              .fold<double>(0, (sum, item) => sum + item.amount);
          final expenses = transactions
              .where((t) => !t.isRevenue)
              .fold<double>(0, (sum, item) => sum + item.amount);
          final workCost = works.fold<double>(
            0,
            (sum, item) => sum + item.cost,
          );
          final lastDate = _lastDate(rentals, transactions, works);
          final collectionRate = rentalValue <= 0
              ? 0.0
              : (paid / rentalValue * 100).clamp(0, 100);
          final summaryRows = <(String, String)>[
            if (kind == ReportDetailKind.apartments ||
                kind == ReportDetailKind.floors ||
                kind == ReportDetailKind.brokers) ...[
              ('عدد الحجوزات', '${rentals.length}'),
              ('القيمة الإيجارية', '${rentalValue.toCurrencyFormat()} ج.م'),
              ('المدفوع', '${paid.toCurrencyFormat()} ج.م'),
              ('نسبة التحصيل', '${collectionRate.toStringAsFixed(0)}%'),
              ('عمولات السماسرة', '${commission.toCurrencyFormat()} ج.م'),
            ],
            if (transactions.isNotEmpty) ...[
              ('عدد العمليات المالية', '${transactions.length}'),
              ('إجمالي الإيرادات', '${revenue.toCurrencyFormat()} ج.م'),
              ('إجمالي المصروفات', '${expenses.toCurrencyFormat()} ج.م'),
              ('الصافي', '${(revenue - expenses).toCurrencyFormat()} ج.م'),
            ],
            if (works.isNotEmpty || kind == ReportDetailKind.workers) ...[
              ('عدد أعمال العمال', '${works.length}'),
              ('تكلفة العمال', '${workCost.toCurrencyFormat()} ج.م'),
            ],
            (
              'آخر نشاط',
              lastDate == null
                  ? 'لا يوجد'
                  : lastDate.toLocal().toString().split(' ')[0],
            ),
          ];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SummaryCard(
                title: title,
                subtitle: kind.title,
                rows: summaryRows,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _sharePdf(title, rentals, transactions, works, ref),
                      icon: const Icon(Icons.share),
                      label: const Text('مشاركة PDF'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _printPdf(title, rentals, transactions, works, ref),
                      icon: const Icon(Icons.print),
                      label: const Text('طباعة / حفظ'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _AdminNotesCard(
                rentalsCount: rentals.length,
                transactionsCount: transactions.length,
                worksCount: works.length,
                averageRental: rentals.isEmpty
                    ? 0
                    : rentalValue / rentals.length,
                averagePaid: rentals.isEmpty ? 0 : paid / rentals.length,
              ),
              const SizedBox(height: 12),
              _RentalsSection(rentals: rentals),
              _TransactionsSection(transactions: transactions),
              _WorksSection(works: works),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  List<RentalRecord> _rentals(FinancialSummary report) {
    final rentals = ReportCalculator.filteredRentals(report, filters);
    switch (kind) {
      case ReportDetailKind.apartments:
        return rentals.where((r) => r.apartmentId == metricKey).toList();
      case ReportDetailKind.floors:
        return rentals.where((r) => _floorKey(r) == metricKey).toList();
      case ReportDetailKind.brokers:
        return rentals
            .where((r) => (r.brokerId ?? r.brokerName) == metricKey)
            .toList();
      case ReportDetailKind.workers:
      case ReportDetailKind.expenses:
        return [];
    }
  }

  List<Transaction> _transactions(FinancialSummary report) {
    final transactions = ReportCalculator.filteredTransactions(
      report,
      filters,
      technicianWorkAsTransactions: kind == ReportDetailKind.workers,
    );
    switch (kind) {
      case ReportDetailKind.apartments:
        return transactions.where((t) => t.apartmentId == metricKey).toList();
      case ReportDetailKind.floors:
        return transactions
            .where((t) => _floorKeyFromNumber(t.floorNumber) == metricKey)
            .toList();
      case ReportDetailKind.brokers:
        return transactions
            .where((t) => (t.brokerId ?? t.brokerName) == metricKey)
            .toList();
      case ReportDetailKind.workers:
        return transactions
            .where((t) => (t.technicianId ?? t.technicianName) == metricKey)
            .toList();
      case ReportDetailKind.expenses:
        return transactions.where((t) => t.expenseType == metricKey).toList();
    }
  }

  List<WorkRecord> _works(FinancialSummary report) {
    final works = ReportCalculator.filteredWorkRecords(report, filters);
    switch (kind) {
      case ReportDetailKind.apartments:
        return works.where((w) => w.apartmentId == metricKey).toList();
      case ReportDetailKind.floors:
        return works
            .where((w) => _floorKeyFromNumber(w.floorNumber) == metricKey)
            .toList();
      case ReportDetailKind.workers:
        return works.where((w) => w.technicianId == metricKey).toList();
      case ReportDetailKind.brokers:
      case ReportDetailKind.expenses:
        return [];
    }
  }

  String _title(
    List<RentalRecord> rentals,
    List<Transaction> transactions,
    List<WorkRecord> works,
  ) {
    if (rentals.isNotEmpty) {
      if (kind == ReportDetailKind.apartments) {
        return 'شقة ${rentals.first.apartmentNumber}';
      }
      if (kind == ReportDetailKind.floors) return _floorKey(rentals.first);
      if (kind == ReportDetailKind.brokers) {
        return rentals.first.brokerName ?? 'سمسار';
      }
    }
    if (works.isNotEmpty) return works.first.technicianName;
    if (transactions.isNotEmpty) {
      final t = transactions.first;
      if (kind == ReportDetailKind.expenses) return expenseTypeLabel(metricKey);
      return t.description;
    }
    return metricKey;
  }

  DateTime? _lastDate(
    List<RentalRecord> rentals,
    List<Transaction> transactions,
    List<WorkRecord> works,
  ) {
    final dates = <DateTime>[
      ...rentals.map((r) => r.date),
      ...transactions.map((t) => t.date),
      ...works.map((w) => w.date),
    ];
    if (dates.isEmpty) return null;
    dates.sort((a, b) => b.compareTo(a));
    return dates.first;
  }

  String _floorKey(RentalRecord rental) =>
      _floorKeyFromNumber(rental.floorNumber);

  String _floorKeyFromNumber(int? floorNumber) {
    return floorNumber == null ? 'دور غير محدد' : 'الدور $floorNumber';
  }

  Future<void> _sharePdf(
    String title,
    List<RentalRecord> rentals,
    List<Transaction> transactions,
    List<WorkRecord> works,
    WidgetRef ref,
  ) async {
    final bytes = await _buildPdf(title, rentals, transactions, works);
    await Printing.sharePdf(bytes: bytes, filename: '${kind.key}_details.pdf');
    await AuditLogService(ref.read(databaseProvider)).log(
      action: 'share_pdf',
      entityType: 'report',
      title: 'مشاركة تفاصيل تقرير',
      description: 'تمت مشاركة تفاصيل $title',
      route: '/reports',
      newValues: {'report': kind.key, 'item': title},
    );
  }

  Future<void> _printPdf(
    String title,
    List<RentalRecord> rentals,
    List<Transaction> transactions,
    List<WorkRecord> works,
    WidgetRef ref,
  ) async {
    await Printing.layoutPdf(
      onLayout: (_) => _buildPdf(title, rentals, transactions, works),
    );
    await AuditLogService(ref.read(databaseProvider)).log(
      action: 'print_pdf',
      entityType: 'report',
      title: 'طباعة تفاصيل تقرير',
      description: 'تمت طباعة/حفظ تفاصيل $title',
      route: '/reports',
      newValues: {'report': kind.key, 'item': title},
    );
  }

  Future<Uint8List> _buildPdf(
    String title,
    List<RentalRecord> rentals,
    List<Transaction> transactions,
    List<WorkRecord> works,
  ) {
    final paid = rentals.fold<double>(0, (sum, item) => sum + item.paidRevenue);
    final rentalValue = rentals.fold<double>(0, (sum, item) {
      return sum + (item.rentalValue > 0 ? item.rentalValue : item.paidRevenue);
    });
    final expenses = transactions
        .where((t) => !t.isRevenue)
        .fold<double>(0, (sum, item) => sum + item.amount);
    final workCost = works.fold<double>(0, (sum, item) => sum + item.cost);

    return PdfExportService.generateMetricsPdf(
      title: 'تفاصيل $title',
      dateRange: filters.dateRangeLabel,
      headers: const ['البند', 'القيمة'],
      rows: [
        ['عدد الحجوزات', '${rentals.length}'],
        ['المدفوع', '${paid.toCurrencyFormat()} ج.م'],
        ['القيمة الإيجارية', '${rentalValue.toCurrencyFormat()} ج.م'],
        ['المصروفات', '${expenses.toCurrencyFormat()} ج.م'],
        ['تكلفة العمال', '${workCost.toCurrencyFormat()} ج.م'],
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<(String, String)> rows;

  const _SummaryCard({
    required this.title,
    required this.subtitle,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.14,
                  ),
                  child: Icon(
                    Icons.analytics,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(subtitle, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: rows
                  .map((row) => _DetailPill(label: row.$1, value: row.$2))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailPill extends StatelessWidget {
  final String label;
  final String value;

  const _DetailPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(minWidth: 130),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.35,
        ),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: theme.textTheme.labelSmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminNotesCard extends StatelessWidget {
  final int rentalsCount;
  final int transactionsCount;
  final int worksCount;
  final double averageRental;
  final double averagePaid;

  const _AdminNotesCard({
    required this.rentalsCount,
    required this.transactionsCount,
    required this.worksCount,
    required this.averageRental,
    required this.averagePaid,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'معلومات إدارية',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _DetailPill(
                  label: 'متوسط القيمة الإيجارية',
                  value: '${averageRental.toCurrencyFormat()} ج.م',
                ),
                _DetailPill(
                  label: 'متوسط المدفوع',
                  value: '${averagePaid.toCurrencyFormat()} ج.م',
                ),
                _DetailPill(
                  label: 'عمليات مالية مرتبطة',
                  value: '$transactionsCount',
                ),
                _DetailPill(label: 'أعمال عمال مرتبطة', value: '$worksCount'),
              ],
            ),
            if (rentalsCount == 0 && transactionsCount == 0 && worksCount == 0)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text('لا توجد بيانات مرتبطة بالفلاتر الحالية.'),
              ),
          ],
        ),
      ),
    );
  }
}

class _RentalsSection extends StatelessWidget {
  final List<RentalRecord> rentals;

  const _RentalsSection({required this.rentals});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'الحجوزات والإيجارات',
      emptyText: 'لا توجد حجوزات مرتبطة',
      children: rentals.map((rental) {
        return ListTile(
          title: Text(
            '${rental.season == 'summer' ? 'صيف' : 'شتاء'} - ${rental.customerName}',
          ),
          subtitle: Text(
            '${rental.buildingName ?? ''} شقة ${rental.apartmentNumber} - ${rental.date.toLocal().toString().split(' ')[0]}',
          ),
          trailing: Text('${rental.rentalValue.toCurrencyFormat()} ج.م'),
        );
      }).toList(),
    );
  }
}

class _TransactionsSection extends StatelessWidget {
  final List<Transaction> transactions;

  const _TransactionsSection({required this.transactions});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'العمليات المالية',
      emptyText: 'لا توجد عمليات مالية مرتبطة',
      children: transactions.map((transaction) {
        return ListTile(
          title: Text(transaction.description),
          subtitle: Text(transaction.date.toLocal().toString().split(' ')[0]),
          trailing: Text(
            '${transaction.isRevenue ? '+' : '-'} ${transaction.amount.toCurrencyFormat()} ج.م',
          ),
        );
      }).toList(),
    );
  }
}

class _WorksSection extends StatelessWidget {
  final List<WorkRecord> works;

  const _WorksSection({required this.works});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'أعمال العمال',
      emptyText: 'لا توجد أعمال عمال مرتبطة',
      children: works.map((work) {
        return ListTile(
          title: Text(work.technicianName),
          subtitle: Text(
            '${work.description} - ${work.status == 'resolved' ? 'مكتمل' : 'مفتوح'}',
          ),
          trailing: Text('${work.cost.toCurrencyFormat()} ج.م'),
        );
      }).toList(),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String emptyText;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.emptyText,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        initiallyExpanded: children.isNotEmpty,
        title: Text(title),
        subtitle: Text(
          children.isEmpty ? emptyText : '${children.length} عنصر',
        ),
        children: children.isEmpty
            ? [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(emptyText),
                ),
              ]
            : children,
      ),
    );
  }
}
