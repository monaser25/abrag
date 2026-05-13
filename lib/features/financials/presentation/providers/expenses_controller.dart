import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database.dart';
import '../../../../core/database/tables.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';

final expensesControllerProvider = StateNotifierProvider<ExpensesController, AsyncValue<void>>((ref) {
  return ExpensesController(ref.watch(databaseProvider));
});

class ExpensesController extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;

  ExpensesController(this._db) : super(const AsyncData(null));

  Future<void> addExpense({
    String? buildingId,
    String? apartmentId,
    required String expenseType,
    required double amount,
    required DateTime date,
    String? description,
    int? installmentNumber,
  }) async {
    state = const AsyncLoading();
    try {
      final id = const Uuid().v4();
      
      await _db.into(_db.expenses).insert(
        ExpensesCompanion.insert(
          id: id,
          buildingId: Value(buildingId),
          apartmentId: Value(apartmentId),
          expenseType: expenseType,
          amountEgp: amount,
          expenseDate: date,
          description: Value(description),
          installmentNumber: Value(installmentNumber),
          syncStatus: const Value(SyncStatus.pendingInsert),
          createdAt: DateTime.now(),
        ),
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
