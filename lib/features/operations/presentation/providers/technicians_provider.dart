import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import '../../../../core/database/database.dart';
import '../../../../core/database/tables.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';

final techniciansProvider = StreamProvider<List<Technician>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.technicians).watch();
});

final techniciansControllerProvider = StateNotifierProvider<TechniciansController, AsyncValue<void>>((ref) {
  return TechniciansController(ref.watch(databaseProvider));
});

class TechniciansController extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;

  TechniciansController(this._db) : super(const AsyncData(null));

  Future<void> addTechnician({
    required String name,
    required String specialty,
    String? phone,
    String? notes,
  }) async {
    state = const AsyncLoading();
    try {
      final id = const Uuid().v4();
      await _db.into(_db.technicians).insert(
        TechniciansCompanion.insert(
          id: id,
          name: name,
          specialty: specialty,
          phone: Value(phone),
          notes: Value(notes),
          syncStatus: const Value(SyncStatus.pendingInsert),
          createdAt: DateTime.now(),
        ),
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateTechnician(String id, {
    required String name,
    required String specialty,
    String? phone,
    String? notes,
  }) async {
    state = const AsyncLoading();
    try {
      await (_db.update(_db.technicians)..where((t) => t.id.equals(id))).write(
        TechniciansCompanion(
          name: Value(name),
          specialty: Value(specialty),
          phone: Value(phone),
          notes: Value(notes),
          syncStatus: const Value(SyncStatus.pendingUpdate),
        ),
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteTechnician(String id) async {
    state = const AsyncLoading();
    try {
      await (_db.update(_db.technicians)..where((t) => t.id.equals(id))).write(
        const TechniciansCompanion(
          syncStatus: Value(SyncStatus.pendingDelete),
        ),
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
