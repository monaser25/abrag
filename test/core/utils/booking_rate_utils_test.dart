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

    test('stay days count nights and ignore the time of day', () {
      final booking = createBooking(
        checkInDate: DateTime(2026, 8, 1, 14, 0),
        checkOutDate: DateTime(2026, 8, 5, 8, 0),
      );
      expect(summerBookingStayDays(booking), 4);
    });

    test('stay days stop at the early checkout date', () {
      final booking = createBooking(
        checkInDate: DateTime(2026, 8, 1),
        checkOutDate: DateTime(2026, 8, 10),
        earlyCheckoutDate: DateTime(2026, 8, 4),
      );
      expect(summerBookingStayDays(booking), 3);
    });

    test('a plain booking divides its total over its nights', () {
      final booking = createBooking(
        checkInDate: DateTime(2026, 8, 1),
        checkOutDate: DateTime(2026, 8, 5),
        totalPriceEgp: 2000,
      );
      expect(summerBookingDailyRate(booking), 500);
    });

    // الحالة اللي حصلت في شقة ١٦: ١٨٠٠ ج.م لأربع ليالي، اتمددت مرتين ×٧ أيام
    // بـ ٢٨٠٠ لكل مرة. الحساب القديم كان بيطرح رسوم التمديد فيطلّع
    // ١٨٠٠ ÷ ١٨ = ١٠٠. الصح إن الإجمالي كله يتقسم على كل الليالي.
    test('an extended booking averages the whole total over all nights', () {
      final booking = createBooking(
        checkInDate: DateTime(2026, 8, 2),
        checkOutDate: DateTime(2026, 8, 20),
        totalPriceEgp: 7400,
        overstayDays: 14,
        overstayFeeEgp: 5600,
      );
      expect(summerBookingStayDays(booking), 18);
      expect(summerBookingDailyRate(booking), closeTo(411.11, 0.01));
    });

    // شقة ٩: ٢٤٠٠ لأربع ليالي (٦٠٠) + تمديد ٦ أيام بـ ٣٦٠٠ (٦٠٠ برضه).
    // لما السعرين واحد، المتوسط لازم يطلّع نفس الرقم بالظبط.
    test('a booking extended at the same rate keeps that exact rate', () {
      final booking = createBooking(
        checkInDate: DateTime(2026, 8, 7),
        checkOutDate: DateTime(2026, 8, 17),
        totalPriceEgp: 6000,
        overstayDays: 6,
        overstayFeeEgp: 3600,
      );
      expect(summerBookingDailyRate(booking), 600);
    });

    // الباج القديم: تعديل بيسيب رسوم التمديد ويقلّل الإجمالي، فالطرح كان
    // بيطلّع سعر بالسالب. دلوقتي مفيش طرح أصلًا فمستحيل يحصل.
    test('an overstay fee larger than the total never goes negative', () {
      final booking = createBooking(
        checkInDate: DateTime(2026, 8, 1),
        checkOutDate: DateTime(2026, 8, 5),
        totalPriceEgp: 2400,
        overstayDays: 6,
        overstayFeeEgp: 3600,
      );
      expect(summerBookingDailyRate(booking), 600);
      expect(summerBookingDailyRate(booking), greaterThan(0));
    });

    test('a same-day booking counts as one night, never divides by zero', () {
      final booking = createBooking(
        checkInDate: DateTime(2026, 8, 1, 10, 0),
        checkOutDate: DateTime(2026, 8, 1, 20, 0),
        totalPriceEgp: 700,
      );
      expect(summerBookingStayDays(booking), 1);
      expect(summerBookingDailyRate(booking), 700);
    });
  });
}
