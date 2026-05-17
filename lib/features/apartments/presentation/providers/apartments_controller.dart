import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database.dart';
import '../../../../core/database/tables.dart';
import '../../../../core/services/audit_log_service.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';
import 'apartment_occupancy_rules_provider.dart';

final apartmentsProvider = StreamProvider<List<Apartment>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.apartments).watch();
});

final apartmentsControllerProvider =
    StateNotifierProvider<ApartmentsController, AsyncValue<void>>((ref) {
      return ApartmentsController(
        ref.watch(databaseProvider),
        ref.watch(apartmentOccupancyRulesProvider),
      );
    });

class ApartmentsController extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;
  final ApartmentOccupancyRules _occupancyRules;
  late final AuditLogService _auditLog;

  ApartmentsController(this._db, this._occupancyRules)
    : super(const AsyncData(null)) {
    _auditLog = AuditLogService(_db);
  }

  Future<void> addApartment(
    String buildingId,
    String apartmentNumber,
    int floorNumber, {
    String? inventory,
    String? landlineNumber,
    String? landlineOwnerName,
    String? landlineNotes,
  }) async {
    state = const AsyncLoading();
    try {
      final id = const Uuid().v4();
      await _db
          .into(_db.apartments)
          .insert(
            ApartmentsCompanion.insert(
              id: id,
              buildingId: buildingId,
              apartmentNumber: apartmentNumber,
              floorNumber: Value(floorNumber),
              inventory: Value(inventory),
              landlineNumber: Value(landlineNumber),
              landlineOwnerName: Value(landlineOwnerName),
              landlineNotes: Value(landlineNotes),
              syncStatus: const Value(SyncStatus.pendingInsert),
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
      await _auditLog.log(
        action: 'create',
        entityType: 'apartment',
        entityId: id,
        title: 'إضافة شقة',
        description: 'تم إضافة شقة $apartmentNumber',
        route: '/apartments/profile/$id',
        newValues: {
          'apartmentNumber': apartmentNumber,
          'floorNumber': floorNumber,
          'landlineNumber': landlineNumber,
        },
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateLandline({
    required String id,
    required String landlineNumber,
    required String ownerName,
    required String notes,
  }) async {
    state = const AsyncLoading();
    try {
      await (_db.update(_db.apartments)..where((t) => t.id.equals(id))).write(
        ApartmentsCompanion(
          landlineNumber: Value(
            landlineNumber.trim().isEmpty ? null : landlineNumber.trim(),
          ),
          landlineOwnerName: Value(
            ownerName.trim().isEmpty ? null : ownerName.trim(),
          ),
          landlineNotes: Value(notes.trim().isEmpty ? null : notes.trim()),
          syncStatus: const Value(SyncStatus.pendingUpdate),
          updatedAt: Value(DateTime.now()),
        ),
      );
      await _auditLog.log(
        action: 'update_landline',
        entityType: 'apartment',
        entityId: id,
        title: 'تعديل الخط الأرضي',
        description: 'تم تعديل بيانات الخط الأرضي',
        route: '/apartments/profile/$id',
        newValues: {
          'landlineNumber': landlineNumber,
          'ownerName': ownerName,
          'notes': notes,
        },
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateApartment({
    required String id,
    required String buildingId,
    required String apartmentNumber,
    int? floorNumber,
    String? inventory,
    String? landlineNumber,
    String? landlineOwnerName,
    String? landlineNotes,
  }) async {
    state = const AsyncLoading();
    try {
      await (_db.update(_db.apartments)..where((t) => t.id.equals(id))).write(
        ApartmentsCompanion(
          buildingId: Value(buildingId),
          apartmentNumber: Value(apartmentNumber),
          floorNumber: Value(floorNumber),
          inventory: Value(inventory),
          landlineNumber: Value(landlineNumber),
          landlineOwnerName: Value(landlineOwnerName),
          landlineNotes: Value(landlineNotes),
          syncStatus: const Value(SyncStatus.pendingUpdate),
          updatedAt: Value(DateTime.now()),
        ),
      );
      await _auditLog.log(
        action: 'update',
        entityType: 'apartment',
        entityId: id,
        title: 'تعديل شقة',
        description: 'تم تعديل بيانات شقة $apartmentNumber',
        route: '/apartments/profile/$id',
        newValues: {
          'buildingId': buildingId,
          'apartmentNumber': apartmentNumber,
          'floorNumber': floorNumber,
          'landlineNumber': landlineNumber,
        },
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteApartment(String id) async {
    state = const AsyncLoading();
    try {
      final hasSummerBookings = await (_db.select(_db.summerBookings)
            ..where((t) => t.apartmentId.equals(id)))
          .get();
      final hasWinterContracts = await (_db.select(_db.winterContracts)
            ..where((t) => t.apartmentId.equals(id)))
          .get();
      if (hasSummerBookings.isNotEmpty || hasWinterContracts.isNotEmpty) {
        throw Exception(
          'مينفعش حذف الشقة لأن عليها حجوزات أو عقود. ممكن تعديل بياناتها بدل الحذف.',
        );
      }
      await (_db.delete(_db.apartments)..where((t) => t.id.equals(id))).go();
      await _auditLog.log(
        action: 'delete',
        entityType: 'apartment',
        entityId: id,
        title: 'حذف شقة',
        description: 'تم حذف شقة لا تحتوي على حجوزات أو عقود',
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateInventory(String id, String inventory) async {
    state = const AsyncLoading();
    try {
      await (_db.update(_db.apartments)..where((t) => t.id.equals(id))).write(
        ApartmentsCompanion(
          inventory: Value(inventory),
          syncStatus: const Value(SyncStatus.pendingUpdate),
          updatedAt: Value(DateTime.now()),
        ),
      );
      await _auditLog.log(
        action: 'update_inventory',
        entityType: 'apartment',
        entityId: id,
        title: 'تعديل جرد شقة',
        description: 'تم تعديل جرد الشقة',
        route: '/apartments/profile/$id',
        newValues: {'inventory': inventory},
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  String _mergeInventory(String oldInv, String newInv) {
    if (oldInv.trim().isEmpty) return newInv;
    if (newInv.trim().isEmpty) return oldInv;

    final isNewFormat1 = oldInv.contains('\n') || oldInv.contains(':');
    final separator1 = isNewFormat1 ? '\n' : ',';
    final oldItems = oldInv
        .split(separator1)
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final isNewFormat2 = newInv.contains('\n') || newInv.contains(':');
    final separator2 = isNewFormat2 ? '\n' : ',';
    final newItems = newInv
        .split(separator2)
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final groups = <String, Set<String>>{};
    String currentGroup = '';

    void processItems(List<String> items) {
      for (final item in items) {
        if (item.endsWith(':')) {
          currentGroup = item;
          groups.putIfAbsent(currentGroup, () => {});
        } else {
          groups.putIfAbsent(currentGroup, () => {});
          groups[currentGroup]!.add(item);
        }
      }
    }

    processItems(oldItems);
    currentGroup = ''; // Reset for new items
    processItems(newItems);

    final result = <String>[];
    for (final entry in groups.entries) {
      if (entry.key.isNotEmpty) {
        if (result.isNotEmpty) result.add('');
        result.add(entry.key);
      }
      result.addAll(entry.value);
    }

    return result.join('\n');
  }

  Future<void> applyInventoryToApartments(
    List<String> apartmentIds,
    String inventory, {
    bool append = false,
  }) async {
    state = const AsyncLoading();
    try {
      await _db.transaction(() async {
        for (final id in apartmentIds) {
          String finalInventory = inventory;
          if (append) {
            final apt = await (_db.select(
              _db.apartments,
            )..where((t) => t.id.equals(id))).getSingle();
            if (apt.inventory != null && apt.inventory!.trim().isNotEmpty) {
              finalInventory = _mergeInventory(apt.inventory!, inventory);
            }
          }
          await (_db.update(
            _db.apartments,
          )..where((t) => t.id.equals(id))).write(
            ApartmentsCompanion(
              inventory: Value(finalInventory),
              syncStatus: const Value(SyncStatus.pendingUpdate),
              updatedAt: Value(DateTime.now()),
            ),
          );
        }
      });
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateCleaningStatus(String id, String status) async {
    state = const AsyncLoading();
    try {
      final isOccupied = await _occupancyRules.isApartmentOccupiedNow(id);
      if (isOccupied) {
        throw Exception(
          'مينفعش تغيير حالة النظافة والشقة فيها ساكن. لازم تكون فارغة الأول.',
        );
      }
      await (_db.update(_db.apartments)..where((t) => t.id.equals(id))).write(
        ApartmentsCompanion(
          cleaningStatus: Value(status),
          syncStatus: const Value(SyncStatus.pendingUpdate),
          updatedAt: Value(DateTime.now()),
        ),
      );
      await _auditLog.log(
        action: 'update_cleaning',
        entityType: 'apartment',
        entityId: id,
        title: 'تغيير حالة النظافة',
        description: 'تم تغيير حالة نظافة الشقة إلى $status',
        route: '/apartments/profile/$id',
        newValues: {'cleaningStatus': status},
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
