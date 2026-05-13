import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import '../providers/reports_provider.dart';
import '../../domain/services/pdf_export_service.dart';

class StatementScreen extends ConsumerWidget {
  const StatementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(financialReportProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('كشف الحساب'),
      ),
      body: reportAsync.when(
        data: (report) {
          return PdfPreview(
            build: (format) => PdfExportService.generateStatementPdf(
              title: 'تقرير كشف الحساب',
              dateRange: 'جميع الأوقات', // Should be dynamic based on filters
              totalRevenue: report.totalRevenue,
              totalExpenses: report.totalExpenses,
              netProfit: report.netProfit,
              transactions: report.transactions.map((t) => {
                'date': t.date.toLocal().toString().split(' ')[0],
                'description': t.description,
                'amount': t.isRevenue ? '+ ${t.amount}' : '- ${t.amount}',
                'isRevenue': t.isRevenue,
              }).toList(),
            ),
            allowPrinting: true,
            allowSharing: true,
            canChangeOrientation: false,
            canChangePageFormat: false,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
