import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onboarding_reference/onboarding_reference.dart';

// ── Fakes ─────────────────────────────────────────────────────────

class _SuccessAuthService implements AuthService {
  int loginCalls = 0;
  String? lastEmail;
  String? lastPassword;

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    loginCalls++;
    lastEmail = email;
    lastPassword = password;
    return const AuthResult(token: 'test-token');
  }

  @override
  Future<void> logout({required String token}) async {}
}

class _FailingAuthService implements AuthService {
  final String message;

  const _FailingAuthService(this.message);

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    throw AuthException(message);
  }

  @override
  Future<void> logout({required String token}) async {}
}

class _ThrowingAuthService implements AuthService {
  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    throw Exception('network error');
  }

  @override
  Future<void> logout({required String token}) async {}
}

/// Allows precise control over when login completes.
class _ControlledAuthService implements AuthService {
  final Completer<AuthResult> _completer;

  _ControlledAuthService(this._completer);

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) => _completer.future;

  @override
  Future<void> logout({required String token}) async {}
}

// ── Helpers ───────────────────────────────────────────────────────

Widget _buildScreen({
  required AuthService authService,
  String? initialEmail,
  Future<void> Function(AuthResult, String)? onLoginSuccess,
}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: QInvWeb3Theme.dark(),
    home: EmailPasswordScreen(
      authService: authService,
      initialEmail: initialEmail,
      onLoginSuccess: onLoginSuccess ?? (_, __) async {},
    ),
  );
}

Finder _emailField() => find.byWidgetPredicate(
      (w) => w is TextField && (w.decoration?.labelText == 'Email'),
    );

Finder _passwordField() => find.byWidgetPredicate(
      (w) => w is TextField && (w.decoration?.labelText == 'Password'),
    );

Finder _submitButton() => find.widgetWithText(ElevatedButton, 'Sign in');

/// Pumps enough frames to allow immediately-resolving async operations to
/// complete, without using pumpAndSettle (which never returns on screens
/// that have infinite animations like GlassBackground).
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump(const Duration(milliseconds: 50));
}

// ── Tests ─────────────────────────────────────────────────────────

