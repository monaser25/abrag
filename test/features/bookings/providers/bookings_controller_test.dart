import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:abrag/core/database/database.dart';
import 'package:abrag/features/bookings/presentation/providers/bookings_controller.dart';

void main() {
  late AppDatabase db;
  late BookingsController controller;

  Future<String> seedApartment() async {
    const buildingId = 'building-1';
    const apartmentId = 'apartment-1';
    final now = DateTime(2026, 5, 1);

    await db
        .into(db.buildings)
        .insert(
          BuildingsCompanion.insert(
            id: buildingId,
            name: 'برج 1',
            createdAt: now,
          ),
        );

    await db
        .into(db.apartments)
        .insert(
          ApartmentsCompanion.insert(
            id: apartmentId,
            buildingId: buildingId,
            apartmentNumber: '101',
            createdAt: now,
            updatedAt: now,
          ),
        );

    return apartmentId;
  }

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    controller = BookingsController(db);
  });

  tearDown(() {
    db.close();
  });

  test(
    'prevents two active bookings for same apartment during same dates',
    () async {
      final apartmentId = await seedApartment();

      await controller.addBooking(
        apartmentId: apartmentId,
        guestName: 'أحمد',
        guestPhone: '01000000000',
        checkInDate: DateTime(2026, 7, 1, 12),
        checkOutDate: DateTime(2026, 7, 5, 8),
        totalPriceEgp: 5000,
        amountPaidEgp: 1000,
        paymentMethod: 'cash',
        brokerCommissionType: 'none',
        brokerCommissionFixedEgp: 0,
        brokerCommissionPercentage: 10,
      );

      await controller.addBooking(
        apartmentId: apartmentId,
        guestName: 'محمد',
        guestPhone: '01111111111',
        checkInDate: DateTime(2026, 7, 3, 12),
        checkOutDate: DateTime(2026, 7, 6, 8),
        totalPriceEgp: 3000,
        amountPaidEgp: 3000,
        paymentMethod: 'cash',
        brokerCommissionType: 'none',
        brokerCommissionFixedEgp: 0,
        brokerCommissionPercentage: 10,
      );

      final bookings = await db.select(db.summerBookings).get();
      expect(bookings, hasLength(1));
    },
  );

  test('allows booking after early checkout date', () async {
    final apartmentId = await seedApartment();

    await controller.addBooking(
      apartmentId: apartmentId,
      guestName: 'أحمد',
      guestPhone: '01000000000',
      checkInDate: DateTime(2026, 7, 1, 12),
      checkOutDate: DateTime(2026, 7, 10, 8),
      totalPriceEgp: 9000,
      amountPaidEgp: 9000,
      paymentMethod: 'cash',
      brokerCommissionType: 'none',
      brokerCommissionFixedEgp: 0,
      brokerCommissionPercentage: 10,
    );

    final firstBooking = (await db.select(db.summerBookings).get()).single;
    await controller.earlyCheckoutBooking(
      id: firstBooking.id,
      newCheckoutDate: DateTime(2026, 7, 4, 8),
    );

    await controller.addBooking(
      apartmentId: apartmentId,
      guestName: 'محمد',
      guestPhone: '01111111111',
      checkInDate: DateTime(2026, 7, 4, 12),
      checkOutDate: DateTime(2026, 7, 8, 8),
      totalPriceEgp: 4000,
      amountPaidEgp: 1000,
      paymentMethod: 'cash',
      brokerCommissionType: 'fixed',
      brokerCommissionFixedEgp: 500,
      brokerCommissionPercentage: 10,
    );

    final bookings = await db.select(db.summerBookings).get();
    expect(bookings, hasLength(2));
  });
}
