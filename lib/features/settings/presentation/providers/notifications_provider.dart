import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../contracts/presentation/providers/contracts_provider.dart';
import '../../../contracts/presentation/models/winter_payment_status.dart';
import '../../../bookings/presentation/providers/bookings_provider.dart';
import '../../../buildings/presentation/providers/buildings_controller.dart';
import '../../../operations/presentation/providers/maintenance_provider.dart';
import '../../../operations/presentation/providers/apartment_inspections_provider.dart';
import '../../../apartments/presentation/providers/apartments_controller.dart';
import '../../../../core/config/app_settings_provider.dart';
import '../../../../core/services/notification_service.dart';
import '../../../users/presentation/providers/users_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/permissions_provider.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime date;
  final String type; // 'rent', 'checkout', 'expiration', 'system'
  final String? route;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    required this.type,
    this.route,
  });
}

class DismissedNotificationsController extends StateNotifier<Set<String>> {
  final AppSettingsController _settingsController;
  final Map<String, dynamic> _currentSettings;

  DismissedNotificationsController(
    super.initial,
    this._settingsController,
    this._currentSettings,
  );

  Future<void> dismiss(String id) async {
    final next = {...state, id};
    state = next;
    await _save(next);
  }

  Future<void> clearAllVisible(Iterable<String> ids) async {
    final next = {...state, ...ids};
    state = next;
    await _save(next);
  }

  Future<void> restoreAll() async {
    state = {};
    await _save(state);
  }

  Future<void> _save(Set<String> ids) async {
    final newSettings = Map<String, dynamic>.from(_currentSettings);
    newSettings['dismissed_notifications'] = ids.toList();
    await _settingsController.updateSettings(newSettings);
  }
}

final dismissedNotificationsProvider =
    StateNotifierProvider<DismissedNotificationsController, Set<String>>((ref) {
      final settings = ref.watch(appSettingsProvider).value ?? {};
      final dismissed =
          (settings['dismissed_notifications'] as List<dynamic>?)
              ?.map((id) => id.toString())
              .toSet() ??
          <String>{};
      return DismissedNotificationsController(
        dismissed,
        ref.read(appSettingsControllerProvider),
        settings,
      );
    });

// Controls whether notifications are muted or not (Do Not Disturb)
class NotificationsSettingsController extends StateNotifier<bool> {
  final AppSettingsController _settingsController;
  final Map<String, dynamic> _currentSettings;

  NotificationsSettingsController(
    super.initial,
    this._settingsController,
    this._currentSettings,
  );

  Future<void> toggleMute(bool isMuted) async {
    state = isMuted;
    final newSettings = Map<String, dynamic>.from(_currentSettings);
    newSettings['notifications_muted'] = isMuted;
    await _settingsController.updateSettings(newSettings);

    if (isMuted) {
      await NotificationService.cancelAll();
    }
  }
}

final notificationsMutedProvider =
    StateNotifierProvider<NotificationsSettingsController, bool>((ref) {
      final settings = ref.watch(appSettingsProvider).value ?? {};
      final isMuted = (settings['notifications_muted'] ?? false) == true;
      return NotificationsSettingsController(
        isMuted,
        ref.read(appSettingsControllerProvider),
        settings,
      );
    });

