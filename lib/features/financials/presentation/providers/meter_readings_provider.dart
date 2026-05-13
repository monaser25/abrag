import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';

final meterReadingsProvider = StreamProvider<List<MeterReading>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.meterReadings)
        ..orderBy([(t) => OrderingTerm(expression: t.readingDate)]))
      .watch();
});
