import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../../features/dashboard/presentation/providers/database_provider.dart';
import '../database/database.dart';
import '../database/tables.dart';
import '../services/audit_log_service.dart';

const kSettingsBuildingId = 'ffffffff-ffff-ffff-ffff-ffffffffffff';
const kSettingsBuildingName = '__ABRAG_SETTINGS__';

final appSettingsProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.buildings)
        ..where((t) => t.id.equals(kSettingsBuildingId)))
      .watchSingleOrNull()
      .map((b) {
        if (b == null || b.address == null || b.address!.isEmpty) return {};
        try {
          return jsonDecode(b.address!) as Map<String, dynamic>;
        } catch (_) {
          return {};
        }
      });
});

final appSettingsControllerProvider = Provider(
  (ref) => AppSettingsController(ref.watch(databaseProvider)),
);

class AppSettingsController {
  final AppDatabase _db;
  late final AuditLogService _auditLog;

  AppSettingsController(this._db) {
    _auditLog = AuditLogService(_db);
  }

  Future<void> updateSettings(Map<String, dynamic> newSettings) async {
    final b = await (_db.select(
      _db.buildings,
    )..where((t) => t.id.equals(kSettingsBuildingId))).getSingleOrNull();
    final jsonStr = jsonEncode(newSettings);
    if (b == null) {
      await _db
          .into(_db.buildings)
          .insert(
            BuildingsCompanion.insert(
              id: kSettingsBuildingId,
              name: kSettingsBuildingName,
              address: Value(jsonStr),
              totalApartments: const Value(0),
              createdAt: DateTime.now(),
              syncStatus: const Value(SyncStatus.pendingInsert),
            ),
          );
    } else {
      await (_db.update(
        _db.buildings,
      )..where((t) => t.id.equals(kSettingsBuildingId))).write(
        BuildingsCompanion(
          address: Value(jsonStr),
          syncStatus: const Value(SyncStatus.pendingUpdate),
        ),
      );
    }
    await _auditLog.log(
      action: 'update',
      entityType: 'settings',
      entityId: kSettingsBuildingId,
      title: 'تعديل الإعدادات',
      description: 'تم تعديل إعدادات التطبيق',
      route: '/settings',
      oldValues: b?.address == null
          ? null
          : jsonDecode(b!.address!) as Map<String, dynamic>?,
      newValues: newSettings,
    );
  }
}
