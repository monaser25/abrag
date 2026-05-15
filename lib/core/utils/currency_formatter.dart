import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

extension CurrencyFormatter on num {
  String toCurrencyFormat() {
    final formatter = NumberFormat("#,##0.##", "en_US");
    return formatter.format(this);
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Remove all non-digit characters except for decimal point
    final text = newValue.text.replaceAll(RegExp(r'[^0-9.]'), '');
    
    // Prevent multiple decimal points
    if (text.split('.').length > 2) {
      return oldValue;
    }

    final parts = text.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

    if (integerPart.isEmpty) {
      return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }

    final number = int.parse(integerPart);
    final formatter = NumberFormat('#,###', 'en_US');
    final formattedString = formatter.format(number) + decimalPart;

    return TextEditingValue(
      text: formattedString,
      selection: TextSelection.collapsed(offset: formattedString.length),
    );
  }
}

