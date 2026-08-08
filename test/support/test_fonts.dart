import 'dart:io';

import 'package:flutter/services.dart';

/// Loads the real app fonts (and Material icon glyphs when available) so
/// goldens render text/icons faithfully instead of placeholder boxes.
Future<void> loadAppFonts() async {
  final loader = FontLoader('IBMPlexSansArabic');
  for (final file in [
    'assets/fonts/IBMPlexSansArabic-Regular.ttf',
    'assets/fonts/IBMPlexSansArabic-Medium.ttf',
    'assets/fonts/IBMPlexSansArabic-Bold.ttf',
  ]) {
    final bytes = File(file).readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await loader.load();

  // Produced by `flutter test` asset assembly; skip if absent.
  final iconFont = File(
    'build/unit_test_assets/fonts/MaterialIcons-Regular.otf',
  );
  if (iconFont.existsSync()) {
    final bytes = iconFont.readAsBytesSync();
    final iconLoader = FontLoader('MaterialIcons')
      ..addFont(Future.value(ByteData.view(bytes.buffer)));
    await iconLoader.load();
  }
}
