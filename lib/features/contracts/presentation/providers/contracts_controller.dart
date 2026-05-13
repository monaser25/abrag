import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database.dart';
import '../../../../core/database/tables.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';

final contractsControllerProvider = StateNotifierProvider<ContractsController, AsyncValue<void>>((ref) {
  return ContractsController(ref.watch(databaseProvider));
});

class ContractsController extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;

  ContractsController(this._db) : super(const AsyncData(null));

  Future<void> addContract({
    required String studentName,
    required String university,
    required double monthlyRentEgp,
    required double depositEgp,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    state = const AsyncLoading();
    try {
      final id = const Uuid().v4();
      
      final apartments = await _db.select(_db.apartments).get();
      if (apartments.isEmpty) {
        throw Exception('No apartments available for contract.');
      }
      final apartmentId = apartments.first.id;

      await _db.into(_db.winterContracts).insert(
        WinterContractsCompanion.insert(
          id: id,
          apartmentId: apartmentId,
          studentName: studentName,
          university: Value(university),
          startDate: startDate,
          endDate: endDate,
          monthlyRentEgp: monthlyRentEgp,
          depositEgp: Value(depositEgp),
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
}
