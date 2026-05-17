import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../database/database.dart';
import '../database/tables.dart';

class AuditLogService {
  final AppDatabase _db;

  AuditLogService(this._db);

  Future<void> log({
    required String action,
    required String entityType,
    String? entityId,
    required String title,
    required String description,
    String? route,
    Map<String, dynamic>? oldValues,
    Map<String, dynamic>? newValues,
  }) async {
    User? user;
    try {
      user = Supabase.instance.client.auth.currentUser;
    } catch (_) {
      user = null;
    }
    final actorName = await _actorName(user);
    await _db
        .into(_db.auditLogs)
        .insert(
          AuditLogsCompanion.insert(
            id: const Uuid().v4(),
            actorUserId: Value(user?.id),
            actorName: actorName,
            action: action,
            entityType: entityType,
            entityId: Value(entityId),
            title: title,
            description: description,
            route: Value(route),
            oldValuesJson: Value(_encode(oldValues)),
            newValuesJson: Value(_encode(newValues)),
            createdAt: DateTime.now(),
            syncStatus: const Value(SyncStatus.pendingInsert),
          ),
        );
  }

  Future<String> _actorName(User? user) async {
    if (user == null) return 'مستخدم النظام';
    try {
      final profile = await (_db.select(
        _db.userProfiles,
      )..where((table) => table.id.equals(user.id))).getSingleOrNull();
      final fullName = profile?.fullName?.trim();
      if (fullName != null && fullName.isNotEmpty) return fullName;
      return profile?.email ?? user.email ?? 'مستخدم النظام';
    } catch (_) {
      return user.email ?? 'مستخدم النظام';
    }
  }

  String? _encode(Map<String, dynamic>? values) {
    if (values == null || values.isEmpty) return null;
    return jsonEncode(
      values.map((key, value) => MapEntry(key, value?.toString())),
    );
  }
}
