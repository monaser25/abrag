import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database.dart';
import '../../../../core/database/tables.dart';
import '../../../../core/services/audit_log_service.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';
import '../../../apartments/presentation/providers/apartment_occupancy_rules_provider.dart';

final bookingsControllerProvider =
    StateNotifierProvider<BookingsController, AsyncValue<void>>((ref) {
      return BookingsController(
        ref.watch(databaseProvider),
        ref.watch(apartmentOccupancyRulesProvider),
      );
    });

class BookingsController extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;
  final ApartmentOccupancyRules _occupancyRules;
  late final AuditLogService _auditLog;

  BookingsController(this._db, [ApartmentOccupancyRules? occupancyRules])
    : _occupancyRules = occupancyRules ?? ApartmentOccupancyRules(_db),
      super(const AsyncData(null)) {
    _auditLog = AuditLogService(_db);
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
      await _occupancyRules.ensureApartmentIsFreeForPeriod(
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
      await _auditLog.log(
        action: 'create',
        entityType: 'summer_booking',
        entityId: id,
        title: 'إضافة حجز صيفي',
        description:
            'تم إضافة حجز صيفي باسم $guestName بقيمة $totalPriceEgp ج.م',
        route: '/summer_bookings/details/$id',
        newValues: {
          'guestName': guestName,
          'guestPhone': guestPhone,
          'checkInDate': checkInDate,
          'checkOutDate': checkOutDate,
          'totalPriceEgp': totalPriceEgp,
          'amountPaidEgp': amountPaidEgp,
        },
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
      await _occupancyRules.ensureApartmentIsFreeForPeriod(
        apartmentId: apartmentId,
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
        excludingSummerBookingId: id,
      );

      String status = 'pending';
      if (amountPaidEgp > 0) status = 'confirmed';

      final old = await (_db.select(
        _db.summerBookings,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
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
      await _auditLog.log(
        action: 'update',
        entityType: 'summer_booking',
        entityId: id,
        title: 'تعديل حجز صيفي',
        description: 'تم تعديل بيانات حجز $guestName',
        route: '/summer_bookings/details/$id',
        oldValues: old?.toJson(),
        newValues: {
          'guestName': guestName,
          'guestPhone': guestPhone,
          'checkInDate': checkInDate,
          'checkOutDate': checkOutDate,
          'totalPriceEgp': totalPriceEgp,
          'amountPaidEgp': amountPaidEgp,
        },
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
      await _auditLog.log(
        action: 'checkout',
        entityType: 'summer_booking',
        entityId: id,
        title: 'تسجيل خروج مصيف',
        description: 'تم تسجيل خروج حجز صيفي',
        route: '/summer_bookings/details/$id',
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

  Future<void> updateBookingPayment({
    required String id,
    required double newAmountPaidEgp,
  }) async {
    state = const AsyncLoading();
    try {
      final booking = await (_db.select(
        _db.summerBookings,
      )..where((t) => t.id.equals(id))).getSingle();
      if (newAmountPaidEgp > booking.totalPriceEgp) {
        throw Exception('المدفوع لا يمكن أن يكون أكبر من إجمالي الحجز');
      }
      await (_db.update(
        _db.summerBookings,
      )..where((t) => t.id.equals(id))).write(
        SummerBookingsCompanion(
          amountPaidEgp: Value(newAmountPaidEgp),
          syncStatus: const Value(SyncStatus.pendingUpdate),
          updatedAt: Value(DateTime.now()),
        ),
      );
      await _auditLog.log(
        action: 'payment',
        entityType: 'summer_booking',
        entityId: id,
        title: 'تسديد حجز صيفي',
        description: 'تم تحديث المدفوع إلى $newAmountPaidEgp ج.م',
        route: '/summer_bookings/details/$id',
        oldValues: {'amountPaidEgp': booking.amountPaidEgp},
        newValues: {'amountPaidEgp': newAmountPaidEgp},
      );
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
      await _auditLog.log(
        action: 'early_checkout',
        entityType: 'summer_booking',
        entityId: id,
        title: 'خروج مبكر',
        description: 'تم تسجيل خروج مبكر بتاريخ $newCheckoutDate',
        route: '/summer_bookings/details/$id',
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
      await _auditLog.log(
        action: 'extend',
        entityType: 'summer_booking',
        entityId: id,
        title: 'تمديد حجز صيفي',
        description:
            'تم تمديد الحجز $overstayDays يوم بقيمة $additionalFeeEgp ج.م',
        route: '/summer_bookings/details/$id',
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteBooking(String id) async {
    state = const AsyncLoading();
    try {
      final booking = await (_db.select(
        _db.summerBookings,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      if (booking == null) {
        state = const AsyncData(null);
        return;
      }

      await (_db.update(
        _db.summerBookings,
      )..where((t) => t.id.equals(id))).write(
        SummerBookingsCompanion(
          status: const Value('deleted'),
          syncStatus: const Value(SyncStatus.pendingUpdate),
          updatedAt: Value(DateTime.now()),
        ),
      );
      await _auditLog.log(
        action: 'delete',
        entityType: 'summer_booking',
        entityId: id,
        title: 'حذف حجز صيفي',
        description: 'تم حذف حجز ${booking.guestName}',
        oldValues: booking.toJson(),
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
