import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database.dart';
import '../../../../core/database/tables.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';

final bookingsControllerProvider =
    StateNotifierProvider<BookingsController, AsyncValue<void>>((ref) {
      return BookingsController(ref.watch(databaseProvider));
    });

class BookingsController extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;

  BookingsController(this._db) : super(const AsyncData(null));

  DateTime _effectiveCheckoutDate(SummerBooking booking) {
    return booking.earlyCheckoutDate ?? booking.checkOutDate;
  }

  Future<void> _ensureNoApartmentConflict({
    required String apartmentId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    String? excludingBookingId,
  }) async {
    final query = _db.select(_db.summerBookings)
      ..where((t) => t.apartmentId.equals(apartmentId))
      ..where((t) => t.status.isNotIn(['cancelled']));

    if (excludingBookingId != null) {
      query.where((t) => t.id.equals(excludingBookingId).not());
    }

    final existingBookings = await query.get();
    final hasConflict = existingBookings.any((booking) {
      final existingEnd = _effectiveCheckoutDate(booking);
      return checkInDate.isBefore(existingEnd) &&
          checkOutDate.isAfter(booking.checkInDate);
    });

    if (hasConflict) {
      throw Exception('هذه الشقة محجوزة بالفعل في هذه الفترة.');
    }
  }

  Future<void> addBooking({
    required String apartmentId,
    required String guestName,
    required String guestPhone,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required double totalPriceEgp,
    required double amountPaidEgp,
    required String paymentMethod,
    String? brokerId,
    String? brokerName,
    required String brokerCommissionType,
    required double brokerCommissionFixedEgp,
    required double brokerCommissionPercentage,
    String? nationalId,
    String? idFrontImage,
    String? idBackImage,
  }) async {
    state = const AsyncLoading();
    try {
      if (amountPaidEgp > totalPriceEgp) {
        throw Exception('العربون لا يمكن أن يكون أكبر من السعر الإجمالي');
      }
      await _ensureNoApartmentConflict(
        apartmentId: apartmentId,
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
      );

      final id = const Uuid().v4();

      // Determine initial status based on payment
      String status = 'pending';
      if (amountPaidEgp >= totalPriceEgp && totalPriceEgp > 0) {
        status = 'confirmed'; // Or checked_in if dates match
      } else if (amountPaidEgp > 0) {
        status = 'confirmed'; // partial payment means confirmed
      }

      await _db
          .into(_db.summerBookings)
          .insert(
            SummerBookingsCompanion.insert(
              id: id,
              apartmentId: apartmentId,
              guestName: guestName,
              guestPhone: Value(guestPhone),
              checkInDate: checkInDate,
              checkOutDate: checkOutDate,
              status: Value(status),
              totalPriceEgp: totalPriceEgp,
              amountPaidEgp: Value(amountPaidEgp),
              paymentMethod: Value(paymentMethod),
              brokerId: Value(brokerId),
              brokerName: Value(brokerName),
              brokerCommissionType: Value(brokerCommissionType),
              brokerCommissionFixedEgp: Value(brokerCommissionFixedEgp),
              brokerCommissionPercentage: Value(brokerCommissionPercentage),
              nationalId: Value(nationalId),
              idFrontImage: Value(idFrontImage),
              idBackImage: Value(idBackImage),
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

  Future<void> updateBooking({
    required String id,
    required String apartmentId,
    required String guestName,
    required String guestPhone,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required double totalPriceEgp,
    required double amountPaidEgp,
    required String paymentMethod,
    String? brokerId,
    String? brokerName,
    required String brokerCommissionType,
    required double brokerCommissionFixedEgp,
    required double brokerCommissionPercentage,
    String? nationalId,
    String? idFrontImage,
    String? idBackImage,
  }) async {
    state = const AsyncLoading();
    try {
      if (amountPaidEgp > totalPriceEgp) {
        throw Exception('العربون لا يمكن أن يكون أكبر من السعر الإجمالي');
      }
      await _ensureNoApartmentConflict(
        apartmentId: apartmentId,
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
        excludingBookingId: id,
      );

      String status = 'pending';
      if (amountPaidEgp > 0) status = 'confirmed';

      await (_db.update(
        _db.summerBookings,
      )..where((t) => t.id.equals(id))).write(
        SummerBookingsCompanion(
          apartmentId: Value(apartmentId),
          guestName: Value(guestName),
          guestPhone: Value(guestPhone),
          checkInDate: Value(checkInDate),
          checkOutDate: Value(checkOutDate),
          status: Value(status),
          totalPriceEgp: Value(totalPriceEgp),
          amountPaidEgp: Value(amountPaidEgp),
          paymentMethod: Value(paymentMethod),
          brokerId: Value(brokerId),
          brokerName: Value(brokerName),
          brokerCommissionType: Value(brokerCommissionType),
          brokerCommissionFixedEgp: Value(brokerCommissionFixedEgp),
          brokerCommissionPercentage: Value(brokerCommissionPercentage),
          nationalId: Value(nationalId),
          idFrontImage: Value(idFrontImage),
          idBackImage: Value(idBackImage),
          syncStatus: const Value(SyncStatus.pendingUpdate),
          updatedAt: Value(DateTime.now()),
        ),
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> checkoutBooking(
    String id, {
    String cleaningStatus = 'needs_cleaning',
    String? apartmentId,
  }) async {
    state = const AsyncLoading();
    try {
      await (_db.update(
        _db.summerBookings,
      )..where((t) => t.id.equals(id))).write(
        SummerBookingsCompanion(
          status: const Value('checked_out'),
          syncStatus: const Value(SyncStatus.pendingUpdate),
          updatedAt: Value(DateTime.now()),
        ),
      );

      if (apartmentId != null) {
        await (_db.update(
          _db.apartments,
        )..where((t) => t.id.equals(apartmentId))).write(
          ApartmentsCompanion(
            cleaningStatus: Value(cleaningStatus),
            syncStatus: const Value(SyncStatus.pendingUpdate),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }

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
      await (_db.update(
        _db.summerBookings,
      )..where((t) => t.id.equals(id))).write(
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
      final booking = await (_db.select(
        _db.summerBookings,
      )..where((t) => t.id.equals(id))).getSingle();

      await (_db.update(
        _db.summerBookings,
      )..where((t) => t.id.equals(id))).write(
        SummerBookingsCompanion(
          checkOutDate: Value(newCheckoutDate),
          overstayDays: Value(booking.overstayDays + overstayDays),
          overstayFeeEgp: Value(booking.overstayFeeEgp + additionalFeeEgp),
          totalPriceEgp: Value(booking.totalPriceEgp + additionalFeeEgp),
          amountPaidEgp: Value(booking.amountPaidEgp + additionalFeeEgp),
          syncStatus: const Value(SyncStatus.pendingUpdate),
          updatedAt: Value(DateTime.now()),
        ),
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteBooking(String id) async {
    state = const AsyncLoading();
    try {
      // Offline-first deletion: either physically delete if not synced yet,
      // or mark with a status like 'deleted' / pendingDelete for sync.
      // Assuming Drift physical delete for simplicity here:
      await (_db.delete(
        _db.summerBookings,
      )..where((t) => t.id.equals(id))).go();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
