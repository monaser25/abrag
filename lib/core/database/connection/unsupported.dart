import 'package:drift/drift.dart';

/// Fallback for platforms that have neither `dart:io` nor `dart:js_interop`.
/// In practice this is never reached in this app, but the conditional export
/// needs a default target.
DatabaseConnection openConnection() {
  throw UnsupportedError(
    'No database connection is available on this platform.',
  );
}
