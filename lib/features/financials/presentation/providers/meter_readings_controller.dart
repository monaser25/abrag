import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database.dart';
import '../../../../core/database/tables.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';

final meterReadingsControllerProvider = StateNotifierProvider<MeterReadingsController, AsyncValue<void>>((ref) {
  return MeterReadingsController(ref.watch(databaseProvider));
});

class MeterReadingsController extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;

  MeterReadingsController(this._db) : super(const AsyncData(null));

  Future<void> addReading({
    String? buildingId,
    String? apartmentId,
    required DateTime date,
    required double previousReading,
    required double currentReading,
    required double amount,
    required bool isSharedExpense,
  }) async {
    state = const AsyncLoading();
    try {
      final id = const Uuid().v4();
      
      await _db.into(_db.meterReadings).insert(
        MeterReadingsCompanion.insert(
          id: id,
          buildingId: Value(buildingId),
          apartmentId: Value(apartmentId),
          readingDate: date,
          previousReading: previousReading,
          currentReading: currentReading,
          amountEgp: amount,
          isSharedExpense: Value(isSharedExpense),
          syncStatus: const Value(SyncStatus.pendingInsert),
          createdAt: DateTime.now(),
        ),
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
