import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/database.dart';
import '../../../../core/database/tables.dart';
import '../../../../core/services/audit_log_service.dart';
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

final financialTransfersProvider = StreamProvider<List<FinancialTransfer>>((ref) {
  final db = ref.watch(databaseProvider);
  final selectedSeason = ref.watch(selectedFinancialSeasonProvider);
  final query = db.select(db.financialTransfers)
    ..orderBy([(t) => OrderingTerm.desc(t.transferDate)]);
  if (selectedSeason != 'all') {
    query.where((t) => t.season.equals(selectedSeason));
  }
  return query.watch();
});

final selectedFinancialSeasonProvider = StateProvider<String>((ref) => 'all');

final accountBalancesProvider = StreamProvider<Map<String, double>>((ref) {
  final db = ref.watch(databaseProvider);
  final selectedSeason = ref.watch(selectedFinancialSeasonProvider);
  final seasonFilter = selectedSeason == 'all'
      ? ''
      : "AND season = '$selectedSeason'";
  final hideSummer = selectedSeason == 'winter' ? 'AND 1 = 0' : '';
  final hideWinter = selectedSeason == 'summer' ? 'AND 1 = 0' : '';
  return db.customSelect('''
    SELECT account, SUM(amount) AS balance
    FROM (
      SELECT payment_method AS account, amount_paid_egp AS amount
      FROM summer_bookings
      WHERE status != 'cancelled' $hideSummer
      UNION ALL
      SELECT payment_method AS account, amount_egp AS amount
      FROM winter_payments
      WHERE 1 = 1 $hideWinter
      UNION ALL
      SELECT payment_method AS account, -amount_egp AS amount
      FROM expenses
      WHERE 1 = 1 $seasonFilter
      UNION ALL
      SELECT from_account AS account, -amount_egp AS amount
      FROM financial_transfers
      WHERE 1 = 1 $seasonFilter
      UNION ALL
      SELECT to_account AS account, amount_egp AS amount
      FROM financial_transfers
      WHERE transfer_type = 'internal' $seasonFilter
      UNION ALL
      SELECT 'company_vault' AS account, amount_egp AS amount
      FROM financial_transfers
      WHERE transfer_type = 'cash_deposit' $seasonFilter
    ) money_movements
    GROUP BY account
  ''', readsFrom: {
    db.summerBookings,
    db.winterPayments,
    db.expenses,
    db.financialTransfers,
  }).watch().map((rows) {
    final balances = {for (final key in treasuryAccounts.keys) key: 0.0};
    for (final row in rows) {
      final account = row.read<String>('account');
      if (balances.containsKey(account)) {
        balances[account] = row.read<double?>('balance') ?? 0;
      }
    }
    return balances;
  });
});

final financialTransfersControllerProvider =
    StateNotifierProvider<FinancialTransfersController, AsyncValue<void>>((ref) {
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
    String season = 'all',
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
      final balances = await _calculateBalances(season: season);
      final available = balances[fromAccount] ?? 0;
      if (available + 0.001 < amount) {
        throw Exception(
          'الرصيد غير كافي في ${treasuryAccounts[fromAccount] ?? fromAccount}. المتاح: ${available.toStringAsFixed(2)} ج.م',
        );
      }
      final id = const Uuid().v4();
      await _db.into(_db.financialTransfers).insert(
        FinancialTransfersCompanion.insert(
          id: id,
          fromAccount: fromAccount,
          toAccount: toAccount,
          transferType: Value(transferType),
          season: Value(season),
          amountEgp: amount,
          transferDate: date,
          notes: Value(notes?.trim().isEmpty == true ? null : notes?.trim()),
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
          'season': season,
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
    required String season,
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
      final balances = await _calculateBalances(
        season: season,
        excludingTransferId: id,
      );
      final available = balances[fromAccount] ?? 0;
      if (available + 0.001 < amount) {
        throw Exception(
          'الرصيد غير كافي في ${treasuryAccounts[fromAccount] ?? fromAccount}. المتاح: ${available.toStringAsFixed(2)} ج.م',
        );
      }
      await (_db.update(_db.financialTransfers)..where((t) => t.id.equals(id)))
          .write(
        FinancialTransfersCompanion(
          fromAccount: Value(fromAccount),
          toAccount: Value(toAccount),
          transferType: Value(transferType),
          season: Value(season),
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
          'season': season,
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

  Future<Map<String, double>> _calculateBalances({
    required String season,
    String? excludingTransferId,
  }) async {
    final balances = {for (final key in treasuryAccounts.keys) key: 0.0};

    void add(String account, double amount) {
      if (balances.containsKey(account)) {
        balances[account] = (balances[account] ?? 0) + amount;
      }
    }

    if (season != 'winter') {
      final bookings = await _db.select(_db.summerBookings).get();
      for (final booking in bookings) {
        if (booking.status == 'cancelled') continue;
        add(booking.paymentMethod, booking.amountPaidEgp);
      }
    }

    if (season != 'summer') {
      final payments = await _db.select(_db.winterPayments).get();
      for (final payment in payments) {
        add(payment.paymentMethod, payment.amountEgp);
      }
    }

    final expenses = await _db.select(_db.expenses).get();
    for (final expense in expenses) {
      if (season != 'all' && expense.season != season) continue;
      add(expense.paymentMethod, -(expense.amountEgp - expense.discountEgp));
    }

    final transfers = await _db.select(_db.financialTransfers).get();
    for (final transfer in transfers) {
      if (transfer.id == excludingTransferId) continue;
      if (season != 'all' && transfer.season != season) continue;
      add(transfer.fromAccount, -transfer.amountEgp);
      if (transfer.transferType == 'internal') {
        add(transfer.toAccount, transfer.amountEgp);
      } else if (transfer.transferType == 'cash_deposit') {
        add('company_vault', transfer.amountEgp);
      }
    }

    return balances;
  }
}
