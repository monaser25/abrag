import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_settings_provider.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/widgets.dart';

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
    final colors = context.colors;

    return AppScaffold(
      appBar: const AbragAppBar(title: 'مواعيد الخروج'),
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconTile(
                          icon: Icons.wb_sunny_outlined,
                          tint: colors.summer,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ميعاد خروج حجوزات الصيف',
                                style: AppTextStyles.title
                                    .copyWith(color: colors.ink),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'هيتطبّق تلقائياً عند حساب تاريخ الخروج في الحجز الجديد.',
                                style: AppTextStyles.bodyS
                                    .copyWith(color: colors.ink2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    AppDateField(
                      label: 'الساعة الحالية',
                      value: _summerCheckoutTime.format(context),
                      icon: Icons.schedule,
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _summerCheckoutTime,
                        );
                        if (picked != null) {
                          setState(() => _summerCheckoutTime = picked);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'حفظ الإعدادات',
                icon: Icons.save_outlined,
                expand: true,
                loading: _saving,
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
              ),
            ],
          );
        },
        loading: () => const LoadingSkeleton(),
        error: (error, _) => ErrorState(
          title: 'تعذّر تحميل الإعدادات',
          message: 'حدث خطأ: $error',
          retryLabel: 'إعادة المحاولة',
          onRetry: () => ref.invalidate(appSettingsProvider),
        ),
      ),
    );
  }
}
