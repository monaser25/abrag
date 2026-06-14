import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:abrag/features/reports/domain/services/pdf_export_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('generateStatementPdf renders with breakdowns and many rows', () async {
    // Many rows force the MultiPage layout to span pages — this is what
    // surfaced the "height (Infinity)" regression in the summary row.
    final transactions = List.generate(60, (i) {
      final revenue = i.isEven;
      return {
        'date': '2026-06-${(i % 28) + 1}',
        'unit': 'شقة ${i + 1}',
        'description': 'عملية رقم $i - تفاصيل البيان المطوّلة لاختبار الالتفاف',
        'broker': revenue ? 'سمسار $i' : '—',
        'commission': revenue ? '250' : '—',
        'payment': i % 3 == 0 ? 'نقدي' : 'فودافون كاش',
        'amount': revenue ? '5,000 +' : '1,200 -',
        'isRevenue': revenue,
      };
    });

    final bytes = await PdfExportService.generateStatementPdf(
      title: 'كشف حساب - اختبار',
      dateRange: 'يونيو 2026',
      totalRevenue: 150000,
      totalExpenses: 36000,
      netProfit: 114000,
      revenueBreakdown: const [
        ['نقدي', '2,000'],
        ['فودافون كاش', '2,000'],
        ['إنستاباي', '1,000'],
      ],
      expenseBreakdown: const [
        ['نقدي', '1,000'],
        ['فودافون كاش', '500'],
      ],
      netBreakdown: const [
        ['نقدي', '1,000'],
        ['فودافون كاش', '1,500'],
      ],
      transactions: transactions,
    );

    expect(bytes, isA<Uint8List>());
    expect(bytes.lengthInBytes, greaterThan(1000));
  });

  test('generateStatementPdf renders with empty breakdowns', () async {
    final bytes = await PdfExportService.generateStatementPdf(
      title: 'كشف حساب فارغ',
      dateRange: 'يونيو 2026',
      totalRevenue: 0,
      totalExpenses: 0,
      netProfit: 0,
      transactions: const [],
    );

    expect(bytes.lengthInBytes, greaterThan(500));
  });
}
