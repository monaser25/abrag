import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database.dart';
import '../../../../core/database/tables.dart';
import '../../../../core/services/audit_log_service.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';

final contractPaymentsProvider =
    StreamProvider.family<List<WinterPayment>, String>((ref, contractId) {
      final db = ref.watch(databaseProvider);
      return (db.select(
        db.winterPayments,
      )..where((t) => t.contractId.equals(contractId))).watch();
    });

final contractPaymentControllerProvider =
    StateNotifierProvider<ContractPaymentController, AsyncValue<void>>((ref) {
      return ContractPaymentController(ref.watch(databaseProvider));
    });

class ContractPaymentController extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;
  late final AuditLogService _auditLog;

  ContractPaymentController(this._db) : super(const AsyncData(null)) {
    _auditLog = AuditLogService(_db);
  }

  Future<void> addPayment({
    required String contractId,
    required double amount,
    required DateTime date,
    required String paymentMethod,
  }) async {
    state = const AsyncLoading();
    try {
      if (amount <= 0) {
        throw Exception('قيمة الدفعة يجب أن تكون أكبر من صفر');
      }
      final id = const Uuid().v4();
      await _db
          .into(_db.winterPayments)
          .insert(
            WinterPaymentsCompanion.insert(
              id: id,
              contractId: contractId,
              amountEgp: amount,
              paymentDate: date,
              paymentMethod: Value(paymentMethod),
              syncStatus: const Value(SyncStatus.pendingInsert),
              createdAt: DateTime.now(),
            ),
          );
      await _auditLog.log(
        action: 'payment',
        entityType: 'winter_payment',
        entityId: id,
        title: 'تسجيل دفعة شتوية',
        description: 'تم تسجيل دفعة بقيمة $amount ج.م ($paymentMethod)',
        route: '/winter_contracts/payments/$contractId',
        newValues: {
          'contractId': contractId,
          'amount': amount,
          'paymentMethod': paymentMethod,
        },
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updatePayment({
    required String id,
    required double amount,
    required String paymentMethod,
  }) async {
    state = const AsyncLoading();
    try {
      if (amount <= 0) {
        throw Exception('قيمة الدفعة يجب أن تكون أكبر من صفر');
      }
      final old = await (_db.select(
        _db.winterPayments,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      await (_db.update(
        _db.winterPayments,
      )..where((t) => t.id.equals(id))).write(
        WinterPaymentsCompanion(
          amountEgp: Value(amount),
          paymentMethod: Value(paymentMethod),
          syncStatus: const Value(SyncStatus.pendingUpdate),
        ),
      );
      await _auditLog.log(
        action: 'update_payment',
        entityType: 'winter_payment',
        entityId: id,
        title: 'تعديل دفعة شتوية',
        description: 'تم تعديل الدفعة إلى $amount ج.م ($paymentMethod)',
        route: old == null
            ? null
            : '/winter_contracts/payments/${old.contractId}',
        oldValues: {
          'amount': old?.amountEgp,
          'paymentMethod': old?.paymentMethod,
        },
        newValues: {'amount': amount, 'paymentMethod': paymentMethod},
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
