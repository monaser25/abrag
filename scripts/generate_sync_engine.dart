import 'dart:io';

void main() {
  final tablesDart = File('lib/core/database/tables.dart').readAsStringSync();
  final regex = RegExp(
    r'class\s+(\w+)\s+extends\s+Table\s+with\s+SyncableTable\s+{([^}]+)}',
  );

  final matches = regex.allMatches(tablesDart);

  final StringBuffer pullBuffer = StringBuffer();
  final StringBuffer pushBuffer = StringBuffer();
  const serverGeneratedColumns = {
    'SummerBookings': {'brokerCommissionAmountEgp'},
  };

  for (final match in matches) {
    final className = match.group(1)!;
    final body = match.group(2)!;

    // convert className to snake_case
    final tableName = className.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (m) => '${m.start == 0 ? "" : "_"}${m.group(0)!.toLowerCase()}',
    );
    final driftTableName =
        className.substring(0, 1).toLowerCase() + className.substring(1);

    final columnsRegExp = RegExp(
      r'(TextColumn|IntColumn|RealColumn|BoolColumn|DateTimeColumn)\s+get\s+(\w+)',
    );
    final columnMatches = columnsRegExp.allMatches(body);

    final columns = <String, String>{};
    for (final cMatch in columnMatches) {
      final type = cMatch.group(1)!;
      final name = cMatch.group(2)!;
      columns[name] = type;
    }

    // Build Pull
    pullBuffer.writeln('      // Sync $className');
    pullBuffer.writeln(
      '      final ${driftTableName}Data = await supabase.from(\'$tableName\').select();',
    );
    pullBuffer.writeln('      for (final row in ${driftTableName}Data) {');
    pullBuffer.writeln(
      '        await db.into(db.$driftTableName).insertOnConflictUpdate(',
    );
    pullBuffer.writeln('          ${className}Companion(');

    for (final col in columns.entries) {
      final name = col.key;
      final type = col.value;
      if (name == 'syncStatus') continue;
      if (name == 'lastModifiedLocal') continue;

      final snakeName = name.replaceAllMapped(
        RegExp(r'[A-Z]'),
        (m) => '_${m.group(0)!.toLowerCase()}',
      );

      String parseStr = '';
      if (type == 'DateTimeColumn') {
        parseStr =
            "row['$snakeName'] == null ? const Value.absent() : Value(DateTime.parse(row['$snakeName']))";
      } else if (type == 'RealColumn') {
        parseStr =
            "row['$snakeName'] == null ? const Value.absent() : Value((row['$snakeName'] as num).toDouble())";
      } else if (type == 'IntColumn') {
        parseStr =
            "row['$snakeName'] == null ? const Value.absent() : Value((row['$snakeName'] as num).toInt())";
      } else {
        parseStr =
            "row['$snakeName'] == null ? const Value.absent() : Value(row['$snakeName'])";
      }

      pullBuffer.writeln('            $name: $parseStr,');
    }
    pullBuffer.writeln(
      '            syncStatus: const Value(SyncStatus.synced),',
    );
    pullBuffer.writeln('          ),');
    pullBuffer.writeln('        );');
    pullBuffer.writeln('      }\n');

    // Build Push
    pushBuffer.writeln('    final pending$className = await (db.select(');
    pushBuffer.writeln('      db.$driftTableName,');
    pushBuffer.writeln(
      '    )..where((t) => t.syncStatus.isNotIn([SyncStatus.synced.index]))).get();',
    );
    pushBuffer.writeln('');
    pushBuffer.writeln('    for (final item in pending$className) {');
    pushBuffer.writeln('      try {');

    for (final col in columns.entries) {
      final name = col.key;
      final snakeName = name.replaceAllMapped(
        RegExp(r'[A-Z]'),
        (m) => '_${m.group(0)!.toLowerCase()}',
      );
      if (snakeName.contains('image') ||
          snakeName.contains('receipt') ||
          snakeName.contains('url')) {
        pushBuffer.writeln('        String? uploaded_$name = item.$name;');
        pushBuffer.writeln(
          '        if (uploaded_$name != null && !uploaded_$name.startsWith(\'http\')) {',
        );
        pushBuffer.writeln(
          '          uploaded_$name = await _uploadFileIfLocal(uploaded_$name, \'abrag_storage\', \'$tableName\');',
        );
        pushBuffer.writeln('        }');
      }
    }

    pushBuffer.writeln('        final payload = {');
    for (final col in columns.entries) {
      final name = col.key;
      final type = col.value;
      if (name == 'syncStatus' || name == 'lastModifiedLocal') continue;
      if (serverGeneratedColumns[className]?.contains(name) ?? false) continue;
      final snakeName = name.replaceAllMapped(
        RegExp(r'[A-Z]'),
        (m) => '_${m.group(0)!.toLowerCase()}',
      );

      if (type == 'DateTimeColumn') {
        pushBuffer.writeln(
          '          \'$snakeName\': item.$name${columns.entries.any((e) => e.key == name && body.contains("$name => dateTime().nullable()")) ? "?" : ""}.toUtc().toIso8601String(),',
        );
      } else if (snakeName.contains('image') ||
          snakeName.contains('receipt') ||
          snakeName.contains('url')) {
        pushBuffer.writeln('          \'$snakeName\': uploaded_$name,');
      } else {
        pushBuffer.writeln('          \'$snakeName\': item.$name,');
      }
    }
    pushBuffer.writeln('        };');
    pushBuffer.writeln('');
    pushBuffer.writeln(
      '        if (item.syncStatus == SyncStatus.pendingDelete) {',
    );
    pushBuffer.writeln(
      '          await supabase.from(\'$tableName\').delete().eq(\'id\', item.id);',
    );
    pushBuffer.writeln('          await (db.delete(');
    pushBuffer.writeln('            db.$driftTableName,');
    pushBuffer.writeln(
      '          )..where((t) => t.id.equals(item.id))).go();',
    );
    pushBuffer.writeln('        } else {');
    pushBuffer.writeln(
      '          await supabase.from(\'$tableName\').upsert(payload);',
    );
    pushBuffer.writeln('          await (db.update(');
    pushBuffer.writeln('            db.$driftTableName,');
    pushBuffer.writeln(
      '          )..where((t) => t.id.equals(item.id))).write(',
    );
    pushBuffer.writeln(
      '            const ${className}Companion(syncStatus: Value(SyncStatus.synced)),',
    );
    pushBuffer.writeln('          );');
    pushBuffer.writeln('        }');
    pushBuffer.writeln('      } catch (e, st) {');
    pushBuffer.writeln(
      '        throw Exception(\'Error syncing $tableName (push): \$e\\nItem: \$item\');',
    );
    pushBuffer.writeln('      }');
    pushBuffer.writeln('    }\n');
  }

  final fullClass =
      '''
import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import '../database/database.dart';
import '../database/tables.dart';

class SyncEngine {
  final AppDatabase db;
  final SupabaseClient supabase;

  SyncEngine(this.db, this.supabase);

  Future<String?> _uploadFileIfLocal(String? path, String bucket, String folder) async {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    
    try {
      final file = File(path);
      if (!await file.exists()) return path;

      final ext = path.split('.').last;
      final fileName = '\${const Uuid().v4()}.\$ext';
      final storagePath = '\$folder/\$fileName';

      await supabase.storage.from(bucket).upload(storagePath, file);
      final publicUrl = supabase.storage.from(bucket).getPublicUrl(storagePath);
      return publicUrl;
    } catch (e) {
      return path;
    }
  }

  Future<void> syncAll() async {
    await _pushLocalChanges();
    await _pullRemoteChanges();
  }

  Future<void> _pushLocalChanges() async {
$pushBuffer
  }

  Future<void> _pullRemoteChanges() async {
    try {
$pullBuffer
    } catch (e) {
      rethrow;
    }
  }
}
''';

  File('lib/core/sync/sync_engine.dart').writeAsStringSync(fullClass);
  stdout.writeln('Sync engine generated successfully!');
}
