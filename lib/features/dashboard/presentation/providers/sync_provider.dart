import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/sync/sync_engine.dart';
import 'database_provider.dart';

final syncEngineProvider = Provider<SyncEngine>((ref) {
  final db = ref.watch(databaseProvider);
  return SyncEngine(db, Supabase.instance.client);
});

final syncControllerProvider = StateNotifierProvider<SyncController, AsyncValue<void>>((ref) {
  return SyncController(ref.watch(syncEngineProvider));
});

class SyncController extends StateNotifier<AsyncValue<void>> {
  final SyncEngine _syncEngine;

  SyncController(this._syncEngine) : super(const AsyncData(null));

  Future<void> syncData() async {
    state = const AsyncLoading();
    try {
      await _syncEngine.syncAll();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

// Stats providers for dashboard
final buildingsCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.buildings).watch().map((list) => list.length);
});

final apartmentsCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.apartments).watch().map((list) => list.length);
});
