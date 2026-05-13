import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../database/database.dart';
import '../database/tables.dart';

class SyncEngine {
  final AppDatabase db;
  final SupabaseClient supabase;

  SyncEngine(this.db, this.supabase);

  Future<void> syncAll() async {
    // 1. Push local pending changes to Supabase
    await _pushLocalChanges();

    // 2. Pull remote changes from Supabase to local Drift DB
    await _pullRemoteChanges();
  }

  Future<void> _pushLocalChanges() async {
    // Example: Push Apartments with pending updates
    final pendingApartments = await (db.select(db.apartments)
          ..where((t) => t.syncStatus.equals(SyncStatus.pendingUpdate.index)))
        .get();

    for (final apt in pendingApartments) {
      try {
        await supabase.from('apartments').update({
          'cleaning_status': apt.cleaningStatus,
          'broker_visibility': apt.brokerVisibility,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        }).eq('id', apt.id);

        // Mark as synced locally
        await (db.update(db.apartments)..where((t) => t.id.equals(apt.id))).write(
          const ApartmentsCompanion(syncStatus: Value(SyncStatus.synced)),
        );
      } catch (e) {
        // Log conflict or error
        // print('Error syncing apartment ${apt.id}: $e');
      }
    }
  }

  Future<void> _pullRemoteChanges() async {
    try {
      // Sync Buildings
      final buildingsData = await supabase.from('buildings').select();
      for (final row in buildingsData) {
        await db.into(db.buildings).insertOnConflictUpdate(
              BuildingsCompanion(
                id: Value(row['id']),
                name: Value(row['name']),
                address: Value(row['address'] as String?),
                totalApartments: Value(row['total_apartments']),
                createdAt: Value(DateTime.parse(row['created_at'])),
                syncStatus: const Value(SyncStatus.synced),
              ),
            );
      }

      // Sync Apartments
      final apartmentsData = await supabase.from('apartments').select();
      for (final row in apartmentsData) {
        await db.into(db.apartments).insertOnConflictUpdate(
              ApartmentsCompanion(
                id: Value(row['id']),
                buildingId: Value(row['building_id']),
                apartmentNumber: Value(row['apartment_number']),
                floorNumber: Value(row['floor_number'] as int?),
                cleaningStatus: Value(row['cleaning_status']),
                brokerVisibility: Value(row['broker_visibility']),
                createdAt: Value(DateTime.parse(row['created_at'])),
                updatedAt: Value(DateTime.parse(row['updated_at'])),
                syncStatus: const Value(SyncStatus.synced),
              ),
            );
      }
    } catch (e) {
      // print('Error pulling remote changes: $e');
      rethrow;
    }
  }
}
