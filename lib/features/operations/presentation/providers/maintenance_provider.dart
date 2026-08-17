import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';

final maintenanceProvider = StreamProvider<List<MaintenanceRequest>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(
    db.maintenanceRequests,
  )..orderBy([(t) => OrderingTerm(expression: t.createdAt)])).watch();
});
