import 'package:drift/wasm.dart';

// Compiled to web/drift_worker.dart.js and loaded by WasmDatabase.open on the
// web. Recompile after bumping drift with:
//   dart compile js -O4 -o web/drift_worker.dart.js web/drift_worker.dart
void main() => WasmDatabase.workerMainForOpen();
