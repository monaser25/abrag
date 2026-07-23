import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/database.dart';
import '../../../../core/database/tables.dart';
import '../../../../core/services/audit_log_service.dart';
import '../../../../core/utils/season_utils.dart';
import '../../../../core/utils/summer_booking_payment_utils.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';

const paymentAccounts = <String, String>{
  'cash': 'نقدي',
  'instapay': 'إنستا باي',
  'vodafone_cash': 'فودافون كاش',
};

const treasuryAccounts = <String, String>{
  ...paymentAccounts,
  'company_vault': 'خزنة الشركة',
};

final financialTransfersProvider = StreamProvider<List<FinancialTransfer>>((
  ref,
) {
  final db = ref.watch(databaseProvider);
  final selectedSeason = ref.watch(selectedFinancialSeasonProvider);
  final query = db.select(db.financialTransfers)
    ..orderBy([(t) => OrderingTerm.desc(t.transferDate)]);
  if (selectedSeason != 'all') {
    query.where((t) => t.season.equals(selectedSeason));
  }
  return query.watch();
});

final selectedFinancialSeasonProvider = StateProvider<String>(
  (ref) => currentSeasonKey(),
);

final accountBalancesProvider = StreamProvider<Map<String, double>>((ref) {
  final db = ref.watch(databaseProvider);
  final selectedSeason = ref.watch(selectedFinancialSeasonProvider);
  late final StreamController<Map<String, double>> controller;
  final subscriptions = <StreamSubscription<dynamic>>[];
  Timer? debounce;

  Future<void> emit() async {
    try {
      final balances = await buildTreasuryBalances(db, selectedSeason);
      if (!controller.isClosed) controller.add(balances);
    } catch (error, stackTrace) {
      if (!controller.isClosed) controller.addError(error, stackTrace);
    }
  }

  void scheduleEmit() {
    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 80), emit);
  }

  controller = StreamController<Map<String, double>>(
    onListen: () {
      subscriptions.add(
        db.select(db.summerBookings).watch().listen((_) => scheduleEmit()),
      );
      subscriptions.add(
        db.select(db.bookingPayments).watch().listen((_) => scheduleEmit()),
      );
      subscriptions.add(
        db.select(db.winterPayments).watch().listen((_) => scheduleEmit()),
      );
      subscriptions.add(
        db.select(db.expenses).watch().listen((_) => scheduleEmit()),
      );
      subscriptions.add(
        db.select(db.financialTransfers).watch().listen((_) => scheduleEmit()),
      );
      scheduleEmit();
    },
    onCancel: () async {
      debounce?.cancel();
      for (final subscription in subscriptions) {
        await subscription.cancel();
      }
    },
  );

  return controller.stream;
});

Future<Map<String, double>> buildTreasuryBalances(
  AppDatabase db,
  String season, {
  String? excludingTransferId,
}) async {
  final balances = {for (final key in treasuryAccounts.keys) key: 0.0};

  void add(String account, double amount) {
    if (balances.containsKey(account)) {
      balances[account] = (balances[account] ?? 0) + amount;
    }
  }

  final bookings = await db.select(db.summerBookings).get();
  final bookingPayments = await db.select(db.bookingPayments).get();
  final paymentsByBookingId = indexActiveBookingPayments(bookingPayments);
  for (final booking in bookings) {
    if (booking.status == 'cancelled' || booking.status == 'deleted') continue;
    if (booking.syncStatus == SyncStatus.pendingDelete) continue;
    if (!seasonMatchesDate(booking.checkInDate, season)) continue;
    final paymentBreakdown = summerBookingPaymentBreakdown(
      booking,
      paymentsByBookingId[booking.id] ?? const <BookingPayment>[],
    );
    for (final entry in paymentBreakdown.entries) {
      add(entry.key, entry.value);
    }
    final commission = _summerBookingCommission(booking);
    for (final entry in summerBookingCommissionDeductions(
      booking,
      commission,
    ).entries) {
      add(entry.key, -entry.value);
    }
  }

  final payments = await db.select(db.winterPayments).get();
  for (final payment in payments) {
    if (!seasonMatchesDate(payment.paymentDate, season)) continue;
    add(payment.paymentMethod, payment.amountEgp);
  }

  final expenses = await db.select(db.expenses).get();
  for (final expense in expenses) {
    final normalizedSeason = normalizeStoredSeason(
      expense.season,
      expense.expenseDate,
    );
    if (!seasonMatchesKey(normalizedSeason, season)) continue;
    add(expense.paymentMethod, -(expense.amountEgp - expense.discountEgp));
  }

  final transfers = await db.select(db.financialTransfers).get();
  for (final transfer in transfers) {
    if (transfer.id == excludingTransferId) continue;
    final normalizedSeason = normalizeStoredSeason(
      transfer.season,
      transfer.transferDate,
    );
    if (!seasonMatchesKey(normalizedSeason, season)) continue;
    add(transfer.fromAccount, -transfer.amountEgp);
    if (transfer.transferType == 'internal') {
      add(transfer.toAccount, transfer.amountEgp);
    } else if (transfer.transferType == 'cash_deposit') {
      add('company_vault', transfer.amountEgp);
    }
  }

  return balances;
}

