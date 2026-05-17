import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database.dart';
import '../../../../core/database/tables.dart';
import '../../../../core/services/audit_log_service.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';
import 'customers_provider.dart';

final customersControllerProvider =
    StateNotifierProvider<CustomersController, AsyncValue<void>>((ref) {
      return CustomersController(ref.watch(databaseProvider));
    });

class CustomersController extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;
  late final AuditLogService _auditLog;

  CustomersController(this._db) : super(const AsyncData(null)) {
    _auditLog = AuditLogService(_db);
  }

  Future<void> updateCustomer(
    CustomerModel customer, {
    required String name,
    required String phone,
    required String nationalId,
  }) async {
    state = const AsyncLoading();
    try {
      final cleanName = name.trim();
      final cleanPhone = phone.trim().isEmpty ? null : phone.trim();
      final cleanNationalId = nationalId.trim().isEmpty
          ? null
          : nationalId.trim();

      await _db.transaction(() async {
        for (final activity in customer.activities) {
          if (activity.source == 'summer') {
            await (_db.update(
              _db.summerBookings,
            )..where((t) => t.id.equals(activity.id))).write(
              SummerBookingsCompanion(
                guestName: Value(cleanName),
                guestPhone: Value(cleanPhone),
                nationalId: Value(cleanNationalId),
                syncStatus: const Value(SyncStatus.pendingUpdate),
                updatedAt: Value(DateTime.now()),
              ),
            );
          } else if (activity.source == 'winter') {
            await (_db.update(
              _db.winterContracts,
            )..where((t) => t.id.equals(activity.id))).write(
              WinterContractsCompanion(
                studentName: Value(cleanName),
                parentPhone: Value(cleanPhone),
                nationalId: Value(cleanNationalId),
                syncStatus: const Value(SyncStatus.pendingUpdate),
                updatedAt: Value(DateTime.now()),
              ),
            );
          }
        }
      });
      await _auditLog.log(
        action: 'update',
        entityType: 'customer',
        entityId: customer.id,
        title: 'تعديل بيانات عميل',
        description: 'تم تعديل بيانات العميل ${customer.name} إلى $cleanName',
        route: customer.activities.isEmpty
            ? null
            : customer.activities.first.route,
        oldValues: {
          'name': customer.name,
          'phone': customer.phone,
          'nationalId': customer.nationalId,
        },
        newValues: {
          'name': cleanName,
          'phone': cleanPhone,
          'nationalId': cleanNationalId,
        },
      );
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}
