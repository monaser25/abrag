import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database.dart';
import '../../../../core/database/tables.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';

final bookingsControllerProvider = StateNotifierProvider<BookingsController, AsyncValue<void>>((ref) {
  return BookingsController(ref.watch(databaseProvider));
});

class BookingsController extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;

  BookingsController(this._db) : super(const AsyncData(null));

  Future<void> addBooking({
    required String guestName,
    required String guestPhone,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required double totalPriceEgp,
  }) async {
    state = const AsyncLoading();
    try {
      final id = const Uuid().v4();
      
      // In a real app, you would select an actual apartment ID.
      // For now, we'll use a dummy ID or fetch the first available one.
      final apartments = await _db.select(_db.apartments).get();
      if (apartments.isEmpty) {
        throw Exception('No apartments available to book.');
      }
      final apartmentId = apartments.first.id;

      await _db.into(_db.summerBookings).insert(
        SummerBookingsCompanion.insert(
          id: id,
          apartmentId: apartmentId,
          guestName: guestName,
          guestPhone: Value(guestPhone),
          checkInDate: checkInDate,
          checkOutDate: checkOutDate,
          totalPriceEgp: totalPriceEgp,
          syncStatus: const Value(SyncStatus.pendingInsert),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> checkoutBooking(String id) async {
    state = const AsyncLoading();
    try {
      await (_db.update(_db.summerBookings)..where((t) => t.id.equals(id))).write(
        SummerBookingsCompanion(
          status: const Value('checked_out'),
          syncStatus: const Value(SyncStatus.pendingUpdate),
          updatedAt: Value(DateTime.now()),
        ),
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> earlyCheckoutBooking({
    required String id,
    required DateTime newCheckoutDate,
  }) async {
    state = const AsyncLoading();
    try {
      await (_db.update(_db.summerBookings)..where((t) => t.id.equals(id))).write(
        SummerBookingsCompanion(
          status: const Value('checked_out'),
          earlyCheckoutDate: Value(newCheckoutDate),
          syncStatus: const Value(SyncStatus.pendingUpdate),
          updatedAt: Value(DateTime.now()),
        ),
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> extendBooking({
    required String id,
    required DateTime newCheckoutDate,
    required int overstayDays,
    required double additionalFeeEgp,
  }) async {
    state = const AsyncLoading();
    try {
      final booking = await (_db.select(_db.summerBookings)..where((t) => t.id.equals(id))).getSingle();
      
      await (_db.update(_db.summerBookings)..where((t) => t.id.equals(id))).write(
        SummerBookingsCompanion(
          checkOutDate: Value(newCheckoutDate),
          overstayDays: Value(booking.overstayDays + overstayDays),
          overstayFeeEgp: Value(booking.overstayFeeEgp + additionalFeeEgp),
          totalPriceEgp: Value(booking.totalPriceEgp + additionalFeeEgp),
          syncStatus: const Value(SyncStatus.pendingUpdate),
          updatedAt: Value(DateTime.now()),
        ),
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
