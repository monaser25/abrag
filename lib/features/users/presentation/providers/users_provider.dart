import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database.dart';
import '../../../../core/database/tables.dart';
import '../../../../core/services/audit_log_service.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final brokersProvider = StreamProvider<List<UserProfile>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.userProfiles)..where(
        (t) =>
            t.role.equals('broker') &
            t.syncStatus.isNotIn([SyncStatus.pendingDelete.index]),
      ))
      .watch();
});

final currentUserProfileProvider = StreamProvider<UserProfile?>((ref) {
  final authState = ref.watch(authStateProvider);
  final db = ref.watch(databaseProvider);
  final user = authState.value?.session?.user;

  if (user == null) {
    return Stream.value(null);
  }

  return (db.select(
    db.userProfiles,
  )..where((t) => t.id.equals(user.id))).watchSingleOrNull();
});

final currentUserRoleProvider = StreamProvider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  final db = ref.watch(databaseProvider);
  final user = authState.value?.session?.user;

  if (user == null) {
    return Stream.value(null);
  }

  return (db.select(db.userProfiles)..where((t) => t.id.equals(user.id)))
      .watchSingleOrNull()
      .map((p) => p?.role);
});

final brokersControllerProvider =
    StateNotifierProvider<BrokersController, AsyncValue<void>>((ref) {
      return BrokersController(ref.watch(databaseProvider));
    });

final userProfileControllerProvider =
    StateNotifierProvider<UserProfileController, AsyncValue<void>>((ref) {
      return UserProfileController(ref.watch(databaseProvider));
    });

class UserProfileController extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;

  UserProfileController(this._db) : super(const AsyncData(null));

  Future<void> updateName({
    required String id,
    required String fullName,
  }) async {
    state = const AsyncLoading();
    try {
      final trimmedName = fullName.trim();
      final updatedRows =
          await (_db.update(
            _db.userProfiles,
          )..where((t) => t.id.equals(id))).write(
            UserProfilesCompanion(
              fullName: Value(trimmedName),
              updatedAt: Value(DateTime.now()),
              syncStatus: const Value(SyncStatus.pendingUpdate),
            ),
          );

      if (updatedRows == 0) {
        final user = Supabase.instance.client.auth.currentUser;
        await _db
            .into(_db.userProfiles)
            .insert(
              UserProfilesCompanion.insert(
                id: id,
                email: user?.email ?? 'user-$id@local.abrag',
                fullName: Value(trimmedName),
                role: const Value('admin'),
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                syncStatus: const Value(SyncStatus.pendingInsert),
              ),
            );
      }
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

class BrokersController extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;
  late final AuditLogService _auditLog;

  BrokersController(this._db) : super(const AsyncData(null)) {
    _auditLog = AuditLogService(_db);
  }

  /// Insert a new broker (userProfiles, role='broker') and return its id.
  /// Shared by [addBroker] and [findOrCreateBrokerByName].
  Future<String> _insertBroker({
    required String fullName,
    String? phoneNumber,
    String? secondaryPhone,
  }) async {
    final normalizedPhone = _normalizeEgyptianMobile(phoneNumber ?? '');
    final normalizedSecondary = _normalizeEgyptianMobile(secondaryPhone ?? '');
    final id = const Uuid().v4();
    final now = DateTime.now();
    await _db
        .into(_db.userProfiles)
        .insert(
          UserProfilesCompanion.insert(
            id: id,
            email: 'broker-$id@local.abrag',
            fullName: Value(fullName.trim()),
            phoneNumber: Value(normalizedPhone),
            secondaryPhone: Value(normalizedSecondary),
            role: const Value('broker'),
            createdAt: now,
            updatedAt: now,
            syncStatus: const Value(SyncStatus.pendingInsert),
          ),
        );
    await _auditLog.log(
      action: 'create',
      entityType: 'broker',
      entityId: id,
      title: 'إضافة سمسار',
      description: 'تم إضافة سمسار باسم ${fullName.trim()}',
      route: '/brokers/details/$id',
      newValues: {'fullName': fullName.trim(), 'phoneNumber': normalizedPhone},
    );
    return id;
  }

  /// Returns the id of an existing broker whose name matches (case-insensitive),
  /// otherwise creates a new broker with that name and returns its id. Used when
  /// a booking references a broker typed via the "other" option (#12).
  Future<String> findOrCreateBrokerByName(String name) async {
    final trimmedName = name.trim();
    final existingList =
        await (_db.select(_db.userProfiles)..where(
              (t) =>
                  t.role.equals('broker') &
                  t.syncStatus.isNotIn([SyncStatus.pendingDelete.index]),
            ))
            .get();
    for (final b in existingList) {
      if ((b.fullName ?? '').trim().toLowerCase() ==
          trimmedName.toLowerCase()) {
        return b.id;
      }
    }
    return _insertBroker(fullName: trimmedName);
  }

  Future<void> addBroker({
    required String fullName,
    required String phoneNumber,
    String? secondaryPhone,
  }) async {
    state = const AsyncLoading();
    try {
      await _insertBroker(
        fullName: fullName,
        phoneNumber: phoneNumber,
        secondaryPhone: secondaryPhone,
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateBroker({
    required String id,
    required String fullName,
    required String phoneNumber,
    String? secondaryPhone,
  }) async {
    state = const AsyncLoading();
    try {
      final normalizedPhone = _normalizeEgyptianMobile(phoneNumber);
      final normalizedSecondary = _normalizeEgyptianMobile(
        secondaryPhone ?? '',
      );
      final old = await (_db.select(
        _db.userProfiles,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      final now = DateTime.now();
      await (_db.update(_db.userProfiles)..where((t) => t.id.equals(id))).write(
        UserProfilesCompanion(
          fullName: Value(fullName.trim()),
          phoneNumber: Value(normalizedPhone),
          secondaryPhone: Value(normalizedSecondary),
          updatedAt: Value(now),
          syncStatus: const Value(SyncStatus.pendingUpdate),
        ),
      );
      await _auditLog.log(
        action: 'update',
        entityType: 'broker',
        entityId: id,
        title: 'تعديل سمسار',
        description: 'تم تعديل بيانات سمسار ${fullName.trim()}',
        route: '/brokers/details/$id',
        oldValues: old?.toJson(),
        newValues: {
          'fullName': fullName.trim(),
          'phoneNumber': normalizedPhone,
        },
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteBroker(String id) async {
    state = const AsyncLoading();
    try {
      final old = await (_db.select(
        _db.userProfiles,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      // Soft-delete; the sync engine pushes this as a server delete. Past
      // bookings keep their denormalized broker_name, so history is preserved.
      await (_db.update(_db.userProfiles)..where((t) => t.id.equals(id))).write(
        const UserProfilesCompanion(
          syncStatus: Value(SyncStatus.pendingDelete),
        ),
      );
      await _auditLog.log(
        action: 'delete',
        entityType: 'broker',
        entityId: id,
        title: 'حذف سمسار',
        description: 'تم حذف سمسار ${old?.fullName ?? old?.email ?? ''}',
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
      throw Exception('رقم التليفون يجب أن يكون 11 رقم ويبدأ بـ 01');
    }
    return phone;
  }
}
