import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onboarding_reference/onboarding_reference/presentation/widgets/phone_mask_formatter.dart';

void main() {
  String format(PhoneMaskFormatter formatter, String input) {
    final result = formatter.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(text: input),
    );
    return result.text;
  }

  group('PhoneMaskFormatter', () {
    final brMask = PhoneMaskFormatter('(##) #####-####');

    test('empty input returns empty', () {
      expect(format(brMask, ''), equals(''));
    });

    test('full BR number applies mask correctly', () {
      expect(format(brMask, '11999990000'), equals('(11) 99999-0000'));
    });

    test('partial input applies partial mask', () {
      expect(format(brMask, '119'), equals('(11) 9'));
    });

    test('single digit starts the mask', () {
      expect(format(brMask, '1'), equals('(1'));
    });

    test('non-digit characters are stripped', () {
      expect(format(brMask, '1-1-9'), equals('(11) 9'));
    });

    test('excess digits are truncated to max', () {
      // BR mask has 11 digit slots; 13 digits should clip to 11
      expect(format(brMask, '1199999000099'), equals('(11) 99999-0000'));
    });

    test('cursor position is at end of formatted text', () {
      final result = brMask.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '11999'),
      );
      expect(result.selection.baseOffset, equals(result.text.length));
      expect(result.selection.extentOffset, equals(result.text.length));
    });

    test('different mask pattern works', () {
      final simpleMask = PhoneMaskFormatter('##-##');
      expect(format(simpleMask, '1234'), equals('12-34'));
      expect(format(simpleMask, '12345'), equals('12-34'));
    });

    test('only non-digits returns empty', () {
      expect(format(brMask, 'abc'), equals(''));
    });

    test('mixed letters and digits extracts digits only', () {
      expect(format(brMask, 'a1b2c3'), equals('(12) 3'));
    });
  });
}
