import 'dart:async';

import 'package:onboarding_reference/l10n/app_localizations_en.dart';
import 'package:onboarding_reference/onboarding_reference.dart';

// ── BiometricAuthService ─────────────────────────────────────────────

class FakeBiometricAuthService implements BiometricAuthService {
  bool availableResult;
  bool authenticateResult;
  BiometricException? errorToThrow;
  int authenticateCalls = 0;

  /// When set, overrides [authenticateResult] per call index.
  final bool Function(int callIndex)? onAuthenticate;

  /// When set, the call at index [pauseOnCall] awaits this completer.
  final Completer<bool>? authenticateCompleter;
  final int pauseOnCall;

  FakeBiometricAuthService({
    this.availableResult = true,
    this.authenticateResult = true,
    this.errorToThrow,
    this.onAuthenticate,
    this.authenticateCompleter,
    this.pauseOnCall = 1,
  });

  @override
  Future<bool> isAvailable() async => availableResult;

  @override
  Future<bool> authenticate({required String localizedReason}) async {
    final callIndex = authenticateCalls;
    authenticateCalls++;

    if (errorToThrow != null) throw errorToThrow!;

    if (authenticateCompleter != null && callIndex == pauseOnCall) {
      return authenticateCompleter!.future;
    }

    if (onAuthenticate != null) return onAuthenticate!(callIndex);

    return authenticateResult;
  }
}

// ── AuthService ──────────────────────────────────────────────────────

class FakeAuthService implements AuthService {
  final AuthResult? loginResult;
  final Object? loginException;
  final Completer<AuthResult>? loginCompleter;

  int loginCalls = 0;
  String? lastEmail;
  String? lastPassword;

  FakeAuthService({
    this.loginResult,
    this.loginException,
    this.loginCompleter,
  });

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    loginCalls++;
    lastEmail = email;
    lastPassword = password;

    if (loginCompleter != null) return loginCompleter!.future;
    if (loginException != null) throw loginException!;
    return loginResult ?? const AuthResult(token: 'test-token');
  }

  @override
  Future<void> logout({required String token}) async {}
}

// ── OnboardingBackendService ─────────────────────────────────────────

class FakeOnboardingBackendService implements OnboardingBackendService {
  final Object? startSessionError;
  final Object? saveAnswerError;
  bool failNextSave;
  final Completer<void>? submitCompleter;

  bool started = false;
  bool submitted = false;
  int submitCount = 0;
  int saveCalls = 0;
  final Map<String, dynamic> saved = {};
  final List<String> cleared = [];

  FakeOnboardingBackendService({
    this.startSessionError,
    this.saveAnswerError,
    this.failNextSave = false,
    this.submitCompleter,
  });

  @override
  Future<OnboardingSessionDto> startSession() async {
    if (startSessionError != null) throw startSessionError!;
    started = true;
    return const OnboardingSessionDto(sessionId: 'test-session');
  }

  @override
  Future<void> saveAnswer({
    required String sessionId,
    required String stepId,
    required dynamic value,
  }) async {
    saveCalls++;
    if (failNextSave) {
      failNextSave = false;
      throw Exception('save failed');
    }
    if (saveAnswerError != null) throw saveAnswerError!;
    saved[stepId] = value;
  }

  @override
  Future<SubmitResultDto> submitAll({
    required String sessionId,
    required Map<String, dynamic> answers,
  }) async {
    submitCount++;
    submitted = true;
    if (submitCompleter != null && !submitCompleter!.isCompleted) {
      await submitCompleter!.future;
    }
    return const SubmitResultDto(success: true);
  }

  @override
  Future<void> clearAnswer({
    required String sessionId,
    required String stepId,
  }) async {
    cleared.add(stepId);
    saved.remove(stepId);
  }
}

// ── OnboardingAnalyticsService ───────────────────────────────────────

class FakeOnboardingAnalyticsService implements OnboardingAnalyticsService {
  final bool trackEvents;
  final List<String> events = [];

  FakeOnboardingAnalyticsService({this.trackEvents = true});

  @override
  Future<void> trackEvent(String name, {Map<String, dynamic>? properties}) async {
    if (trackEvents) events.add(name);
  }
}

// ── Flow Controller Factory ─────────────────────────────────────────

OnboardingFlowController makeTestController({
  required List<OnboardingStep> steps,
  OnboardingBackendService? backend,
  OnboardingAnalyticsService? analytics,
}) {
  final l10n = AppLocalizationsEn();
  return OnboardingFlowController(
    steps: steps,
    backend: backend ?? FakeOnboardingBackendService(),
    analytics: analytics ?? FakeOnboardingAnalyticsService(trackEvents: false),
    validator: DefaultOnboardingValidator(l10n),
    l10n: l10n,
  );
}
