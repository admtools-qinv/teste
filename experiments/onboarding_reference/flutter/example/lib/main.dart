import 'package:flutter/material.dart';
import 'package:onboarding_reference/onboarding_reference.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: QInvWeb3Theme.dark(),
      home: const _LoginEntry(),
    );
  }
}

// ── Login entry point ────────────────────────────────────────────

class _LoginEntry extends StatelessWidget {
  const _LoginEntry();

  @override
  Widget build(BuildContext context) {
    return LoginScreen(
      onGoogleAuth: () {
        // TODO: implement Google auth
      },
      onSignUp: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (ctx) => OnboardingScreen(
              steps: defaultOnboardingSteps,
              voiceService: FlutterTtsVoiceService(),
              backend: _ExampleBackend(),
              analytics: _ExampleAnalytics(),
              onExit: () => Navigator.of(ctx).pop(),
            ),
          ),
        );
      },
      onLogin: () {
        // TODO: implement email/password login
      },
    );
  }
}

// ── Stub implementations ─────────────────────────────────────────

class _ExampleBackend implements OnboardingBackendService {
  @override
  Future<OnboardingSessionDto> startSession() async {
    return const OnboardingSessionDto(sessionId: 'example-session');
  }

  @override
  Future<void> saveAnswer({
    required String sessionId,
    required String stepId,
    required dynamic value,
  }) async {}

  @override
  Future<SubmitResultDto> submitAll({
    required String sessionId,
    required Map<String, dynamic> answers,
  }) async {
    return const SubmitResultDto(success: true);
  }

  @override
  Future<void> clearAnswer({
    required String sessionId,
    required String stepId,
  }) async {}
}

class _ExampleAnalytics implements OnboardingAnalyticsService {
  @override
  Future<void> trackEvent(String name,
      {Map<String, dynamic>? properties}) async {}
}
