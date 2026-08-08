import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database.dart';
import '../../../../core/database/tables.dart';
import '../../../../core/services/audit_log_service.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';
import '../../../apartments/presentation/providers/apartment_occupancy_rules_provider.dart';

List<double> splitAmountExactly(double total, int count) {
  if (count <= 0) {
    throw ArgumentError.value(count, 'count', 'لازم تختار شقة واحدة على الأقل');
  }
  if (count == 1) return [total];

  final parts = <double>[];
  var acc = 0.0;
  for (var i = 0; i < count - 1; i++) {
    final part = double.parse((total / count).toStringAsFixed(2));
    parts.add(part);
    acc += part;
  }
  parts.add(double.parse((total - acc).toStringAsFixed(2)));
  return parts;
}

const _bookingPaymentMethodOrder = ['cash', 'vodafone_cash', 'instapay'];

List<Map<String, double>> _allocatePaymentBreakdowns({
  required Map<String, double> paymentBreakdown,
  required List<double> paidParts,
}) {
  final remainingByMethod = {
    for (final method in _bookingPaymentMethodOrder)
      method: _toCents(paymentBreakdown[method] ?? 0),
  };

  return [
    for (final paidPart in paidParts)
      _allocateApartmentPaymentBreakdown(remainingByMethod, _toCents(paidPart)),
  ];
}

Map<String, double> _allocateApartmentPaymentBreakdown(
  Map<String, int> remainingByMethod,
  int paidCents,
) {
  var remainingPaidCents = paidCents;
  final allocations = <String, double>{};

  for (final method in _bookingPaymentMethodOrder) {
    if (remainingPaidCents <= 0) break;
    final methodCents = remainingByMethod[method] ?? 0;
    if (methodCents <= 0) continue;
    final allocatedCents = remainingPaidCents < methodCents
        ? remainingPaidCents
        : methodCents;
    allocations[method] = _fromCents(allocatedCents);
    remainingByMethod[method] = methodCents - allocatedCents;
    remainingPaidCents -= allocatedCents;
  }

  return allocations;
}

int _toCents(double amount) => (amount * 100).round();

