import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database.dart';
import '../../../../core/database/tables.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final brokersProvider = StreamProvider<List<UserProfile>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(
    db.userProfiles,
  )..where((t) => t.role.equals('broker'))).watch();
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
      final updatedRows = await (_db.update(_db.userProfiles)..where((t) => t.id.equals(id))).write(
        UserProfilesCompanion(
          fullName: Value(trimmedName),
          updatedAt: Value(DateTime.now()),
          syncStatus: const Value(SyncStatus.pendingUpdate),
        ),
      );

      if (updatedRows == 0) {
        final user = Supabase.instance.client.auth.currentUser;
        await _db.into(_db.userProfiles).insert(
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

  BrokersController(this._db) : super(const AsyncData(null));

  Future<void> addBroker({
    required String fullName,
    required String phoneNumber,
  }) async {
    state = const AsyncLoading();
    try {
      final id = const Uuid().v4();
      final now = DateTime.now();
      await _db
          .into(_db.userProfiles)
          .insert(
            UserProfilesCompanion.insert(
              id: id,
              email: 'broker-$id@local.abrag',
              fullName: Value(fullName.trim()),
              phoneNumber: Value(
                phoneNumber.trim().isEmpty ? null : phoneNumber.trim(),
              ),
              role: const Value('broker'),
              createdAt: now,
              updatedAt: now,
              syncStatus: const Value(SyncStatus.pendingInsert),
            ),
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
  }) async {
    state = const AsyncLoading();
    try {
      final now = DateTime.now();
      await (_db.update(_db.userProfiles)..where((t) => t.id.equals(id))).write(
        UserProfilesCompanion(
          fullName: Value(fullName.trim()),
          phoneNumber: Value(
            phoneNumber.trim().isEmpty ? null : phoneNumber.trim(),
          ),
          updatedAt: Value(now),
          syncStatus: const Value(SyncStatus.pendingUpdate),
        ),
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
