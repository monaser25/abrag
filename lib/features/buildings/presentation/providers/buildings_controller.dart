import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database.dart';
import '../../../../core/database/tables.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';

final buildingsProvider = StreamProvider<List<Building>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.buildings).watch();
});

final buildingsControllerProvider = StateNotifierProvider<BuildingsController, AsyncValue<void>>((ref) {
  return BuildingsController(ref.watch(databaseProvider));
});

class BuildingsController extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;
  
  BuildingsController(this._db) : super(const AsyncData(null));

  Future<void> addBuilding(String name, String address, int totalApartments) async {
    state = const AsyncLoading();
    try {
      final id = const Uuid().v4();
      await _db.into(_db.buildings).insert(
        BuildingsCompanion.insert(
          id: id,
          name: name,
          address: Value(address),
          totalApartments: Value(totalApartments),
          syncStatus: const Value(SyncStatus.pendingInsert),
          createdAt: DateTime.now(),
        ),
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateBuilding(String id, String name, String address, int totalApartments) async {
    state = const AsyncLoading();
    try {
      await (_db.update(_db.buildings)..where((t) => t.id.equals(id))).write(
        BuildingsCompanion(
          name: Value(name),
          address: Value(address),
          totalApartments: Value(totalApartments),
          syncStatus: const Value(SyncStatus.pendingUpdate),
        ),
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateRentSettings(String buildingId, double annualRent, String installmentsDates) async {
    state = const AsyncLoading();
    try {
      await (_db.update(_db.buildings)..where((t) => t.id.equals(buildingId))).write(
        BuildingsCompanion(
          annualRentEgp: Value(annualRent),
          rentInstallmentsDates: Value(installmentsDates),
          syncStatus: const Value(SyncStatus.pendingUpdate),
        ),
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
