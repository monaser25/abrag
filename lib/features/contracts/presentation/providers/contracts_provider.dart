import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';

final winterContractsProvider = StreamProvider<List<WinterContract>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.winterContracts).watch();
});

final allWinterPaymentsProvider = StreamProvider<List<WinterPayment>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.winterPayments).watch();
});
