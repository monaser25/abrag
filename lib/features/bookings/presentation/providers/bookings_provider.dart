import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';

final summerBookingsProvider = StreamProvider<List<SummerBooking>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.summerBookings).watch();
});
