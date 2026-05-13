import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PricingManagementScreen extends ConsumerWidget {
  const PricingManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة التسعير')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPricingSection(context, 'الصيف (موسم عالي)', '1200 ج.م / ليلة'),
          const SizedBox(height: 16),
          _buildPricingSection(context, 'الصيف (موسم عادي)', '800 ج.م / ليلة'),
          const SizedBox(height: 16),
          _buildPricingSection(context, 'الشتاء (طلاب)', '3500 ج.م / شهر'),
        ],
      ),
    );
  }

  Widget _buildPricingSection(BuildContext context, String title, String price) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(price, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).colorScheme.primary)),
                OutlinedButton(onPressed: () {}, child: const Text('تعديل')),
              ],
            )
          ],
        ),
      ),
    );
  }
}
