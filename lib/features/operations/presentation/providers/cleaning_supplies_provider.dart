import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database.dart';
import '../../../../core/database/tables.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';

final cleaningSuppliesProvider = StreamProvider<List<CleaningSupply>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.cleaningSupplies).watch();
});

final cleaningSuppliesControllerProvider = StateNotifierProvider<CleaningSuppliesController, AsyncValue<void>>((ref) {
  return CleaningSuppliesController(ref.watch(databaseProvider));
});

class CleaningSuppliesController extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;

  CleaningSuppliesController(this._db) : super(const AsyncData(null));

  Future<void> addSupply(String name, String unit) async {
    state = const AsyncLoading();
    try {
      await _db.into(_db.cleaningSupplies).insert(
        CleaningSuppliesCompanion.insert(
          id: const Uuid().v4(),
          name: name,
          unit: Value(unit),
          syncStatus: const Value(SyncStatus.pendingInsert),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateSupply(String id, String name, String unit) async {
    state = const AsyncLoading();
    try {
      await (_db.update(_db.cleaningSupplies)..where((t) => t.id.equals(id))).write(
        CleaningSuppliesCompanion(
          name: Value(name),
          unit: Value(unit),
          updatedAt: Value(DateTime.now()),
          syncStatus: const Value(SyncStatus.pendingUpdate),
        ),
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> logTransaction({
    required String supplyId,
    required String type, // 'purchase' or 'consumption'
    required double quantity,
    double costEgp = 0,
    String? notes,
  }) async {
    state = const AsyncLoading();
    try {
      await _db.transaction(() async {
        // Add transaction
        await _db.into(_db.cleaningTransactions).insert(
          CleaningTransactionsCompanion.insert(
            id: const Uuid().v4(),
            supplyId: supplyId,
            transactionType: type,
            quantity: quantity,
            costEgp: Value(costEgp),
            transactionDate: DateTime.now(),
            notes: Value(notes),
            syncStatus: const Value(SyncStatus.pendingInsert),
            createdAt: DateTime.now(),
          ),
        );

        // Update stock
        final supply = await (_db.select(_db.cleaningSupplies)..where((t) => t.id.equals(supplyId))).getSingle();
        final newStock = type == 'purchase' ? supply.stockQuantity + quantity : supply.stockQuantity - quantity;
        
        await (_db.update(_db.cleaningSupplies)..where((t) => t.id.equals(supplyId))).write(
          CleaningSuppliesCompanion(
            stockQuantity: Value(newStock),
            updatedAt: Value(DateTime.now()),
            syncStatus: const Value(SyncStatus.pendingUpdate),
          ),
        );

        // If it's a purchase and has cost, log expense
        if (type == 'purchase' && costEgp > 0) {
          await _db.into(_db.expenses).insert(
            ExpensesCompanion.insert(
              id: const Uuid().v4(),
              expenseType: 'cleaning',
              amountEgp: costEgp,
              expenseDate: DateTime.now(),
              description: Value('شراء أدوات نظافة: ${supply.name} - الكمية $quantity ${supply.unit}'),
              syncStatus: const Value(SyncStatus.pendingInsert),
              createdAt: DateTime.now(),
            ),
          );
        }
      });
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
