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

        // If the owner paid for repairs, log an expense automatically
        if (ownerRepairCostEgp > 0) {
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
        
        // Note: If the tenant paid a fine (tenantFineEgp), this usually goes into income.
        // In the current schema, we don't have a specific income table other than rents,
        // but it's recorded in the inspection. You might want to add an Income table later.
      });

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
