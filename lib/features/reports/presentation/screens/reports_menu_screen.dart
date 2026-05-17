import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/report_view_models.dart';

class ReportsMenuScreen extends StatelessWidget {
  final ReportFilterState filters;

  const ReportsMenuScreen({
    super.key,
    this.filters = const ReportFilterState(),
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        title: 'كشف حساب مفصل',
        description: 'فلاتر كاملة ثم معاينة PDF ومشاركة أو طباعة.',
        icon: Icons.picture_as_pdf,
        path: '/reports/statement',
      ),
      (
        title: ReportDetailKind.apartments.title,
        description: 'تفاصيل كل شقة، الإيرادات، الحجوزات، والمتوسطات.',
        icon: Icons.apartment,
        path: '/reports/details/${ReportDetailKind.apartments.key}',
      ),
      (
        title: ReportDetailKind.floors.title,
        description: 'مقارنة الأدوار حسب عدد الحجوزات والقيمة الإيجارية.',
        icon: Icons.layers,
        path: '/reports/details/${ReportDetailKind.floors.key}',
      ),
      (
        title: ReportDetailKind.brokers.title,
        description: 'حسابات السماسرة، قيمة الحجوزات والعمولات.',
        icon: Icons.handshake,
        path: '/reports/details/${ReportDetailKind.brokers.key}',
      ),
      (
        title: ReportDetailKind.workers.title,
        description: 'أعمال العمال والتكاليف وعدد مرات الشغل.',
        icon: Icons.engineering,
        path: '/reports/details/${ReportDetailKind.workers.key}',
      ),
      (
        title: ReportDetailKind.expenses.title,
        description: 'المصروفات مجمعة حسب النوع وعدد العمليات.',
        icon: Icons.receipt_long,
        path: '/reports/details/${ReportDetailKind.expenses.key}',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('التقارير التفصيلية')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Icon(item.icon)),
              title: Text(item.title),
              subtitle: Text(item.description),
              trailing: const Icon(Icons.chevron_left),
              onTap: () => context.push(item.path, extra: filters),
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemCount: items.length,
      ),
    );
  }
}
