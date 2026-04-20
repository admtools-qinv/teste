import 'package:flutter_test/flutter_test.dart';
import 'package:onboarding_reference/onboarding_reference.dart';

import '../helpers/fake_services.dart';

void main() {
  // ── BiometricFailureReason ───────────────────���────────────────

  group('BiometricFailureReason', () {
    test('has all expected values', () {
      expect(BiometricFailureReason.values, containsAll([
        BiometricFailureReason.notAvailable,
        BiometricFailureReason.notEnrolled,
        BiometricFailureReason.lockedOut,
        BiometricFailureReason.permanentlyLockedOut,
        BiometricFailureReason.passcodeNotSet,
        BiometricFailureReason.unknown,
      ]));
    });
  });

  // ── BiometricException ──────────────��─────────────────────────

  group('BiometricException', () {
    test('carries the reason', () {
      const ex = BiometricException(BiometricFailureReason.notEnrolled);
      expect(ex.reason, equals(BiometricFailureReason.notEnrolled));
    });

    test('platformCode is optional', () {
      const ex = BiometricException(BiometricFailureReason.lockedOut);
      expect(ex.platformCode, isNull);
    });

    test('toString includes reason', () {
      const ex = BiometricException(
        BiometricFailureReason.notAvailable,
        platformCode: 'NotAvailable',
      );
      expect(ex.toString(), contains('notAvailable'));
      expect(ex.toString(), contains('NotAvailable'));
    });

    test('is an Exception', () {
      expect(
        const BiometricException(BiometricFailureReason.unknown),
        isA<Exception>(),
      );
    });
  });

  // ── FakeBiometricAuthService ─────────────────────���───────────
  // Tests for the fake itself — ensures it behaves as expected
  // before it is used in widget tests.

  group('FakeBiometricAuthService', () {
    test('isAvailable returns the configured value (true)', () async {
      final svc = FakeBiometricAuthService(availableResult: true);
      expect(await svc.isAvailable(), isTrue);
    });

    test('isAvailable returns the configured value (false)', () async {
      final svc = FakeBiometricAuthService(availableResult: false);
      expect(await svc.isAvailable(), isFalse);
    });

    test('authenticate returns the configured result', () async {
      final svc = FakeBiometricAuthService(authenticateResult: false);
      expect(
        await svc.authenticate(localizedReason: 'test'),
        isFalse,
      );
    });

    test('authenticate throws the configured exception', () async {
      const ex = BiometricException(BiometricFailureReason.lockedOut);
      final svc = FakeBiometricAuthService(errorToThrow: ex);
      await expectLater(
        () => svc.authenticate(localizedReason: 'test'),
        throwsA(isA<BiometricException>()),
      );
    });

    test('authenticateCalls tracks invocation count', () async {
      final svc = FakeBiometricAuthService();
      await svc.authenticate(localizedReason: 'r1');
      await svc.authenticate(localizedReason: 'r2');
      expect(svc.authenticateCalls, equals(2));
    });
  });
}
