import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onboarding_reference/onboarding_reference.dart';

// ── Fake service ──────────────────────────────────────────────────

class _FakeBiometric implements BiometricAuthService {
  bool availableResult;
  bool authenticateResult;
  BiometricException? errorToThrow;
  int authenticateCalls = 0;

  _FakeBiometric({
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

/// Fake whose behaviour changes on subsequent calls.
class _CallCountBiometric implements BiometricAuthService {
  final bool Function(int callIndex) onCall;
  int _callCount = 0;

  _CallCountBiometric({required this.onCall});

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<bool> authenticate({required String localizedReason}) async =>
      onCall(_callCount++);
}

/// Fake that pauses on the second authenticate() call until [resume] is called.
/// Used to observe the intermediate _busy=true state between retries.
class _PausableBiometric implements BiometricAuthService {
  final bool firstResult;
  int _callCount = 0;
  Completer<bool>? _pauseCompleter;

  _PausableBiometric({this.firstResult = false});

  /// Completer controlling the second call. Call [resume] to unblock it.
  Completer<bool> get pauseCompleter => _pauseCompleter!;

  void resume(bool value) => _pauseCompleter!.complete(value);

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<bool> authenticate({required String localizedReason}) {
    final index = _callCount++;
    if (index == 0) return Future.value(firstResult);
    _pauseCompleter = Completer<bool>();
    return _pauseCompleter!.future;
  }
}

// ── Helper ────────────────────────────────────────────────────────

Widget _buildScreen({
  required BiometricAuthService biometricService,
  String email = 'user@qinv.com',
  VoidCallback? onSuccess,
  VoidCallback? onFallback,
}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: QInvWeb3Theme.dark(),
    home: BiometricLoginScreen(
      email: email,
      biometricService: biometricService,
      onSuccess: onSuccess ?? () {},
      onFallbackToPassword: onFallback ?? () {},
    ),
  );
}

/// Pumps enough frames to allow immediately-resolving async operations to
/// complete without using pumpAndSettle (which hangs on GlassBackground).
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();                                    // schedules postFrameCallback
  await tester.pump();                                    // fires callback, starts Future
  await tester.pump(const Duration(milliseconds: 50));    // microtasks / async completes
  await tester.pump();                                    // setState propagates
}

// ── Tests ─────────────────────────────────────────────────────────

void main() {
  // ── Static content ────────────────────────────────────────────

  group('static content', () {
    testWidgets('shows the saved email in the chip', (tester) async {
      final svc = _FakeBiometric();
      await tester.pumpWidget(
        _buildScreen(biometricService: svc, email: 'fabricio@qinv.com'),
      );
      await tester.pump();
      expect(find.text('fabricio@qinv.com'), findsOneWidget);
    });

    testWidgets('shows "Use password instead" link', (tester) async {
      final svc = _FakeBiometric();
      await tester.pumpWidget(_buildScreen(biometricService: svc));
      await tester.pump(); // one frame — auth hasn't settled yet
      expect(find.text('Use password instead'), findsOneWidget);
    });
  });

  // ── Auto-trigger ──────────────────────────────────────────────

  group('auto-trigger on mount', () {
    testWidgets('calls authenticate automatically', (tester) async {
      final svc = _FakeBiometric();
      await tester.pumpWidget(_buildScreen(biometricService: svc));
      await _settle(tester);
      expect(svc.authenticateCalls, greaterThanOrEqualTo(1));
    });
  });

  // ── Success ───────────────────────────────────────────────────

  group('success', () {
    testWidgets('calls onSuccess when authentication succeeds', (tester) async {
      bool called = false;
      final svc = _FakeBiometric(authenticateResult: true);

      await tester.pumpWidget(
        _buildScreen(biometricService: svc, onSuccess: () => called = true),
      );
      await _settle(tester);

      expect(called, isTrue);
    });

    testWidgets('shows fingerprint icon after successful auth (before callback navigates)',
        (tester) async {
      // If onSuccess does nothing (e.g. in tests), the icon should still be
      // visible after success — the screen doesn't navigate itself.
      final svc = _FakeBiometric(authenticateResult: true);
      await tester.pumpWidget(_buildScreen(biometricService: svc));
      await _settle(tester);

      expect(find.byIcon(Icons.fingerprint_rounded), findsOneWidget);
    });
  });

  // ── Cancellation ──────────────────────────────────────────────

  group('user cancellation (authenticate returns false)', () {
    testWidgets('shows cancellation message', (tester) async {
      final svc = _FakeBiometric(authenticateResult: false);
      await tester.pumpWidget(_buildScreen(biometricService: svc));
      await _settle(tester);

      expect(find.textContaining('cancelled'), findsOneWidget);
    });

    testWidgets('does NOT call onSuccess', (tester) async {
      bool called = false;
      final svc = _FakeBiometric(authenticateResult: false);

      await tester.pumpWidget(
        _buildScreen(biometricService: svc, onSuccess: () => called = true),
      );
      await _settle(tester);

      expect(called, isFalse);
    });
  });

  // ── Unavailable ───────────────────────────────────────────────

  group('biometric not available', () {
    testWidgets('shows "not available" message', (tester) async {
      final svc = _FakeBiometric(availableResult: false);
      await tester.pumpWidget(_buildScreen(biometricService: svc));
      await _settle(tester);

      expect(find.textContaining('not available'), findsOneWidget);
    });

    testWidgets('does NOT call onSuccess', (tester) async {
      bool called = false;
      final svc = _FakeBiometric(availableResult: false);

      await tester.pumpWidget(
        _buildScreen(biometricService: svc, onSuccess: () => called = true),
      );
      await _settle(tester);

      expect(called, isFalse);
    });
  });

  // ── BiometricException error messages ─────────────────────────

  group('BiometricException error messages', () {
    Future<void> _assertMessage(
      WidgetTester tester,
      BiometricFailureReason reason,
      String expectedSubstring,
    ) async {
      final svc = _FakeBiometric(errorToThrow: BiometricException(reason));
      await tester.pumpWidget(_buildScreen(biometricService: svc));
      await _settle(tester);
      expect(find.textContaining(expectedSubstring), findsOneWidget);
    }

    testWidgets('notAvailable', (tester) async =>
        _assertMessage(tester, BiometricFailureReason.notAvailable, 'not available'));

    testWidgets('notEnrolled', (tester) async =>
        _assertMessage(tester, BiometricFailureReason.notEnrolled, 'enrolled'));

    testWidgets('lockedOut', (tester) async =>
        _assertMessage(tester, BiometricFailureReason.lockedOut, 'attempts'));

    testWidgets('permanentlyLockedOut', (tester) async =>
        _assertMessage(tester, BiometricFailureReason.permanentlyLockedOut, 'locked'));

    testWidgets('passcodeNotSet', (tester) async =>
        _assertMessage(tester, BiometricFailureReason.passcodeNotSet, 'PIN or passcode'));

    testWidgets('unknown', (tester) async =>
        _assertMessage(tester, BiometricFailureReason.unknown, 'Authentication error'));
  });

  // ── Retry ─────────────────────────────────────────────────────

  group('retry on tap', () {
    testWidgets('tapping fingerprint button after failure retries and succeeds',
        (tester) async {
      bool successCalled = false;
      // First call throws; second returns true.
      final svc = _CallCountBiometric(
        onCall: (i) => i == 0
            ? throw const BiometricException(BiometricFailureReason.unknown)
            : true,
      );

      await tester.pumpWidget(
        _buildScreen(
          biometricService: svc,
          onSuccess: () => successCalled = true,
        ),
      );
      await _settle(tester);

      // Error is visible.
      expect(find.textContaining('Authentication error'), findsOneWidget);

      // Tap fingerprint icon to retry.
      await tester.tap(find.byIcon(Icons.fingerprint_rounded));
      await _settle(tester);

      expect(successCalled, isTrue);
    });

    testWidgets('error message clears on retry attempt', (tester) async {
      // First call cancels (returns false); second call is paused so we can
      // observe the _busy=true / _errorMessage=null intermediate state.
      final svc = _PausableBiometric(firstResult: false);
      await tester.pumpWidget(_buildScreen(biometricService: svc));
      await _settle(tester);

      // First cancellation message visible.
      expect(find.textContaining('cancelled'), findsOneWidget);

      // Tap to retry — second authenticate() call is now blocked on the Completer.
      await tester.tap(find.byIcon(Icons.fingerprint_rounded));
      await tester.pump(); // advances to _busy=true, _errorMessage=null

      // Error must be gone while the retry is in-flight.
      expect(find.textContaining('cancelled'), findsNothing);

      // Resolve the paused call so the widget can finish and the test tears down cleanly.
      svc.resume(false);
      await _settle(tester);
    });
  });

  // ── Fallback to password ──────────────────────────────────────

  group('fallback to password', () {
    testWidgets('"Use password instead" link calls onFallbackToPassword', (tester) async {
      bool called = false;
      final svc = _FakeBiometric();

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
      final svc = _FakeBiometric(authenticateResult: false);

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
