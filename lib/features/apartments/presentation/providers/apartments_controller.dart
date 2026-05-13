import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database.dart';
import '../../../../core/database/tables.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';

final apartmentsProvider = StreamProvider<List<Apartment>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.apartments).watch();
});

final apartmentsControllerProvider = StateNotifierProvider<ApartmentsController, AsyncValue<void>>((ref) {
  return ApartmentsController(ref.watch(databaseProvider));
});

class ApartmentsController extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;
  
  ApartmentsController(this._db) : super(const AsyncData(null));

  Future<void> addApartment(String buildingId, String apartmentNumber, int floorNumber) async {
    state = const AsyncLoading();
    try {
      final id = const Uuid().v4();
      await _db.into(_db.apartments).insert(
        ApartmentsCompanion.insert(
          id: id,
          buildingId: buildingId,
          apartmentNumber: apartmentNumber,
          floorNumber: Value(floorNumber),
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
