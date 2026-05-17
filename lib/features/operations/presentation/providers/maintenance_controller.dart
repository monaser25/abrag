import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database.dart';
import '../../../../core/database/tables.dart';
import '../../../../core/services/audit_log_service.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';

final maintenanceControllerProvider =
    StateNotifierProvider<MaintenanceController, AsyncValue<void>>((ref) {
      return MaintenanceController(ref.watch(databaseProvider));
    });

class MaintenanceController extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;
  late final AuditLogService _auditLog;

  MaintenanceController(this._db) : super(const AsyncData(null)) {
    _auditLog = AuditLogService(_db);
  }

  Future<void> addRequest({
    required String apartmentId,
    required String reportedBy,
    required String description,
    String? technicianId,
  }) async {
    state = const AsyncLoading();
    try {
      final id = const Uuid().v4();

      await _db
          .into(_db.maintenanceRequests)
          .insert(
            MaintenanceRequestsCompanion.insert(
              id: id,
              apartmentId: apartmentId,
              reportedBy: reportedBy,
              issueDescription: description,
              technicianId: Value(technicianId),
              syncStatus: const Value(SyncStatus.pendingInsert),
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
      await _auditLog.log(
        action: 'create',
        entityType: 'maintenance',
        entityId: id,
        title: 'فتح طلب صيانة',
        description: 'تم فتح طلب صيانة: $description',
        route: '/maintenance',
        newValues: {
          'reportedBy': reportedBy,
          'description': description,
          'technicianId': technicianId,
        },
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateRequest({
    required String id,
    required String reportedBy,
    required String description,
    String? technicianId,
    double? costEgp,
  }) async {
    state = const AsyncLoading();
    try {
      final request = await (_db.select(
        _db.maintenanceRequests,
      )..where((t) => t.id.equals(id))).getSingle();

      await (_db.update(
        _db.maintenanceRequests,
      )..where((t) => t.id.equals(id))).write(
        MaintenanceRequestsCompanion(
          reportedBy: Value(reportedBy),
          issueDescription: Value(description),
          technicianId: Value(technicianId),
          costEgp: costEgp != null ? Value(costEgp) : const Value.absent(),
          syncStatus: const Value(SyncStatus.pendingUpdate),
          updatedAt: Value(DateTime.now()),
        ),
      );
      await _auditLog.log(
        action: 'update',
        entityType: 'maintenance',
        entityId: id,
        title: 'تعديل طلب صيانة',
        description: 'تم تعديل طلب الصيانة',
        route: '/maintenance',
        oldValues: request.toJson(),
        newValues: {
          'reportedBy': reportedBy,
          'description': description,
          'technicianId': technicianId,
          'costEgp': costEgp,
        },
      );

      // If cost was updated and the request was resolved, try to find and update the associated expense
      if (costEgp != null && request.status == 'resolved') {
        final expense =
            await (_db.select(_db.expenses)..where(
                  (t) =>
                      t.apartmentId.equals(request.apartmentId) &
                      t.expenseType.equals('maintenance') &
                      t.amountEgp.equals(request.costEgp),
                ))
                .getSingleOrNull();

        if (expense != null) {
          String expenseDescription = 'صيانة: $description';
          if (technicianId != null) {
            final tech = await (_db.select(
              _db.technicians,
            )..where((t) => t.id.equals(technicianId))).getSingleOrNull();
            if (tech != null) {
              expenseDescription += ' (الفني: ${tech.name})';
            }
          }
          await (_db.update(
            _db.expenses,
          )..where((t) => t.id.equals(expense.id))).write(
            ExpensesCompanion(
              amountEgp: Value(costEgp),
              description: Value(expenseDescription),
              syncStatus: const Value(SyncStatus.pendingUpdate),
            ),
          );
        }
      }

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateStatus(String id, String newStatus, {double? cost}) async {
    state = const AsyncLoading();
    try {
      await (_db.update(
        _db.maintenanceRequests,
      )..where((t) => t.id.equals(id))).write(
        MaintenanceRequestsCompanion(
          status: Value(newStatus),
          costEgp: cost != null ? Value(cost) : const Value.absent(),
          resolvedAt: newStatus == 'resolved'
              ? Value(DateTime.now())
              : const Value.absent(),
          syncStatus: const Value(SyncStatus.pendingUpdate),
          updatedAt: Value(DateTime.now()),
        ),
      );
      await _auditLog.log(
        action: 'status',
        entityType: 'maintenance',
        entityId: id,
        title: newStatus == 'resolved' ? 'إغلاق طلب صيانة' : 'تغيير حالة صيانة',
        description: 'تم تغيير حالة الصيانة إلى $newStatus',
        route: '/maintenance',
        newValues: {'status': newStatus, 'cost': cost},
      );

      if (newStatus == 'resolved' && cost != null && cost > 0) {
        final request = await (_db.select(
          _db.maintenanceRequests,
        )..where((t) => t.id.equals(id))).getSingle();

        String expenseDescription = 'صيانة: ${request.issueDescription}';
        if (request.technicianId != null) {
          final tech =
              await (_db.select(_db.technicians)
                    ..where((t) => t.id.equals(request.technicianId!)))
                  .getSingleOrNull();
          if (tech != null) {
            expenseDescription += ' (الفني: ${tech.name})';
          }
        }

        await _db
            .into(_db.expenses)
            .insert(
              ExpensesCompanion.insert(
                id: const Uuid().v4(),
                apartmentId: Value(request.apartmentId),
                expenseType: 'maintenance',
                amountEgp: cost,
                expenseDate: DateTime.now(),
                description: Value(expenseDescription),
                syncStatus: const Value(SyncStatus.pendingInsert),
                createdAt: DateTime.now(),
              ),
            );
      }

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
