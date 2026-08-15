import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show AsyncError;
import 'package:abrag/core/database/database.dart';
import 'package:abrag/core/database/tables.dart';
import 'package:abrag/core/utils/summer_booking_payment_utils.dart';
import 'package:abrag/features/bookings/presentation/providers/bookings_controller.dart';

void main() {
  late AppDatabase db;
  late BookingsController controller;

  Future<List<String>> seedApartments(int count) async {
    const buildingId = 'building-1';
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

    final apartmentIds = <String>[];
    for (var i = 0; i < count; i++) {
      final apartmentId = 'apartment-${i + 1}';
      apartmentIds.add(apartmentId);
      await db
          .into(db.apartments)
          .insert(
            ApartmentsCompanion.insert(
              id: apartmentId,
              buildingId: buildingId,
              apartmentNumber: '${101 + i}',
              createdAt: now,
              updatedAt: now,
            ),
          );
    }

    return apartmentIds;
  }

  Future<String> seedApartment() async {
    return (await seedApartments(1)).single;
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

  test('adds multiple bookings with exact split and payment rows', () async {
    final apartmentIds = await seedApartments(3);

    await controller.addBookingsForApartments(
      apartmentIds: apartmentIds,
      guestName: 'أحمد',
      guestPhone: '01000000000',
      checkInDate: DateTime(2026, 7, 1, 12),
      checkOutDate: DateTime(2026, 7, 5, 8),
      totalPriceEgp: 1000,
      amountPaidEgp: 1000,
      paymentMethod: 'cash',
      paymentBreakdown: const {'cash': 1000, 'vodafone_cash': 0, 'instapay': 0},
      brokerCommissionType: 'fixed',
      brokerCommissionFixedEgp: 1000,
      brokerCommissionPercentage: 10,
      brokerCommissionPaidCashEgp: 100,
      brokerCommissionPaidVodafoneEgp: 200,
      brokerCommissionPaidInstapayEgp: 10,
    );

    final bookings = await db.select(db.summerBookings).get();
    final bookingByApartment = {for (final b in bookings) b.apartmentId: b};

    expect(bookings, hasLength(3));
    expect(
      bookings.fold<double>(0, (sum, booking) => sum + booking.totalPriceEgp),
      closeTo(1000, 0.001),
    );
    expect(
      bookings.fold<double>(
        0,
        (sum, booking) => sum + booking.brokerCommissionFixedEgp,
      ),
      closeTo(1000, 0.001),
    );
    expect(
      bookingByApartment[apartmentIds[0]]!.totalPriceEgp,
      closeTo(333.33, 0.001),
    );
    expect(
      bookingByApartment[apartmentIds[1]]!.totalPriceEgp,
      closeTo(333.33, 0.001),
    );
    expect(
      bookingByApartment[apartmentIds[2]]!.totalPriceEgp,
      closeTo(333.34, 0.001),
    );
    expect(
      bookingByApartment[apartmentIds[2]]!.brokerCommissionFixedEgp,
      closeTo(333.34, 0.001),
    );
    expect(
      bookings.fold<double>(
        0,
        (sum, booking) => sum + booking.brokerCommissionPaidCashEgp,
      ),
      closeTo(100, 0.001),
    );
    expect(
      bookings.fold<double>(
        0,
        (sum, booking) => sum + booking.brokerCommissionPaidVodafoneEgp,
      ),
      closeTo(200, 0.001),
    );
    expect(
      bookings.fold<double>(
        0,
        (sum, booking) => sum + booking.brokerCommissionPaidInstapayEgp,
      ),
      closeTo(10, 0.001),
    );
    expect(
      bookingByApartment[apartmentIds[2]]!.brokerCommissionPaidCashEgp,
      closeTo(33.34, 0.001),
    );
    expect(
      bookingByApartment[apartmentIds[2]]!.brokerCommissionPaidVodafoneEgp,
      closeTo(66.66, 0.001),
    );
    expect(
      bookingByApartment[apartmentIds[2]]!.brokerCommissionPaidInstapayEgp,
      closeTo(3.34, 0.001),
    );

    final payments = await db.select(db.bookingPayments).get();
    final paymentByBookingId = {for (final p in payments) p.bookingId: p};

    expect(payments, hasLength(3));
    expect(
      paymentByBookingId[bookingByApartment[apartmentIds[0]]!.id]!.amountEgp,
      closeTo(333.33, 0.001),
    );
    expect(
      paymentByBookingId[bookingByApartment[apartmentIds[1]]!.id]!.amountEgp,
      closeTo(333.33, 0.001),
    );
    expect(
      paymentByBookingId[bookingByApartment[apartmentIds[2]]!.id]!.amountEgp,
      closeTo(333.34, 0.001),
    );
    expect(payments.every((p) => p.paymentMethod == 'cash'), isTrue);
  });

  test(
    'fully paid batch split has no per-apartment remaining with mixed payments',
    () async {
      final apartmentIds = await seedApartments(3);

      await controller.addBookingsForApartments(
        apartmentIds: apartmentIds,
        guestName: 'أحمد',
        guestPhone: '01000000000',
        checkInDate: DateTime(2026, 7, 1, 12),
        checkOutDate: DateTime(2026, 7, 5, 8),
        totalPriceEgp: 1000,
        amountPaidEgp: 1000,
        paymentMethod: 'cash',
        paymentBreakdown: const {'cash': 500, 'instapay': 500},
        brokerCommissionType: 'none',
        brokerCommissionFixedEgp: 0,
        brokerCommissionPercentage: 10,
      );

      final bookings = await db.select(db.summerBookings).get();
      final payments = await db.select(db.bookingPayments).get();
      final paymentTotalsByMethod = <String, double>{};

      for (final payment in payments) {
        paymentTotalsByMethod[payment.paymentMethod] =
            (paymentTotalsByMethod[payment.paymentMethod] ?? 0) +
            payment.amountEgp;
      }

      expect(bookings, hasLength(3));
      expect(
        bookings.fold<double>(0, (sum, booking) => sum + booking.totalPriceEgp),
        closeTo(1000, 0.001),
      );
      expect(
        bookings.fold<double>(0, (sum, booking) => sum + booking.amountPaidEgp),
        closeTo(1000, 0.001),
      );
      expect(paymentTotalsByMethod['cash'], closeTo(500, 0.001));
      expect(paymentTotalsByMethod['instapay'], closeTo(500, 0.001));

      for (final booking in bookings) {
        final bookingPaymentTotal = payments
            .where((payment) => payment.bookingId == booking.id)
            .fold<double>(0, (sum, payment) => sum + payment.amountEgp);
        expect(bookingPaymentTotal, closeTo(booking.amountPaidEgp, 0.001));
        expect(booking.amountPaidEgp >= booking.totalPriceEgp, isTrue);
      }
    },
  );

  test('batch add creates no bookings when any apartment conflicts', () async {
    final apartmentIds = await seedApartments(2);

    await controller.addBooking(
      apartmentId: apartmentIds[1],
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

    await controller.addBookingsForApartments(
      apartmentIds: apartmentIds,
      guestName: 'محمد',
      guestPhone: '01111111111',
      checkInDate: DateTime(2026, 7, 3, 12),
      checkOutDate: DateTime(2026, 7, 6, 8),
      totalPriceEgp: 6000,
      amountPaidEgp: 3000,
      paymentMethod: 'cash',
      paymentBreakdown: const {'cash': 3000, 'vodafone_cash': 0, 'instapay': 0},
      brokerCommissionType: 'none',
      brokerCommissionFixedEgp: 0,
      brokerCommissionPercentage: 10,
    );

    final bookings = await db.select(db.summerBookings).get();
    expect(bookings, hasLength(1));
    expect(bookings.single.apartmentId, apartmentIds[1]);
  });

  test('delete marks booking pending delete and frees apartment', () async {
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

    final firstBooking = (await db.select(db.summerBookings).get()).single;
    await controller.deleteBooking(firstBooking.id);

    final deletedBooking = await (db.select(
      db.summerBookings,
    )..where((t) => t.id.equals(firstBooking.id))).getSingle();
    expect(deletedBooking.status, isNot('deleted'));
    expect(deletedBooking.syncStatus, SyncStatus.pendingDelete);

    await controller.addBooking(
      apartmentId: apartmentId,
      guestName: 'محمد',
      guestPhone: '01111111111',
      checkInDate: DateTime(2026, 7, 2, 12),
      checkOutDate: DateTime(2026, 7, 4, 8),
      totalPriceEgp: 3000,
      amountPaidEgp: 1000,
      paymentMethod: 'cash',
      brokerCommissionType: 'none',
      brokerCommissionFixedEgp: 0,
      brokerCommissionPercentage: 10,
    );

    final bookings = await db.select(db.summerBookings).get();
    expect(bookings, hasLength(2));
    expect(
      bookings.where(
        (booking) => booking.syncStatus != SyncStatus.pendingDelete,
      ),
      hasLength(1),
    );
  });

  test('legacy deleted bookings do not block new booking', () async {
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

    final oldBooking = (await db.select(db.summerBookings).get()).single;
    await (db.update(db.summerBookings)
          ..where((t) => t.id.equals(oldBooking.id)))
        .write(const SummerBookingsCompanion(status: Value('deleted')));

    await controller.addBooking(
      apartmentId: apartmentId,
      guestName: 'محمد',
      guestPhone: '01111111111',
      checkInDate: DateTime(2026, 7, 2, 12),
      checkOutDate: DateTime(2026, 7, 4, 8),
      totalPriceEgp: 3000,
      amountPaidEgp: 1000,
      paymentMethod: 'cash',
      brokerCommissionType: 'none',
      brokerCommissionFixedEgp: 0,
      brokerCommissionPercentage: 10,
    );

    final bookings = await db.select(db.summerBookings).get();
    expect(bookings, hasLength(2));
  });

  test('delete cascades pending delete to the booking payment rows', () async {
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
      paymentBreakdown: const {'cash': 1000},
      brokerCommissionType: 'none',
      brokerCommissionFixedEgp: 0,
      brokerCommissionPercentage: 10,
    );

    final booking = (await db.select(db.summerBookings).get()).single;
    final paymentsBefore = await db.select(db.bookingPayments).get();
    expect(paymentsBefore, hasLength(1));
    expect(paymentsBefore.single.syncStatus, isNot(SyncStatus.pendingDelete));

    await controller.deleteBooking(booking.id);

    final payments = await db.select(db.bookingPayments).get();
    expect(payments, hasLength(1));
    expect(payments.single.syncStatus, SyncStatus.pendingDelete);
  });

  test('deleting a payment subtracts it from the booking paid total', () async {
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
    final booking = (await db.select(db.summerBookings).get()).single;

    await controller.addBookingPayment(
      bookingId: booking.id,
      amount: 1500,
      paymentMethod: 'cash',
    );
    expect(
      (await db.select(db.summerBookings).get()).single.amountPaidEgp,
      2500,
    );

    final payment = (await db.select(db.bookingPayments).get()).single;
    await controller.deleteBookingPayment(paymentId: payment.id);

    expect(
      (await db.select(db.summerBookings).get()).single.amountPaidEgp,
      1000,
    );
    expect(
      (await db.select(db.bookingPayments).get()).single.syncStatus,
      SyncStatus.pendingDelete,
    );
  });

  test('an edit cannot wipe an extension off the total', () async {
    // ده اللي بوّظ حجز شقة 9: تمديد 6 أيام بـ 3600، وبعدين تعديل رجّع
    // الإجمالي لـ 2400 وساب رسوم التمديد مكانها → سعر اليوم طلع بالسالب.
    final apartmentId = await seedApartment();

    await controller.addBooking(
      apartmentId: apartmentId,
      guestName: 'أحمد',
      guestPhone: '01000000000',
      checkInDate: DateTime(2026, 8, 7, 14),
      checkOutDate: DateTime(2026, 8, 11, 8),
      totalPriceEgp: 2400,
      amountPaidEgp: 2400,
      paymentMethod: 'cash',
      brokerCommissionType: 'none',
      brokerCommissionFixedEgp: 0,
      brokerCommissionPercentage: 10,
    );
    final booking = (await db.select(db.summerBookings).get()).single;

    await controller.extendBooking(
      id: booking.id,
      newCheckoutDate: DateTime(2026, 8, 17, 8),
      overstayDays: 6,
      additionalFeeEgp: 3600,
      collectedNowEgp: 3600,
    );
    expect(
      (await db.select(db.summerBookings).get()).single.totalPriceEgp,
      6000,
    );

    // تعديل بيحاول يرجّع الإجمالي 2400 وهو أقل من رسوم التمديد
    await controller.updateBooking(
      id: booking.id,
      apartmentId: apartmentId,
      guestName: 'أحمد',
      guestPhone: '01000000000',
      checkInDate: DateTime(2026, 8, 7, 14),
      checkOutDate: DateTime(2026, 8, 11, 8),
      totalPriceEgp: 2400,
      amountPaidEgp: 6000,
      paymentMethod: 'cash',
      brokerCommissionType: 'none',
      brokerCommissionFixedEgp: 0,
      brokerCommissionPercentage: 10,
    );

    expect(controller.state, isA<AsyncError<void>>());
    final unchanged = (await db.select(db.summerBookings).get()).single;
    expect(unchanged.totalPriceEgp, 6000, reason: 'التعديل اترفض');
    expect(
      unchanged.totalPriceEgp - unchanged.overstayFeeEgp,
      2400,
      reason: 'سعر الإقامة الأصلية فضل سليم فالسعر اليومي مايطلعش بالسالب',
    );
  });

  test('extension fee is owed, not silently counted as paid', () async {
    // الباج اللي خلى الخزنة تقول 53,005 والمالك معاه 45,500: التمديد كان
    // بيزوّد المدفوع تلقائيًا من غير ما العميل يدفع ومن غير صف دفعة.
    final apartmentId = await seedApartment();

    await controller.addBooking(
      apartmentId: apartmentId,
      guestName: 'أحمد',
      guestPhone: '01000000000',
      checkInDate: DateTime(2026, 7, 1, 14),
      checkOutDate: DateTime(2026, 7, 5, 8),
      totalPriceEgp: 1800,
      amountPaidEgp: 1800,
      paymentMethod: 'cash',
      brokerCommissionType: 'none',
      brokerCommissionFixedEgp: 0,
      brokerCommissionPercentage: 10,
    );
    final booking = (await db.select(db.summerBookings).get()).single;

    await controller.extendBooking(
      id: booking.id,
      newCheckoutDate: DateTime(2026, 7, 7, 8),
      overstayDays: 2,
      additionalFeeEgp: 800,
    );

    final extended = (await db.select(db.summerBookings).get()).single;
    expect(extended.totalPriceEgp, 2600, reason: 'الرسوم بتتضاف للإجمالي');
    expect(extended.amountPaidEgp, 1800, reason: 'ومش بتتحسب مدفوعة لوحدها');
    expect(await db.select(db.bookingPayments).get(), isEmpty);
  });

  test(
    'extension records a real payment row when collected on the spot',
    () async {
      final apartmentId = await seedApartment();

      await controller.addBooking(
        apartmentId: apartmentId,
        guestName: 'أحمد',
        guestPhone: '01000000000',
        checkInDate: DateTime(2026, 7, 1, 14),
        checkOutDate: DateTime(2026, 7, 5, 8),
        totalPriceEgp: 1800,
        amountPaidEgp: 1800,
        paymentMethod: 'cash',
        brokerCommissionType: 'none',
        brokerCommissionFixedEgp: 0,
        brokerCommissionPercentage: 10,
      );
      final booking = (await db.select(db.summerBookings).get()).single;

      await controller.extendBooking(
        id: booking.id,
        newCheckoutDate: DateTime(2026, 7, 7, 8),
        overstayDays: 2,
        additionalFeeEgp: 800,
        collectedNowEgp: 800,
        paymentMethod: 'vodafone_cash',
      );

      final extended = (await db.select(db.summerBookings).get()).single;
      expect(extended.totalPriceEgp, 2600);
      expect(extended.amountPaidEgp, 2600);

      final payment = (await db.select(db.bookingPayments).get()).single;
      expect(payment.amountEgp, 800);
      expect(
        payment.paymentMethod,
        'vodafone_cash',
        reason: 'الرسوم بتتنسب لمحفظتها الصح مش للنقدي دايمًا',
      );
    },
  );

  test(
    'one guest in two apartments logs two distinguishable settles',
    () async {
      // محمود ماهر حجز شقتين وسدّد كل واحدة مرة — السجل كان بيطلّع سطرين
      // متطابقين ("تم تسديد 3350 ج.م") فبانوا كأنهم تسديد اتسجل مرتين بالغلط.
      final apartmentIds = await seedApartments(2);

      for (final apartmentId in apartmentIds) {
        await controller.addBooking(
          apartmentId: apartmentId,
          guestName: 'محمود ماهر',
          guestPhone: '01000000000',
          checkInDate: DateTime(2026, 8, 7, 14),
          checkOutDate: DateTime(2026, 8, 14, 8),
          totalPriceEgp: 3850,
          amountPaidEgp: 500,
          paymentMethod: 'cash',
          brokerCommissionType: 'none',
          brokerCommissionFixedEgp: 0,
          brokerCommissionPercentage: 10,
        );
      }

      for (final booking in await db.select(db.summerBookings).get()) {
        await controller.addBookingPayment(
          bookingId: booking.id,
          amount: 3350,
          paymentMethod: 'cash',
        );
      }

      final settleLogs = (await db.select(db.auditLogs).get())
          .where((log) => log.action == 'payment')
          .toList();

      expect(settleLogs, hasLength(2));
      expect(
        settleLogs.map((log) => log.description).toSet(),
        hasLength(2),
        reason: 'كل سطر لازم يوضّح شقة مين عشان ما يبانوش تسديد مكرر',
      );
      expect(
        settleLogs.every((log) => log.description.contains('شقة')),
        isTrue,
      );
      expect(
        settleLogs.every((log) => log.description.contains('محمود ماهر')),
        isTrue,
      );
    },
  );

  test(
    'refuses an edit that would drop paid below recorded payments',
    () async {
      final apartmentId = await seedApartment();

      await controller.addBooking(
        apartmentId: apartmentId,
        guestName: 'أحمد',
        guestPhone: '01000000000',
        checkInDate: DateTime(2026, 7, 1, 12),
        checkOutDate: DateTime(2026, 7, 5, 8),
        totalPriceEgp: 5000,
        amountPaidEgp: 0,
        paymentMethod: 'cash',
        brokerCommissionType: 'none',
        brokerCommissionFixedEgp: 0,
        brokerCommissionPercentage: 10,
      );
      final booking = (await db.select(db.summerBookings).get()).single;

      // تسديد اتسجل (يمكن من جهاز تاني) بـ 2400.
      await controller.addBookingPayment(
        bookingId: booking.id,
        amount: 2400,
        paymentMethod: 'cash',
      );

      // تعديل بينزّل المدفوع لـ 1800 — ده كان بيسيب صف دفعة بـ 2400 على حجز
      // مدفوعه 1800 (وده اللي حصل فعلاً في الداتا الحقيقية).
      await controller.updateBooking(
        id: booking.id,
        apartmentId: apartmentId,
        guestName: 'أحمد',
        guestPhone: '01000000000',
        checkInDate: DateTime(2026, 7, 1, 12),
        checkOutDate: DateTime(2026, 7, 5, 8),
        totalPriceEgp: 1800,
        amountPaidEgp: 1800,
        paymentMethod: 'cash',
        brokerCommissionType: 'none',
        brokerCommissionFixedEgp: 0,
        brokerCommissionPercentage: 10,
      );

      expect(controller.state, isA<AsyncError<void>>());
      final unchanged = (await db.select(db.summerBookings).get()).single;
      expect(
        unchanged.amountPaidEgp,
        2400,
        reason: 'التعديل اترفض فالمدفوع زي ما هو',
      );
      expect(unchanged.totalPriceEgp, 5000);
    },
  );

  group('الإقفال التلقائي', () {
    Future<String> seedStay({
      required double totalPriceEgp,
      required double amountPaidEgp,
      String? apartmentId,
    }) async {
      final id = apartmentId ?? await seedApartment();
      await controller.addBooking(
        apartmentId: id,
        guestName: 'أحمد',
        guestPhone: '01000000000',
        checkInDate: DateTime(2026, 8, 10, 12),
        checkOutDate: DateTime(2026, 8, 14, 8),
        totalPriceEgp: totalPriceEgp,
        amountPaidEgp: amountPaidEgp,
        paymentMethod: 'cash',
        brokerCommissionType: 'none',
        brokerCommissionFixedEgp: 0,
        brokerCommissionPercentage: 10,
      );
      return (await db.select(db.summerBookings).get()).last.id;
    }

    test(
      'closes a paid-up stay and frees the apartment for cleaning',
      () async {
        final apartmentId = await seedApartment();
        await seedStay(
          totalPriceEgp: 2000,
          amountPaidEgp: 2000,
          apartmentId: apartmentId,
        );

        final closed = await controller.runAutomaticCheckouts(
          now: DateTime(2026, 8, 14, 10),
        );

        expect(closed, 1);
        final booking = (await db.select(db.summerBookings).get()).single;
        expect(booking.status, 'checked_out');
        final apartment = await (db.select(
          db.apartments,
        )..where((t) => t.id.equals(apartmentId))).getSingle();
        expect(apartment.cleaningStatus, 'needs_cleaning');
      },
    );

    test('leaves a stay the guest still owes money on', () async {
      await seedStay(totalPriceEgp: 2000, amountPaidEgp: 500);

      final closed = await controller.runAutomaticCheckouts(
        now: DateTime(2026, 8, 20),
      );

      expect(closed, 0);
      final booking = (await db.select(db.summerBookings).get()).single;
      expect(booking.status, isNot('checked_out'));
    });

    test('does nothing before the hour', () async {
      await seedStay(totalPriceEgp: 2000, amountPaidEgp: 2000);

      final closed = await controller.runAutomaticCheckouts(
        now: DateTime(2026, 8, 14, 9),
      );

      expect(closed, 0);
    });

    test('running twice does not close the same stay twice', () async {
      await seedStay(totalPriceEgp: 2000, amountPaidEgp: 2000);
      final at = DateTime(2026, 8, 14, 11);

      expect(await controller.runAutomaticCheckouts(now: at), 1);
      expect(await controller.runAutomaticCheckouts(now: at), 0);

      final logs = await (db.select(
        db.auditLogs,
      )..where((t) => t.action.equals('auto_checkout'))).get();
      expect(logs, hasLength(1), reason: 'سطر واحد بس في سجل النظام');
    });
  });

  group('نقل الشقة', () {
    /// ضيف حجز ٥ ليالي بـ ٢٥٠٠ (٥٠٠ لليلة) ودفعهم كلهم.
    Future<(String, String)> seedTransferCase() async {
      final apartmentIds = await seedApartments(2);
      await controller.addBooking(
        apartmentId: apartmentIds[0],
        guestName: 'أحمد',
        guestPhone: '01000000000',
        checkInDate: DateTime(2026, 7, 1, 12),
        checkOutDate: DateTime(2026, 7, 6, 8),
        totalPriceEgp: 2500,
        amountPaidEgp: 2500,
        paymentMethod: 'cash',
        brokerCommissionType: 'none',
        brokerCommissionFixedEgp: 0,
        brokerCommissionPercentage: 10,
      );
      final booking = (await db.select(db.summerBookings).get()).single;
      return (booking.id, apartmentIds[1]);
    }

    Future<SummerBooking> fetch(String id) => (db.select(
      db.summerBookings,
    )..where((t) => t.id.equals(id))).getSingle();

    /// النقدي في الخزنة محسوب بنفس منطق التطبيق بالظبط: صفوف الدفعات زائد
    /// الباقي المنسوب لطريقة دفع الحجز.
    Future<double> cashInTreasury() async {
      final payments = indexActiveBookingPayments(
        await db.select(db.bookingPayments).get(),
      );
      var cash = 0.0;
      for (final booking in await db.select(db.summerBookings).get()) {
        final breakdown = summerBookingPaymentBreakdown(
          booking,
          payments[booking.id] ?? const <BookingPayment>[],
        );
        cash += breakdown['cash'] ?? 0;
      }
      return cash;
    }

    test('splits the stay and carries the money across', () async {
      final (oldId, newApartmentId) = await seedTransferCase();

      await controller.transferBooking(
        id: oldId,
        newApartmentId: newApartmentId,
        transferDate: DateTime(2026, 7, 2),
        newBookingTotalEgp: 2800,
        collectedNowEgp: 800,
        paymentMethod: 'cash',
      );
      expect(controller.state, isNot(isA<AsyncError>()));

      final bookings = await db.select(db.summerBookings).get();
      expect(bookings, hasLength(2));
      final old = bookings.firstWhere((b) => b.id == oldId);
      final fresh = bookings.firstWhere((b) => b.id != oldId);

      // القديم اتقفل على ليلة واحدة بسعرها.
      expect(old.checkOutDate, DateTime(2026, 7, 2));
      expect(old.totalPriceEgp, 500);
      expect(old.amountPaidEgp, 500);
      expect(old.status, 'checked_out');

      // والجديد أخد باقي المدة كاملة، مدفوعة بالكامل.
      expect(fresh.apartmentId, newApartmentId);
      expect(fresh.checkInDate, DateTime(2026, 7, 2));
      expect(fresh.checkOutDate, DateTime(2026, 7, 6, 8));
      expect(fresh.totalPriceEgp, 2800);
      expect(fresh.amountPaidEgp, 2800);
      expect(fresh.guestName, 'أحمد');

      expect(old.transferredToBookingId, fresh.id);
      expect(fresh.transferredFromBookingId, oldId);
    });

    test('the treasury only moves by what was actually collected', () async {
      final (oldId, newApartmentId) = await seedTransferCase();

      await controller.transferBooking(
        id: oldId,
        newApartmentId: newApartmentId,
        transferDate: DateTime(2026, 7, 2),
        newBookingTotalEgp: 2800,
        collectedNowEgp: 800,
        paymentMethod: 'cash',
      );

      // الخزنة زي ما التطبيق بيحسبها: ٢٥٠٠ اللي اتحصلت الأول + ٨٠٠ الفرق.
      // صفّي الترحيل (سالب على القديم وموجب على الجديد) بيلغوا بعض، فالنقل
      // نفسه مبيخلقش ولا بيمسح مليم.
      expect(await cashInTreasury(), closeTo(3300, 0.001));
    });

    test('a cheaper apartment refunds the difference', () async {
      final (oldId, newApartmentId) = await seedTransferCase();

      // ليلة بـ ٥٠٠، وباقي ٤ ليالي بـ ١٢٠٠ بس ← يترجع له ٨٠٠.
      await controller.transferBooking(
        id: oldId,
        newApartmentId: newApartmentId,
        transferDate: DateTime(2026, 7, 2),
        newBookingTotalEgp: 1200,
        refundedNowEgp: 800,
        paymentMethod: 'cash',
      );
      expect(controller.state, isNot(isA<AsyncError>()));

      final fresh = (await db.select(db.summerBookings).get()).firstWhere(
        (b) => b.id != oldId,
      );
      expect(fresh.totalPriceEgp, 1200);
      expect(fresh.amountPaidEgp, 1200);

      expect(
        await cashInTreasury(),
        closeTo(1700, 0.001),
        reason: '٢٥٠٠ اتحصلت ناقص ٨٠٠ رجعت',
      );
    });

    test('refuses a transfer date outside the stay', () async {
      final (oldId, newApartmentId) = await seedTransferCase();

      await controller.transferBooking(
        id: oldId,
        newApartmentId: newApartmentId,
        transferDate: DateTime(2026, 7, 6),
        newBookingTotalEgp: 1000,
      );
      expect(controller.state, isA<AsyncError>());
      expect(await db.select(db.summerBookings).get(), hasLength(1));
    });

    test('refuses to transfer into an occupied apartment', () async {
      final (oldId, newApartmentId) = await seedTransferCase();
      await controller.addBooking(
        apartmentId: newApartmentId,
        guestName: 'سالم',
        guestPhone: '01222222222',
        checkInDate: DateTime(2026, 7, 3, 12),
        checkOutDate: DateTime(2026, 7, 8, 8),
        totalPriceEgp: 3000,
        amountPaidEgp: 3000,
        paymentMethod: 'cash',
        brokerCommissionType: 'none',
        brokerCommissionFixedEgp: 0,
        brokerCommissionPercentage: 10,
      );
      expect(await db.select(db.summerBookings).get(), hasLength(2));

      await controller.transferBooking(
        id: oldId,
        newApartmentId: newApartmentId,
        transferDate: DateTime(2026, 7, 2),
        newBookingTotalEgp: 2800,
      );
      expect(controller.state, isA<AsyncError>());

      // النقل اترفض بالكامل — لا حجز جديد ولا الحجز القديم اتغير.
      expect(await db.select(db.summerBookings).get(), hasLength(2));
      final old = await fetch(oldId);
      expect(old.totalPriceEgp, 2500);
      expect(old.transferredToBookingId, null);
    });

    test('refuses a second transfer of the same booking', () async {
      final apartmentIds = await seedApartments(3);
      await controller.addBooking(
        apartmentId: apartmentIds[0],
        guestName: 'أحمد',
        guestPhone: '01000000000',
        checkInDate: DateTime(2026, 7, 1, 12),
        checkOutDate: DateTime(2026, 7, 6, 8),
        totalPriceEgp: 2500,
        amountPaidEgp: 2500,
        paymentMethod: 'cash',
        brokerCommissionType: 'none',
        brokerCommissionFixedEgp: 0,
        brokerCommissionPercentage: 10,
      );
      final oldId = (await db.select(db.summerBookings).get()).single.id;

      await controller.transferBooking(
        id: oldId,
        newApartmentId: apartmentIds[1],
        transferDate: DateTime(2026, 7, 2),
        newBookingTotalEgp: 2000,
      );
      expect(controller.state, isNot(isA<AsyncError>()));

      await controller.transferBooking(
        id: oldId,
        newApartmentId: apartmentIds[2],
        transferDate: DateTime(2026, 7, 2),
        newBookingTotalEgp: 2000,
      );
      expect(controller.state, isA<AsyncError>());
      expect(await db.select(db.summerBookings).get(), hasLength(2));
    });

    test('refuses when the nights stayed are not paid for', () async {
      final apartmentIds = await seedApartments(2);
      await controller.addBooking(
        apartmentId: apartmentIds[0],
        guestName: 'أحمد',
        guestPhone: '01000000000',
        checkInDate: DateTime(2026, 7, 1, 12),
        checkOutDate: DateTime(2026, 7, 6, 8),
        totalPriceEgp: 2500,
        amountPaidEgp: 300, // أقل من تمن الليلة الواحدة (٥٠٠)
        paymentMethod: 'cash',
        brokerCommissionType: 'none',
        brokerCommissionFixedEgp: 0,
        brokerCommissionPercentage: 10,
      );
      final oldId = (await db.select(db.summerBookings).get()).single.id;

      await controller.transferBooking(
        id: oldId,
        newApartmentId: apartmentIds[1],
        transferDate: DateTime(2026, 7, 2),
        newBookingTotalEgp: 2800,
      );
      expect(controller.state, isA<AsyncError>());
      expect(await db.select(db.summerBookings).get(), hasLength(1));
    });
  });
}
