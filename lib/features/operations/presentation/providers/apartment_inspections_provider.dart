import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database.dart';
import '../../../../core/database/tables.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';

final apartmentInspectionsProvider = StreamProvider<List<ApartmentInspection>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.apartmentInspections)..orderBy([(t) => OrderingTerm.desc(t.inspectionDate)])).watch();
});

final apartmentInspectionsControllerProvider = StateNotifierProvider<ApartmentInspectionsController, AsyncValue<void>>((ref) {
  return ApartmentInspectionsController(ref.watch(databaseProvider));
});

class ApartmentInspectionsController extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;

  ApartmentInspectionsController(this._db) : super(const AsyncData(null));

  Future<void> addInspection({
    required String apartmentId,
    required DateTime inspectionDate,
    required bool isClean,
    required bool hasDamages,
    String? damagesDescription,
    double tenantFineEgp = 0,
    double ownerRepairCostEgp = 0,
    required String inspectorName,
    String? notes,
    bool createMaintenanceRequest = false,
  }) async {
    state = const AsyncLoading();
    try {
      await _db.transaction(() async {
        await _db.into(_db.apartmentInspections).insert(
          ApartmentInspectionsCompanion.insert(
            id: const Uuid().v4(),
            apartmentId: apartmentId,
            inspectionDate: inspectionDate,
            isClean: Value(isClean),
            hasDamages: Value(hasDamages),
            damagesDescription: Value(damagesDescription),
            tenantFineEgp: Value(tenantFineEgp),
            ownerRepairCostEgp: Value(ownerRepairCostEgp),
            inspectorName: inspectorName,
            notes: Value(notes),
            syncStatus: const Value(SyncStatus.pendingInsert),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        // Update apartment cleaning status
        await (_db.update(_db.apartments)..where((t) => t.id.equals(apartmentId))).write(
          ApartmentsCompanion(
            cleaningStatus: Value(isClean ? 'clean' : 'needs_cleaning'),
            updatedAt: Value(DateTime.now()),
            syncStatus: const Value(SyncStatus.pendingUpdate),
          ),
        );

        // If createMaintenanceRequest is true, log a maintenance request
        if (createMaintenanceRequest && hasDamages) {
          await _db.into(_db.maintenanceRequests).insert(
            MaintenanceRequestsCompanion.insert(
              id: const Uuid().v4(),
              apartmentId: apartmentId,
              reportedBy: inspectorName,
              issueDescription: damagesDescription ?? 'تلفيات تم رصدها أثناء الفحص',
              syncStatus: const Value(SyncStatus.pendingInsert),
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
        } else if (ownerRepairCostEgp > 0) {
          // If the owner paid for repairs immediately, log an expense automatically
          await _db.into(_db.expenses).insert(
            ExpensesCompanion.insert(
              id: const Uuid().v4(),
              apartmentId: Value(apartmentId),
              expenseType: 'maintenance',
              amountEgp: ownerRepairCostEgp,
              expenseDate: inspectionDate,
              description: Value('إصلاح تلفيات بعد فحص الشقة: $damagesDescription'),
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

  Future<void> updateCleaningStatus(String inspectionId, String apartmentId, bool isClean) async {
    state = const AsyncLoading();
    try {
      await _db.transaction(() async {
        await (_db.update(_db.apartments)..where((t) => t.id.equals(apartmentId))).write(
          ApartmentsCompanion(
            cleaningStatus: Value(isClean ? 'clean' : 'needs_cleaning'),
            updatedAt: Value(DateTime.now()),
            syncStatus: const Value(SyncStatus.pendingUpdate),
          ),
        );
        
        await (_db.update(_db.apartmentInspections)..where((t) => t.id.equals(inspectionId))).write(
          ApartmentInspectionsCompanion(
            isClean: Value(isClean),
            updatedAt: Value(DateTime.now()),
            syncStatus: const Value(SyncStatus.pendingUpdate),
          ),
        );
      });
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
