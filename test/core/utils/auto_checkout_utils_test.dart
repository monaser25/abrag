import 'package:abrag/core/database/database.dart';
import 'package:abrag/core/database/tables.dart';
import 'package:abrag/core/utils/auto_checkout_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  SummerBooking booking({
    DateTime? checkOutDate,
    DateTime? earlyCheckoutDate,
    double totalPriceEgp = 1000,
    double amountPaidEgp = 1000,
    String status = 'confirmed',
  }) {
    return SummerBooking(
      syncStatus: SyncStatus.synced,
      lastModifiedLocal: DateTime(2026, 8, 1),
      id: '1',
      apartmentId: '1',
      guestName: 'ضيف',
      checkInDate: DateTime(2026, 8, 10),
      checkOutDate: checkOutDate ?? DateTime(2026, 8, 14, 8),
      earlyCheckoutDate: earlyCheckoutDate,
      status: status,
      totalPriceEgp: totalPriceEgp,
      amountPaidEgp: amountPaidEgp,
      paymentMethod: 'cash',
      brokerCommissionType: 'none',
      brokerCommissionPercentage: 0,
      brokerCommissionFixedEgp: 0,
      brokerCommissionPaidCashEgp: 0,
      brokerCommissionPaidVodafoneEgp: 0,
      brokerCommissionPaidInstapayEgp: 0,
      overstayDays: 0,
      overstayFeeEgp: 0,
      createdAt: DateTime(2026, 8, 10),
      updatedAt: DateTime(2026, 8, 10),
    );
  }

  group('الإقفال التلقائي', () {
    test('waits until the hour has passed on the checkout day', () {
      final b = booking();
      // الساعة ٩:٥٩ يوم الخروج — لسه بدري.
      expect(
        summerBookingAutoCheckoutSkipReason(b, DateTime(2026, 8, 14, 9, 59)),
        AutoCheckoutSkipReason.notDueYet,
      );
      // الساعة ١٠:٠٠ بالظبط — يتقفل.
      expect(
        summerBookingAutoCheckoutSkipReason(b, DateTime(2026, 8, 14, 10)),
        isNull,
      );
    });

    test('the checkout time of day does not matter, only the date', () {
      // حجز خروجه ٨ صباحاً وحجز خروجه ١٢ بليل نفس اليوم — الاتنين بيتقفلوا
      // الساعة ١٠. المقارنة على اليوم عشان الداتا القديمة والجديدة مختلفين.
      final atEight = booking(checkOutDate: DateTime(2026, 8, 14, 8));
      final atMidnight = booking(checkOutDate: DateTime(2026, 8, 14));
      final at10 = DateTime(2026, 8, 14, 10);
      expect(summerBookingAutoCheckoutSkipReason(atEight, at10), isNull);
      expect(summerBookingAutoCheckoutSkipReason(atMidnight, at10), isNull);
    });

    test('never closes a booking the guest still owes money on', () {
      final owing = booking(totalPriceEgp: 1000, amountPaidEgp: 400);
      expect(
        summerBookingAutoCheckoutSkipReason(owing, DateTime(2026, 8, 20)),
        AutoCheckoutSkipReason.unpaid,
        reason: 'الدين لازم يفضل ظاهر لحد ما يتحصّل',
      );
    });

    test('a rounding-sized shortfall still counts as paid', () {
      final b = booking(totalPriceEgp: 1000, amountPaidEgp: 999.995);
      expect(
        summerBookingAutoCheckoutSkipReason(b, DateTime(2026, 8, 20)),
        isNull,
      );
    });

    test('an overdue checkout closes on the next run', () {
      final b = booking();
      expect(
        summerBookingAutoCheckoutSkipReason(b, DateTime(2026, 8, 17, 3)),
        isNull,
        reason: 'يوم الخروج عدّى من ٣ أيام',
      );
    });

    test('an early checkout date brings the closing time forward', () {
      final b = booking(
        checkOutDate: DateTime(2026, 8, 20),
        earlyCheckoutDate: DateTime(2026, 8, 14),
      );
      expect(
        summerBookingAutoCheckoutSkipReason(b, DateTime(2026, 8, 14, 10)),
        isNull,
      );
    });

    test('a custom hour is respected', () {
      final b = booking();
      expect(
        summerBookingAutoCheckoutSkipReason(
          b,
          DateTime(2026, 8, 14, 10),
          hour: 14,
        ),
        AutoCheckoutSkipReason.notDueYet,
      );
      expect(
        summerBookingAutoCheckoutSkipReason(
          b,
          DateTime(2026, 8, 14, 14),
          hour: 14,
        ),
        isNull,
      );
    });

    test('the closing moment is the checkout day at the given hour', () {
      expect(
        summerBookingAutoCheckoutAt(booking(), 10),
        DateTime(2026, 8, 14, 10),
      );
    });
  });
}
