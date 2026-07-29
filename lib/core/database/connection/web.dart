import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// Web connection: sqlite3 compiled to WebAssembly, persisted by drift in the
/// most reliable storage the browser offers (OPFS when available, otherwise
/// IndexedDB). Requires `web/sqlite3.wasm` and `web/drift_worker.dart.js`.
DatabaseConnection openConnection() {
  return DatabaseConnection.delayed(
    Future(() async {
      final result = await WasmDatabase.open(
        databaseName: 'abrag_local_v4',
        sqlite3Uri: Uri.parse('sqlite3.wasm'),
        driftWorkerUri: Uri.parse('drift_worker.dart.js'),
      );

      if (result.missingFeatures.isNotEmpty) {
        // Local persistence is central to this offline-first app; surface a
        // hint in the console if only an unreliable storage backend exists.
        // ignore: avoid_print
        print(
          'drift: using ${result.chosenImplementation} due to missing browser '
          'features: ${result.missingFeatures}',
        );
      }

      return result.resolvedExecutor;
    }),
  );
}
