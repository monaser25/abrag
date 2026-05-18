import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import '../../../../core/sync/sync_engine.dart';
import '../../../../core/services/notification_service.dart';
import 'database_provider.dart';

final syncEngineProvider = Provider<SyncEngine>((ref) {
  final db = ref.watch(databaseProvider);
  return SyncEngine(db, Supabase.instance.client);
});

final syncControllerProvider =
    StateNotifierProvider<SyncController, AsyncValue<void>>((ref) {
      return SyncController(ref.watch(syncEngineProvider), ref);
    });

final lastSuccessfulSyncProvider = StateProvider<DateTime?>((ref) => null);

class SyncController extends StateNotifier<AsyncValue<void>> {
  final SyncEngine _syncEngine;
  final Ref _ref;
  RealtimeChannel? _realtimeChannel;
  Timer? _realtimeDebounceTimer;
  Timer? _periodicSyncTimer;
  bool _isSyncing = false;

  SyncController(this._syncEngine, this._ref) : super(const AsyncData(null)) {
    syncData();
    _periodicSyncTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) syncData();
    });
    _initRealtime();
  }

  void _initRealtime() {
    _realtimeChannel = Supabase.instance.client
        .channel('public:all')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          callback: (payload) {
            if (payload.table == 'audit_logs' &&
                payload.eventType == PostgresChangeEvent.insert) {
              final newRecord = payload.newRecord;
              final actorId = newRecord['actor_user_id'];
              final currentUser = Supabase.instance.client.auth.currentUser;
              if (currentUser != null && actorId != currentUser.id) {
                NotificationService.showNotification(
                  id: DateTime.now().millisecond,
                  title: newRecord['title']?.toString() ?? 'إشعار جديد',
                  body:
                      newRecord['description']?.toString() ??
                      'تم إضافة تحديث جديد في النظام',
                );
              }
            }

            _realtimeDebounceTimer?.cancel();
            _realtimeDebounceTimer = Timer(const Duration(seconds: 2), () {
              if (mounted) {
                syncData();
              }
            });
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    _realtimeDebounceTimer?.cancel();
    _periodicSyncTimer?.cancel();
    _realtimeChannel?.unsubscribe();
    super.dispose();
  }

  Future<void> syncData() async {
    if (_isSyncing) return;
    _isSyncing = true;
    state = const AsyncLoading();
    try {
      await _syncEngine.syncAll();
      _ref.read(lastSuccessfulSyncProvider.notifier).state = DateTime.now();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    } finally {
      _isSyncing = false;
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
