import 'package:flutter_test/flutter_test.dart';

import 'package:abrag/features/reports/presentation/providers/reports_provider.dart';

void main() {
  Transaction summerBooking({
    required DateTime checkInDate,
    required double amount,
  }) {
    return Transaction(
      date: checkInDate,
      description: 'حجز صيفي: ضيف',
      amount: amount,
      isRevenue: true,
      paymentMethod: 'cash',
      paymentBreakdown: const {'cash': 1000},
      commissionBreakdown: const {'cash': 100},
      buildingId: 'building-1',
      apartmentId: 'apartment-1',
      buildingName: 'برج 1',
      apartmentNumber: '101',
      floorNumber: 1,
      season: 'summer_2026',
      customerName: 'ضيف',
      brokerId: 'broker-1',
      brokerName: 'سمسار',
      rentalValue: 2000,
      brokerCommission: 100,
    );
  }

  test('single-month stay remains one cash-bearing transaction', () {
    final booking = summerBooking(
      checkInDate: DateTime(2026, 7, 10, 12),
      amount: 1000,
    );

    final slices = allocateSummerBookingTransactions(
      booking,
      DateTime(2026, 7, 13, 8),
    );

    expect(slices, hasLength(1));
    expect(slices.single, same(booking));
    expect(slices.single.amount, 1000);
    expect(slices.single.affectsCash, isTrue);
  });

  // Regression: summer revenue used to be assigned entirely to check-in month.
  test('two-month stay keeps cash and commission on its first slice', () {
    final slices = allocateSummerBookingTransactions(
      summerBooking(checkInDate: DateTime(2026, 7, 30, 12), amount: 1650),
      DateTime(2026, 8, 2, 8),
    );

    expect(slices, hasLength(2));
    expect(slices.map((slice) => slice.amount).toList(), [1100, 550]);
    expect(slices.first.date, DateTime(2026, 7, 30, 12));
    expect(slices.first.paymentBreakdown, {'cash': 1000});
    expect(slices.first.commissionBreakdown, {'cash': 100});
    expect(slices.first.brokerCommission, 100);
    expect(slices.first.rentalValue, 2000);
    expect(slices.first.affectsCash, isTrue);

    expect(slices.last.date, DateTime(2026, 8, 1, 12));
    expect(slices.last.paymentBreakdown, isEmpty);
    expect(slices.last.commissionBreakdown, isEmpty);
    expect(slices.last.brokerCommission, 0);
    expect(slices.last.rentalValue, 0);
    expect(slices.last.affectsCash, isFalse);
    expect(slices.last.season, 'summer_2026');
  });

  test('long multi-month stay allocates every cent exactly once', () {
    // 31 Aug -> 3 Nov is 64 nights spread over FOUR months:
    // Aug 31 (1), September (30), October (31), Nov 1-2 (2).
    final slices = allocateSummerBookingTransactions(
      summerBooking(checkInDate: DateTime(2026, 8, 31, 12), amount: 10000.01),
      DateTime(2026, 11, 3, 8),
    );

    expect(slices, hasLength(4));
    expect(slices.first.affectsCash, isTrue);
    expect(
      slices.skip(1).every((slice) => !slice.affectsCash),
      isTrue,
      reason: 'only the check-in slice may carry cash',
    );
    final totalCents = slices.fold<int>(
      0,
      (sum, slice) => sum + (slice.amount * 100).round(),
    );
    expect(totalCents, (10000.01 * 100).round());
  });

  test('uneven night weighting rounds before the last-month remainder', () {
    final slices = allocateSummerBookingTransactions(
      summerBooking(checkInDate: DateTime(2026, 7, 30, 12), amount: 1000),
      DateTime(2026, 8, 2, 8),
    );

    expect(slices.map((slice) => slice.amount).toList(), [666.67, 333.33]);
    expect(
      slices.fold<int>(0, (sum, slice) => sum + (slice.amount * 100).round()),
      100000,
    );
  });
}
