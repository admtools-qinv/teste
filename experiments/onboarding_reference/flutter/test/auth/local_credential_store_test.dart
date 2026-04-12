import 'package:flutter_test/flutter_test.dart';
import 'package:onboarding_reference/onboarding_reference.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Helpers ─────────────────────────────────────────────────────────

/// Builds a [LocalCredentialStore] backed by a fresh in-memory
/// SharedPreferences instance and an [InMemorySecureStore].
Future<LocalCredentialStore> _makeStore({
  Map<String, Object> initialPrefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(initialPrefs);
  final prefs = await SharedPreferences.getInstance();
  return LocalCredentialStore(prefs: prefs, secureStore: InMemorySecureStore());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ── Initial state ─────────────────────────────────────────────

  group('initial state (empty store)', () {
    test('savedEmail is null', () async {
      final store = await _makeStore();
      expect(store.savedEmail, isNull);
    });

    test('isBiometricEnabled is false', () async {
      final store = await _makeStore();
      expect(store.isBiometricEnabled, isFalse);
    });

    test('hasBiometricBeenAsked is false', () async {
      final store = await _makeStore();
      expect(store.hasBiometricBeenAsked, isFalse);
    });

    test('getToken returns null', () async {
      final store = await _makeStore();
      expect(await store.getToken(), isNull);
    });
  });

  // ── saveEmail ─────────────────────────────────────────────────

  group('saveEmail', () {
    test('persists the email', () async {
      final store = await _makeStore();
      await store.saveEmail('fabricio@qinv.com');
      expect(store.savedEmail, equals('fabricio@qinv.com'));
    });

    test('overwrites a previous email', () async {
      final store = await _makeStore();
      await store.saveEmail('old@qinv.com');
      await store.saveEmail('new@qinv.com');
      expect(store.savedEmail, equals('new@qinv.com'));
    });

    test('accepts an empty string', () async {
      final store = await _makeStore();
      await store.saveEmail('');
      // SharedPreferences stores '' as a valid value.
      expect(store.savedEmail, equals(''));
    });
  });

  // ── setBiometricEnabled ───────────────────────────────────────

  group('setBiometricEnabled(enabled: true)', () {
    test('sets isBiometricEnabled to true', () async {
      final store = await _makeStore();
      await store.setBiometricEnabled(enabled: true);
      expect(store.isBiometricEnabled, isTrue);
    });

    test('marks hasBiometricBeenAsked as true', () async {
      final store = await _makeStore();
      await store.setBiometricEnabled(enabled: true);
      expect(store.hasBiometricBeenAsked, isTrue);
    });
  });

  group('setBiometricEnabled(enabled: false)', () {
    test('sets isBiometricEnabled to false', () async {
      final store = await _makeStore();
      // Enable first.
      await store.setBiometricEnabled(enabled: true);
      // Then disable.
      await store.setBiometricEnabled(enabled: false);
      expect(store.isBiometricEnabled, isFalse);
    });

    test('still marks hasBiometricBeenAsked as true', () async {
      final store = await _makeStore();
      await store.setBiometricEnabled(enabled: false);
      expect(store.hasBiometricBeenAsked, isTrue);
    });
  });

  // ── markBiometricAsked ────────────────────────────────────────

  group('markBiometricAsked', () {
    test('sets hasBiometricBeenAsked without changing isBiometricEnabled', () async {
      final store = await _makeStore();
      expect(store.isBiometricEnabled, isFalse);
      await store.markBiometricAsked();
      expect(store.hasBiometricBeenAsked, isTrue);
      expect(store.isBiometricEnabled, isFalse);
    });

    test('does not flip existing biometric enabled flag', () async {
      final store = await _makeStore();
      await store.setBiometricEnabled(enabled: true);
      await store.markBiometricAsked(); // should be no-op for the flag
      expect(store.isBiometricEnabled, isTrue);
    });
  });

  // ── Token ─────────────────────────────────────────────────────

  group('saveToken / getToken', () {
    test('read after write returns the same value', () async {
      final store = await _makeStore();
      await store.saveToken('jwt-abc-xyz');
      expect(await store.getToken(), equals('jwt-abc-xyz'));
    });

    test('overwrites a previous token', () async {
      final store = await _makeStore();
      await store.saveToken('old-token');
      await store.saveToken('new-token');
      expect(await store.getToken(), equals('new-token'));
    });
  });

  // ── clearSession ──────────────────────────────────────────────

  group('clearSession', () {
    test('removes token', () async {
      final store = await _makeStore();
      await store.saveToken('tok');
      await store.clearSession();
      expect(await store.getToken(), isNull);
    });

    test('removes biometric flags', () async {
      final store = await _makeStore();
      await store.setBiometricEnabled(enabled: true);
      await store.clearSession();
      expect(store.isBiometricEnabled, isFalse);
      expect(store.hasBiometricBeenAsked, isFalse);
    });

    test('RETAINS the saved email', () async {
      final store = await _makeStore();
      await store.saveEmail('keep@qinv.com');
      await store.clearSession();
      expect(store.savedEmail, equals('keep@qinv.com'));
    });
  });

  // ── clearAll ──────────────────────────────────────────────────

  group('clearAll', () {
    test('removes email', () async {
      final store = await _makeStore();
      await store.saveEmail('gone@qinv.com');
      await store.clearAll();
      expect(store.savedEmail, isNull);
    });

    test('removes token', () async {
      final store = await _makeStore();
      await store.saveToken('tok');
      await store.clearAll();
      expect(await store.getToken(), isNull);
    });

    test('removes all biometric flags', () async {
      final store = await _makeStore();
      await store.setBiometricEnabled(enabled: true);
      await store.clearAll();
      expect(store.isBiometricEnabled, isFalse);
      expect(store.hasBiometricBeenAsked, isFalse);
    });

    test('results in fully empty store', () async {
      final store = await _makeStore();
      await store.saveEmail('a@b.com');
      await store.saveToken('tok');
      await store.setBiometricEnabled(enabled: true);
      await store.clearAll();
      expect(store.savedEmail, isNull);
      expect(store.isBiometricEnabled, isFalse);
      expect(store.hasBiometricBeenAsked, isFalse);
      expect(await store.getToken(), isNull);
    });
  });

  // ── Edge cases ────────────────────────────────────────────────

  group('edge cases', () {
    test('clearSession on an empty store does not throw', () async {
      final store = await _makeStore();
      await expectLater(store.clearSession(), completes);
    });

    test('clearAll on an empty store does not throw', () async {
      final store = await _makeStore();
      await expectLater(store.clearAll(), completes);
    });

    test('setBiometricEnabled called multiple times is idempotent', () async {
      final store = await _makeStore();
      await store.setBiometricEnabled(enabled: true);
      await store.setBiometricEnabled(enabled: true);
      expect(store.isBiometricEnabled, isTrue);
      expect(store.hasBiometricBeenAsked, isTrue);
    });

    test('initial values can be seeded via setMockInitialValues', () async {
      final store = await _makeStore(initialPrefs: {
        'qinv_saved_email': 'seeded@qinv.com',
        'qinv_biometric_enabled': true,
        'qinv_biometric_asked': true,
      });
      expect(store.savedEmail, equals('seeded@qinv.com'));
      expect(store.isBiometricEnabled, isTrue);
      expect(store.hasBiometricBeenAsked, isTrue);
    });
  });
}