double _summerBookingCommission(SummerBooking booking) {
  if (booking.brokerCommissionType == 'fixed') {
    return booking.brokerCommissionFixedEgp;
  }
  if (booking.brokerCommissionType == 'percentage') {
    return booking.totalPriceEgp * booking.brokerCommissionPercentage / 100;
  }
  // 'none' => the broker took no commission at all.
  return 0;
}

final financialTransfersControllerProvider =
    StateNotifierProvider<FinancialTransfersController, AsyncValue<void>>((
      ref,
    ) {
      return FinancialTransfersController(ref.watch(databaseProvider));
    });

class FinancialTransfersController extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;
  late final AuditLogService _auditLog;

  FinancialTransfersController(this._db) : super(const AsyncData(null)) {
    _auditLog = AuditLogService(_db);
  }

  Future<void> addTransfer({
    required String fromAccount,
    required String toAccount,
    required double amount,
    required DateTime date,
    String transferType = 'internal',
    String? season,
    String? notes,
  }) async {
    state = const AsyncLoading();
    try {
      if (transferType == 'internal' && fromAccount == toAccount) {
        throw Exception('اختار مكانين مختلفين للتحويل');
      }
      if (amount <= 0) {
        throw Exception('المبلغ لازم يكون أكبر من صفر');
      }
      final effectiveSeason = season ?? currentSeasonKey();
      final balances = await buildTreasuryBalances(_db, effectiveSeason);
      final available = balances[fromAccount] ?? 0;
      if (available + 0.001 < amount) {
        throw Exception(
          'الرصيد غير كافي في ${treasuryAccounts[fromAccount] ?? fromAccount}. المتاح: ${available.toStringAsFixed(2)} ج.م',
        );
      }
      final id = const Uuid().v4();
      await _db
          .into(_db.financialTransfers)
          .insert(
            FinancialTransfersCompanion.insert(
              id: id,
              fromAccount: fromAccount,
              toAccount: toAccount,
              transferType: Value(transferType),
              season: Value(effectiveSeason),
              amountEgp: amount,
              transferDate: date,
              notes: Value(
                notes?.trim().isEmpty == true ? null : notes?.trim(),
              ),
              createdAt: DateTime.now(),
              syncStatus: const Value(SyncStatus.pendingInsert),
            ),
          );
      await _auditLog.log(
        action: transferType == 'cash_deposit' ? 'cash_deposit' : 'transfer',
        entityType: 'financial_transfer',
        entityId: id,
        title: transferType == 'cash_deposit'
            ? 'توريد نقدية لخزنة الشركة'
            : 'تحويل داخلي',
        description: transferType == 'cash_deposit'
            ? 'تم توريد $amount ج.م من النقدية لخزنة الشركة'
            : 'تم تحويل $amount ج.م من ${paymentAccounts[fromAccount] ?? fromAccount} إلى ${paymentAccounts[toAccount] ?? toAccount}',
        route: '/financial_transfers',
        newValues: {
          'fromAccount': fromAccount,
          'toAccount': toAccount,
          'transferType': transferType,
          'season': effectiveSeason,
          'amount': amount,
          'notes': notes,
        },
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateTransfer({
    required String id,
    required String fromAccount,
    required String toAccount,
    required double amount,
    required DateTime date,
    required String transferType,
    String? season,
    String? notes,
  }) async {
    state = const AsyncLoading();
    try {
      if (transferType == 'internal' && fromAccount == toAccount) {
        throw Exception('اختار مكانين مختلفين للتحويل');
      }
      if (amount <= 0) {
        throw Exception('المبلغ لازم يكون أكبر من صفر');
      }
      final old = await (_db.select(
        _db.financialTransfers,
      )..where((t) => t.id.equals(id))).getSingle();
      final effectiveSeason = season ?? currentSeasonKey();
      final balances = await buildTreasuryBalances(
        _db,
        effectiveSeason,
        excludingTransferId: id,
      );
      final available = balances[fromAccount] ?? 0;
      if (available + 0.001 < amount) {
        throw Exception(
          'الرصيد غير كافي في ${treasuryAccounts[fromAccount] ?? fromAccount}. المتاح: ${available.toStringAsFixed(2)} ج.م',
        );
      }
      await (_db.update(
        _db.financialTransfers,
      )..where((t) => t.id.equals(id))).write(
        FinancialTransfersCompanion(
          fromAccount: Value(fromAccount),
          toAccount: Value(toAccount),
          transferType: Value(transferType),
          season: Value(effectiveSeason),
          amountEgp: Value(amount),
          transferDate: Value(date),
          notes: Value(notes?.trim().isEmpty == true ? null : notes?.trim()),
          syncStatus: const Value(SyncStatus.pendingUpdate),
        ),
      );
      await _auditLog.log(
        action: transferType == 'cash_deposit'
            ? 'update_cash_deposit'
            : 'update_transfer',
        entityType: 'financial_transfer',
        entityId: id,
        title: transferType == 'cash_deposit'
            ? 'تعديل توريد نقدية'
            : 'تعديل تحويل داخلي',
        description: transferType == 'cash_deposit'
            ? 'تم تعديل توريد $amount ج.م لخزنة الشركة'
            : 'تم تعديل تحويل $amount ج.م من ${treasuryAccounts[fromAccount] ?? fromAccount} إلى ${treasuryAccounts[toAccount] ?? toAccount}',
        route: '/financial_transfers',
        oldValues: old.toJson(),
        newValues: {
          'fromAccount': fromAccount,
          'toAccount': toAccount,
          'transferType': transferType,
          'season': effectiveSeason,
          'amount': amount,
          'notes': notes,
        },
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteTransfer(String id) async {
    state = const AsyncLoading();
    try {
      final old = await (_db.select(
        _db.financialTransfers,
      )..where((t) => t.id.equals(id))).getSingle();

      await (_db.delete(
        _db.financialTransfers,
      )..where((t) => t.id.equals(id))).go();

      await _auditLog.log(
        action: old.transferType == 'cash_deposit'
            ? 'delete_cash_deposit'
            : 'delete_transfer',
        entityType: 'financial_transfer',
        entityId: id,
        title: old.transferType == 'cash_deposit'
            ? 'حذف توريد نقدية'
            : 'حذف تحويل داخلي',
        description: old.transferType == 'cash_deposit'
            ? 'تم حذف توريد ${old.amountEgp} ج.م لخزنة الشركة'
            : 'تم حذف تحويل ${old.amountEgp} ج.م من ${treasuryAccounts[old.fromAccount] ?? old.fromAccount} إلى ${treasuryAccounts[old.toAccount] ?? old.toAccount}',
        route: '/financial_transfers',
        oldValues: old.toJson(),
      );

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
