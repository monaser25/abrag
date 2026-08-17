import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_settings_provider.dart';
import '../../../../core/utils/auto_checkout_utils.dart';
import 'bookings_controller.dart';

/// الساعة اللي بعدها الخروج بيتقفل تلقائيًا يوم الخروج (من الإعدادات).
final autoCheckoutHourProvider = Provider<int>((ref) {
  final settings = ref.watch(appSettingsProvider).valueOrNull ?? const {};
  final stored = (settings['auto_checkout_hour'] as num?)?.toInt();
  if (stored == null || stored < 0 || stored > 23) {
    return kDefaultAutoCheckoutHour;
  }
  return stored;
});

/// الميزة شغالة ولا المالك قافلها.
final autoCheckoutEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(appSettingsProvider).valueOrNull ?? const {};
  return settings['auto_checkout_enabled'] != false;
});

/// بيشغّل جولة الإقفال التلقائي أول ما التطبيق يفتح وبعدها كل ١٠ دقايق.
///
/// جوّه التطبيق مش على السيرفر عن قصد: كده الإقفال بيمشي في نفس مسار تسجيل
/// الخروج العادي — نفس سجل النظام ونفس المزامنة — بدل ما يعدّل الداتا من بره
/// ويلف حوالين قواعد التطبيق.
final autoCheckoutRunnerProvider = Provider<AutoCheckoutRunner>((ref) {
  final runner = AutoCheckoutRunner(ref);
  ref.onDispose(runner.dispose);
  return runner;
});

class AutoCheckoutRunner {
  final Ref _ref;
  Timer? _timer;
  bool _isRunning = false;

  AutoCheckoutRunner(this._ref) {
    unawaited(run());
    _timer = Timer.periodic(
      const Duration(minutes: 10),
      (_) => unawaited(run()),
    );
  }

  /// آخر عدد حجوزات اتقفلت، عشان الواجهة تقدر تعرض إشعار لو حبّت.
  int lastClosedCount = 0;

  Future<void> run() async {
    if (_isRunning) return;
    if (!_ref.read(autoCheckoutEnabledProvider)) return;
    _isRunning = true;
    try {
      lastClosedCount = await _ref
          .read(bookingsControllerProvider.notifier)
          .runAutomaticCheckouts(hour: _ref.read(autoCheckoutHourProvider));
    } catch (_) {
      // جولة فشلت مش مشكلة — الجولة اللي بعدها هتلحقها. ومينفعش نوقف
      // التطبيق عشان إقفال تلقائي.
    } finally {
      _isRunning = false;
    }
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
