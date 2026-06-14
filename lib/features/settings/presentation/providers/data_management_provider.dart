import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/app_settings_provider.dart';
import '../../../../core/database/database.dart';
import '../../../../core/database/tables.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';

final dataManagementProvider = Provider<DataManagementService>((ref) {
  return DataManagementService(
    ref.watch(databaseProvider),
    Supabase.instance.client,
  );
});

class DataManagementService {
  final AppDatabase _db;
  final SupabaseClient _supabase;

  DataManagementService(this._db, this._supabase);

  Future<File> exportAllData() async {
    final data = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'buildings': (await _db.select(_db.buildings).get())
          .map((e) => e.toJson())
          .toList(),
      'apartments': (await _db.select(_db.apartments).get())
          .map((e) => e.toJson())
          .toList(),
      'summerBookings': (await _db.select(_db.summerBookings).get())
          .map((e) => e.toJson())
          .toList(),
      'winterContracts': (await _db.select(_db.winterContracts).get())
          .map((e) => e.toJson())
          .toList(),
      'winterPayments': (await _db.select(_db.winterPayments).get())
          .map((e) => e.toJson())
          .toList(),
      'expenses': (await _db.select(_db.expenses).get())
          .map((e) => e.toJson())
          .toList(),
      'technicians': (await _db.select(_db.technicians).get())
          .map((e) => e.toJson())
          .toList(),
      'cleaningSupplies': (await _db.select(_db.cleaningSupplies).get())
          .map((e) => e.toJson())
          .toList(),
      'cleaningTransactions': (await _db.select(_db.cleaningTransactions).get())
          .map((e) => e.toJson())
          .toList(),
      'apartmentInspections': (await _db.select(_db.apartmentInspections).get())
          .map((e) => e.toJson())
          .toList(),
      'maintenanceRequests': (await _db.select(_db.maintenanceRequests).get())
          .map((e) => e.toJson())
          .toList(),
      'userProfiles': (await _db.select(_db.userProfiles).get())
          .map((e) => e.toJson())
          .toList(),
    };
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      '${dir.path}/abrag_backup_${DateTime.now().millisecondsSinceEpoch}.json',
    );
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
    return file;
  }

  Future<void> shareExport(File file) async {
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
  }

  Future<void> importDataFromPickedFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    final path = result?.files.single.path;
    if (path == null) return;
    final jsonMap =
        jsonDecode(await File(path).readAsString()) as Map<String, dynamic>;
    await _db.transaction(() async {
      await _importCustomersAsUserProfiles(jsonMap['customers']);
      await _importSummerBookings(jsonMap['summerBookings']);
      await _importWinterContracts(jsonMap['winterContracts']);
    });
  }

  Future<void> clearAllDataWithPassword(String password) async {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email;
    if (email == null) throw Exception('لا يوجد إيميل مسجل للدخول');
    await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    await _deleteServerData();
    await _deleteLocalData();
  }

  Future<void> _deleteServerData() async {
    // Single admin-guarded server function (see
    // supabase/09_reset_app_data_function.sql). Replaces the previous
    // per-table client deletes, which RLS silently turned into no-ops for
    // non-admins. The RPC is atomic and raises if the caller isn't an admin,
    // so the UI surfaces a real error instead of a false success.
    await _supabase.rpc('reset_app_data');
  }

  Future<void> _deleteLocalData() async {
    await _db.transaction(() async {
      await _db.delete(_db.auditLogs).go();
      await _db.delete(_db.maintenanceRequests).go();
      await _db.delete(_db.apartmentInspections).go();
      await _db.delete(_db.cleaningTransactions).go();
      await _db.delete(_db.cleaningSupplies).go();
      await _db.delete(_db.technicians).go();
      await _db.delete(_db.financialTransfers).go();
      await _db.delete(_db.expenses).go();
      await _db.delete(_db.meterReadings).go();
      await _db.delete(_db.winterPayments).go();
      await _db.delete(_db.winterContracts).go();
      await _db.delete(_db.summerBookings).go();
      await _db.delete(_db.apartments).go();
      // Keep the app settings/permissions row (__ABRAG_SETTINGS__).
      await (_db.delete(
        _db.buildings,
      )..where((t) => t.id.isNotValue(kSettingsBuildingId))).go();
    });
  }

  Future<void> cleanupInvalidPendingUsers() async {
    final invalidUsers =
        await (_db.select(_db.userProfiles)..where(
              (t) => t.id.like('pending-user-%') | t.id.like('pending user-%'),
            ))
            .get();

    for (final user in invalidUsers) {
      await (_db.delete(
        _db.userProfiles,
      )..where((t) => t.id.equals(user.id))).go();
    }
  }

  Future<void> _importCustomersAsUserProfiles(dynamic customers) async {
    if (customers is! List) return;
    for (final item in customers) {
      if (item is! Map) continue;
      final name = item['name']?.toString().trim() ?? '';
      if (name.isEmpty) continue;
      final id = item['id']?.toString().trim().isNotEmpty == true
          ? item['id'].toString()
          : 'imported-${DateTime.now().microsecondsSinceEpoch}';
      await _db
          .into(_db.userProfiles)
          .insertOnConflictUpdate(
            UserProfilesCompanion.insert(
              id: id,
              email: item['email']?.toString() ?? '$id@imported.local',
              fullName: Value(name),
              phoneNumber: Value(item['phone']?.toString()),
              role: const Value('viewer'),
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              syncStatus: const Value(SyncStatus.pendingInsert),
            ),
          );
    }
  }

  Future<void> _importSummerBookings(dynamic bookings) async {
    // Full structured backup import can be expanded later safely.
    if (bookings is! List) return;
  }

  Future<void> _importWinterContracts(dynamic contracts) async {
    if (contracts is! List) return;
  }
}
