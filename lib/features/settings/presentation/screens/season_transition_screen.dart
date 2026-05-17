import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_settings_provider.dart';

class SeasonTransitionScreen extends ConsumerWidget {
  const SeasonTransitionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(appSettingsProvider);
    final settingsController = ref.watch(appSettingsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('الانتقال بين المواسم')),
      body: settingsAsync.when(
        data: (settings) {
          final isWinter = (settings['active_season'] ?? 'winter') == 'winter';

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  isWinter ? Icons.ac_unit : Icons.wb_sunny,
                  size: 80,
                  color: isWinter ? Colors.blue : Colors.orange,
                ),
                const SizedBox(height: 24),
                Text(
                  'الموسم النشط حالياً: ${isWinter ? 'الشتاء' : 'الصيف'}',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  isWinter
                      ? 'واجهة التطبيق مهيئة الآن لإدارة عقود الطلبة (الشتوي). عند الانتقال للصيف، سيتم التركيز على الحجوزات اليومية والإيرادات السريعة.'
                      : 'واجهة التطبيق مهيئة الآن لإدارة الحجوزات اليومية (الصيفي). عند الانتقال للشتاء، سيتم التركيز على الإيجارات الشهرية.',
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () async {
                    final newSettings = Map<String, dynamic>.from(settings);
                    newSettings['active_season'] = isWinter
                        ? 'summer'
                        : 'winter';
                    await settingsController.updateSettings(newSettings);
                  },
                  icon: Icon(isWinter ? Icons.wb_sunny : Icons.ac_unit),
                  label: Text(
                    isWinter
                        ? 'التبديل إلى موسم الصيف'
                        : 'التبديل إلى موسم الشتاء',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: isWinter ? Colors.orange : Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
