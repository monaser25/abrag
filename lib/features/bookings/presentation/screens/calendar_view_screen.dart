import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/config/app_settings_provider.dart';
import '../../../../core/database/database.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/utils/season_utils.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../apartments/presentation/providers/apartments_controller.dart';
import '../../../settings/presentation/providers/permissions_provider.dart';
import '../providers/bookings_provider.dart';

/// occupied = مقيمة في اليوم المحدد (دخلت قبله أو فيه ولسه ما خرجتش)؛
/// checkIns = اللي **دخلت في اليوم المحدد نفسه** بس — دي اللي بيقصدها
/// المالك بـ"مؤجرة اليوم".
enum _CalendarFilter {
  all,
  occupied,
  checkIns,
  upcomingCheckouts,
  upcoming,
  available,
}

class CalendarViewScreen extends ConsumerStatefulWidget {
  const CalendarViewScreen({super.key});

  @override
  ConsumerState<CalendarViewScreen> createState() => _CalendarViewScreenState();
}

class _CalendarViewScreenState extends ConsumerState<CalendarViewScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  late _CalendarFilter _filter;
  bool _didReadInitialFilter = false;

  @override
  void initState() {
    super.initState();
    _filter = _CalendarFilter.all;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didReadInitialFilter) {
      _filter = _filterFromQuery();
      _didReadInitialFilter = true;
    }
  }

  _CalendarFilter _filterFromQuery() {
    final filter = GoRouterState.of(context).uri.queryParameters['filter'];
    switch (filter) {
      case 'occupied':
        return _CalendarFilter.occupied;
      case 'checkIns':
        return _CalendarFilter.checkIns;
      case 'available':
        return _CalendarFilter.available;
      case 'upcomingCheckouts':
        return _CalendarFilter.upcomingCheckouts;
      case 'upcoming':
        return _CalendarFilter.upcoming;
      default:
        return _CalendarFilter.all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(summerBookingsProvider);
    final apartmentsAsync = ref.watch(apartmentsProvider);
    final activeSeason = ref.watch(activeSeasonKeyProvider);
    final theme = Theme.of(context);
    final monthFormatter = DateFormat('MMMM yyyy', 'ar');
    final isViewer = !ref.watch(canManageBookingsProvider);

    return AppScaffold(
      appBar: AbragAppBar(
        title: 'أجندة الحجوزات',
        subtitle: 'الموسم المعروض: ${seasonLabel(activeSeason)}',
        actions: [
          AppIconButton(
            tooltip: 'اليوم',
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
            icon: Icons.today,
          ),
        ],
      ),
      body: bookingsAsync.when(
        data: (bookings) {
          final apartments = apartmentsAsync.value ?? [];
          final selectedStats = _buildStats(bookings, apartments, _selectedDay);

          return ListView(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 28),
            children: [
              AppCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => setState(() {
                            _focusedDay = DateTime(
                              _focusedDay.year,
                              _focusedDay.month - 1,
                            );
                          }),
                          icon: const Icon(Icons.chevron_right),
                        ),
                        Expanded(
                          child: Text(
                            monthFormatter.format(_focusedDay),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(() {
                            _focusedDay = DateTime(
                              _focusedDay.year,
                              _focusedDay.month + 1,
                            );
                          }),
                          icon: const Icon(Icons.chevron_left),
                        ),
                      ],
                    ),
                    TableCalendar<SummerBooking>(
                      firstDay: DateTime.now().subtract(
                        const Duration(days: 365),
                      ),
                      lastDay: DateTime.now().add(
                        const Duration(days: 365 * 2),
                      ),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      eventLoader: (day) => _eventsForDay(bookings, day),
                      locale: 'ar',
                      headerVisible: false,
                      daysOfWeekHeight: 32,
                      rowHeight: 58,
                      calendarStyle: CalendarStyle(
                        outsideDaysVisible: false,
                        todayDecoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.18,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.colorScheme.primary),
                        ),
                        selectedDecoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        markerDecoration: BoxDecoration(
                          color: context.colors.summer,
                          shape: BoxShape.circle,
                        ),
                        markersMaxCount: 3,
                      ),
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, day, events) {
                          if (events.isEmpty) return null;
                          final hasCheckout = events.any(
                            (booking) => _isCheckoutOnDay(booking, day),
                          );
                          final hasCheckIn = events.any(
                            (booking) => _isCheckInOnDay(booking, day),
                          );
                          return Positioned(
                            bottom: 4,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (hasCheckIn &&
                                    _filter !=
                                        _CalendarFilter.upcomingCheckouts)
                                  _dot(context.colors.ok),
                                if (events.isNotEmpty &&
                                    _filter == _CalendarFilter.all)
                                  _dot(context.colors.summer),
                                if (hasCheckout) _dot(context.colors.err),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _SelectedDaySummary(
                stats: selectedStats,
                selectedDay: _selectedDay,
                onFilterSelected: (filter) => setState(() => _filter = filter),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterChip('الكل', _CalendarFilter.all),
                    _filterChip('مؤجرة اليوم', _CalendarFilter.checkIns),
                    _filterChip(
                      'خروجات قادمة',
                      _CalendarFilter.upcomingCheckouts,
                    ),
                    _filterChip('حجز مستقبلي', _CalendarFilter.upcoming),
                    _filterChip('الشقق المتاحة', _CalendarFilter.available),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildSelectedDayContent(
                context,
                bookings,
                apartments,
                selectedStats,
                isViewer: isViewer,
              ),
            ],
          );
        },
        loading: () => const LoadingSkeleton(),
        error: (err, stack) => ErrorState(
          title: 'تعذّر تحميل البيانات',
          message: 'حدث خطأ: $err',
          retryLabel: 'إعادة المحاولة',
          onRetry: () => ref.invalidate(summerBookingsProvider),
        ),
      ),
    );
  }

  Widget _buildSelectedDayContent(
    BuildContext context,
    List<SummerBooking> bookings,
    List<Apartment> apartments,
    _DayStats stats, {
    bool isViewer = false,
  }) {
    final selectedBookings = bookings.where((booking) {
      switch (_filter) {
        case _CalendarFilter.upcomingCheckouts:
          return _isUpcomingCheckout(booking, from: DateTime.now());
        case _CalendarFilter.occupied:
          return _isBookingActiveOnDay(booking, _selectedDay);
        case _CalendarFilter.checkIns:
          // "مؤجرة اليوم": اللي دخلت في اليوم ده فقط، مش كل المقيمين.
          return _isCheckInOnDay(booking, _selectedDay);
        case _CalendarFilter.upcoming:
          return _isFutureCheckIn(booking, after: _selectedDay);
        case _CalendarFilter.available:
          return false;
        case _CalendarFilter.all:
          return _isBookingActiveOnDay(booking, _selectedDay) ||
              _isCheckoutOnDay(booking, _selectedDay) ||
              _isCheckInOnDay(booking, _selectedDay);
      }
    }).toList();

    if (_filter == _CalendarFilter.upcomingCheckouts) {
      selectedBookings.sort(
        (a, b) => (a.earlyCheckoutDate ?? a.checkOutDate).compareTo(
          b.earlyCheckoutDate ?? b.checkOutDate,
        ),
      );
    } else if (_filter == _CalendarFilter.upcoming) {
      selectedBookings.sort((a, b) => a.checkInDate.compareTo(b.checkInDate));
    }

    if (_filter == _CalendarFilter.available) {
      if (stats.availableApartments.isEmpty) {
        return const _EmptyCalendarState(
          message: 'لا توجد شقق متاحة في اليوم ده',
        );
      }
      return Column(
        children: stats.availableApartments
            .map(
              (apartment) => Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.meeting_room)),
                  title: Text('شقة ${apartment.apartmentNumber}'),
                  subtitle: Text('الدور: ${apartment.floorNumber ?? '-'}'),
                  trailing: isViewer
                      ? null
                      : const Icon(Icons.add_circle_outline),
                  onTap: isViewer
                      ? null
                      : () => context.push('/summer_bookings/add'),
                ),
              ),
            )
            .toList(),
      );
    }

    if (selectedBookings.isEmpty) {
      return const _EmptyCalendarState(message: 'لا توجد حجوزات مطابقة للفلتر');
    }

    if (_filter == _CalendarFilter.upcomingCheckouts) {
      return _buildUpcomingCheckoutsContent(
        context,
        selectedBookings,
        apartments,
        bookings,
      );
    }

    final dateFormat = DateFormat('EEEE yyyy-MM-dd', 'ar');

    return Column(
      children: selectedBookings.map((booking) {
        final apartmentNumber = _apartmentNumberFor(apartments, booking);
        final isCheckout =
            _filter == _CalendarFilter.upcomingCheckouts ||
            _isCheckoutOnDay(booking, _selectedDay);
        final isCheckIn = _isCheckInOnDay(booking, _selectedDay);
        final isFutureCheckIn = _filter == _CalendarFilter.upcoming;
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isCheckout
                  ? context.colors.errSoft
                  : isCheckIn
                  ? context.colors.okSoft
                  : context.colors.summerSoft,
              child: Icon(
                isCheckout
                    ? Icons.logout
                    : isCheckIn
                    ? Icons.login
                    : Icons.hotel,
                color: isCheckout
                    ? context.colors.err
                    : isCheckIn
                    ? context.colors.ok
                    : context.colors.summer,
              ),
            ),
            title: Text(booking.guestName),
            subtitle: Text(
              isFutureCheckIn
                  ? 'شقة $apartmentNumber • دخول ${dateFormat.format(booking.checkInDate)}'
                  : 'شقة $apartmentNumber • ${isCheckout
                        ? "خروج"
                        : isCheckIn
                        ? "دخول"
                        : "إقامة"}',
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => context.push('/summer_bookings/details/${booking.id}'),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUpcomingCheckoutsContent(
    BuildContext context,
    List<SummerBooking> bookings,
    List<Apartment> apartments,
    List<SummerBooking> allBookings,
  ) {
    final grouped = <DateTime, List<SummerBooking>>{};
    for (final booking in bookings) {
      final checkoutDay = _dateOnly(
        booking.earlyCheckoutDate ?? booking.checkOutDate,
      );
      grouped.putIfAbsent(checkoutDay, () => []).add(booking);
    }

    final days = grouped.keys.toList()..sort();
    final formatter = DateFormat('EEEE، yyyy-MM-dd', 'ar');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: days.map((day) {
        final dayBookings = grouped[day]!
          ..sort(
            (a, b) => _apartmentNumberFor(
              apartments,
              a,
            ).compareTo(_apartmentNumberFor(apartments, b)),
          );
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.event_available, color: context.colors.err),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        formatter.format(day),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text('${dayBookings.length} شقق'),
                  ],
                ),
                const SizedBox(height: 8),
                ...dayBookings.map((booking) {
                  final apartmentNumber = _apartmentNumberFor(
                    apartments,
                    booking,
                  );
                  final nextBooking = _nextBookingForApartment(
                    allBookings,
                    booking,
                    from: day,
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: context.colors.errSoft,
                          child: Icon(Icons.logout, color: context.colors.err),
                        ),
                        title: Text('شقة $apartmentNumber'),
                        subtitle: Text(booking.guestName),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => context.push(
                          '/summer_bookings/details/${booking.id}',
                        ),
                      ),
                      _NextBookingBanner(
                        checkoutDay: day,
                        nextBooking: nextBooking,
                        onTap: nextBooking == null
                            ? null
                            : () => context.push(
                                '/summer_bookings/details/${nextBooking.id}',
                              ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  );
                }),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// أقرب حجز جاي على نفس الشقة بعد (أو في) يوم الخروج ده — عشان نعرف
  /// إن الشقة محجوزة تاني قبل ما نحجزها لعميل جديد.
  SummerBooking? _nextBookingForApartment(
    List<SummerBooking> allBookings,
    SummerBooking booking, {
    required DateTime from,
  }) {
    final candidates = allBookings.where((other) {
      if (other.id == booking.id) return false;
      if (other.apartmentId != booking.apartmentId) return false;
      if (other.status == 'cancelled' || other.status == 'checked_out') {
        return false;
      }
      return !_dateOnly(other.checkInDate).isBefore(_dateOnly(from));
    }).toList()..sort((a, b) => a.checkInDate.compareTo(b.checkInDate));
    return candidates.isEmpty ? null : candidates.first;
  }

  String _apartmentNumberFor(
    List<Apartment> apartments,
    SummerBooking booking,
  ) {
    final apartment = apartments
        .where((a) => a.id == booking.apartmentId)
        .toList();
    return apartment.isEmpty
        ? booking.apartmentId
        : apartment.first.apartmentNumber;
  }

  Widget _filterChip(String label, _CalendarFilter value) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: _filter == value,
        onSelected: (_) => setState(() => _filter = value),
      ),
    );
  }

  Widget _dot(Color color) => Container(
    width: 6,
    height: 6,
    margin: const EdgeInsets.symmetric(horizontal: 1.5),
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );

  _DayStats _buildStats(
    List<SummerBooking> bookings,
    List<Apartment> apartments,
    DateTime day,
  ) {
    final activeBookings = bookings.where((booking) {
      return _isBookingActiveOnDay(booking, day);
    }).toList();
    final occupiedIds = activeBookings
        .map((booking) => booking.apartmentId)
        .toSet();
    final checkouts = bookings
        .where((booking) => _isUpcomingCheckout(booking, from: DateTime.now()))
        .toList();
    final futureBookings = bookings
        .where((booking) => _isFutureCheckIn(booking, after: day))
        .toList();
    final availableApartments = apartments
        .where((apartment) => !occupiedIds.contains(apartment.id))
        .toList();

    return _DayStats(
      occupiedCount: occupiedIds.length,
      availableCount: availableApartments.length,
      checkoutCount: checkouts.length,
      futureCount: futureBookings.length,
      totalApartments: apartments.length,
      availableApartments: availableApartments,
    );
  }

  bool _isBookingActiveOnDay(SummerBooking booking, DateTime day) {
    if (booking.status == 'checked_out' || booking.status == 'cancelled') {
      return false;
    }
    final target = _dateOnly(day);
    final start = _dateOnly(booking.checkInDate);
    final endDate = booking.earlyCheckoutDate ?? booking.checkOutDate;
    final end = _dateOnly(endDate);
    return !target.isBefore(start) && !target.isAfter(end);
  }

  bool _isCheckoutOnDay(SummerBooking booking, DateTime day) {
    final checkout = booking.earlyCheckoutDate ?? booking.checkOutDate;
    return _isSameDate(checkout, day) && booking.status != 'cancelled';
  }

  bool _isUpcomingCheckout(SummerBooking booking, {required DateTime from}) {
    if (booking.status == 'checked_out' || booking.status == 'cancelled') {
      return false;
    }
    final checkout = booking.earlyCheckoutDate ?? booking.checkOutDate;
    final start = _dateOnly(from);
    final checkoutDay = _dateOnly(checkout);
    return !checkoutDay.isBefore(start);
  }

  List<SummerBooking> _eventsForDay(
    List<SummerBooking> bookings,
    DateTime day,
  ) {
    return bookings.where((booking) {
      switch (_filter) {
        case _CalendarFilter.upcomingCheckouts:
          return _isCheckoutOnDay(booking, day) &&
              !_dateOnly(day).isBefore(_dateOnly(DateTime.now()));
        case _CalendarFilter.upcoming:
          // علّم على أيام الدخول الجاية بس، مش كل يوم قبل الحجز.
          return _isCheckInOnDay(booking, day) &&
              _dateOnly(day).isAfter(_dateOnly(DateTime.now()));
        case _CalendarFilter.available:
          return false;
        case _CalendarFilter.occupied:
          return _isBookingActiveOnDay(booking, day);
        case _CalendarFilter.checkIns:
          return _isCheckInOnDay(booking, day);
        case _CalendarFilter.all:
          return _isBookingActiveOnDay(booking, day) ||
              _isCheckoutOnDay(booking, day) ||
              _isCheckInOnDay(booking, day);
      }
    }).toList();
  }

  bool _isCheckInOnDay(SummerBooking booking, DateTime day) {
    return _isSameDate(booking.checkInDate, day) &&
        booking.status != 'cancelled';
  }

  /// حجز مستقبلي = يدخل في يوم **بعد** اليوم المحدد.
  /// المقارنة باليوم مش بالساعة، عشان حجز داخل النهاردة الساعة ٢ الضهر
  /// يتحسب "مؤجرة اليوم" مش "حجز مستقبلي".
  bool _isFutureCheckIn(SummerBooking booking, {required DateTime after}) {
    if (booking.status == 'cancelled' || booking.status == 'checked_out') {
      return false;
    }
    return _dateOnly(booking.checkInDate).isAfter(_dateOnly(after));
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DayStats {
  final int occupiedCount;
  final int availableCount;
  final int checkoutCount;
  final int futureCount;
  final int totalApartments;
  final List<Apartment> availableApartments;

  const _DayStats({
    required this.occupiedCount,
    required this.availableCount,
    required this.checkoutCount,
    required this.futureCount,
    required this.totalApartments,
    required this.availableApartments,
  });
}

class _SelectedDaySummary extends StatelessWidget {
  final _DayStats stats;
  final DateTime selectedDay;
  final ValueChanged<_CalendarFilter> onFilterSelected;

  const _SelectedDaySummary({
    required this.stats,
    required this.selectedDay,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('EEEE، d MMMM', 'ar');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formatter.format(selectedDay),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 2.6,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                _TinyStat(
                  label: 'مؤجرة',
                  value: '${stats.occupiedCount}',
                  color: context.colors.summer,
                  onTap: () => onFilterSelected(_CalendarFilter.occupied),
                ),
                _TinyStat(
                  label: 'غير مؤجرة',
                  value: '${stats.availableCount}',
                  color: context.colors.ok,
                  onTap: () => onFilterSelected(_CalendarFilter.available),
                ),
                _TinyStat(
                  label: 'خروجات قادمة',
                  value: '${stats.checkoutCount}',
                  color: context.colors.err,
                  onTap: () =>
                      onFilterSelected(_CalendarFilter.upcomingCheckouts),
                ),
                _TinyStat(
                  label: 'إجمالي الشقق',
                  value: '${stats.totalApartments}',
                  color: context.colors.brand,
                  onTap: () => onFilterSelected(_CalendarFilter.all),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// بيوضّح تحت كل خروج قادم: الشقة دي محجوزة بعد كده ولا لأ، والحجز الجاي
/// بيدخل إمتى وقاعد كام ليلة — عشان محدش يحجزها لعميل تاني بالغلط.
class _NextBookingBanner extends StatelessWidget {
  final DateTime checkoutDay;
  final SummerBooking? nextBooking;
  final VoidCallback? onTap;

  const _NextBookingBanner({
    required this.checkoutDay,
    required this.nextBooking,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final booking = nextBooking;

    if (booking == null) {
      return _banner(
        context,
        icon: Icons.event_available_outlined,
        tint: colors.ok,
        background: colors.okSoft,
        text: 'مفيش حجز بعد الخروج — الشقة متاحة',
      );
    }

    final checkIn = DateTime(
      booking.checkInDate.year,
      booking.checkInDate.month,
      booking.checkInDate.day,
    );
    final checkOutSource = booking.earlyCheckoutDate ?? booking.checkOutDate;
    final checkOut = DateTime(
      checkOutSource.year,
      checkOutSource.month,
      checkOutSource.day,
    );
    final nights = checkOut.difference(checkIn).inDays;
    final gapDays = checkIn.difference(checkoutDay).inDays;
    final formatter = DateFormat('EEEE d MMMM', 'ar');

    final gapText = gapDays <= 0
        ? 'نفس يوم الخروج'
        : gapDays == 1
        ? 'تاني يوم'
        : gapDays == 2
        ? 'بعد يومين'
        : 'بعد $gapDays أيام';
    final nightsText = nights <= 0
        ? ''
        : nights == 1
        ? ' · ليلة واحدة'
        : nights == 2
        ? ' · ليلتين'
        : ' · $nights ليالي';

    return _banner(
      context,
      icon: Icons.event_repeat,
      tint: colors.warn,
      background: colors.warnSoft,
      text:
          'محجوزة بعدها: ${booking.guestName} · دخول ${formatter.format(checkIn)} ($gapText)$nightsText',
      onTap: onTap,
    );
  }

  Widget _banner(
    BuildContext context, {
    required IconData icon,
    required Color tint,
    required Color background,
    required String text,
    VoidCallback? onTap,
  }) {
    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tint.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: tint),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: context.colors.ink),
            ),
          ),
          if (onTap != null)
            Icon(Icons.arrow_forward_ios, size: 12, color: tint),
        ],
      ),
    );

    if (onTap == null) return content;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: content,
    );
  }
}

class _TinyStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _TinyStat({
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 6),
            Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}

class _EmptyCalendarState extends StatelessWidget {
  final String message;

  const _EmptyCalendarState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(child: Text(message)),
      ),
    );
  }
}