final appNotificationsProvider = Provider<AsyncValue<List<AppNotification>>>((
  ref,
) {
  final isMuted = ref.watch(notificationsMutedProvider);
  final dismissedIds = ref.watch(dismissedNotificationsProvider);

  final role = ref.watch(currentUserRoleProvider).value;
  final isSuperAdmin = role == 'admin';
  final userId = ref.watch(authStateProvider).value?.session?.user.id;
  final rolesConfig = ref.watch(rolesConfigProvider);

  bool hasPerm(String perm) {
    if (isSuperAdmin) return true;
    if (userId == null) return false;
    final customRoleName = rolesConfig.userRoles[userId];
    if (customRoleName == null) return false;
    final perms = rolesConfig.roleTemplates[customRoleName] ?? [];
    return perms.contains(perm);
  }

  // Watch all relevant data
  final contractsAsync = ref.watch(winterContractsProvider);
  final bookingsAsync = ref.watch(summerBookingsProvider);
  final buildingsAsync = ref.watch(buildingsProvider);
  final paymentsAsync = ref.watch(allWinterPaymentsProvider);
  final maintenanceAsync = ref.watch(maintenanceProvider);
  final inspectionsAsync = ref.watch(apartmentInspectionsProvider);
  final apartmentsAsync = ref.watch(apartmentsProvider);

  if (contractsAsync is AsyncLoading ||
      bookingsAsync is AsyncLoading ||
      buildingsAsync is AsyncLoading ||
      paymentsAsync is AsyncLoading) {
    return const AsyncLoading();
  }

  try {
    final notifications = <AppNotification>[];
    final now = DateTime.now();

    // 1. Summer Bookings Checkouts
    if (hasPerm('manage_bookings') || hasPerm('checkout_winter')) {
      final bookings = bookingsAsync.asData?.value ?? [];
      for (final b in bookings) {
        if (b.status == 'checked_out' || b.status == 'cancelled') continue;

        final checkoutDate = b.earlyCheckoutDate ?? b.checkOutDate;
        final diff = checkoutDate.difference(now).inDays;
        final checkInDiff = b.checkInDate.difference(now).inDays;

        if (checkInDiff >= 0 && checkInDiff <= 1) {
          notifications.add(
            AppNotification(
              id: 'booking_checkin_${b.id}',
              title: 'دخول حجز قريب',
              body:
                  'العميل ${b.guestName} موعد دخوله ${checkInDiff == 0 ? "اليوم" : "غداً"}.',
              date: b.checkInDate,
              type: 'checkin',
              route: '/summer_bookings/details/${b.id}',
            ),
          );
        }

        // If checking out today or tomorrow
        if (diff >= 0 && diff <= 1) {
          final baseTotal = b.totalPriceEgp - b.overstayFeeEgp;
          final remaining = (baseTotal - b.amountPaidEgp).clamp(
            0,
            double.infinity,
          );
          notifications.add(
            AppNotification(
              id: 'booking_checkout_${b.id}',
              title: 'موعد خروج مصيف',
              body:
                  'العميل ${b.guestName} في شقة ${b.apartmentId} موعد خروجه ${diff == 0 ? "اليوم" : "غداً"} الساعة 8 صباحاً.',
              date: checkoutDate,
              type: 'checkout',
              route: '/summer_bookings/details/${b.id}',
            ),
          );

          if (remaining > 0) {
            notifications.add(
              AppNotification(
                id: 'booking_unpaid_checkout_${b.id}',
                title: 'باقي فلوس قبل التسليم',
                body:
                    'العميل ${b.guestName} عليه ${remaining.toStringAsFixed(0)} ج.م قبل ميعاد الخروج.',
                date: checkoutDate,
                type: 'rent',
                route: '/summer_bookings/details/${b.id}',
              ),
            );
          }

          // Schedule local notification if not muted
          if (!isMuted) {
            final scheduleDayBefore = checkoutDate
                .subtract(const Duration(days: 1))
                .add(const Duration(hours: 20)); // 8 PM day before
            if (scheduleDayBefore.isAfter(now)) {
              NotificationService.scheduleNotification(
                id: b.id.hashCode,
                title: 'موعد خروج غداً',
                body: 'العميل ${b.guestName} موعد خروجه غداً الساعة 8 صباحاً.',
                scheduledDate: scheduleDayBefore,
              );
            }
            final scheduleExactly = checkoutDate.add(
              const Duration(hours: 8),
            ); // 8 AM on the day
            if (scheduleExactly.isAfter(now)) {
              NotificationService.scheduleNotification(
                id: b.id.hashCode + 1,
                title: 'موعد خروج الآن',
                body: 'العميل ${b.guestName} موعد خروجه الآن.',
                scheduledDate: scheduleExactly,
              );
            }
          }
        }
      }
    }

    // 4. Operations notifications: maintenance, damages, cleaning, inventory.
    if (hasPerm('manage_maintenance') || hasPerm('checkout_winter')) {
      final maintenance = maintenanceAsync.asData?.value ?? [];
      for (final request in maintenance) {
        if (request.status != 'resolved') {
          notifications.add(
            AppNotification(
              id: 'maintenance_open_${request.id}',
              title: 'طلب صيانة مفتوح',
              body: request.issueDescription,
              date: request.createdAt,
              type: 'maintenance',
              route: '/maintenance',
            ),
          );
        }
      }

      final inspections = inspectionsAsync.asData?.value ?? [];
      for (final inspection in inspections) {
        if (inspection.hasDamages) {
          notifications.add(
            AppNotification(
              id: 'inspection_damage_${inspection.id}',
              title: 'تلفيات في شقة',
              body:
                  inspection.damagesDescription ??
                  'تم تسجيل تلفيات أثناء الفحص',
              date: inspection.createdAt,
              type: 'damage',
              route: '/inspections',
            ),
          );
        }
        if (!inspection.isClean) {
          notifications.add(
            AppNotification(
              id: 'inspection_cleaning_${inspection.id}',
              title: 'شقة تحتاج نظافة',
              body: 'تم تسجيل شقة تحتاج نظافة بعد الفحص.',
              date: inspection.createdAt,
              type: 'cleaning',
              route: '/inspections',
            ),
          );
        }
      }

      final apartments = apartmentsAsync.asData?.value ?? [];
      for (final apartment in apartments) {
        if (apartment.cleaningStatus == 'needs_cleaning') {
          notifications.add(
            AppNotification(
              id: 'apartment_needs_cleaning_${apartment.id}',
              title: 'شقة غير نظيفة',
              body: 'شقة ${apartment.apartmentNumber} تحتاج نظافة.',
              date: apartment.updatedAt,
              type: 'cleaning',
              route: '/apartments/profile/${apartment.id}',
            ),
          );
        }
        if ((apartment.inventory ?? '').trim().isEmpty) {
          notifications.add(
            AppNotification(
              id: 'apartment_missing_inventory_${apartment.id}',
              title: 'جرد غير مكتمل',
              body: 'شقة ${apartment.apartmentNumber} لا يوجد لها جرد مسجل.',
              date: apartment.updatedAt,
              type: 'inventory',
              route: '/apartments/profile/${apartment.id}',
            ),
          );
        }
      }
    }

    // 2. Winter Contracts Rent Due & Expiration
    if (hasPerm('manage_bookings') ||
        hasPerm('checkout_winter') ||
        hasPerm('view_reports')) {
      final contracts = contractsAsync.asData?.value ?? [];
      final payments = paymentsAsync.asData?.value ?? [];
      for (final c in contracts) {
        if (!c.isActive) continue;

        // Expiration
        if (hasPerm('manage_bookings') || hasPerm('checkout_winter')) {
          final expireDiff = c.endDate.difference(now).inDays;
          if (expireDiff >= 0 && expireDiff <= 15) {
            notifications.add(
              AppNotification(
                id: 'contract_expire_${c.id}',
                title: 'اقتراب انتهاء عقد شتوي',
                body:
                    'عقد الطالب ${c.studentName} سينتهي خلال $expireDiff يوم.',
                date: c.endDate,
                type: 'expiration',
                route: '/winter_contracts/details/${c.id}',
              ),
            );

            if (!isMuted && expireDiff > 0) {
              final notifyDate = c.endDate
                  .subtract(const Duration(days: 3))
                  .add(const Duration(hours: 10)); // 3 days before at 10 AM
              if (notifyDate.isAfter(now)) {
                NotificationService.scheduleNotification(
                  id: c.id.hashCode + 2,
                  title: 'اقتراب انتهاء عقد',
                  body: 'عقد الطالب ${c.studentName} سينتهي قريباً.',
                  scheduledDate: notifyDate,
                );
              }
            }
          }
        }

        // Rent Due
        if (hasPerm('view_reports') || hasPerm('manage_bookings')) {
          final cPayments = payments
              .where((p) => p.contractId == c.id)
              .toList();
          final status = calculateWinterRentStatus(c, cPayments, today: now);

          if (status.hasOverdue) {
            notifications.add(
              AppNotification(
                id: 'contract_rent_${c.id}',
                title: 'تأخير إيجار شتوي',
                body:
                    'الطالب ${c.studentName} متأخر في الدفع. ${status.statusTitle}',
                date: status.nextUnpaidDueDate ?? now,
                type: 'rent',
                route: '/winter_contracts/payments/${c.id}',
              ),
            );
          } else if (status.nextUnpaidDueDate != null) {
            // Schedule reminder for upcoming rent
            if (!isMuted) {
              final upcomingDue = status.nextUnpaidDueDate!;
              final notifyDate = upcomingDue.add(
                const Duration(hours: 9),
              ); // 9 AM on due date
              if (notifyDate.isAfter(now)) {
                NotificationService.scheduleNotification(
                  id: c.id.hashCode + 3,
                  title: 'استحقاق إيجار شتوي',
                  body: 'إيجار الطالب ${c.studentName} مستحق اليوم.',
                  scheduledDate: notifyDate,
                );
              }
            }
          }
        }
      }
    }

    // 3. Building Rent Installments
    if (hasPerm('view_reports') || hasPerm('manage_expenses')) {
      final buildings = buildingsAsync.asData?.value ?? [];
      for (final b in buildings) {
        if (b.rentInstallmentsDates != null &&
            b.rentInstallmentsDates!.isNotEmpty) {
          try {
            final dates = jsonDecode(b.rentInstallmentsDates!) as List<dynamic>;
            for (final dateStr in dates) {
              final date = DateTime.parse(dateStr.toString());
              final diff = date.difference(now).inDays;
              if (diff >= -5 && diff <= 10) {
                notifications.add(
                  AppNotification(
                    id: 'building_rent_${b.id}_$dateStr',
                    title: 'قسط إيجار العمارة',
                    body:
                        'قسط إيجار عمارة ${b.name} مستحق ${diff < 0 ? "منذ ${-diff} يوم" : "بعد $diff يوم"}.',
                    date: date,
                    type: 'rent',
                    route: '/building_rent',
                  ),
                );

                if (!isMuted && diff > 0) {
                  final notifyDate = date
                      .subtract(const Duration(days: 3))
                      .add(const Duration(hours: 10)); // 3 days before
                  if (notifyDate.isAfter(now)) {
                    NotificationService.scheduleNotification(
                      id: b.id.hashCode + dateStr.hashCode,
                      title: 'تنبيه قسط العمارة',
                      body: 'قسط إيجار العمارة يستحق بعد 3 أيام.',
                      scheduledDate: notifyDate,
                    );
                  }
                }
              }
            }
          } catch (_) {}
        }
      }
    }

    // Sort by date descending
    notifications.removeWhere(
      (notification) => dismissedIds.contains(notification.id),
    );
    notifications.sort((a, b) => b.date.compareTo(a.date));

    return AsyncData(notifications);
  } catch (e, st) {
    return AsyncError(e, st);
  }
});
