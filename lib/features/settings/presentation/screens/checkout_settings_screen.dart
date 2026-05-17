import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_settings_provider.dart';

class CheckoutSettingsScreen extends ConsumerStatefulWidget {
  const CheckoutSettingsScreen({super.key});

  @override
  ConsumerState<CheckoutSettingsScreen> createState() =>
      _CheckoutSettingsScreenState();
}

class _CheckoutSettingsScreenState
    extends ConsumerState<CheckoutSettingsScreen> {
  TimeOfDay _summerCheckoutTime = const TimeOfDay(hour: 8, minute: 0);
  bool _initialized = false;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(appSettingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('مواعيد الخروج')),
      body: settingsAsync.when(
        data: (settings) {
          if (!_initialized) {
            _summerCheckoutTime = TimeOfDay(
              hour: (settings['summer_checkout_hour'] as num?)?.toInt() ?? 8,
              minute:
                  (settings['summer_checkout_minute'] as num?)?.toInt() ?? 0,
            );
            _initialized = true;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: theme.colorScheme.primary
                                .withValues(alpha: 0.15),
                            child: Icon(
                              Icons.wb_sunny_outlined,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ميعاد خروج حجوزات الصيف',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'هيتطبّق تلقائياً عند حساب تاريخ الخروج في الحجز الجديد.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.schedule),
                        title: const Text('الساعة الحالية'),
                        subtitle: Text(_summerCheckoutTime.format(context)),
                        trailing: OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: _summerCheckoutTime,
                            );
                            if (picked != null) {
                              setState(() => _summerCheckoutTime = picked);
                            }
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('تغيير'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _saving
                    ? null
                    : () async {
                        setState(() => _saving = true);
                        final next = Map<String, dynamic>.from(settings);
                        next['summer_checkout_hour'] = _summerCheckoutTime.hour;
                        next['summer_checkout_minute'] =
                            _summerCheckoutTime.minute;
                        await ref
                            .read(appSettingsControllerProvider)
                            .updateSettings(next);
                        if (!context.mounted) return;
                        setState(() => _saving = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم حفظ ميعاد الخروج')),
                        );
                      },
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: const Text('حفظ الإعدادات'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('حدث خطأ: $error')),
      ),
    );
  }
}
