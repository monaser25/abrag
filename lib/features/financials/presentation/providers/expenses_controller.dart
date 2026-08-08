import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database.dart';
import '../../../../core/database/tables.dart';
import '../../../../core/services/audit_log_service.dart';
import '../../../../core/utils/season_utils.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';

final expensesControllerProvider =
    StateNotifierProvider<ExpensesController, AsyncValue<void>>((ref) {
      return ExpensesController(ref.watch(databaseProvider));
    });

class ExpensesController extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;
  late final AuditLogService _auditLog;

  ExpensesController(this._db) : super(const AsyncData(null)) {
    _auditLog = AuditLogService(_db);
  }

  Future<void> addExpense({
    String? buildingId,
    String? apartmentId,
    required String expenseType,
    required double amount,
    String paymentMethod = 'cash',
    String? season,
    required DateTime date,
    String? description,
    int? installmentNumber,
    double discountEgp = 0,
    String? discountReason,
  }) async {
    state = const AsyncLoading();
    try {
      final id = const Uuid().v4();

      await _db
          .into(_db.expenses)
          .insert(
            ExpensesCompanion.insert(
              id: id,
              buildingId: Value(buildingId),
              apartmentId: Value(apartmentId),
              expenseType: expenseType,
              amountEgp: amount,
              paymentMethod: Value(paymentMethod),
              season: Value(season ?? currentSeasonKey()),
              expenseDate: date,
              description: Value(description),
              installmentNumber: Value(installmentNumber),
              discountEgp: Value(discountEgp),
              discountReason: Value(discountReason),
              syncStatus: const Value(SyncStatus.pendingInsert),
              createdAt: DateTime.now(),
            ),
          );
      await _auditLog.log(
        action: 'create',
        entityType: 'expense',
        entityId: id,
        title: 'إضافة مصروف',
        description: 'تم إضافة مصروف بقيمة $amount ج.م',
        route: '/expenses',
        newValues: {
          'expenseType': expenseType,
          'amount': amount,
          'paymentMethod': paymentMethod,
          'season': season ?? currentSeasonKey(),
          'date': date,
          'description': description,
        },
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Soft-delete: mark the expense as pendingDelete so it disappears from the
  /// UI and the sync engine deletes it on the server. Mirrors the technicians/
  /// brokers delete pattern; keeps history recoverable until the next sync.
  Future<void> deleteExpense(String id) async {
    state = const AsyncLoading();
    try {
      final old = await (_db.select(
        _db.expenses,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      await (_db.update(_db.expenses)..where((t) => t.id.equals(id))).write(
        const ExpensesCompanion(syncStatus: Value(SyncStatus.pendingDelete)),
      );
      await _auditLog.log(
        action: 'delete',
        entityType: 'expense',
        entityId: id,
        title: 'حذف مصروف',
        description: 'تم حذف مصروف بقيمة ${old?.amountEgp ?? ''} ج.م',
        route: '/expenses',
        oldValues: old?.toJson(),
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateExpense({
    required String id,
    String? buildingId,
    String? apartmentId,
    required String expenseType,
    required double amount,
    String paymentMethod = 'cash',
    String? season,
    required DateTime date,
    String? description,
    int? installmentNumber,
    double discountEgp = 0,
    String? discountReason,
  }) async {
    state = const AsyncLoading();
    try {
      await (_db.update(_db.expenses)..where((t) => t.id.equals(id))).write(
        ExpensesCompanion(
          buildingId: Value(buildingId),
          apartmentId: Value(apartmentId),
          expenseType: Value(expenseType),
          amountEgp: Value(amount),
          paymentMethod: Value(paymentMethod),
          season: Value(season ?? currentSeasonKey()),
          expenseDate: Value(date),
          description: Value(description),
          installmentNumber: Value(installmentNumber),
          discountEgp: Value(discountEgp),
          discountReason: Value(discountReason),
          syncStatus: const Value(SyncStatus.pendingUpdate),
        ),
      );
      await _auditLog.log(
        action: 'update',
        entityType: 'expense',
        entityId: id,
        title: 'تعديل مصروف',
        description: 'تم تعديل مصروف بقيمة $amount ج.م',
        route: '/expenses',
        newValues: {
          'expenseType': expenseType,
          'amount': amount,
          'paymentMethod': paymentMethod,
          'season': season ?? currentSeasonKey(),
          'date': date,
          'description': description,
        },
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
