import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/bookings_provider.dart';
import '../../../apartments/presentation/providers/apartments_controller.dart';
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
    final apartmentsAsync = ref.watch(apartmentsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('أجندة الحجوزات'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(theme.colorScheme.primary, 'يوم مختار'),
                const SizedBox(width: 16),
                _buildLegendItem(theme.colorScheme.secondary, 'يوجد حجوزات'),
                const SizedBox(width: 16),
                _buildLegendItem(theme.colorScheme.primary.withValues(alpha: 0.3), 'اليوم'),
              ],
            ),
          ),
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
                : _buildBookingsListForDay(bookingsAsync, apartmentsAsync),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildBookingsListForDay(AsyncValue<List<SummerBooking>> bookingsAsync, AsyncValue<List<Apartment>> apartmentsAsync) {
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
            final aptNumber = apartmentsAsync.maybeWhen(
              data: (apts) {
                try {
                  return apts.firstWhere((a) => a.id == booking.apartmentId).apartmentNumber;
                } catch (_) {
                  return 'غير معروف';
                }
              },
              orElse: () => '...',
            );

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(booking.guestName),
                subtitle: Text('رقم الشقة: $aptNumber'),
                trailing: Text(
                  booking.status == 'checked_out' ? 'منتهية' : 'جارية',
                  style: TextStyle(
                    color: booking.status == 'checked_out' ? Colors.grey : Colors.green,
                  ),
                ),
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
