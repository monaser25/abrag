import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database.dart';
import '../../../../core/database/tables.dart';
import '../../../../core/services/audit_log_service.dart';
import '../../../../core/utils/auto_checkout_utils.dart';
import '../../../../core/utils/occupancy_utils.dart';
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

    final apartment = await (_db.select(
      _db.apartments,
    )..where((t) => t.id.equals(apartmentId))).getSingleOrNull();
    final apartmentLabel = apartment == null
        ? ''
        : 'شقة ${apartment.apartmentNumber} — ';
    await _auditLog.log(
      action: 'create',
      entityType: 'summer_booking',
      entityId: id,
      title: 'إضافة حجز صيفي',
      description:
          'تم إضافة حجز صيفي — $apartmentLabel$guestName بقيمة $totalPriceEgp ج.م',
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

      // الدفعات المسجلة لازم تفضل مطابقة للمدفوع. لو التعديل هينزّل المدفوع
      // تحت إجمالي الدفعات المسجلة، ده يا إما (أ) تعديل سعر بعد تسديد —
      // فالمفروض تتعدّل/تتمسح الدفعة الأول، أو (ب) حد تاني سجّل تسديد على
      // جهاز تاني والشاشة دي فاتحة من قبله فهتلغيه من غير ما حد ياخد باله.
      // في الحالتين نرفض الحفظ ونوضّح السبب بدل ما نمسح فلوس بصمت.
      final recordedPayments =
          await (_db.select(_db.bookingPayments)..where(
                (t) =>
                    t.bookingId.equals(id) &
                    t.syncStatus.isNotIn([SyncStatus.pendingDelete.index]),
              ))
              .get();
      final recordedTotal = recordedPayments.fold<double>(
        0,
        (sum, payment) => sum + payment.amountEgp,
      );
      if (recordedTotal > amountPaidEgp + 0.01) {
        throw Exception(
          'فيه دفعات مسجلة على الحجز بإجمالي ${recordedTotal.toStringAsFixed(2)} ج.م، '
          'أكبر من المدفوع اللي دخلته (${amountPaidEgp.toStringAsFixed(2)} ج.م). '
          'امسح أو عدّل الدفعة من "تفاصيل الدفعات" الأول، أو اكتب مبلغ مدفوع مش أقل من إجمالي الدفعات.',
        );
      }

      // الحجز اللي عليه تمديد: الإجمالي لازم يفضل شامل رسوم التمديد. من غير
      // الشرط ده، أي تعديل بعد التمديد بيرجّع الإجمالي لسعر الإقامة الأصلية
      // ويسيب رسوم التمديد مكانها، فيطلع "سعر اليوم" بالسالب والحسابات تبوظ.
      final existingOverstayFee = old?.overstayFeeEgp ?? 0;
      if (existingOverstayFee > 0 &&
          totalPriceEgp + 0.01 < existingOverstayFee) {
        throw Exception(
          'الحجز ده عليه تمديد بـ ${existingOverstayFee.toStringAsFixed(2)} ج.م، '
          'فالإجمالي مينفعش يقل عن كده. الإجمالي المفروض يكون سعر الإقامة '
          'الأصلية + رسوم التمديد.',
        );
      }

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
        description:
            'تم تعديل بيانات حجز ${old == null ? guestName : await _bookingLabel(old)}',
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
    bool automatic = false,
  }) async {
    state = const AsyncLoading();
    try {
      final booking = await (_db.select(
        _db.summerBookings,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
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
        action: automatic ? 'auto_checkout' : 'checkout',
        entityType: 'summer_booking',
        entityId: id,
        title: automatic ? 'تسجيل خروج تلقائي' : 'تسجيل خروج مصيف',
        description: booking == null
            ? 'تم تسجيل خروج حجز صيفي'
            : automatic
            ? 'تم تسجيل خروج ${await _bookingLabel(booking)} تلقائيًا بعد '
                  'ميعاد الخروج'
            : 'تم تسجيل خروج ${await _bookingLabel(booking)}',
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

  /// وصف مختصر للحجز عشان يظهر في سجل النظام: "شقة ٨ — محمود ماهر".
  ///
  /// من غيره، عميل واحد حاجز شقتين بيطلّع سطرين متطابقين حرف بحرف في السجل
  /// ("تم تسديد ٣٣٥٠ ج.م" مرتين) فيبان كأن التسديد اتسجل مرتين بالغلط — وده
  /// حصل فعلاً مع محمود ماهر (شقة ٨ وشقة ١١) وخض المالك.
  Future<String> _bookingLabel(SummerBooking booking) async {
    final apartment = await (_db.select(
      _db.apartments,
    )..where((t) => t.id.equals(booking.apartmentId))).getSingleOrNull();
    final apartmentPart = apartment == null
        ? ''
        : 'شقة ${apartment.apartmentNumber} — ';
    return '$apartmentPart${booking.guestName}';
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
        description:
            'تم تحديث المدفوع إلى $newAmountPaidEgp ج.م — ${await _bookingLabel(booking)}',
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
          description:
              'تم تسديد $amount ج.م — ${await _bookingLabel(booking)} '
              '(المدفوع بقى $newAmountPaidEgp من ${booking.totalPriceEgp})',
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
              'تم حذف دفعة بقيمة ${payment.amountEgp} ج.م — '
              '${await _bookingLabel(booking)} (المدفوع بقى $newAmountPaidEgp)',
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
      final booking = await (_db.select(
        _db.summerBookings,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
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
      final checkoutDay = newCheckoutDate.toLocal().toString().split(' ').first;
      await _auditLog.log(
        action: 'early_checkout',
        entityType: 'summer_booking',
        entityId: id,
        title: 'خروج مبكر',
        description: booking == null
            ? 'تم تسجيل خروج مبكر بتاريخ $checkoutDay'
            : 'تم تسجيل خروج مبكر بتاريخ $checkoutDay — ${await _bookingLabel(booking)}',
        route: '/summer_bookings/details/$id',
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// تمديد إقامة. رسوم التمديد بتتضاف لإجمالي الحجز (اللي العميل عليه)، ومش
  /// بتتحسب مدفوعة إلا لو اتحصّلت فعلاً.
  ///
  /// قبل كده كان بيضيف الرسوم للمدفوع تلقائيًا من غير ما يسأل ومن غير صف دفعة،
  /// فالخزنة كانت بتوريك فلوس نقدي مش في إيدك (٧ تمديدات = ٧٤٥٠ ج.م وهمية).
  /// [collectedNowEgp] لو أكبر من صفر بيتسجل كدفعة حقيقية بالطريقة المختارة.
  Future<void> extendBooking({
    required String id,
    required DateTime newCheckoutDate,
    required int overstayDays,
    required double additionalFeeEgp,
    double collectedNowEgp = 0,
    String paymentMethod = 'cash',
  }) async {
    state = const AsyncLoading();
    try {
      if (collectedNowEgp < 0 || collectedNowEgp > additionalFeeEgp + 0.01) {
        throw Exception('المبلغ المحصّل لا يمكن أن يزيد عن رسوم التمديد');
      }
      await _db.transaction(() async {
        final booking = await (_db.select(
          _db.summerBookings,
        )..where((t) => t.id.equals(id))).getSingle();

        if (collectedNowEgp > 0) {
          await _db
              .into(_db.bookingPayments)
              .insert(
                BookingPaymentsCompanion.insert(
                  id: const Uuid().v4(),
                  bookingId: id,
                  amountEgp: collectedNowEgp,
                  paymentMethod: Value(paymentMethod),
                  paymentDate: DateTime.now(),
                  notes: const Value('تحصيل رسوم تمديد'),
                  syncStatus: const Value(SyncStatus.pendingInsert),
                  createdAt: DateTime.now(),
                ),
              );
        }

        await (_db.update(
          _db.summerBookings,
        )..where((t) => t.id.equals(id))).write(
          SummerBookingsCompanion(
            checkOutDate: Value(newCheckoutDate),
            overstayDays: Value(booking.overstayDays + overstayDays),
            overstayFeeEgp: Value(booking.overstayFeeEgp + additionalFeeEgp),
            totalPriceEgp: Value(booking.totalPriceEgp + additionalFeeEgp),
            amountPaidEgp: Value(booking.amountPaidEgp + collectedNowEgp),
            syncStatus: const Value(SyncStatus.pendingUpdate),
            updatedAt: Value(DateTime.now()),
          ),
        );
        final remaining = additionalFeeEgp - collectedNowEgp;
        await _auditLog.log(
          action: 'extend',
          entityType: 'summer_booking',
          entityId: id,
          title: 'تمديد حجز صيفي',
          description:
              'تم تمديد الحجز $overstayDays يوم بقيمة $additionalFeeEgp ج.م — '
              '${await _bookingLabel(booking)}'
              '${collectedNowEgp > 0 ? ' (اتحصّل $collectedNowEgp ج.م)' : ''}'
              '${remaining > 0.01 ? ' (باقي $remaining ج.م على العميل)' : ''}',
          route: '/summer_bookings/details/$id',
        );
      });
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// تسجيل خروج تلقائي لكل حجز عدّى ميعاد خروجه.
  ///
  /// المالك بيستلم الشقة ٨ الصبح وساعات بينسى يسجّل الخروج، فالشقة بتفضل
  /// ظاهرة مؤجرة وهي فاضية. بعد الساعة [hour] يوم الخروج التطبيق بيقفلها
  /// لوحده ويحطها "محتاجة تنظيف".
  ///
  /// **بيسيب أي حجز العميل لسه عليه فيه فلوس** — الدين لازم يفضل قدام عين
  /// المالك لحد ما يحصّله، ومينفعش الحجز يتقفل من ورا ظهره.
  ///
  /// بيرجّع عدد الحجوزات اللي اتقفلت.
  Future<int> runAutomaticCheckouts({
    DateTime? now,
    int hour = kDefaultAutoCheckoutHour,
  }) async {
    final at = now ?? DateTime.now();
    final candidates = await (_db.select(
      _db.summerBookings,
    )..where((t) => t.status.isNotIn(['cancelled', 'checked_out']))).get();

    var closed = 0;
    for (final booking in candidates) {
      if (booking.syncStatus == SyncStatus.pendingDelete) continue;
      if (booking.status == 'deleted') continue;
      final skip = summerBookingAutoCheckoutSkipReason(booking, at, hour: hour);
      if (skip != null) continue;

      await checkoutBooking(
        booking.id,
        apartmentId: booking.apartmentId,
        automatic: true,
      );
      closed++;
    }
    return closed;
  }

  /// نقل ضيف من شقة لشقة في نص إقامته.
  ///
  /// الإقامة بتتقسم لحجزين: القديم بيتقفل على الليالي اللي قعدها فعلاً بسعرها،
  /// والجديد بياخد باقي المدة في الشقة الجديدة بسعرها. الفلوس اللي دفعها
  /// قبل كده بتترحّل مع الضيف.
  ///
  /// الترحيل بيتسجل كصفّين دفعة متقابلين: سالب على الحجز القديم وموجب على
  /// الجديد بنفس الطريقة. ده بيخلي الخزنة **متتأثرش خالص** بالنقل — الفلوس
  /// اتحصّلت مرة واحدة وفضلت في نفس الحساب — والوحيد اللي بيزوّد الخزنة هو
  /// [collectedNowEgp] لو الشقة الجديدة أغلى ودفع الفرق.
  ///
  /// [refundedNowEgp] العكس: لو الشقة الجديدة أرخص ورجّعنا له فلوس.
  Future<void> transferBooking({
    required String id,
    required String newApartmentId,
    required DateTime transferDate,
    required double newBookingTotalEgp,
    double collectedNowEgp = 0,
    double refundedNowEgp = 0,
    String paymentMethod = 'cash',
    String cleaningStatus = 'needs_cleaning',
  }) async {
    state = const AsyncLoading();
    try {
      if (collectedNowEgp < 0 || refundedNowEgp < 0) {
        throw Exception('المبالغ لا يمكن أن تكون بالسالب');
      }
      if (collectedNowEgp > 0 && refundedNowEgp > 0) {
        throw Exception('مينفعش تحصّل وترجّع فلوس في نفس النقل');
      }
      if (newBookingTotalEgp < 0) {
        throw Exception('سعر الحجز الجديد لا يمكن أن يكون بالسالب');
      }

      final newBookingId = const Uuid().v4();
      await _db.transaction(() async {
        final old = await (_db.select(
          _db.summerBookings,
        )..where((t) => t.id.equals(id))).getSingle();

        if (old.transferredToBookingId != null) {
          throw Exception('الحجز ده اتنقل قبل كده لشقة تانية');
        }
        final transferDay = dateOnly(transferDate);
        final checkInDay = dateOnly(old.checkInDate);
        final checkOutDay = dateOnly(old.checkOutDate);
        if (!transferDay.isAfter(checkInDay)) {
          throw Exception(
            'تاريخ النقل لازم يكون بعد تاريخ الدخول. لو الضيف مقعدش ولا ليلة، '
            'عدّل الشقة في الحجز نفسه بدل النقل.',
          );
        }
        if (!transferDay.isBefore(checkOutDay)) {
          throw Exception(
            'تاريخ النقل لازم يكون قبل تاريخ الخروج، وإلا مفيش مدة تتنقل.',
          );
        }
        if (old.apartmentId == newApartmentId) {
          throw Exception('اختار شقة غير اللي هو فيها');
        }
        await _occupancyRules.ensureApartmentIsFreeForPeriod(
          apartmentId: newApartmentId,
          checkInDate: transferDay,
          checkOutDate: old.checkOutDate,
        );

        // سعر الليلة في الشقة القديمة من غير رسوم تمديد، عشان نحسب بيه
        // الليالي اللي قعدها فعلاً.
        final stayedNights = transferDay.difference(checkInDay).inDays;
        final bookedNights = checkOutDay.difference(checkInDay).inDays;
        final oldNightlyRate = bookedNights > 0
            ? old.totalPriceEgp / bookedNights
            : old.totalPriceEgp;
        final oldNewTotal = oldNightlyRate * stayedNights;

        // اللي اتحصّل فعلاً على الحجز القديم ناقص تمن الليالي اللي قعدها =
        // الرصيد اللي بيمشي مع الضيف.
        final carriedAmount = old.amountPaidEgp - oldNewTotal;
        if (carriedAmount < -0.01) {
          throw Exception(
            'المدفوع على الحجز القديم (${old.amountPaidEgp.toStringAsFixed(0)} ج.م) '
            'أقل من تمن الليالي اللي قعدها (${oldNewTotal.toStringAsFixed(0)} ج.م). '
            'سجّل الباقي الأول قبل النقل.',
          );
        }

        final now = DateTime.now();
        final transferDayLabel = transferDay.toString().split(' ').first;

        // صف سالب على القديم + صف موجب على الجديد = الخزنة متتأثرش.
        if (carriedAmount.abs() > 0.01) {
          await _db
              .into(_db.bookingPayments)
              .insert(
                BookingPaymentsCompanion.insert(
                  id: const Uuid().v4(),
                  bookingId: id,
                  amountEgp: -carriedAmount,
                  paymentMethod: Value(old.paymentMethod),
                  paymentDate: now,
                  notes: Value(
                    'مرحّل لحجز الشقة الجديدة (نقل بتاريخ $transferDayLabel)',
                  ),
                  syncStatus: const Value(SyncStatus.pendingInsert),
                  createdAt: now,
                ),
              );
          await _db
              .into(_db.bookingPayments)
              .insert(
                BookingPaymentsCompanion.insert(
                  id: const Uuid().v4(),
                  bookingId: newBookingId,
                  amountEgp: carriedAmount,
                  paymentMethod: Value(old.paymentMethod),
                  paymentDate: now,
                  notes: Value(
                    'مرحّل من حجز الشقة القديمة (نقل بتاريخ $transferDayLabel)',
                  ),
                  syncStatus: const Value(SyncStatus.pendingInsert),
                  createdAt: now,
                ),
              );
        }

        if (collectedNowEgp > 0) {
          await _db
              .into(_db.bookingPayments)
              .insert(
                BookingPaymentsCompanion.insert(
                  id: const Uuid().v4(),
                  bookingId: newBookingId,
                  amountEgp: collectedNowEgp,
                  paymentMethod: Value(paymentMethod),
                  paymentDate: now,
                  notes: const Value('فرق سعر الشقة الجديدة'),
                  syncStatus: const Value(SyncStatus.pendingInsert),
                  createdAt: now,
                ),
              );
        }
        if (refundedNowEgp > 0) {
          await _db
              .into(_db.bookingPayments)
              .insert(
                BookingPaymentsCompanion.insert(
                  id: const Uuid().v4(),
                  bookingId: newBookingId,
                  amountEgp: -refundedNowEgp,
                  paymentMethod: Value(paymentMethod),
                  paymentDate: now,
                  notes: const Value('مرتجع فرق سعر الشقة الجديدة'),
                  syncStatus: const Value(SyncStatus.pendingInsert),
                  createdAt: now,
                ),
              );
        }

        // الحجز الجديد: نفس بيانات الضيف، باقي المدة، الشقة الجديدة.
        // العمولة بتفضل على الحجز القديم لوحده — السمسار جاب الضيف مرة واحدة
        // فمينفعش تتحسب عليه مرتين.
        await _db
            .into(_db.summerBookings)
            .insert(
              SummerBookingsCompanion.insert(
                id: newBookingId,
                apartmentId: newApartmentId,
                guestName: old.guestName,
                guestPhone: Value(old.guestPhone),
                checkInDate: transferDay,
                checkOutDate: old.checkOutDate,
                status: const Value('confirmed'),
                totalPriceEgp: newBookingTotalEgp,
                amountPaidEgp: Value(
                  carriedAmount + collectedNowEgp - refundedNowEgp,
                ),
                paymentMethod: Value(old.paymentMethod),
                nationalId: Value(old.nationalId),
                idFrontImage: Value(old.idFrontImage),
                idBackImage: Value(old.idBackImage),
                transferredFromBookingId: Value(id),
                createdAt: now,
                updatedAt: now,
                syncStatus: const Value(SyncStatus.pendingInsert),
              ),
            );

        // الحجز القديم بيتقفل على اللي قعده فعلاً.
        await (_db.update(
          _db.summerBookings,
        )..where((t) => t.id.equals(id))).write(
          SummerBookingsCompanion(
            checkOutDate: Value(transferDay),
            totalPriceEgp: Value(oldNewTotal),
            amountPaidEgp: Value(oldNewTotal),
            status: const Value('checked_out'),
            transferredToBookingId: Value(newBookingId),
            syncStatus: const Value(SyncStatus.pendingUpdate),
            updatedAt: Value(now),
          ),
        );

        await (_db.update(
          _db.apartments,
        )..where((t) => t.id.equals(old.apartmentId))).write(
          ApartmentsCompanion(
            cleaningStatus: Value(cleaningStatus),
            syncStatus: const Value(SyncStatus.pendingUpdate),
            updatedAt: Value(now),
          ),
        );

        final newApartment = await (_db.select(
          _db.apartments,
        )..where((t) => t.id.equals(newApartmentId))).getSingleOrNull();
        final newApartmentLabel = newApartment == null
            ? 'الشقة الجديدة'
            : 'شقة ${newApartment.apartmentNumber}';

        await _auditLog.log(
          action: 'transfer',
          entityType: 'summer_booking',
          entityId: id,
          title: 'نقل ضيف لشقة تانية',
          description:
              'تم نقل ${await _bookingLabel(old)} إلى $newApartmentLabel بتاريخ '
              '$transferDayLabel. '
              'الحجز القديم اتقفل على $stayedNights ليلة بـ '
              '${oldNewTotal.toStringAsFixed(0)} ج.م، والحجز الجديد بـ '
              '${newBookingTotalEgp.toStringAsFixed(0)} ج.م'
              '${carriedAmount.abs() > 0.01 ? ' (اترحّل ${carriedAmount.toStringAsFixed(0)} ج.م من المدفوع)' : ''}'
              '${collectedNowEgp > 0 ? ' (اتحصّل فرق ${collectedNowEgp.toStringAsFixed(0)} ج.م)' : ''}'
              '${refundedNowEgp > 0 ? ' (اترجّع ${refundedNowEgp.toStringAsFixed(0)} ج.م)' : ''}',
          route: '/summer_bookings/details/$newBookingId',
          oldValues: {
            'apartmentId': old.apartmentId,
            'checkOutDate': old.checkOutDate.toIso8601String(),
            'totalPriceEgp': old.totalPriceEgp,
            'amountPaidEgp': old.amountPaidEgp,
          },
          newValues: {
            'newBookingId': newBookingId,
            'newApartmentId': newApartmentId,
            'transferDate': transferDay.toIso8601String(),
            'oldBookingTotalEgp': oldNewTotal,
            'newBookingTotalEgp': newBookingTotalEgp,
            'carriedAmountEgp': carriedAmount,
            'collectedNowEgp': collectedNowEgp,
            'refundedNowEgp': refundedNowEgp,
          },
        );
      });
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
        description: 'تم حذف حجز ${await _bookingLabel(booking)}',
        oldValues: booking.toJson(),
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
