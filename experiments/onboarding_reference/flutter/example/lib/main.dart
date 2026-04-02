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
      home: const _ExampleHome(),
    );
  }
}

class _ExampleHome extends StatelessWidget {
  const _ExampleHome();

  @override
  Widget build(BuildContext context) {
    return OnboardingScreen(
      steps: defaultOnboardingSteps,
      voiceService: NullVoiceService(),
      backend: _ExampleBackend(),
      analytics: _ExampleAnalytics(),
    );
  }
}

class _ExampleBackend implements OnboardingBackendService {
  @override
  Future<void> clearAnswer({required String stepId}) async {}

  @override
  Future<void> saveAnswer({required String stepId, required dynamic value}) async {}

  @override
  Future<void> startSession() async {}

  @override
  Future<void> submitAll(Map<String, dynamic> answers) async {}
}

class _ExampleAnalytics implements OnboardingAnalyticsService {
  @override
  Future<void> trackEvent(String name, {Map<String, dynamic>? properties}) async {}
}
