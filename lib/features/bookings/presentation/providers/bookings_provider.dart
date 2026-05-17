import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_settings_provider.dart';
import '../../../../core/database/database.dart';
import '../../../../core/utils/season_utils.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';

final allSummerBookingsProvider = StreamProvider<List<SummerBooking>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.summerBookings).watch();
});

final summerBookingsProvider = StreamProvider<List<SummerBooking>>((ref) {
  final db = ref.watch(databaseProvider);
  final activeSeason = ref.watch(activeSeasonKeyProvider);
  return db.select(db.summerBookings).watch().map((bookings) {
      final filtered = bookings
          .where((booking) => seasonMatchesDate(booking.checkInDate, activeSeason))
          .toList()
        ..sort((a, b) => b.checkInDate.compareTo(a.checkInDate));
      return filtered;
    });
});
