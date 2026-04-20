import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onboarding_reference/onboarding_reference.dart';

import '../helpers/fake_services.dart';
import '../helpers/pump_helpers.dart';
import '../helpers/test_app.dart';

// ── Helper ────────────────────────────────────────────────────────

Widget _buildScreen({
  required BiometricAuthService biometricService,
  String email = 'user@qinv.com',
  VoidCallback? onSuccess,
  VoidCallback? onFallback,
}) {
  return buildTestApp(
    home: BiometricLoginScreen(
      email: email,
      biometricService: biometricService,
      onSuccess: onSuccess ?? () {},
      onFallbackToPassword: onFallback ?? () {},
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────

void main() {
  // ── Static content ────────────────────────────────────────────

  group('static content', () {
    testWidgets('shows the saved email in the chip', (tester) async {
      final svc = FakeBiometricAuthService();
      await tester.pumpWidget(
        _buildScreen(biometricService: svc, email: 'fabricio@qinv.com'),
      );
      await tester.pump();
      expect(find.text('fabricio@qinv.com'), findsOneWidget);
    });

    testWidgets('shows "Use password instead" link', (tester) async {
      final svc = FakeBiometricAuthService();
      await tester.pumpWidget(_buildScreen(biometricService: svc));
      await tester.pump(); // one frame — auth hasn't settled yet
      expect(find.text('Use password instead'), findsOneWidget);
    });
  });

  // ── Auto-trigger ──────────────────────────────────────────────

  group('auto-trigger on mount', () {
    testWidgets('calls authenticate automatically', (tester) async {
      final svc = FakeBiometricAuthService();
      await tester.pumpWidget(_buildScreen(biometricService: svc));
      await settle(tester);
      expect(svc.authenticateCalls, equals(1));
    });
  });

  // ── Success ───────────────────────────────────────────────────

  group('success', () {
    testWidgets('calls onSuccess when authentication succeeds', (tester) async {
      bool called = false;
      final svc = FakeBiometricAuthService(authenticateResult: true);

      await tester.pumpWidget(
        _buildScreen(biometricService: svc, onSuccess: () => called = true),
      );
      await settle(tester);

      expect(called, isTrue);
    });

    testWidgets('shows fingerprint icon after successful auth (before callback navigates)',
        (tester) async {
      final svc = FakeBiometricAuthService(authenticateResult: true);
      await tester.pumpWidget(_buildScreen(biometricService: svc));
      await settle(tester);

      expect(find.byIcon(Icons.fingerprint_rounded), findsOneWidget);
    });
  });

  // ── Cancellation ──────────────────────────────────────────────

  group('user cancellation (authenticate returns false)', () {
    testWidgets('shows cancellation message', (tester) async {
      final svc = FakeBiometricAuthService(authenticateResult: false);
      await tester.pumpWidget(_buildScreen(biometricService: svc));
      await settle(tester);

      expect(find.textContaining('cancelled'), findsOneWidget);
    });

    testWidgets('does NOT call onSuccess', (tester) async {
      bool called = false;
      final svc = FakeBiometricAuthService(authenticateResult: false);

      await tester.pumpWidget(
        _buildScreen(biometricService: svc, onSuccess: () => called = true),
      );
      await settle(tester);

      expect(called, isFalse);
    });
  });

  // ── Unavailable ───────────────────────────────────────────────

  group('biometric not available', () {
    testWidgets('shows "not available" message', (tester) async {
      final svc = FakeBiometricAuthService(availableResult: false);
      await tester.pumpWidget(_buildScreen(biometricService: svc));
      await settle(tester);

      expect(find.textContaining('not available'), findsOneWidget);
    });

    testWidgets('does NOT call onSuccess', (tester) async {
      bool called = false;
      final svc = FakeBiometricAuthService(availableResult: false);

      await tester.pumpWidget(
        _buildScreen(biometricService: svc, onSuccess: () => called = true),
      );
      await settle(tester);

      expect(called, isFalse);
    });
  });

  // ── BiometricException error messages ─────────────────────────

  group('BiometricException error messages', () {
    Future<void> assertMessage(
      WidgetTester tester,
      BiometricFailureReason reason,
      String expectedSubstring,
    ) async {
      final svc = FakeBiometricAuthService(errorToThrow: BiometricException(reason));
      await tester.pumpWidget(_buildScreen(biometricService: svc));
      await settle(tester);
      expect(find.textContaining(expectedSubstring), findsOneWidget);
    }

    testWidgets('notAvailable', (tester) async =>
        assertMessage(tester, BiometricFailureReason.notAvailable, 'not available'));

    testWidgets('notEnrolled', (tester) async =>
        assertMessage(tester, BiometricFailureReason.notEnrolled, 'enrolled'));

    testWidgets('lockedOut', (tester) async =>
        assertMessage(tester, BiometricFailureReason.lockedOut, 'attempts'));

    testWidgets('permanentlyLockedOut', (tester) async =>
        assertMessage(tester, BiometricFailureReason.permanentlyLockedOut, 'locked'));

    testWidgets('passcodeNotSet', (tester) async =>
        assertMessage(tester, BiometricFailureReason.passcodeNotSet, 'PIN or passcode'));

    testWidgets('unknown', (tester) async =>
        assertMessage(tester, BiometricFailureReason.unknown, 'Authentication error'));
  });

  // ── Retry ─────────────────────────────────────────────────────

  group('retry on tap', () {
    testWidgets('tapping fingerprint button after failure retries and succeeds',
        (tester) async {
      bool successCalled = false;
      // First call throws; second returns true.
      final svc = FakeBiometricAuthService(
        onAuthenticate: (i) {
          if (i == 0) throw const BiometricException(BiometricFailureReason.unknown);
          return true;
        },
      );

      await tester.pumpWidget(
        _buildScreen(
          biometricService: svc,
          onSuccess: () => successCalled = true,
        ),
      );
      await settle(tester);

      // Error is visible.
      expect(find.textContaining('Authentication error'), findsOneWidget);

      // Tap fingerprint icon to retry.
      await tester.tap(find.byIcon(Icons.fingerprint_rounded));
      await settle(tester);

      expect(successCalled, isTrue);
    });

    testWidgets('error message clears on retry attempt', (tester) async {
      // First call cancels (returns false); second call is paused so we can
      // observe the _busy=true / _errorMessage=null intermediate state.
      final completer = Completer<bool>();
      final svc = FakeBiometricAuthService(
        authenticateResult: false,
        authenticateCompleter: completer,
        pauseOnCall: 1,
      );
      await tester.pumpWidget(_buildScreen(biometricService: svc));
      await settle(tester);

      // First cancellation message visible.
      expect(find.textContaining('cancelled'), findsOneWidget);

      // Tap to retry — second authenticate() call is now blocked on the Completer.
      await tester.tap(find.byIcon(Icons.fingerprint_rounded));
      await tester.pump(); // advances to _busy=true, _errorMessage=null

      // Error must be gone while the retry is in-flight.
      expect(find.textContaining('cancelled'), findsNothing);

      // Resolve the paused call so the widget can finish and the test tears down cleanly.
      completer.complete(false);
      await settle(tester);
    });
  });

  // ── Fallback to password ──────────────────────────────────────

  group('fallback to password', () {
    testWidgets('"Use password instead" link calls onFallbackToPassword', (tester) async {
      bool called = false;
      final svc = FakeBiometricAuthService();

      await tester.pumpWidget(
        _buildScreen(biometricService: svc, onFallback: () => called = true),
      );
      await tester.pump(); // render only — don't wait for auth

      await tester.tap(find.text('Use password instead'));
      await tester.pump();

      expect(called, isTrue);
    });

    testWidgets('"Use password instead" does NOT call onSuccess', (tester) async {
      bool successCalled = false;
      // Make auth cancel so we can test the fallback independently.
      final svc = FakeBiometricAuthService(authenticateResult: false);

      await tester.pumpWidget(
        _buildScreen(
          biometricService: svc,
          onSuccess: () => successCalled = true,
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Use password instead'));
      await tester.pump();

      expect(successCalled, isFalse);
    });
  });
}
