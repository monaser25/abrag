import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/widgets.dart';

class PricingManagementScreen extends ConsumerWidget {
  const PricingManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    return AppScaffold(
      appBar: const AbragAppBar(title: 'إدارة التسعير'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _buildPricingSection(
            context,
            'الصيف (موسم عالي)',
            '1200 ج.م / ليلة',
            Icons.wb_sunny,
            colors.summer,
          ),
          const SizedBox(height: 12),
          _buildPricingSection(
            context,
            'الصيف (موسم عادي)',
            '800 ج.م / ليلة',
            Icons.wb_cloudy,
            colors.summer,
          ),
          const SizedBox(height: 12),
          _buildPricingSection(
            context,
            'الشتاء (طلاب)',
            '3500 ج.م / شهر',
            Icons.ac_unit,
            colors.winter,
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection(
    BuildContext context,
    String title,
    String price,
    IconData icon,
    Color tint,
  ) {
    final colors = context.colors;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconTile(icon: icon, tint: tint),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.title.copyWith(color: colors.ink),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                price,
                style: AppTextStyles.tabular(
                  AppTextStyles.h2.copyWith(color: colors.brand),
                ),
              ),
              AppButton(
                label: 'تعديل',
                variant: AppButtonVariant.outline,
                small: true,
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
