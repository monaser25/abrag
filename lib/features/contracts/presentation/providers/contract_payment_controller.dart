import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database.dart';
import '../../../../core/database/tables.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';

final contractPaymentsProvider = StreamProvider.family<List<WinterPayment>, String>((ref, contractId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.winterPayments)..where((t) => t.contractId.equals(contractId))).watch();
});

final contractPaymentControllerProvider = StateNotifierProvider<ContractPaymentController, AsyncValue<void>>((ref) {
  return ContractPaymentController(ref.watch(databaseProvider));
});

class ContractPaymentController extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;

  ContractPaymentController(this._db) : super(const AsyncData(null));

  Future<void> addPayment({
    required String contractId,
    required double amount,
    required DateTime date,
  }) async {
    state = const AsyncLoading();
    try {
      final id = const Uuid().v4();
      await _db.into(_db.winterPayments).insert(
        WinterPaymentsCompanion.insert(
          id: id,
          contractId: contractId,
          amountEgp: amount,
          paymentDate: date,
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
