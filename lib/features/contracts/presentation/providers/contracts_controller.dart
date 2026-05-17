import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database.dart';
import '../../../../core/database/tables.dart';
import '../../../../core/services/audit_log_service.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';
import '../../../apartments/presentation/providers/apartment_occupancy_rules_provider.dart';

final contractsControllerProvider =
    StateNotifierProvider<ContractsController, AsyncValue<void>>((ref) {
      return ContractsController(
        ref.watch(databaseProvider),
        ref.watch(apartmentOccupancyRulesProvider),
      );
    });

class ContractsController extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;
  final ApartmentOccupancyRules _occupancyRules;
  late final AuditLogService _auditLog;

  ContractsController(this._db, this._occupancyRules)
    : super(const AsyncData(null)) {
    _auditLog = AuditLogService(_db);
  }

  Future<void> addContract({
    required String apartmentId,
    required String contractType,
    required String studentName,
    required String studentPhone,
    String? university,
    required double monthlyRentEgp,
    required double depositEgp,
    required DateTime startDate,
    required DateTime endDate,
    required bool isElectricityOnStudent,
    required bool isGasOnStudent,
    required bool isWaterOnStudent,
    String? roommates,
    String? nationalId,
    String? idFrontImage,
    String? idBackImage,
    String? contractFrontImage,
    String? contractBackImage,
  }) async {
    state = const AsyncLoading();
    try {
      final id = const Uuid().v4();
      await _occupancyRules.ensureApartmentIsFreeForPeriod(
        apartmentId: apartmentId,
        checkInDate: startDate,
        checkOutDate: endDate,
      );

      await _db
          .into(_db.winterContracts)
          .insert(
            WinterContractsCompanion.insert(
              id: id,
              apartmentId: apartmentId,
              contractType: Value(contractType),
              studentName: studentName,
              parentPhone: Value(
                studentPhone,
              ), // Storing in parentPhone or need new field
              university: Value(university),
              startDate: startDate,
              endDate: endDate,
              monthlyRentEgp: monthlyRentEgp,
              depositEgp: Value(depositEgp),
              isElectricityOnStudent: Value(isElectricityOnStudent),
              isGasOnStudent: Value(isGasOnStudent),
              isWaterOnStudent: Value(isWaterOnStudent),
              roommates: Value(roommates),
              nationalId: Value(nationalId),
              idFrontImage: Value(idFrontImage),
              idBackImage: Value(idBackImage),
              contractFrontImage: Value(contractFrontImage),
              contractBackImage: Value(contractBackImage),
              syncStatus: const Value(SyncStatus.pendingInsert),
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
      await _auditLog.log(
        action: 'create',
        entityType: 'winter_contract',
        entityId: id,
        title: 'إضافة عقد شتوي',
        description:
            'تم إضافة عقد باسم $studentName بإيجار $monthlyRentEgp ج.م',
        route: '/winter_contracts/details/$id',
        newValues: {
          'studentName': studentName,
          'studentPhone': studentPhone,
          'startDate': startDate,
          'endDate': endDate,
          'monthlyRentEgp': monthlyRentEgp,
        },
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateContract({
    required String id,
    required String apartmentId,
    required String contractType,
    required String studentName,
    required String studentPhone,
    String? university,
    required double monthlyRentEgp,
    required double depositEgp,
    required DateTime startDate,
    required DateTime endDate,
    required bool isElectricityOnStudent,
    required bool isGasOnStudent,
    required bool isWaterOnStudent,
    String? roommates,
    String? nationalId,
    String? idFrontImage,
    String? idBackImage,
    String? contractFrontImage,
    String? contractBackImage,
  }) async {
    state = const AsyncLoading();
    try {
      await _occupancyRules.ensureApartmentIsFreeForPeriod(
        apartmentId: apartmentId,
        checkInDate: startDate,
        checkOutDate: endDate,
        excludingWinterContractId: id,
      );
      final old = await (_db.select(
        _db.winterContracts,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      await (_db.update(
        _db.winterContracts,
      )..where((t) => t.id.equals(id))).write(
        WinterContractsCompanion(
          apartmentId: Value(apartmentId),
          contractType: Value(contractType),
          studentName: Value(studentName),
          parentPhone: Value(studentPhone),
          university: Value(university),
          startDate: Value(startDate),
          endDate: Value(endDate),
          monthlyRentEgp: Value(monthlyRentEgp),
          depositEgp: Value(depositEgp),
          isElectricityOnStudent: Value(isElectricityOnStudent),
          isGasOnStudent: Value(isGasOnStudent),
          isWaterOnStudent: Value(isWaterOnStudent),
          roommates: Value(roommates),
          nationalId: Value(nationalId),
          idFrontImage: Value(idFrontImage),
          idBackImage: Value(idBackImage),
          contractFrontImage: Value(contractFrontImage),
          contractBackImage: Value(contractBackImage),
          syncStatus: const Value(SyncStatus.pendingUpdate),
          updatedAt: Value(DateTime.now()),
        ),
      );
      await _auditLog.log(
        action: 'update',
        entityType: 'winter_contract',
        entityId: id,
        title: 'تعديل عقد شتوي',
        description: 'تم تعديل عقد $studentName',
        route: '/winter_contracts/details/$id',
        oldValues: old?.toJson(),
        newValues: {
          'studentName': studentName,
          'studentPhone': studentPhone,
          'startDate': startDate,
          'endDate': endDate,
          'monthlyRentEgp': monthlyRentEgp,
        },
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> checkoutContract({
    required String id,
    required double depositDeductionEgp,
  }) async {
    state = const AsyncLoading();
    try {
      await _db.transaction(() async {
        // Set contract as inactive
        await (_db.update(
          _db.winterContracts,
        )..where((t) => t.id.equals(id))).write(
          WinterContractsCompanion(
            isActive: const Value(false),
            syncStatus: const Value(SyncStatus.pendingUpdate),
            updatedAt: Value(DateTime.now()),
          ),
        );

        // Add deduction as revenue if > 0
        if (depositDeductionEgp > 0) {
          final paymentId = const Uuid().v4();
          await _db
              .into(_db.winterPayments)
              .insert(
                WinterPaymentsCompanion.insert(
                  id: paymentId,
                  contractId: id,
                  amountEgp: depositDeductionEgp,
                  paymentDate: DateTime.now(),
                  paymentMethod: const Value('deposit_deduction'),
                  syncStatus: const Value(SyncStatus.pendingInsert),
                  createdAt: DateTime.now(),
                ),
              );
        }
      });
      await _auditLog.log(
        action: 'checkout',
        entityType: 'winter_contract',
        entityId: id,
        title: 'إنهاء عقد شتوي',
        description: 'تم إنهاء عقد وخصم $depositDeductionEgp ج.م من التأمين',
        route: '/winter_contracts/details/$id',
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
