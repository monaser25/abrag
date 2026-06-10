import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/abrag_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../models/report_view_models.dart';

class ReportsMenuScreen extends StatelessWidget {
  final ReportFilterState filters;

  const ReportsMenuScreen({
    super.key,
    this.filters = const ReportFilterState(),
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final items = [
      (
        title: 'كشف حساب مفصل',
        description: 'فلاتر كاملة ثم معاينة PDF ومشاركة أو طباعة.',
        icon: Icons.picture_as_pdf,
        tint: colors.accent,
        path: '/reports/statement',
      ),
      (
        title: ReportDetailKind.apartments.title,
        description: 'تفاصيل كل شقة، الإيرادات، الحجوزات، والمتوسطات.',
        icon: Icons.apartment,
        tint: colors.brand,
        path: '/reports/details/${ReportDetailKind.apartments.key}',
      ),
      (
        title: ReportDetailKind.floors.title,
        description: 'مقارنة الأدوار حسب عدد الحجوزات والقيمة الإيجارية.',
        icon: Icons.layers,
        tint: colors.winter,
        path: '/reports/details/${ReportDetailKind.floors.key}',
      ),
      (
        title: ReportDetailKind.brokers.title,
        description: 'حسابات السماسرة، قيمة الحجوزات والعمولات.',
        icon: Icons.handshake,
        tint: colors.summer,
        path: '/reports/details/${ReportDetailKind.brokers.key}',
      ),
      (
        title: ReportDetailKind.workers.title,
        description: 'أعمال العمال والتكاليف وعدد مرات الشغل.',
        icon: Icons.engineering,
        tint: colors.ok,
        path: '/reports/details/${ReportDetailKind.workers.key}',
      ),
      (
        title: ReportDetailKind.expenses.title,
        description: 'المصروفات مجمعة حسب النوع وعدد العمليات.',
        icon: Icons.receipt_long,
        tint: colors.err,
        path: '/reports/details/${ReportDetailKind.expenses.key}',
      ),
    ];

    return AppScaffold(
      appBar: const AbragAppBar(title: 'التقارير التفصيلية'),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final item = items[index];
          return NavRow(
            icon: item.icon,
            title: item.title,
            sub: item.description,
            tint: item.tint,
            onTap: () => context.push(item.path, extra: filters),
          );
        },
        itemCount: items.length,
      ),
    );
  }
}
