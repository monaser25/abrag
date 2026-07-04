import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_settings_provider.dart';
import '../../../../core/database/database.dart';
import '../../../../core/database/tables.dart';
import '../../../../core/utils/season_utils.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';

final allSummerBookingsProvider = StreamProvider<List<SummerBooking>>((ref) {
  final db = ref.watch(databaseProvider);
  return db
      .select(db.summerBookings)
      .watch()
      .map(
        (bookings) => bookings
            .where(
              (booking) =>
                  booking.syncStatus != SyncStatus.pendingDelete &&
                  booking.status != 'deleted',
            )
            .toList(),
      );
});

final summerBookingsProvider = StreamProvider<List<SummerBooking>>((ref) {
  final db = ref.watch(databaseProvider);
  final activeSeason = ref.watch(activeSeasonKeyProvider);
  return db.select(db.summerBookings).watch().map((bookings) {
    final filtered =
        bookings
            .where(
              (booking) =>
                  booking.syncStatus != SyncStatus.pendingDelete &&
                  booking.status != 'deleted' &&
                  seasonMatchesDate(booking.checkInDate, activeSeason),
            )
            .toList()
          ..sort((a, b) => b.checkInDate.compareTo(a.checkInDate));
    return filtered;
  });
});

final bookingPaymentsProvider =
    StreamProvider.family<List<BookingPayment>, String>((ref, bookingId) {
      final db = ref.watch(databaseProvider);
      return (db.select(
        db.bookingPayments,
      )..where((t) => t.bookingId.equals(bookingId))).watch().map((payments) {
        final filtered =
            payments
                .where(
                  (payment) => payment.syncStatus != SyncStatus.pendingDelete,
                )
                .toList()
              ..sort((a, b) => a.paymentDate.compareTo(b.paymentDate));
        return filtered;
      });
    });
