import 'package:flutter_test/flutter_test.dart';
import 'package:onboarding_reference/onboarding_reference.dart';

void main() {
  // ── AuthResult ───────────────────────────────────────────────────

  group('AuthResult', () {
    test('carries the token', () {
      const result = AuthResult(token: 'abc-123');
      expect(result.token, equals('abc-123'));
    });

    test('two instances with same token are equal via const', () {
      const a = AuthResult(token: 'tok');
      const b = AuthResult(token: 'tok');
      // const objects with identical fields share identity.
      expect(identical(a, b), isTrue);
    });
  });

  // ── AuthException ────────────────────────────────────────────────

  group('AuthException', () {
    test('carries the message', () {
      const ex = AuthException('E-mail ou senha incorretos.');
      expect(ex.message, equals('E-mail ou senha incorretos.'));
    });

    test('toString includes the message', () {
      const ex = AuthException('falhou');
      expect(ex.toString(), contains('falhou'));
    });

    test('is an Exception', () {
      expect(const AuthException('x'), isA<Exception>());
    });
  });

  // ── NoopAuthService ──────────────────────────────────────────────

  group('NoopAuthService', () {
    late NoopAuthService sut;

    setUp(() => sut = NoopAuthService());

    test('login returns an AuthResult with a non-empty token', () async {
      final result = await sut.login(email: 'a@b.com', password: '123');
      expect(result, isA<AuthResult>());
      expect(result.token, isNotEmpty);
    });

    test('login does not throw for any credential values', () async {
      // Empty strings — noop never validates.
      await expectLater(
        sut.login(email: '', password: ''),
        completes,
      );
    });

    test('login always resolves (never throws)', () async {
      await expectLater(
        sut.login(email: 'any@email.com', password: 'any-pass'),
        completes,
      );
    });

    test('logout resolves without error', () async {
      await expectLater(sut.logout(token: 'any-token'), completes);
    });

    test('logout is a no-op — no state change', () async {
      // Just verifying it does not throw.
      await sut.logout(token: 'irrelevant');
    });
  });
}
