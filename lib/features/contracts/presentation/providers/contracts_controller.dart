import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database.dart';
import '../../../../core/database/tables.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';

final contractsControllerProvider = StateNotifierProvider<ContractsController, AsyncValue<void>>((ref) {
  return ContractsController(ref.watch(databaseProvider));
});

class ContractsController extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;

  ContractsController(this._db) : super(const AsyncData(null));

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

      await _db.into(_db.winterContracts).insert(
        WinterContractsCompanion.insert(
          id: id,
          apartmentId: apartmentId,
          contractType: Value(contractType),
          studentName: studentName,
          parentPhone: Value(studentPhone), // Storing in parentPhone or need new field
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
      await (_db.update(_db.winterContracts)..where((t) => t.id.equals(id))).write(
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
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
