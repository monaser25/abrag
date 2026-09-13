import 'package:abrag/core/database/database.dart';
import 'package:abrag/core/database/tables.dart';
import 'package:abrag/core/utils/occupancy_utils.dart';
import 'package:flutter_test/flutter_test.dart';

/// المالك بيستلم الشقة ٨ صباحاً وساعات بيسجّل الخروج في التطبيق متأخر — فالشقة
/// لازم تفضى بميعاد الخروج مش بزرار تسجيل الخروج.
void main() {
  SummerBooking booking({
    required DateTime checkIn,
    required DateTime checkOut,
    DateTime? earlyCheckout,
    String status = 'confirmed',
    SyncStatus syncStatus = SyncStatus.synced,
  }) {
    return SummerBooking(
      id: 'booking-1',
      apartmentId: 'apartment-1',
      guestName: 'ضيف',
      guestPhone: '01000000000',
      checkInDate: checkIn,
      checkOutDate: checkOut,
      earlyCheckoutDate: earlyCheckout,
      status: status,
      totalPriceEgp: 1000,
      amountPaidEgp: 1000,
      overstayDays: 0,
      overstayFeeEgp: 0,
      paymentMethod: 'cash',
      brokerCommissionType: 'none',
      brokerCommissionFixedEgp: 0,
      brokerCommissionPercentage: 0,
      brokerCommissionPaidCashEgp: 0,
      brokerCommissionPaidVodafoneEgp: 0,
      brokerCommissionPaidInstapayEgp: 0,
      createdAt: checkIn,
      updatedAt: checkIn,
      syncStatus: syncStatus,
      lastModifiedLocal: checkIn,
    );
  }

  final stay = booking(
    checkIn: DateTime(2026, 8, 1, 14),
    checkOut: DateTime(2026, 8, 8, 8),
  );

  test('holds the apartment while the guest is still staying', () {
    expect(summerBookingHoldsApartment(stay, DateTime(2026, 8, 3, 10)), isTrue);
  });

  test('does not hold the apartment before check-in day', () {
    expect(
      summerBookingHoldsApartment(stay, DateTime(2026, 7, 30, 10)),
      isFalse,
    );
  });

  test('holds it from the morning of check-in day, before the 2pm arrival', () {
    expect(summerBookingHoldsApartment(stay, DateTime(2026, 8, 1, 9)), isTrue);
  });

  test('frees the apartment on checkout day so it can be re-let same day', () {
    // خروج ٨ صباحاً ودخول عميل جديد ٢ الضهر نفس اليوم.
    expect(summerBookingHoldsApartment(stay, DateTime(2026, 8, 8, 9)), isFalse);
    expect(summerBookingChecksOutOn(stay, DateTime(2026, 8, 8)), isTrue);
  });

  test('a forgotten checkout does not hold the apartment forever', () {
    // ده كان الباج: من غير حد لتاريخ الخروج الشقة تفضل "مؤجرة" للأبد.
    final now = DateTime(2026, 9, 20, 12);
    expect(summerBookingHoldsApartment(stay, now), isFalse);
    expect(summerBookingCheckoutIsOverdue(stay, now), isTrue);
  });

  test('checkout is not overdue while the stay is still running', () {
    expect(
      summerBookingCheckoutIsOverdue(stay, DateTime(2026, 8, 3, 10)),
      isFalse,
    );
  });

  test('an early checkout date wins over the original checkout date', () {
    final shortened = booking(
      checkIn: DateTime(2026, 8, 1, 14),
      checkOut: DateTime(2026, 8, 8, 8),
      earlyCheckout: DateTime(2026, 8, 4, 8),
    );
    expect(
      summerBookingHoldsApartment(shortened, DateTime(2026, 8, 5, 10)),
      isFalse,
    );
    expect(summerBookingChecksOutOn(shortened, DateTime(2026, 8, 4)), isTrue);
  });

  test('cancelled, checked-out and deleted bookings never hold or flag', () {
    for (final status in ['cancelled', 'checked_out', 'deleted']) {
      final dead = booking(
        checkIn: DateTime(2026, 8, 1, 14),
        checkOut: DateTime(2026, 8, 8, 8),
        status: status,
      );
      expect(summerBookingHoldsApartment(dead, DateTime(2026, 8, 3)), isFalse);
      expect(
        summerBookingCheckoutIsOverdue(dead, DateTime(2026, 9, 20)),
        isFalse,
        reason: 'خروج $status مالوش تسجيل متأخر',
      );
    }

    final pendingDelete = booking(
      checkIn: DateTime(2026, 8, 1, 14),
      checkOut: DateTime(2026, 8, 8, 8),
      syncStatus: SyncStatus.pendingDelete,
    );
    expect(
      summerBookingHoldsApartment(pendingDelete, DateTime(2026, 8, 3)),
      isFalse,
    );
  });

  test('date-only legacy rows behave like the 8am ones', () {
    // البيانات القديمة متخزّنة ١٢ صباحاً بدل ٨ — المقارنة اليومية بتساويهم.
    final legacy = booking(
      checkIn: DateTime(2026, 8, 1),
      checkOut: DateTime(2026, 8, 8),
    );
    expect(
      summerBookingHoldsApartment(legacy, DateTime(2026, 8, 7, 23)),
      isTrue,
    );
    expect(
      summerBookingHoldsApartment(legacy, DateTime(2026, 8, 8, 1)),
      isFalse,
    );
  });
}
