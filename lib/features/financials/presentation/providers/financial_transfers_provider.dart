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
    ) money_movements
    GROUP BY account
  ''', readsFrom: {
    db.summerBookings,
    db.winterPayments,
    db.expenses,
    db.financialTransfers,
  }).watch().map((rows) {
    final balances = {for (final key in paymentAccounts.keys) key: 0.0};
    for (final row in rows) {
      final account = row.read<String>('account');
      balances[account] = row.read<double?>('balance') ?? 0;
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
}
