import 'package:abrag/core/database/database.dart';
import 'package:abrag/core/database/tables.dart';
import 'package:abrag/core/utils/booking_rate_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('booking rate utils', () {
    SummerBooking createBooking({
      required DateTime checkInDate,
      required DateTime checkOutDate,
      DateTime? earlyCheckoutDate,
      int overstayDays = 0,
      double overstayFeeEgp = 0.0,
      double totalPriceEgp = 0.0,
    }) {
      return SummerBooking(
        syncStatus: SyncStatus.synced,
        lastModifiedLocal: DateTime.now(),
        id: '1',
        apartmentId: '1',
        guestName: 'Guest',
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
        earlyCheckoutDate: earlyCheckoutDate,
        status: 'confirmed',
        totalPriceEgp: totalPriceEgp,
        amountPaidEgp: 0,
        paymentMethod: 'cash',
        brokerCommissionType: 'none',
        brokerCommissionPercentage: 0,
        brokerCommissionFixedEgp: 0,
        brokerCommissionPaidCashEgp: 0,
        brokerCommissionPaidVodafoneEgp: 0,
        brokerCommissionPaidInstapayEgp: 0,
        overstayDays: overstayDays,
        overstayFeeEgp: overstayFeeEgp,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    test('summerBookingStayDays ignores time and correctly counts nights', () {
      final booking = createBooking(
        checkInDate: DateTime(2023, 8, 1, 14, 0),
        checkOutDate: DateTime(2023, 8, 5, 12, 0),
      );
      expect(summerBookingStayDays(booking), 4);
    });

    test('summerBookingStayDays uses earlyCheckoutDate if present', () {
      final booking = createBooking(
        checkInDate: DateTime(2023, 8, 1),
        checkOutDate: DateTime(2023, 8, 10),
        earlyCheckoutDate: DateTime(2023, 8, 4),
      );
      expect(summerBookingStayDays(booking), 3);
    });

    test('summerBookingBaseDays subtracts overstayDays', () {
      final booking = createBooking(
        checkInDate: DateTime(2023, 8, 1),
        checkOutDate: DateTime(2023, 8, 10),
        overstayDays: 2,
      );
      expect(summerBookingBaseDays(booking), 7);
    });

    test('summerBookingBaseDays clamps to at least 1', () {
      final booking = createBooking(
        checkInDate: DateTime(2023, 8, 1),
        checkOutDate: DateTime(2023, 8, 2),
        overstayDays: 5,
      );
      expect(summerBookingBaseDays(booking), 1);
    });

    test('summerBookingBaseDailyRate calculates correctly', () {
      final booking = createBooking(
        checkInDate: DateTime(2023, 8, 1),
        checkOutDate: DateTime(2023, 8, 5),
        totalPriceEgp: 2000,
        overstayDays: 0,
        overstayFeeEgp: 0,
      );
      expect(summerBookingBaseDailyRate(booking), 500);
    });

    test('summerBookingBaseDailyRate calculates correctly with extension', () {
      final booking = createBooking(
        checkInDate: DateTime(2023, 8, 1),
        checkOutDate: DateTime(2023, 8, 10),
        totalPriceEgp: 4500,
        overstayDays: 4,
        overstayFeeEgp: 2000,
      );
      expect(summerBookingBaseDailyRate(booking), 500);
    });

    // الحالة اللي حصلت فعلًا في شقة ١٦: ١٨٠٠ ج.م لأربع ليالي (٤٥٠ لليلة)،
    // اتمددت مرتين ×٧ أيام بـ ٢٨٠٠ لكل مرة. القسمة على كل الليالي كانت
    // بتطلّع ١٨٠٠ ÷ ١٨ = ١٠٠ ج.م لليلة بدل ٤٥٠.
    test('extended booking keeps the original nightly rate (شقة 16)', () {
      final booking = createBooking(
        checkInDate: DateTime(2026, 8, 2),
        checkOutDate: DateTime(2026, 8, 20),
        totalPriceEgp: 7400,
        overstayDays: 14,
        overstayFeeEgp: 5600,
      );
      expect(summerBookingStayDays(booking), 18);
      expect(summerBookingBaseDays(booking), 4);
      expect(summerBookingBaseDailyRate(booking), 450);
    });

    test(
      'summerBookingBaseDailyRate calculates correctly with early checkout',
      () {
        final booking = createBooking(
          checkInDate: DateTime(2023, 8, 1),
          checkOutDate: DateTime(2023, 8, 10),
          earlyCheckoutDate: DateTime(2023, 8, 5),
          totalPriceEgp: 2000,
          overstayDays: 0,
          overstayFeeEgp: 0,
        );
        expect(summerBookingBaseDailyRate(booking), 500);
      },
    );

    test('summerBookingBaseDailyRate clamps negative baseTotal to 0', () {
      final booking = createBooking(
        checkInDate: DateTime(2023, 8, 1),
        checkOutDate: DateTime(2023, 8, 5),
        totalPriceEgp: 1000,
        overstayDays: 1,
        overstayFeeEgp: 2000,
      );
      expect(summerBookingBaseDailyRate(booking), 0.0);
    });
  });
}
