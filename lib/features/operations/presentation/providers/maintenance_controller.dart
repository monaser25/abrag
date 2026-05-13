import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database.dart';
import '../../../../core/database/tables.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';

final maintenanceControllerProvider = StateNotifierProvider<MaintenanceController, AsyncValue<void>>((ref) {
  return MaintenanceController(ref.watch(databaseProvider));
});

class MaintenanceController extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;

  MaintenanceController(this._db) : super(const AsyncData(null));

  Future<void> addRequest({
    required String apartmentId,
    required String reportedBy,
    required String description,
  }) async {
    state = const AsyncLoading();
    try {
      final id = const Uuid().v4();
      
      await _db.into(_db.maintenanceRequests).insert(
        MaintenanceRequestsCompanion.insert(
          id: id,
          apartmentId: apartmentId,
          reportedBy: reportedBy,
          issueDescription: description,
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

  Future<void> updateStatus(String id, String newStatus, {double? cost}) async {
    state = const AsyncLoading();
    try {
      await (_db.update(_db.maintenanceRequests)..where((t) => t.id.equals(id))).write(
        MaintenanceRequestsCompanion(
          status: Value(newStatus),
          costEgp: cost != null ? Value(cost) : const Value.absent(),
          resolvedAt: newStatus == 'resolved' ? Value(DateTime.now()) : const Value.absent(),
          syncStatus: const Value(SyncStatus.pendingUpdate),
          updatedAt: Value(DateTime.now()),
        ),
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
