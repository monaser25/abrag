import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database.dart';
import '../../../../core/database/tables.dart';
import '../../../../core/utils/occupancy_utils.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';

final apartmentOccupancyRulesProvider = Provider<ApartmentOccupancyRules>((
  ref,
) {
  return ApartmentOccupancyRules(ref.watch(databaseProvider));
});

class ApartmentOccupancyRules {
  final AppDatabase _db;

  ApartmentOccupancyRules(this._db);

  Future<void> ensureApartmentIsFreeForPeriod({
    required String apartmentId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    String? excludingSummerBookingId,
    String? excludingWinterContractId,
  }) async {
    final summerBookings =
        await (_db.select(_db.summerBookings)
              ..where((t) => t.apartmentId.equals(apartmentId))
              ..where(
                (t) =>
                    t.status.isNotIn(['cancelled', 'checked_out', 'deleted']),
              )
              ..where(
                (t) => t.syncStatus.isNotIn([SyncStatus.pendingDelete.index]),
              ))
            .get();
    for (final booking in summerBookings) {
      if (booking.id == excludingSummerBookingId) continue;
      final existingEnd = booking.earlyCheckoutDate ?? booking.checkOutDate;
      if (_periodsOverlap(
        checkInDate,
        checkOutDate,
        booking.checkInDate,
        existingEnd,
      )) {
        throw Exception(
          'الشقة عليها حجز صيفي متعارض باسم ${booking.guestName}. راجع الحجز المستقبلي قبل الحفظ.',
        );
      }
    }

    final winterContracts =
        await (_db.select(_db.winterContracts)
              ..where((t) => t.apartmentId.equals(apartmentId))
              ..where((t) => t.isActive.equals(true)))
            .get();
    for (final contract in winterContracts) {
      if (contract.id == excludingWinterContractId) continue;
      if (_periodsOverlap(
        checkInDate,
        checkOutDate,
        contract.startDate,
        contract.endDate,
      )) {
        throw Exception(
          'مينفعش الشقة تكون سكن طالب ومصيف في نفس الوقت. الشقة عليها عقد باسم ${contract.studentName}.',
        );
      }
    }
  }

  Future<Set<String>> occupiedApartmentIdsForPeriod({
    required DateTime checkInDate,
    required DateTime checkOutDate,
    String? excludingSummerBookingId,
  }) async {
    final occupiedIds = <String>{};

    final summerBookings =
        await (_db.select(_db.summerBookings)
              ..where(
                (t) =>
                    t.status.isNotIn(['cancelled', 'checked_out', 'deleted']),
              )
              ..where(
                (t) => t.syncStatus.isNotIn([SyncStatus.pendingDelete.index]),
              ))
            .get();
    for (final booking in summerBookings) {
      if (booking.id == excludingSummerBookingId) continue;
      final existingEnd = booking.earlyCheckoutDate ?? booking.checkOutDate;
      if (_periodsOverlap(
        checkInDate,
        checkOutDate,
        booking.checkInDate,
        existingEnd,
      )) {
        occupiedIds.add(booking.apartmentId);
      }
    }

    final winterContracts = await (_db.select(
      _db.winterContracts,
    )..where((t) => t.isActive.equals(true))).get();
    for (final contract in winterContracts) {
      if (_periodsOverlap(
        checkInDate,
        checkOutDate,
        contract.startDate,
        contract.endDate,
      )) {
        occupiedIds.add(contract.apartmentId);
      }
    }

    return occupiedIds;
  }

  Future<bool> isApartmentOccupiedNow(String apartmentId) async {
    final now = DateTime.now();
    final summerBookings =
        await (_db.select(_db.summerBookings)
              ..where((t) => t.apartmentId.equals(apartmentId))
              ..where(
                (t) =>
                    t.status.isNotIn(['cancelled', 'checked_out', 'deleted']),
              )
              ..where(
                (t) => t.syncStatus.isNotIn([SyncStatus.pendingDelete.index]),
              ))
            .get();
    // كان بيقول "مشغولة" لمجرد إن الدخول عدّى — من غير أي حد لتاريخ الخروج،
    // فحجز قديم ما اتسجلش خروجه كان بيقفل الشقة للأبد.
    final hasSummer = summerBookings.any(
      (booking) => summerBookingHoldsApartment(booking, now),
    );
    if (hasSummer) return true;

    final winterContracts =
        await (_db.select(_db.winterContracts)
              ..where((t) => t.apartmentId.equals(apartmentId))
              ..where((t) => t.isActive.equals(true)))
            .get();
    return winterContracts.any(
      (contract) => winterContractHoldsApartment(contract, now),
    );
  }

  bool _periodsOverlap(
    DateTime startA,
    DateTime endA,
    DateTime startB,
    DateTime endB,
  ) {
    return startA.isBefore(endB) && endA.isAfter(startB);
  }
}
