import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import '../../../../core/database/database.dart';
import '../../../../core/database/tables.dart';
import '../../../../core/services/audit_log_service.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';

final techniciansProvider = StreamProvider<List<Technician>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.technicians).watch();
});

final techniciansControllerProvider =
    StateNotifierProvider<TechniciansController, AsyncValue<void>>((ref) {
      return TechniciansController(ref.watch(databaseProvider));
    });

class TechniciansController extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;
  late final AuditLogService _auditLog;

  TechniciansController(this._db) : super(const AsyncData(null)) {
    _auditLog = AuditLogService(_db);
  }

  Future<void> addTechnician({
    required String name,
    required String specialty,
    String? phone,
    String? secondaryPhone,
    String? notes,
  }) async {
    state = const AsyncLoading();
    try {
      final normalizedPhone = _normalizeEgyptianMobile(phone ?? '');
      final normalizedSecondary = _normalizeEgyptianMobile(secondaryPhone ?? '');
      final id = const Uuid().v4();
      await _db
          .into(_db.technicians)
          .insert(
            TechniciansCompanion.insert(
              id: id,
              name: name,
              specialty: specialty,
              phone: Value(normalizedPhone),
              secondaryPhone: Value(normalizedSecondary),
              notes: Value(notes),
              syncStatus: const Value(SyncStatus.pendingInsert),
              createdAt: DateTime.now(),
            ),
          );
      await _auditLog.log(
        action: 'create',
        entityType: 'technician',
        entityId: id,
        title: 'إضافة عامل/فني',
        description: 'تم إضافة $name - $specialty',
        route: '/technicians/details/$id',
        newValues: {
          'name': name,
          'specialty': specialty,
          'phone': normalizedPhone,
        },
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateTechnician(
    String id, {
    required String name,
    required String specialty,
    String? phone,
    String? secondaryPhone,
    String? notes,
  }) async {
    state = const AsyncLoading();
    try {
      final normalizedPhone = _normalizeEgyptianMobile(phone ?? '');
      final normalizedSecondary = _normalizeEgyptianMobile(secondaryPhone ?? '');
      final old = await (_db.select(
        _db.technicians,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      await (_db.update(_db.technicians)..where((t) => t.id.equals(id))).write(
        TechniciansCompanion(
          name: Value(name),
          specialty: Value(specialty),
          phone: Value(normalizedPhone),
          secondaryPhone: Value(normalizedSecondary),
          notes: Value(notes),
          syncStatus: const Value(SyncStatus.pendingUpdate),
        ),
      );
      await _auditLog.log(
        action: 'update',
        entityType: 'technician',
        entityId: id,
        title: 'تعديل عامل/فني',
        description: 'تم تعديل بيانات $name',
        route: '/technicians/details/$id',
        oldValues: old?.toJson(),
        newValues: {
          'name': name,
          'specialty': specialty,
          'phone': normalizedPhone,
          'notes': notes,
        },
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteTechnician(String id) async {
    state = const AsyncLoading();
    try {
      final old = await (_db.select(
        _db.technicians,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      await (_db.update(_db.technicians)..where((t) => t.id.equals(id))).write(
        const TechniciansCompanion(syncStatus: Value(SyncStatus.pendingDelete)),
      );
      await _auditLog.log(
        action: 'delete',
        entityType: 'technician',
        entityId: id,
        title: 'حذف عامل/فني',
        description: 'تم حذف ${old?.name ?? 'عامل/فني'}',
        oldValues: old?.toJson(),
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  String? _normalizeEgyptianMobile(String value) {
    final phone = value.trim();
    if (phone.isEmpty) return null;
    if (!RegExp(r'^01\d{9}$').hasMatch(phone)) {
      throw Exception('رقم الهاتف يجب أن يكون 11 رقم ويبدأ بـ 01');
    }
    return phone;
  }
}
