import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_settings_provider.dart';
import '../../../../core/database/database.dart';
import '../../../../core/utils/season_utils.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';

final allWinterContractsProvider = StreamProvider<List<WinterContract>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.winterContracts).watch();
});

final winterContractsProvider = StreamProvider<List<WinterContract>>((ref) {
  final db = ref.watch(databaseProvider);
  final activeSeason = ref.watch(activeSeasonKeyProvider);
  return db.select(db.winterContracts).watch().map((contracts) {
    final filtered =
        contracts
            .where(
              (contract) => seasonMatchesDate(contract.startDate, activeSeason),
            )
            .toList()
          ..sort((a, b) => b.startDate.compareTo(a.startDate));
    return filtered;
  });
});

final allWinterPaymentsProvider = StreamProvider<List<WinterPayment>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.winterPayments).watch();
});
