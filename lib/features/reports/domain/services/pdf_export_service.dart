import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../core/utils/currency_formatter.dart';

class PdfExportService {
  static Future<Uint8List> generateStatementPdf({
    required String title,
    required String dateRange,
    required double totalRevenue,
    required double totalExpenses,
    required double netProfit,
    // {date, unit, description, payment, amount, isRevenue}
    required List<Map<String, dynamic>> transactions,
    // Each entry: [label, amount] — payment-method breakdown lines shown
    // under the matching total card.
    List<List<String>> revenueBreakdown = const [],
    List<List<String>> expenseBreakdown = const [],
    List<List<String>> netBreakdown = const [],
  }) async {
    final pdf = pw.Document();

    // Load the Arabic font
    final fontData = await rootBundle.load(
      'assets/fonts/IBMPlexSansArabic-Regular.ttf',
    );
    final ttf = pw.Font.ttf(fontData);

    final fontDataBold = await rootBundle.load(
      'assets/fonts/IBMPlexSansArabic-Bold.ttf',
    );
    final ttfBold = pw.Font.ttf(fontDataBold);

    // Brand mark (monochrome wordmark) for the report header.
    final logoData = await rootBundle.load('assets/icons/abrag_mono.png');
    final logo = pw.MemoryImage(logoData.buffer.asUint8List());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl, // CRITICAL FOR ARABIC
        theme: pw.ThemeData.withFont(base: ttf, bold: ttfBold).copyWith(
          defaultTextStyle: pw.TextStyle(
            font: ttf,
            fontFallback: [ttf, ttfBold],
          ),
        ),
        header: (context) {
          return pw.Column(
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        title,
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        dateRange,
                        style: const pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Image(logo, height: 88),
                      pw.SizedBox(height: 1),
                      pw.Text(
                        'للاستثمار العقاري',
                        style: const pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.Divider(color: PdfColors.grey800, thickness: 2),
              pw.SizedBox(height: 20),
            ],
          );
        },
        build: (context) {
          return [
            // Summary Section
            pw.Text(
              'ملخص الأداء المالي',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Row(
                children: [
                  _summaryCell(
                    title: 'إجمالي الإيرادات',
                    total: totalRevenue.toCurrencyFormat(),
                    totalColor: PdfColors.green700,
                    breakdown: revenueBreakdown,
                  ),
                  _summaryCell(
                    title: 'إجمالي المصروفات',
                    total: totalExpenses.toCurrencyFormat(),
                    totalColor: PdfColors.red700,
                    breakdown: expenseBreakdown,
                    leadingDivider: true,
                  ),
                  _summaryCell(
                    title: 'صافي الربح',
                    total: netProfit.toCurrencyFormat(),
                    totalColor: PdfColors.grey900,
                    breakdown: netBreakdown,
                    background: PdfColors.grey100,
                    leadingDivider: true,
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Divider(color: PdfColor.fromHex('#F4A225'), thickness: 1.5),
            pw.SizedBox(height: 12),

            // Transactions Table
            pw.Text(
              'تفاصيل العمليات',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
              border: const pw.TableBorder(
                top: pw.BorderSide(color: PdfColors.grey500),
                bottom: pw.BorderSide(color: PdfColors.grey500),
                left: pw.BorderSide(color: PdfColors.grey300),
                right: pw.BorderSide(color: PdfColors.grey300),
                horizontalInside: pw.BorderSide(
                  color: PdfColors.grey300,
                  width: 0.7,
                ),
                verticalInside: pw.BorderSide(
                  color: PdfColors.grey200,
                  width: 0.5,
                ),
              ),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                fontSize: 9.5,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey800,
              ),
              oddRowDecoration: const pw.BoxDecoration(
                color: PdfColors.grey100,
              ),
              cellPadding: const pw.EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 6,
              ),
              cellStyle: const pw.TextStyle(fontSize: 9.5),
              cellAlignment: pw.Alignment.centerRight,
              // Structured columns, ordered right-to-left the way the user
              // reads a statement: when → which unit → what → who brokered
              // it + their cut → how it was paid → the amount. Only البيان
              // flexes; the rest are fixed so values stay on one line.
              columnWidths: {
                0: const pw.FixedColumnWidth(66), // التاريخ
                1: const pw.FixedColumnWidth(38), // الشقة
                2: const pw.FlexColumnWidth(), // البيان
                3: const pw.FixedColumnWidth(58), // السمسار
                4: const pw.FixedColumnWidth(54), // العمولة
                5: const pw.FixedColumnWidth(72), // طريقة الدفع
                6: const pw.FixedColumnWidth(62), // المبلغ
              },
              headers: const [
                'التاريخ',
                'الشقة',
                'البيان',
                'السمسار',
                'العمولة',
                'طريقة الدفع',
                'المبلغ',
              ],
              data: transactions.map((t) {
                return [
                  t['date'] ?? '',
                  t['unit'] ?? '',
                  t['description'] ?? '',
                  t['broker'] ?? '—',
                  t['commission'] ?? '—',
                  t['payment'] ?? '',
                  t['amount'] ?? '',
                ];
              }).toList(),
            ),
          ];
        },
        footer: (context) {
          return pw.Column(
            children: [
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'تم الإنشاء بواسطة تطبيق أبراج',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.Text(
                    'الصفحة ${context.pageNumber} من ${context.pagesCount}',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// A single summary card: title, large total, then optional
  /// payment-method breakdown lines (each `[label, amount]`).
  static pw.Widget _summaryCell({
    required String title,
    required String total,
    required PdfColor totalColor,
    required List<List<String>> breakdown,
    PdfColor? background,
    bool leadingDivider = false,
  }) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: background,
          border: leadingDivider
              ? const pw.Border(left: pw.BorderSide(color: PdfColors.grey300))
              : null,
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              title,
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              '$total ج.م',
              style: pw.TextStyle(
                fontSize: 15,
                fontWeight: pw.FontWeight.bold,
                color: totalColor,
              ),
            ),
            if (breakdown.isNotEmpty) ...[
              pw.SizedBox(height: 5),
              ...breakdown.map(
                (b) => pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 1.5),
                  child: pw.Text(
                    '${b[1]} ${b[0]}',
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Future<Uint8List> generateMetricsPdf({
    required String title,
    required String dateRange,
    required List<String> headers,
    required List<List<String>> rows,
  }) async {
    final pdf = pw.Document();

    final fontData = await rootBundle.load(
      'assets/fonts/IBMPlexSansArabic-Regular.ttf',
    );
    final ttf = pw.Font.ttf(fontData);

    final fontDataBold = await rootBundle.load(
      'assets/fonts/IBMPlexSansArabic-Bold.ttf',
    );
    final ttfBold = pw.Font.ttf(fontDataBold);

    // Brand mark (monochrome wordmark) for the report header.
    final logoData = await rootBundle.load('assets/icons/abrag_mono.png');
    final logo = pw.MemoryImage(logoData.buffer.asUint8List());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: ttf, bold: ttfBold).copyWith(
          defaultTextStyle: pw.TextStyle(
            font: ttf,
            fontFallback: [ttf, ttfBold],
          ),
        ),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      title,
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      dateRange,
                      style: const pw.TextStyle(
                        fontSize: 11,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Image(logo, height: 84),
                    pw.SizedBox(height: 1),
                    pw.Text(
                      'للاستثمار العقاري',
                      style: const pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.Divider(color: PdfColors.grey800, thickness: 2),
            pw.SizedBox(height: 12),
          ],
        ),
        build: (context) => [
          pw.TableHelper.fromTextArray(
            border: const pw.TableBorder(
              top: pw.BorderSide(color: PdfColors.grey500),
              bottom: pw.BorderSide(color: PdfColors.grey500),
              left: pw.BorderSide(color: PdfColors.grey300),
              right: pw.BorderSide(color: PdfColors.grey300),
              horizontalInside: pw.BorderSide(
                color: PdfColors.grey300,
                width: 0.7,
              ),
              verticalInside: pw.BorderSide(
                color: PdfColors.grey200,
                width: 0.5,
              ),
            ),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey800),
            oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
            cellPadding: const pw.EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 7,
            ),
            cellStyle: const pw.TextStyle(fontSize: 10),
            cellAlignment: pw.Alignment.centerRight,
            headers: headers,
            data: rows,
          ),
        ],
        footer: (context) => pw.Column(
          children: [
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'تم الإنشاء بواسطة تطبيق أبراج',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.Text(
                  'الصفحة ${context.pageNumber} من ${context.pagesCount}',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return pdf.save();
  }
}
