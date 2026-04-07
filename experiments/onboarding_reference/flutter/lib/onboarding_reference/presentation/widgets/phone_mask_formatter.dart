import 'package:flutter/services.dart';

class PhoneMaskFormatter extends TextInputFormatter {
  final String mask;

  const PhoneMaskFormatter(this.mask);

  int get _maxDigits => mask.runes.where((c) => c == 35 /* # */).length;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return newValue.copyWith(text: '');

    final limited = digits.length > _maxDigits
        ? digits.substring(0, _maxDigits)
        : digits;

    final buffer = StringBuffer();
    int digitIndex = 0;

    for (int i = 0; i < mask.length && digitIndex < limited.length; i++) {
      if (mask[i] == '#') {
        buffer.write(limited[digitIndex++]);
      } else {
        buffer.write(mask[i]);
      }
    }

    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
