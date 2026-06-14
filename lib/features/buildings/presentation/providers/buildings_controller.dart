import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database.dart';
import '../../../../core/database/tables.dart';
import '../../../../core/services/audit_log_service.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';

final buildingsProvider = StreamProvider<List<Building>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.buildings)..where((t) => t.id.isNotValue('ffffffff-ffff-ffff-ffff-ffffffffffff'))).watch();
});

final buildingsControllerProvider = StateNotifierProvider<BuildingsController, AsyncValue<void>>((ref) {
  return BuildingsController(ref.watch(databaseProvider));
});

class BuildingsController extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;
  late final AuditLogService _auditLog;

  BuildingsController(this._db) : super(const AsyncData(null)) {
    _auditLog = AuditLogService(_db);
  }

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

  /// Deletes a building only when nothing references it. Mirrors
  /// [ApartmentsController.deleteApartment]: refuse (don't cascade) when the
  /// building still has apartments, meter readings, or expenses, since those
  /// tables carry a `buildingId` FK and deleting would orphan their records.
  Future<void> deleteBuilding(String id) async {
    state = const AsyncLoading();
    try {
      final apartments = await (_db.select(_db.apartments)
            ..where((t) => t.buildingId.equals(id)))
          .get();
      final meterReadings = await (_db.select(_db.meterReadings)
            ..where((t) => t.buildingId.equals(id)))
          .get();
      final expenses = await (_db.select(_db.expenses)
            ..where((t) => t.buildingId.equals(id)))
          .get();
      if (apartments.isNotEmpty ||
          meterReadings.isNotEmpty ||
          expenses.isNotEmpty) {
        throw Exception(
          'مينفعش حذف المبنى لأنه مرتبط بشقق أو قراءات عدادات أو مصروفات. احذف المرتبط بيه الأول أو عدّل بياناته.',
        );
      }
      await (_db.delete(_db.buildings)..where((t) => t.id.equals(id))).go();
      await _auditLog.log(
        action: 'delete',
        entityType: 'building',
        entityId: id,
        title: 'حذف مبنى',
        description: 'تم حذف مبنى لا يحتوي على شقق أو سجلات مرتبطة',
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
