import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/bookings_provider.dart';
import '../../../../core/database/database.dart';

class CalendarViewScreen extends ConsumerStatefulWidget {
  const CalendarViewScreen({super.key});

  @override
  ConsumerState<CalendarViewScreen> createState() => _CalendarViewScreenState();
}

class _CalendarViewScreenState extends ConsumerState<CalendarViewScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(summerBookingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('أجندة الحجوزات'), // TODO: Localization
      ),
      body: Column(
        children: [
          TableCalendar<SummerBooking>(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: (day) {
              return bookingsAsync.maybeWhen(
                data: (bookings) {
                  return bookings.where((b) {
                    final start = DateTime(b.checkInDate.year, b.checkInDate.month, b.checkInDate.day);
                    final end = DateTime(b.checkOutDate.year, b.checkOutDate.month, b.checkOutDate.day);
                    final target = DateTime(day.year, day.month, day.day);
                    return target.isAfter(start.subtract(const Duration(days: 1))) && 
                           target.isBefore(end.add(const Duration(days: 1)));
                  }).toList();
                },
                orElse: () => [],
              );
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                shape: BoxShape.circle,
                border: Border.all(color: theme.colorScheme.primary, width: 2),
              ),
              selectedDecoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: theme.colorScheme.secondary,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            locale: 'ar',
          ),
          const Divider(),
          Expanded(
            child: _selectedDay == null 
                ? const Center(child: Text('اختر يوماً لعرض الحجوزات'))
                : _buildBookingsListForDay(bookingsAsync),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsListForDay(AsyncValue<List<SummerBooking>> bookingsAsync) {
    return bookingsAsync.when(
      data: (bookings) {
        final dayBookings = bookings.where((b) {
          final start = DateTime(b.checkInDate.year, b.checkInDate.month, b.checkInDate.day);
          final end = DateTime(b.checkOutDate.year, b.checkOutDate.month, b.checkOutDate.day);
          final target = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
          return target.isAfter(start.subtract(const Duration(days: 1))) && 
                 target.isBefore(end.add(const Duration(days: 1)));
        }).toList();

        if (dayBookings.isEmpty) {
          return const Center(child: Text('لا توجد حجوزات في هذا اليوم'));
        }

        return ListView.builder(
          itemCount: dayBookings.length,
          itemBuilder: (context, index) {
            final booking = dayBookings[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(booking.guestName),
                subtitle: Text('رقم الشقة: ${booking.apartmentId}'), // Ideally join with apartments
                trailing: Text(booking.status),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}
