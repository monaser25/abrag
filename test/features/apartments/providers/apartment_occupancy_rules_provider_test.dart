import 'package:abrag/core/database/database.dart';
import 'package:abrag/features/apartments/presentation/providers/apartment_occupancy_rules_provider.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ApartmentOccupancyRules rules;

  Future<String> seedApartment() async {
    final now = DateTime.now();
    const buildingId = 'building-1';
    const apartmentId = 'apartment-1';

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

  Future<void> seedSummerBooking({
    required String apartmentId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    String status = 'confirmed',
  }) async {
    final now = DateTime.now();
    await db
        .into(db.summerBookings)
        .insert(
          SummerBookingsCompanion.insert(
            id: 'booking-$status',
            apartmentId: apartmentId,
            guestName: 'أحمد',
            checkInDate: checkInDate,
            checkOutDate: checkOutDate,
            status: Value(status),
            totalPriceEgp: 1000,
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    rules = ApartmentOccupancyRules(db);
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'keeps summer booking occupied while the stay is still running',
    () async {
      final apartmentId = await seedApartment();
      final today = DateTime.now();

      await seedSummerBooking(
        apartmentId: apartmentId,
        checkInDate: today.subtract(const Duration(days: 4)),
        checkOutDate: today.add(const Duration(days: 3)),
      );

      expect(await rules.isApartmentOccupiedNow(apartmentId), isTrue);
    },
  );

  test('frees the apartment once the checkout day arrives', () async {
    // المالك بيستلم ٨ صباحاً وبيأجّرها لعميل جديد نفس اليوم ٢ الضهر، وساعات
    // بيسجّل الخروج في التطبيق متأخر — فالشقة مالهاش تفضل "مشغولة" مستنية
    // زرار تسجيل الخروج.
    final apartmentId = await seedApartment();
    final today = DateTime.now();

    await seedSummerBooking(
      apartmentId: apartmentId,
      checkInDate: today.subtract(const Duration(days: 4)),
      checkOutDate: today.subtract(const Duration(hours: 1)),
    );

    expect(await rules.isApartmentOccupiedNow(apartmentId), isFalse);
  });

  test(
    'a checkout never registered does not lock the apartment forever',
    () async {
      final apartmentId = await seedApartment();
      final today = DateTime.now();

      await seedSummerBooking(
        apartmentId: apartmentId,
        checkInDate: today.subtract(const Duration(days: 40)),
        checkOutDate: today.subtract(const Duration(days: 33)),
      );

      expect(await rules.isApartmentOccupiedNow(apartmentId), isFalse);
    },
  );

  test('frees summer booking after manual checkout', () async {
    final apartmentId = await seedApartment();
    final today = DateTime.now();

    await seedSummerBooking(
      apartmentId: apartmentId,
      checkInDate: today.subtract(const Duration(days: 4)),
      checkOutDate: today.subtract(const Duration(hours: 1)),
      status: 'checked_out',
    );

    expect(await rules.isApartmentOccupiedNow(apartmentId), isFalse);
  });

  test('does not occupy apartment before summer check-in day', () async {
    final apartmentId = await seedApartment();
    final today = DateTime.now();

    await seedSummerBooking(
      apartmentId: apartmentId,
      checkInDate: today.add(const Duration(days: 1)),
      checkOutDate: today.add(const Duration(days: 5)),
    );

    expect(await rules.isApartmentOccupiedNow(apartmentId), isFalse);
  });
}
