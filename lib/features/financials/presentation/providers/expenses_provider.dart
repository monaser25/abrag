import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';

final expensesProvider = StreamProvider<List<Expense>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.expenses)
        ..orderBy([(t) => OrderingTerm(expression: t.expenseDate)]))
      .watch();
});

final buildingRentProvider = StreamProvider<List<Expense>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.expenses)
        ..where((t) => t.expenseType.equals('building_rent'))
        ..orderBy([(t) => OrderingTerm(expression: t.expenseDate)]))
      .watch();
});
