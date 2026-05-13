import 'package:flutter_test/flutter_test.dart';
import 'package:abrag/core/database/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase();
  });

  tearDown(() {
    db.close();
  });
}
