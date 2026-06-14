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
    required List<Map<String, dynamic>>
    transactions, // {date, description, amount, isRevenue}
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
                      pw.Image(logo, height: 76),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'للاستثمار العقاري',
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey600,
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
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'إجمالي الإيرادات',
                            style: const pw.TextStyle(
                              fontSize: 12,
                              color: PdfColors.grey700,
                            ),
                          ),
                          pw.Text(
                            '${totalRevenue.toCurrencyFormat()} ج.م',
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.green700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  pw.Container(width: 1, height: 40, color: PdfColors.grey300),
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'إجمالي المصروفات',
                            style: const pw.TextStyle(
                              fontSize: 12,
                              color: PdfColors.grey700,
                            ),
                          ),
                          pw.Text(
                            '${totalExpenses.toCurrencyFormat()} ج.م',
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.red700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  pw.Container(width: 1, height: 40, color: PdfColors.grey300),
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      color: PdfColors.grey100,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'صافي الربح',
                            style: const pw.TextStyle(
                              fontSize: 12,
                              color: PdfColors.grey700,
                            ),
                          ),
                          pw.Text(
                            '${netProfit.toCurrencyFormat()} ج.م',
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
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
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey800,
              ),
              oddRowDecoration: const pw.BoxDecoration(
                color: PdfColors.grey100,
              ),
              cellPadding: const pw.EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 7,
              ),
              cellAlignment: pw.Alignment.centerRight,
              headers: ['التاريخ', 'البيان', 'المبلغ (ج.م)'],
              data: transactions.map((t) {
                return [t['date'], t['description'], t['amount'].toString()];
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
                    pw.Image(logo, height: 72),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'للاستثمار العقاري',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
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
              horizontal: 8,
              vertical: 7,
            ),
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
