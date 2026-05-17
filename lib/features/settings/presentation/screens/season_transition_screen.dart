import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_settings_provider.dart';
import '../../../../core/utils/season_utils.dart';

class SeasonTransitionScreen extends ConsumerWidget {
  const SeasonTransitionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(appSettingsProvider);
    final settingsController = ref.watch(appSettingsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('إدارة المواسم')),
      body: settingsAsync.when(
        data: (settings) {
          final activeSeason =
              (settings['active_season_key'] as String?) ?? currentSeasonKey();
          final options = seasonOptionsAround(pastYears: 5, futureYears: 3)
              .where((option) => option.key != 'all')
              .toList();
          final next = nextSeasonKey(activeSeason);

          Future<void> activateSeason(String key) async {
            final newSettings = Map<String, dynamic>.from(settings);
            newSettings['active_season_key'] = key;
            newSettings['active_season'] = key.startsWith('summer')
                ? 'summer'
                : key.startsWith('winter')
                ? 'winter'
                : 'all';
            await settingsController.updateSettings(newSettings);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            child: Icon(
                              activeSeason.startsWith('summer')
                                  ? Icons.wb_sunny
                                  : Icons.ac_unit,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'الموسم النشط: ${seasonLabel(activeSeason)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'الموسم النشط هو اللي يظهر افتراضيًا في الفلاتر عشان الشغل اليومي ما يتلخبطش. المواسم القديمة لا تُحذف، وتفضل موجودة في التقارير وكشف الحساب وسجل النشاط.',
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () => activateSeason(next),
                        icon: const Icon(Icons.add),
                        label: Text('بدء ${seasonLabel(next)}'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'كل المواسم',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...options.map(
                (option) => Card(
                  child: ListTile(
                    leading: Icon(
                      option.key.startsWith('summer')
                          ? Icons.wb_sunny
                          : Icons.ac_unit,
                      color: option.key == activeSeason
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    title: Text(option.label),
                    subtitle: option.key == activeSeason
                        ? const Text('نشط حاليًا')
                        : const Text('مؤرشف / متاح في التقارير'),
                    trailing: option.key == activeSeason
                        ? const Icon(Icons.check_circle)
                        : TextButton(
                            onPressed: () => activateSeason(option.key),
                            child: const Text('تفعيل'),
                          ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