double _fromCents(int cents) => cents / 100;

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
    Map<String, double> paymentBreakdown = const {},
    String? brokerId,
    String? brokerName,
    required String brokerCommissionType,
    required double brokerCommissionFixedEgp,
    required double brokerCommissionPercentage,
    double brokerCommissionPaidCashEgp = 0,
    double brokerCommissionPaidVodafoneEgp = 0,
    double brokerCommissionPaidInstapayEgp = 0,
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

      await _insertSummerBooking(
        apartmentId: apartmentId,
        guestName: guestName,
        guestPhone: guestPhone,
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
        totalPriceEgp: totalPriceEgp,
        amountPaidEgp: amountPaidEgp,
        paymentMethod: paymentMethod,
        paymentBreakdown: paymentBreakdown,
        brokerId: brokerId,
        brokerName: brokerName,
        brokerCommissionType: brokerCommissionType,
        brokerCommissionFixedEgp: brokerCommissionFixedEgp,
        brokerCommissionPercentage: brokerCommissionPercentage,
        brokerCommissionPaidCashEgp: brokerCommissionPaidCashEgp,
        brokerCommissionPaidVodafoneEgp: brokerCommissionPaidVodafoneEgp,
        brokerCommissionPaidInstapayEgp: brokerCommissionPaidInstapayEgp,
        nationalId: nationalId,
        idFrontImage: idFrontImage,
        idBackImage: idBackImage,
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> addBookingsForApartments({
    required List<String> apartmentIds,
    required String guestName,
    required String guestPhone,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required double totalPriceEgp,
    required double amountPaidEgp,
    required String paymentMethod,
    Map<String, double> paymentBreakdown = const {},
    String? brokerId,
    String? brokerName,
    required String brokerCommissionType,
    required double brokerCommissionFixedEgp,
    required double brokerCommissionPercentage,
    double brokerCommissionPaidCashEgp = 0,
    double brokerCommissionPaidVodafoneEgp = 0,
    double brokerCommissionPaidInstapayEgp = 0,
    String? nationalId,
    String? idFrontImage,
    String? idBackImage,
  }) async {
    state = const AsyncLoading();
    try {
      final uniqueApartmentIds = apartmentIds.toSet().toList();
      if (uniqueApartmentIds.isEmpty) {
        throw Exception('اختر شقة واحدة على الأقل');
      }
      if (amountPaidEgp > totalPriceEgp) {
        throw Exception('العربون لا يمكن أن يكون أكبر من السعر الإجمالي');
      }

      final count = uniqueApartmentIds.length;
      final totalPriceParts = splitAmountExactly(totalPriceEgp, count);
      final amountPaidParts = splitAmountExactly(amountPaidEgp, count);
      final paymentBreakdownParts = _allocatePaymentBreakdowns(
        paymentBreakdown: paymentBreakdown,
        paidParts: amountPaidParts,
      );
      final fixedCommissionParts = brokerCommissionType == 'fixed'
          ? splitAmountExactly(brokerCommissionFixedEgp, count)
          : List<double>.filled(count, 0);
      final commissionPaidCashParts = splitAmountExactly(
        brokerCommissionPaidCashEgp,
        count,
      );
      final commissionPaidVodafoneParts = splitAmountExactly(
        brokerCommissionPaidVodafoneEgp,
        count,
      );
      final commissionPaidInstapayParts = splitAmountExactly(
        brokerCommissionPaidInstapayEgp,
        count,
      );

      await _db.transaction(() async {
        for (final apartmentId in uniqueApartmentIds) {
          await _occupancyRules.ensureApartmentIsFreeForPeriod(
            apartmentId: apartmentId,
            checkInDate: checkInDate,
            checkOutDate: checkOutDate,
          );
        }

        for (var i = 0; i < count; i++) {
          await _insertSummerBooking(
            apartmentId: uniqueApartmentIds[i],
            guestName: guestName,
            guestPhone: guestPhone,
            checkInDate: checkInDate,
            checkOutDate: checkOutDate,
            totalPriceEgp: totalPriceParts[i],
            amountPaidEgp: amountPaidParts[i],
            paymentMethod: paymentMethod,
            paymentBreakdown: paymentBreakdownParts[i],
            brokerId: brokerId,
            brokerName: brokerName,
            brokerCommissionType: brokerCommissionType,
            brokerCommissionFixedEgp: fixedCommissionParts[i],
            brokerCommissionPercentage: brokerCommissionPercentage,
            brokerCommissionPaidCashEgp: commissionPaidCashParts[i],
            brokerCommissionPaidVodafoneEgp: commissionPaidVodafoneParts[i],
            brokerCommissionPaidInstapayEgp: commissionPaidInstapayParts[i],
            nationalId: nationalId,
            idFrontImage: idFrontImage,
            idBackImage: idBackImage,
          );
        }
      });

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<String> _insertSummerBooking({
    required String apartmentId,
    required String guestName,
    required String guestPhone,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required double totalPriceEgp,
    required double amountPaidEgp,
    required String paymentMethod,
    required Map<String, double> paymentBreakdown,
    String? brokerId,
    String? brokerName,
    required String brokerCommissionType,
    required double brokerCommissionFixedEgp,
    required double brokerCommissionPercentage,
    double brokerCommissionPaidCashEgp = 0,
    double brokerCommissionPaidVodafoneEgp = 0,
    double brokerCommissionPaidInstapayEgp = 0,
    String? nationalId,
    String? idFrontImage,
    String? idBackImage,
  }) async {
    final id = const Uuid().v4();
    final now = DateTime.now();

    var status = 'pending';
    if (amountPaidEgp >= totalPriceEgp && totalPriceEgp > 0) {
      status = 'confirmed';
    } else if (amountPaidEgp > 0) {
      status = 'confirmed';
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
            brokerCommissionPaidCashEgp: Value(brokerCommissionPaidCashEgp),
            brokerCommissionPaidVodafoneEgp: Value(
              brokerCommissionPaidVodafoneEgp,
            ),
            brokerCommissionPaidInstapayEgp: Value(
              brokerCommissionPaidInstapayEgp,
            ),
            nationalId: Value(nationalId),
            idFrontImage: Value(idFrontImage),
            idBackImage: Value(idBackImage),
            syncStatus: const Value(SyncStatus.pendingInsert),
            createdAt: now,
            updatedAt: now,
          ),
        );

    for (final entry in paymentBreakdown.entries) {
      if (entry.value > 0) {
        await _db
            .into(_db.bookingPayments)
            .insert(
              BookingPaymentsCompanion.insert(
                id: const Uuid().v4(),
                bookingId: id,
                amountEgp: entry.value,
                paymentMethod: Value(entry.key),
                paymentDate: now,
                notes: const Value(null),
                syncStatus: const Value(SyncStatus.pendingInsert),
                createdAt: now,
              ),
            );
      }
    }

    await _auditLog.log(
      action: 'create',
      entityType: 'summer_booking',
      entityId: id,
      title: 'إضافة حجز صيفي',
      description: 'تم إضافة حجز صيفي باسم $guestName بقيمة $totalPriceEgp ج.م',
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

    return id;
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
    double brokerCommissionPaidCashEgp = 0,
    double brokerCommissionPaidVodafoneEgp = 0,
    double brokerCommissionPaidInstapayEgp = 0,
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
          brokerCommissionPaidCashEgp: Value(brokerCommissionPaidCashEgp),
          brokerCommissionPaidVodafoneEgp: Value(
            brokerCommissionPaidVodafoneEgp,
          ),
          brokerCommissionPaidInstapayEgp: Value(
            brokerCommissionPaidInstapayEgp,
          ),
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

  Future<void> addBookingPayment({
    required String bookingId,
    required double amount,
    required String paymentMethod,
    String? notes,
  }) async {
    state = const AsyncLoading();
    try {
      await _db.transaction(() async {
        if (amount <= 0) {
          throw Exception('قيمة التسديد يجب أن تكون أكبر من صفر');
        }
        final booking = await (_db.select(
          _db.summerBookings,
        )..where((t) => t.id.equals(bookingId))).getSingle();
        final newAmountPaidEgp = booking.amountPaidEgp + amount;
        if (newAmountPaidEgp > booking.totalPriceEgp) {
          throw Exception('المدفوع لا يمكن أن يكون أكبر من إجمالي الحجز');
        }

        String newStatus = booking.status;
        if (newStatus == 'pending' && newAmountPaidEgp > 0) {
          newStatus = 'confirmed';
        }

        await _db
            .into(_db.bookingPayments)
            .insert(
              BookingPaymentsCompanion.insert(
                id: const Uuid().v4(),
                bookingId: bookingId,
                amountEgp: amount,
                paymentMethod: Value(paymentMethod),
                paymentDate: DateTime.now(),
                notes: Value(notes),
                syncStatus: const Value(SyncStatus.pendingInsert),
                createdAt: DateTime.now(),
              ),
            );

        await (_db.update(
          _db.summerBookings,
        )..where((t) => t.id.equals(bookingId))).write(
          SummerBookingsCompanion(
            amountPaidEgp: Value(newAmountPaidEgp),
            status: Value(newStatus),
            syncStatus: const Value(SyncStatus.pendingUpdate),
            updatedAt: Value(DateTime.now()),
          ),
        );

        await _auditLog.log(
          action: 'payment',
          entityType: 'summer_booking',
          entityId: bookingId,
          title: 'تسديد حجز صيفي',
          description: 'تم تسديد $amount ج.م',
          route: '/summer_bookings/details/$bookingId',
          oldValues: {'amountPaidEgp': booking.amountPaidEgp},
          newValues: {'amountPaidEgp': newAmountPaidEgp},
        );
      });
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// حذف دفعة اتسجلت بالغلط (تسديد مكرر مثلاً): soft-delete لصف الدفعة
  /// + خصم قيمتها من إجمالي المدفوع للحجز في نفس الـ transaction، والمزامنة
  /// بتمسح الصف من السيرفر زي باقي الجداول.
  Future<void> deleteBookingPayment({required String paymentId}) async {
    state = const AsyncLoading();
    try {
      await _db.transaction(() async {
        final payment = await (_db.select(
          _db.bookingPayments,
        )..where((t) => t.id.equals(paymentId))).getSingleOrNull();
        if (payment == null || payment.syncStatus == SyncStatus.pendingDelete) {
          throw Exception('الدفعة غير موجودة أو محذوفة بالفعل');
        }
        final booking = await (_db.select(
          _db.summerBookings,
        )..where((t) => t.id.equals(payment.bookingId))).getSingle();
        final newAmountPaidEgp = (booking.amountPaidEgp - payment.amountEgp)
            .clamp(0.0, double.infinity)
            .toDouble();

        await (_db.update(
          _db.bookingPayments,
        )..where((t) => t.id.equals(paymentId))).write(
          const BookingPaymentsCompanion(
            syncStatus: Value(SyncStatus.pendingDelete),
          ),
        );

        await (_db.update(
          _db.summerBookings,
        )..where((t) => t.id.equals(payment.bookingId))).write(
          SummerBookingsCompanion(
            amountPaidEgp: Value(newAmountPaidEgp),
            syncStatus: const Value(SyncStatus.pendingUpdate),
            updatedAt: Value(DateTime.now()),
          ),
        );

        await _auditLog.log(
          action: 'delete_payment',
          entityType: 'summer_booking',
          entityId: payment.bookingId,
          title: 'حذف دفعة حجز صيفي',
          description:
              'تم حذف دفعة بقيمة ${payment.amountEgp} ج.م وخصمها من المدفوع',
          route: '/summer_bookings/details/${payment.bookingId}',
          oldValues: {
            'amountPaidEgp': booking.amountPaidEgp,
            'paymentId': paymentId,
            'paymentAmount': payment.amountEgp,
            'paymentMethod': payment.paymentMethod,
          },
          newValues: {'amountPaidEgp': newAmountPaidEgp},
        );
      });
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

      await _db.transaction(() async {
        await (_db.update(
          _db.summerBookings,
        )..where((t) => t.id.equals(id))).write(
          SummerBookingsCompanion(
            syncStatus: const Value(SyncStatus.pendingDelete),
            updatedAt: Value(DateTime.now()),
          ),
        );
        // Cascade the delete to the booking's payment rows. There is no FK
        // cascade on Drift or Supabase, so without this the booking_payments
        // rows would be orphaned when the booking row is removed on sync.
        // Marking them pendingDelete makes the sync engine drop them from
        // Supabase + local too.
        await (_db.update(
          _db.bookingPayments,
        )..where((t) => t.bookingId.equals(id))).write(
          const BookingPaymentsCompanion(
            syncStatus: Value(SyncStatus.pendingDelete),
          ),
        );
      });
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
