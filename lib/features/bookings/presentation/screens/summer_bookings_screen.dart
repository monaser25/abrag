import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_settings_provider.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/season_utils.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/widgets.dart';
import '../providers/bookings_provider.dart';
import '../../../apartments/presentation/providers/apartments_controller.dart';

class SummerBookingsScreen extends ConsumerWidget {
  const SummerBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final bookingsAsync = ref.watch(summerBookingsProvider);
    final apartmentsAsync = ref.watch(apartmentsProvider);
    final activeSeason = ref.watch(activeSeasonKeyProvider);
    final colors = context.colors;

    return AppScaffold(
      appBar: AbragAppBar(title: l10n.summerBookings),
      body: bookingsAsync.when(
        data: (bookings) {
          final apartments = apartmentsAsync.value ?? [];
          final today = DateTime.now();
          final occupiedToday = bookings
              .where((booking) {
                return _isBookingActiveOnDay(booking, today);
              })
              .map((booking) => booking.apartmentId)
              .toSet()
              .length;
          final upcomingCheckouts = bookings.where((booking) {
            if (booking.status == 'checked_out' ||
                booking.status == 'cancelled') {
              return false;
            }
            final checkout = booking.earlyCheckoutDate ?? booking.checkOutDate;
            final target = DateTime(today.year, today.month, today.day);
            final checkoutDay = DateTime(
              checkout.year,
              checkout.month,
              checkout.day,
            );
            return !checkoutDay.isBefore(target);
          }).length;
          // "قادمة" = يبدأ في يوم بعد النهاردة. المقارنة باليوم (مش بالساعة) عشان
          // حجز بيبدأ النهاردة الساعة ٢ الضهر ما يتحسبش حجز مستقبلي.
          final todayOnly = DateTime(today.year, today.month, today.day);
          final upcoming = bookings.where((booking) {
            final checkInDay = DateTime(
              booking.checkInDate.year,
              booking.checkInDate.month,
              booking.checkInDate.day,
            );
            return checkInDay.isAfter(todayOnly) &&
                booking.status != 'cancelled' &&
                booking.status != 'checked_out';
          }).length;
          final availableToday = (apartments.length - occupiedToday).clamp(
            0,
            apartments.length,
          );

          return ListView(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 28),
            children: [
              SeasonHero(
                season: Season.summer,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'إدارة حجوزات الصيف',
                            style: AppTextStyles.h2.copyWith(color: colors.ink),
                          ),
                        ),
                        StatusChip(
                          kind: StatusChipKind.summer,
                          icon: Icons.wb_sunny_outlined,
                          label: seasonLabel(activeSeason),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'تابع الإشغال، مواعيد الخروج، والحجوزات القادمة لهذا الموسم فقط.',
                      style: AppTextStyles.bodyS.copyWith(color: colors.ink2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AppCard(
                padding: const EdgeInsets.all(6),
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 2.1,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _MetricTile(
                      label: 'مؤجرة اليوم',
                      value: '$occupiedToday',
                      icon: Icons.hotel_outlined,
                      tint: colors.summer,
                      onTap: () => context.push(
                        '/summer_bookings/calendar?filter=occupied',
                      ),
                    ),
                    _MetricTile(
                      label: 'متاحة اليوم',
                      value: '$availableToday',
                      icon: Icons.meeting_room_outlined,
                      tint: colors.ok,
                      onTap: () => context.push(
                        '/summer_bookings/calendar?filter=available',
                      ),
                    ),
                    _MetricTile(
                      label: 'خروجات قادمة',
                      value: '$upcomingCheckouts',
                      icon: Icons.logout,
                      tint: colors.err,
                      onTap: () => context.push(
                        '/summer_bookings/calendar?filter=upcomingCheckouts',
                      ),
                    ),
                    _MetricTile(
                      label: 'حجوزات قادمة',
                      value: '$upcoming',
                      icon: Icons.event_available_outlined,
                      tint: colors.brand,
                      onTap: () => context.push(
                        '/summer_bookings/calendar?filter=upcoming',
                      ),
                    ),
                  ],
                ),
              ),
              const SectionTitle(title: 'الحجوزات'),
              NavRow(
                icon: Icons.calendar_month,
                title: 'الأجندة الذكية',
                sub: 'عرض شهري بالفلاتر وإحصائيات اليوم',
                tint: colors.brand,
                onTap: () => context.push('/summer_bookings/calendar'),
              ),
              NavRow(
                icon: Icons.view_agenda_outlined,
                title: 'قائمة الحجوزات',
                sub: 'بحث وفلاتر لكل الحجوزات',
                tint: colors.accent,
                onTap: () => context.push('/summer_bookings/list'),
              ),
            ],
          );
        },
        loading: () => const LoadingSkeleton(),
        error: (error, _) => ErrorState(
          title: 'تعذّر تحميل البيانات',
          message: 'حدث خطأ: $error',
          retryLabel: 'إعادة المحاولة',
          onRetry: () => ref.invalidate(summerBookingsProvider),
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        children: [
          Expanded(
            child: AppButton(
              label: 'حجز جديد',
              icon: Icons.add,
              expand: true,
              onPressed: () => context.push('/summer_bookings/add'),
            ),
          ),
        ],
      ),
    );
  }

  static bool _isBookingActiveOnDay(dynamic booking, DateTime day) {
    if (booking.status == 'checked_out' || booking.status == 'cancelled') {
      return false;
    }
    final target = DateTime(day.year, day.month, day.day);
    final start = DateTime(
      booking.checkInDate.year,
      booking.checkInDate.month,
      booking.checkInDate.day,
    );
    final endDate = booking.earlyCheckoutDate ?? booking.checkOutDate;
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    return !target.isBefore(start) && !target.isAfter(end);
  }
}

/// Tappable metric tile (prototype `MiniMetric` + the existing filter links).
class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color tint;
  final VoidCallback? onTap;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.tint,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: MiniMetric(icon: icon, value: value, label: label, tint: tint),
      ),
    );
  }
}
