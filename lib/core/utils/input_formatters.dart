import 'package:flutter/services.dart';

/// Converts Arabic-Indic (٠-٩) and Extended Arabic-Indic (۰-۹) digits to ASCII
/// (0-9) as the user types or pastes, so numeric fields always store and parse
/// Western digits (#14). Also strips Unicode bidi / directional control marks
/// (RLM/LRM/isolates/embeddings) that can ride along on a pasted number and make
/// it render reversed inside an RTL field (#13).
class ArabicDigitsInputFormatter extends TextInputFormatter {
  const ArabicDigitsInputFormatter();

  static const Map<String, String> _digitMap = {
    '٠': '0',
    '١': '1',
    '٢': '2',
    '٣': '3',
    '٤': '4',
    '٥': '5',
    '٦': '6',
    '٧': '7',
    '٨': '8',
    '٩': '9',
    '۰': '0',
    '۱': '1',
    '۲': '2',
    '۳': '3',
    '۴': '4',
    '۵': '5',
    '۶': '6',
    '۷': '7',
    '۸': '8',
    '۹': '9',
  };

  /// Normalize a raw string: Arabic digits -> ASCII, and drop bidi control marks.
  static String normalize(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      if (_isBidiControl(rune)) continue;
      final ch = String.fromCharCode(rune);
      buffer.write(_digitMap[ch] ?? ch);
    }
    return buffer.toString();
  }

  static bool _isBidiControl(int code) {
    return code == 0x200E || // LEFT-TO-RIGHT MARK
        code == 0x200F || // RIGHT-TO-LEFT MARK
        (code >= 0x202A && code <= 0x202E) || // LRE, RLE, PDF, LRO, RLO
        (code >= 0x2066 && code <= 0x2069); // LRI, RLI, FSI, PDI
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final converted = normalize(newValue.text);
    if (converted == newValue.text) return newValue;
    final base = newValue.selection.baseOffset;
    final offset = base > converted.length ? converted.length : base;
    return TextEditingValue(
      text: converted,
      selection: TextSelection.collapsed(offset: offset < 0 ? 0 : offset),
    );
  }
}
