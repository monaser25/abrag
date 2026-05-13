import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SeasonTransitionScreen extends ConsumerWidget {
  const SeasonTransitionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('الانتقال بين المواسم')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.ac_unit, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            Text(
              'الموسم الحالي: الشتاء',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'سيؤدي الانتقال إلى موسم الصيف إلى إغلاق جميع عقود الشتاء النشطة وتفعيل نظام الحجوزات اليومية.',
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.wb_sunny),
              label: const Text('بدء موسم الصيف'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
