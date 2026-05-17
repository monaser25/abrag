import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import 'dart:typed_data';

import '../../../../core/utils/currency_formatter.dart';
import '../../domain/services/pdf_export_service.dart';
import '../models/report_view_models.dart';
import '../providers/reports_provider.dart';

class ReportDetailScreen extends ConsumerWidget {
  final ReportDetailKind kind;
  final ReportFilterState filters;

  const ReportDetailScreen({
    super.key,
    required this.kind,
    this.filters = const ReportFilterState(),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(financialReportProvider);

    return Scaffold(
      appBar: AppBar(title: Text(kind.title)),
      body: reportAsync.when(
        data: (report) {
          final metrics = ReportCalculator.metricsFor(kind, report, filters);
          final totalCount = metrics.fold<int>(
            0,
            (sum, item) => sum + item.count,
          );
          final totalPaid = metrics.fold<double>(
            0,
            (sum, item) => sum + item.paidRevenue,
          );
          final totalRental = metrics.fold<double>(
            0,
            (sum, item) => sum + item.rentalValue,
          );
          final totalCost = metrics.fold<double>(
            0,
            (sum, item) => sum + item.cost,
          );
          final totalCommission = metrics.fold<double>(
            0,
            (sum, item) => sum + item.commission,
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _HeaderCard(
                title: kind.title,
                dateRange: filters.dateRangeLabel,
                totalCount: totalCount,
                totalPaid: totalPaid,
                totalRental: totalRental,
                totalCost: totalCost,
                totalCommission: totalCommission,
                kind: kind,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: metrics.isEmpty
                          ? null
                          : () => _sharePdf(metrics),
                      icon: const Icon(Icons.share),
                      label: const Text('مشاركة PDF'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: metrics.isEmpty
                          ? null
                          : () => _printPdf(metrics),
                      icon: const Icon(Icons.print),
                      label: const Text('طباعة / حفظ PDF'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (metrics.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(kind.emptyText, textAlign: TextAlign.center),
                  ),
                )
              else
                ...metrics.map(
                  (metric) => _MetricCard(
                    kind: kind,
                    metric: metric,
                    onTap: () => context.push(
                      '/reports/details/${kind.key}/item/${_encodeMetricKey(metric.key)}',
                      extra: filters,
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  String _encodeMetricKey(String key) {
    return base64Url.encode(utf8.encode(key));
  }

  Future<void> _sharePdf(List<ReportMetric> metrics) async {
    final bytes = await _buildPdf(metrics);
    await Printing.sharePdf(bytes: bytes, filename: '${kind.key}_report.pdf');
  }

  Future<void> _printPdf(List<ReportMetric> metrics) async {
    await Printing.layoutPdf(onLayout: (_) => _buildPdf(metrics));
  }

  Future<Uint8List> _buildPdf(List<ReportMetric> metrics) {
    return PdfExportService.generateMetricsPdf(
      title: kind.title,
      dateRange: filters.dateRangeLabel,
      headers: _headers,
      rows: metrics.map(_rowForMetric).toList(),
    );
  }

  List<String> get _headers {
    switch (kind) {
      case ReportDetailKind.apartments:
      case ReportDetailKind.floors:
        return ['البيان', 'عدد الحجوزات', 'المدفوع', 'القيمة الإيجارية'];
      case ReportDetailKind.brokers:
        return ['السمسار', 'عدد الحجوزات', 'قيمة الحجوزات', 'العمولة'];
      case ReportDetailKind.workers:
        return ['العامل', 'عدد الأعمال', 'التكلفة'];
      case ReportDetailKind.expenses:
        return ['نوع المصروف', 'عدد العمليات', 'الإجمالي'];
    }
  }

  List<String> _rowForMetric(ReportMetric metric) {
    switch (kind) {
      case ReportDetailKind.apartments:
      case ReportDetailKind.floors:
        return [
          metric.label,
          '${metric.count}',
          '${metric.paidRevenue.toCurrencyFormat()} ج.م',
          '${metric.rentalValue.toCurrencyFormat()} ج.م',
        ];
      case ReportDetailKind.brokers:
        return [
          metric.label,
          '${metric.count}',
          '${metric.rentalValue.toCurrencyFormat()} ج.م',
          '${metric.commission.toCurrencyFormat()} ج.م',
        ];
      case ReportDetailKind.workers:
      case ReportDetailKind.expenses:
        return [
          metric.label,
          '${metric.count}',
          '${metric.cost.toCurrencyFormat()} ج.م',
        ];
    }
  }
}

class _HeaderCard extends StatelessWidget {
  final String title;
  final String dateRange;
  final int totalCount;
  final double totalPaid;
  final double totalRental;
  final double totalCost;
  final double totalCommission;
  final ReportDetailKind kind;

  const _HeaderCard({
    required this.title,
    required this.dateRange,
    required this.totalCount,
    required this.totalPaid,
    required this.totalRental,
    required this.totalCost,
    required this.totalCommission,
    required this.kind,
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
                  child: Icon(_icon, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(dateRange, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Divider(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MiniTotal(label: 'عدد', value: '$totalCount'),
                if (kind == ReportDetailKind.apartments ||
                    kind == ReportDetailKind.floors)
                  _MiniTotal(
                    label: 'مدفوع',
                    value: '${totalPaid.toCurrencyFormat()} ج.م',
                  ),
                if (kind == ReportDetailKind.apartments ||
                    kind == ReportDetailKind.floors ||
                    kind == ReportDetailKind.brokers)
                  _MiniTotal(
                    label: 'قيمة إيجارية',
                    value: '${totalRental.toCurrencyFormat()} ج.م',
                  ),
                if (kind == ReportDetailKind.brokers)
                  _MiniTotal(
                    label: 'عمولات',
                    value: '${totalCommission.toCurrencyFormat()} ج.م',
                  ),
                if (kind == ReportDetailKind.workers ||
                    kind == ReportDetailKind.expenses)
                  _MiniTotal(
                    label: 'إجمالي',
                    value: '${totalCost.toCurrencyFormat()} ج.م',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData get _icon {
    switch (kind) {
      case ReportDetailKind.apartments:
        return Icons.apartment;
      case ReportDetailKind.floors:
        return Icons.layers;
      case ReportDetailKind.brokers:
        return Icons.handshake;
      case ReportDetailKind.workers:
        return Icons.engineering;
      case ReportDetailKind.expenses:
        return Icons.receipt_long;
    }
  }

  String get _description {
    switch (kind) {
      case ReportDetailKind.apartments:
        return 'ملخص أداء كل شقة من حيث عدد الحجوزات، المدفوع، والقيمة الإيجارية.';
      case ReportDetailKind.floors:
        return 'مقارنة واضحة بين الأدوار حسب الإشغال والإيراد.';
      case ReportDetailKind.brokers:
        return 'متابعة قيمة حجوزات كل سمسار والعمولة المستحقة له.';
      case ReportDetailKind.workers:
        return 'تجميع أعمال العمال والتكاليف حسب كل عامل.';
      case ReportDetailKind.expenses:
        return 'عرض المصروفات مجمعة حسب النوع وعدد العمليات.';
    }
  }
}

class _MiniTotal extends StatelessWidget {
  final String label;
  final String value;

  const _MiniTotal({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.35,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: theme.textTheme.labelSmall),
          Text(value, style: theme.textTheme.titleSmall),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final ReportDetailKind kind;
  final ReportMetric metric;
  final VoidCallback onTap;

  const _MetricCard({
    required this.kind,
    required this.metric,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      metric.label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    _mainValue,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _chips
                    .map((chip) => _MetricPill(label: chip.$1, value: chip.$2))
                    .toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'اضغط لعرض العمليات والحجوزات المرتبطة',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_left),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _mainValue {
    switch (kind) {
      case ReportDetailKind.apartments:
      case ReportDetailKind.floors:
        return '${metric.rentalValue.toCurrencyFormat()} ج.م';
      case ReportDetailKind.brokers:
        return '${metric.commission.toCurrencyFormat()} ج.م';
      case ReportDetailKind.workers:
      case ReportDetailKind.expenses:
        return '${metric.cost.toCurrencyFormat()} ج.م';
    }
  }

  List<(String, String)> get _chips {
    switch (kind) {
      case ReportDetailKind.apartments:
      case ReportDetailKind.floors:
        return [
          ('الحجوزات', '${metric.count}'),
          ('المدفوع', '${metric.paidRevenue.toCurrencyFormat()} ج.م'),
          ('القيمة الإيجارية', '${metric.rentalValue.toCurrencyFormat()} ج.م'),
        ];
      case ReportDetailKind.brokers:
        return [
          ('الحجوزات', '${metric.count}'),
          ('قيمة الحجوزات', '${metric.rentalValue.toCurrencyFormat()} ج.م'),
          ('العمولة', '${metric.commission.toCurrencyFormat()} ج.م'),
        ];
      case ReportDetailKind.workers:
        return [
          ('عدد الأعمال', '${metric.count}'),
          ('إجمالي التكلفة', '${metric.cost.toCurrencyFormat()} ج.م'),
        ];
      case ReportDetailKind.expenses:
        return [
          ('عدد العمليات', '${metric.count}'),
          ('إجمالي المصروف', '${metric.cost.toCurrencyFormat()} ج.م'),
        ];
    }
  }
}

class _MetricPill extends StatelessWidget {
  final String label;
  final String value;

  const _MetricPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.35,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: theme.textTheme.labelSmall),
          Text(
            value,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