void main() {
  // ── Initial render ────────────────────────────────────────────

  group('initial render', () {
    testWidgets('shows email and password fields', (tester) async {
      await tester.pumpWidget(_buildScreen(authService: _SuccessAuthService()));
      await tester.pump();
      expect(_emailField(), findsOneWidget);
      expect(_passwordField(), findsOneWidget);
    });

    testWidgets('shows disabled submit button when fields are empty',
        (tester) async {
      await tester.pumpWidget(_buildScreen(authService: _SuccessAuthService()));
      await tester.pump();
      final btn = tester.widget<ElevatedButton>(_submitButton());
      expect(btn.onPressed, isNull);
    });

    testWidgets('pre-fills email when initialEmail is provided', (tester) async {
      await tester.pumpWidget(_buildScreen(
        authService: _SuccessAuthService(),
        initialEmail: 'prefilled@qinv.com',
      ));
      await tester.pump();
      final emailTF = tester.widget<TextField>(_emailField());
      expect(emailTF.controller?.text, equals('prefilled@qinv.com'));
    });

    testWidgets('shows back button', (tester) async {
      await tester.pumpWidget(_buildScreen(authService: _SuccessAuthService()));
      await tester.pump();
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });

    testWidgets('shows header title', (tester) async {
      await tester.pumpWidget(_buildScreen(authService: _SuccessAuthService()));
      await tester.pump();
      expect(find.text('Welcome back'), findsOneWidget);
    });
  });

  // ── Form validation ───────────────────────────────────────────

  group('form validation', () {
    testWidgets('button enables when both email and password are filled',
        (tester) async {
      await tester.pumpWidget(_buildScreen(authService: _SuccessAuthService()));
      await tester.pump();
      await tester.enterText(_emailField(), 'user@qinv.com');
      await tester.enterText(_passwordField(), 'secret');
      await tester.pump();

      final btn = tester.widget<ElevatedButton>(_submitButton());
      expect(btn.onPressed, isNotNull);
    });

    testWidgets('button stays disabled with only email filled', (tester) async {
      await tester.pumpWidget(_buildScreen(authService: _SuccessAuthService()));
      await tester.pump();
      await tester.enterText(_emailField(), 'user@qinv.com');
      await tester.pump();

      final btn = tester.widget<ElevatedButton>(_submitButton());
      expect(btn.onPressed, isNull);
    });

    testWidgets('button stays disabled with only password filled', (tester) async {
      await tester.pumpWidget(_buildScreen(authService: _SuccessAuthService()));
      await tester.pump();
      await tester.enterText(_passwordField(), 'secret');
      await tester.pump();

      final btn = tester.widget<ElevatedButton>(_submitButton());
      expect(btn.onPressed, isNull);
    });

    testWidgets('whitespace-only email keeps button disabled', (tester) async {
      await tester.pumpWidget(_buildScreen(authService: _SuccessAuthService()));
      await tester.pump();
      await tester.enterText(_emailField(), '   ');
      await tester.enterText(_passwordField(), 'pass');
      await tester.pump();

      final btn = tester.widget<ElevatedButton>(_submitButton());
      expect(btn.onPressed, isNull);
    });
  });

  // ── Successful login ──────────────────────────────────────────

  group('successful login', () {
    testWidgets('calls onLoginSuccess with trimmed email and token',
        (tester) async {
      AuthResult? capturedResult;
      String? capturedEmail;

      final svc = _SuccessAuthService();
      await tester.pumpWidget(_buildScreen(
        authService: svc,
        onLoginSuccess: (result, email) async {
          capturedResult = result;
          capturedEmail = email;
        },
      ));
      await tester.pump();

      await tester.enterText(_emailField(), '  user@qinv.com  ');
      await tester.enterText(_passwordField(), 'pass');
      await tester.pump();
      await tester.tap(_submitButton());
      await _settle(tester);

      expect(capturedResult?.token, equals('test-token'));
      expect(capturedEmail, equals('user@qinv.com')); // trimmed
    });

    testWidgets('sends raw (untrimmed) password to the service', (tester) async {
      final svc = _SuccessAuthService();
      await tester.pumpWidget(_buildScreen(authService: svc));
      await tester.pump();

      await tester.enterText(_emailField(), 'u@q.com');
      await tester.enterText(_passwordField(), ' mypass ');
      await tester.pump();
      await tester.tap(_submitButton());
      await _settle(tester);

      // Password must NOT be trimmed — some passwords contain spaces.
      expect(svc.lastPassword, equals(' mypass '));
    });
  });

  // ── Loading state ─────────────────────────────────────────────

  group('loading state', () {
    testWidgets('shows spinner while login is pending', (tester) async {
      final completer = Completer<AuthResult>();
      await tester.pumpWidget(
        _buildScreen(authService: _ControlledAuthService(completer)),
      );
      await tester.pump();

      await tester.enterText(_emailField(), 'u@q.com');
      await tester.enterText(_passwordField(), 'pass');
      await tester.pump();
      await tester.tap(_submitButton());
      await tester.pump(); // one frame → _busy=true

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Resolve so the test can tear down cleanly.
      completer.complete(const AuthResult(token: 'x'));
      await _settle(tester);
    });

    testWidgets('button is disabled while loading', (tester) async {
      final completer = Completer<AuthResult>();
      await tester.pumpWidget(
        _buildScreen(authService: _ControlledAuthService(completer)),
      );
      await tester.pump();

      await tester.enterText(_emailField(), 'u@q.com');
      await tester.enterText(_passwordField(), 'pass');
      await tester.pump();
      await tester.tap(_submitButton());
      await tester.pump(); // one frame → _busy=true

      final btn = tester.widget<ElevatedButton>(_submitButton());
      expect(btn.onPressed, isNull);

      completer.complete(const AuthResult(token: 'x'));
      await _settle(tester);
    });

    testWidgets('spinner disappears after successful login', (tester) async {
      final svc = _SuccessAuthService();
      await tester.pumpWidget(_buildScreen(authService: svc));
      await tester.pump();

      await tester.enterText(_emailField(), 'u@q.com');
      await tester.enterText(_passwordField(), 'pass');
      await tester.pump();
      await tester.tap(_submitButton());
      await _settle(tester);

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  // ── Error states ──────────────────────────────────────────────

  group('error states', () {
    testWidgets('shows AuthException message in error banner', (tester) async {
      await tester.pumpWidget(_buildScreen(
        authService: const _FailingAuthService('Incorrect email or password.'),
      ));
      await tester.pump();

      await tester.enterText(_emailField(), 'u@q.com');
      await tester.enterText(_passwordField(), 'wrong');
      await tester.pump();
      await tester.tap(_submitButton());
      await _settle(tester);

      expect(find.text('Incorrect email or password.'), findsOneWidget);
    });

    testWidgets('shows generic message for non-AuthException errors',
        (tester) async {
      await tester.pumpWidget(
        _buildScreen(authService: _ThrowingAuthService()),
      );
      await tester.pump();

      await tester.enterText(_emailField(), 'u@q.com');
      await tester.enterText(_passwordField(), 'pass');
      await tester.pump();
      await tester.tap(_submitButton());
      await _settle(tester);

      expect(find.text('Connection error. Try again.'), findsOneWidget);
    });

    testWidgets('error banner disappears when user starts typing', (tester) async {
      await tester.pumpWidget(_buildScreen(
        authService: const _FailingAuthService('Falhou'),
      ));
      await tester.pump();

      await tester.enterText(_emailField(), 'u@q.com');
      await tester.enterText(_passwordField(), 'bad');
      await tester.pump();
      await tester.tap(_submitButton());
      await _settle(tester);

      expect(find.text('Falhou'), findsOneWidget);

      // User starts typing → error must clear.
      await tester.enterText(_emailField(), 'new@q.com');
      await tester.pump();

      expect(find.text('Falhou'), findsNothing);
    });

    testWidgets('spinner is cleared after an error', (tester) async {
      await tester.pumpWidget(_buildScreen(
        authService: const _FailingAuthService('err'),
      ));
      await tester.pump();

      await tester.enterText(_emailField(), 'u@q.com');
      await tester.enterText(_passwordField(), 'p');
      await tester.pump();
      await tester.tap(_submitButton());
      await _settle(tester);

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('button re-enables after an error', (tester) async {
      await tester.pumpWidget(_buildScreen(
        authService: const _FailingAuthService('err'),
      ));
      await tester.pump();

      await tester.enterText(_emailField(), 'u@q.com');
      await tester.enterText(_passwordField(), 'p');
      await tester.pump();
      await tester.tap(_submitButton());
      await _settle(tester);

      final btn = tester.widget<ElevatedButton>(_submitButton());
      expect(btn.onPressed, isNotNull);
    });
  });

  // ── Show/hide password ────────────────────────────────────────

  group('show/hide password toggle', () {
    testWidgets('password is initially obscured', (tester) async {
      await tester.pumpWidget(_buildScreen(authService: _SuccessAuthService()));
      await tester.pump();
      final tf = tester.widget<TextField>(_passwordField());
      expect(tf.obscureText, isTrue);
    });

    testWidgets('tapping eye icon reveals the password', (tester) async {
      await tester.pumpWidget(_buildScreen(authService: _SuccessAuthService()));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      expect(tester.widget<TextField>(_passwordField()).obscureText, isFalse);
    });

    testWidgets('tapping eye icon again re-hides the password', (tester) async {
      await tester.pumpWidget(_buildScreen(authService: _SuccessAuthService()));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();

      expect(tester.widget<TextField>(_passwordField()).obscureText, isTrue);
    });
  });
}
