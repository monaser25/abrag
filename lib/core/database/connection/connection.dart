// Picks the right database connection for the current platform at compile time.
//
// On native platforms (mobile/desktop) this resolves to `native.dart`, which
// uses `NativeDatabase` (sqlite3 + dart:ffi). On the web it resolves to
// `web.dart`, which uses `WasmDatabase` — this is what keeps the ffi/sqlite3
// native code OUT of the web build (dart2js cannot compile dart:ffi).
export 'unsupported.dart'
    if (dart.library.io) 'native.dart'
    if (dart.library.js_interop) 'web.dart';
