import 'package:flutter_test/flutter_test.dart';
import 'package:onboarding_reference/onboarding_reference.dart';

// ── Fakes ─────────────────────────────────────────────────────────

/// Controlled fake for [BiometricAuthService].
///
/// Used by other test files to test widgets that depend on this service.
class FakeBiometricService implements BiometricAuthService {
  bool availableResult;
  bool authenticateResult;
  BiometricException? errorToThrow;
  int authenticateCalls = 0;

  FakeBiometricService({
    this.availableResult = true,
    this.authenticateResult = true,
    this.errorToThrow,
  });

  @override
  Future<bool> isAvailable() async => availableResult;

  @override
  Future<bool> authenticate({required String localizedReason}) async {
    authenticateCalls++;
    if (errorToThrow != null) throw errorToThrow!;
    return authenticateResult;
  }
}

void main() {
  // ── BiometricFailureReason ────────────────────────────────────

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

  // ── BiometricException ────────────────────────────────────────

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

  // ── FakeBiometricService ──────────────────────────────────────
  // Tests for the fake itself — ensures it behaves as expected
  // before it is used in widget tests.

  group('FakeBiometricService', () {
    test('isAvailable returns the configured value (true)', () async {
      final svc = FakeBiometricService(availableResult: true);
      expect(await svc.isAvailable(), isTrue);
    });

    test('isAvailable returns the configured value (false)', () async {
      final svc = FakeBiometricService(availableResult: false);
      expect(await svc.isAvailable(), isFalse);
    });

    test('authenticate returns the configured result', () async {
      final svc = FakeBiometricService(authenticateResult: false);
      expect(
        await svc.authenticate(localizedReason: 'test'),
        isFalse,
      );
    });

    test('authenticate throws the configured exception', () async {
      const ex = BiometricException(BiometricFailureReason.lockedOut);
      final svc = FakeBiometricService(errorToThrow: ex);
      await expectLater(
        () => svc.authenticate(localizedReason: 'test'),
        throwsA(isA<BiometricException>()),
      );
    });

    test('authenticateCalls tracks invocation count', () async {
      final svc = FakeBiometricService();
      await svc.authenticate(localizedReason: 'r1');
      await svc.authenticate(localizedReason: 'r2');
      expect(svc.authenticateCalls, equals(2));
    });
  });
}
