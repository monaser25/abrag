import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final brokersProvider = StreamProvider<List<UserProfile>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.userProfiles)..where((t) => t.role.equals('broker'))).watch();
});

final currentUserRoleProvider = StreamProvider<String>((ref) {
  final authState = ref.watch(authStateProvider);
  final db = ref.watch(databaseProvider);
  final user = authState.value?.session?.user;
  
  if (user == null) {
    return Stream.value('viewer');
  }

  return (db.select(db.userProfiles)..where((t) => t.id.equals(user.id))).watchSingle().map((p) => p.role);
});
