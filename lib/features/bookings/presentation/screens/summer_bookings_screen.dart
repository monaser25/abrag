import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../providers/bookings_provider.dart';
import '../../../apartments/presentation/providers/apartments_controller.dart';

class SummerBookingsScreen extends ConsumerWidget {
  const SummerBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final bookingsAsync = ref.watch(summerBookingsProvider);
    final apartmentsAsync = ref.watch(apartmentsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.summerBookings)),
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
            final checkoutDay = DateTime(checkout.year, checkout.month, checkout.day);
            return !checkoutDay.isBefore(target) &&
                checkoutDay.isBefore(target.add(const Duration(days: 14)));
          }).length;
          final upcoming = bookings.where((booking) {
            return booking.checkInDate.isAfter(today) &&
                booking.status != 'cancelled';
          }).length;
          final availableToday = (apartments.length - occupiedToday).clamp(
            0,
            apartments.length,
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.22),
                      theme.colorScheme.surfaceContainerHighest,
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.18),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إدارة حجوزات الصيف',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'تابع الإشغال، مواعيد الخروج، والحجوزات القادمة من مكان واحد.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () =>
                                context.push('/summer_bookings/add'),
                            icon: const Icon(Icons.add),
                            label: const Text('حجز جديد'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.35,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _MetricCard(
                    title: 'مؤجرة اليوم',
                    value: '$occupiedToday',
                    icon: Icons.hotel,
                    color: Colors.orange,
                    onTap: () => context.push('/summer_bookings/calendar?filter=occupied'),
                  ),
                  _MetricCard(
                    title: 'متاحة اليوم',
                    value: '$availableToday',
                    icon: Icons.meeting_room_outlined,
                    color: Colors.green,
                    onTap: () => context.push('/summer_bookings/calendar?filter=available'),
                  ),
                  _MetricCard(
                    title: 'خروجات قادمة',
                    value: '$upcomingCheckouts',
                    icon: Icons.logout,
                    color: Colors.redAccent,
                    onTap: () => context.push('/summer_bookings/calendar?filter=upcomingCheckouts'),
                  ),
                  _MetricCard(
                    title: 'حجوزات قادمة',
                    value: '$upcoming',
                    icon: Icons.event_available,
                    color: Colors.blueAccent,
                    onTap: () => context.push('/summer_bookings/calendar?filter=upcoming'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _NavigationCard(
                title: 'الأجندة الذكية',
                subtitle:
                    'عرض شهري مع فلاتر، إحصائيات اليوم، وحركات مواعيد الخروج.',
                icon: Icons.calendar_month,
                onTap: () => context.push('/summer_bookings/calendar'),
              ),
              const SizedBox(height: 12),
              _NavigationCard(
                title: 'قائمة الحجوزات',
                subtitle: 'بحث وفلاتر وكروت تفصيلية لكل الحجزات.',
                icon: Icons.view_agenda_outlined,
                onTap: () => context.push('/summer_bookings/list'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('حدث خطأ: $error')),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: () => context.push('/summer_bookings/add'),
          icon: const Icon(Icons.add),
          label: const Text('حجز جديد'),
        ),
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

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const Spacer(),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class _NavigationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _NavigationCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.14),
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(subtitle),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
