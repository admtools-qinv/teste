import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onboarding_reference/onboarding_reference.dart';

class _TestBackend implements OnboardingBackendService {
  int submitCount = 0;
  Completer<void>? submitCompleter;

  @override
  Future<void> clearAnswer({required String stepId}) async {}

  @override
  Future<void> saveAnswer({required String stepId, required dynamic value}) async {}

  @override
  Future<void> startSession() async {}

  @override
  Future<void> submitAll(Map<String, dynamic> answers) async {
    submitCount += 1;
    final completer = submitCompleter;
    if (completer != null && !completer.isCompleted) {
      await completer.future;
    }
  }
}

class _TestAnalytics implements OnboardingAnalyticsService {
  @override
  Future<void> trackEvent(String name, {Map<String, dynamic>? properties}) async {}
}

void main() {
  testWidgets('shows first step content', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: QInvWeb3Theme.dark(),
        home: OnboardingScreen(
          steps: defaultOnboardingSteps,
          voiceService: NullVoiceService(),
          backend: _TestBackend(),
          analytics: _TestAnalytics(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));

    expect(find.text('Mock onboarding intro'), findsOneWidget);
    expect(find.text('This is a mock onboarding flow.'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.byType(QInvButton), findsWidgets);
  });

  testWidgets('renders required and optional chips for step metadata', (tester) async {
    const steps = [
      OnboardingStep(
        id: 'intro',
        type: OnboardingStepType.intro,
        title: 'Intro',
        caption: 'Caption',
        voiceText: 'Voice',
      ),
      OnboardingStep(
        id: 'choice',
        type: OnboardingStepType.singleChoice,
        title: 'Choice',
        caption: 'Caption',
        voiceText: 'Voice',
        required: false,
        options: [
          OnboardingOption(id: 'a', label: 'Option A'),
        ],
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: QInvWeb3Theme.dark(),
        home: OnboardingScreen(
          steps: steps,
          voiceService: NullVoiceService(),
          backend: _TestBackend(),
          analytics: _TestAnalytics(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));

    expect(find.text('Required'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));
    expect(find.text('Optional'), findsOneWidget);
  });

  testWidgets('rehydrates a selected single choice when going back', (tester) async {
    final backend = _TestBackend();

    const steps = [
      OnboardingStep(
        id: 'intro',
        type: OnboardingStepType.intro,
        title: 'Intro',
        caption: 'Caption',
        voiceText: 'Voice',
      ),
      OnboardingStep(
        id: 'choice',
        type: OnboardingStepType.singleChoice,
        title: 'Choice',
        caption: 'Caption',
        voiceText: 'Voice',
        options: [
          OnboardingOption(id: 'a', label: 'Option A'),
          OnboardingOption(id: 'b', label: 'Option B'),
        ],
      ),
      OnboardingStep(
        id: 'done',
        type: OnboardingStepType.completion,
        title: 'Done',
        caption: 'Caption',
        voiceText: 'Voice',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: QInvWeb3Theme.dark(),
        home: OnboardingScreen(
          steps: steps,
          voiceService: NullVoiceService(),
          backend: backend,
          analytics: _TestAnalytics(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));

    await tester.tap(find.text('Continue').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));

    await tester.tap(find.text('Option A'));
    await tester.pump();
    await tester.tap(find.text('Continue').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));

    await tester.tap(find.text('Back'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));

    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    await tester.tap(find.text('Continue').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets('disables final submit while busy and prevents double completion', (tester) async {
    final backend = _TestBackend()..submitCompleter = Completer<void>();

    const steps = [
      OnboardingStep(
        id: 'intro',
        type: OnboardingStepType.intro,
        title: 'Intro',
        caption: 'Caption',
        voiceText: 'Voice',
      ),
      OnboardingStep(
        id: 'choice',
        type: OnboardingStepType.singleChoice,
        title: 'Choice',
        caption: 'Caption',
        voiceText: 'Voice',
        options: [
          OnboardingOption(id: 'a', label: 'Option A'),
        ],
      ),
      OnboardingStep(
        id: 'review',
        type: OnboardingStepType.review,
        title: 'Review',
        caption: 'Caption',
        voiceText: 'Voice',
      ),
      OnboardingStep(
        id: 'done',
        type: OnboardingStepType.completion,
        title: 'Done',
        caption: 'Caption',
        voiceText: 'Voice',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: QInvWeb3Theme.dark(),
        home: OnboardingScreen(
          steps: steps,
          voiceService: NullVoiceService(),
          backend: backend,
          analytics: _TestAnalytics(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));

    await tester.tap(find.text('Continue').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));

    await tester.tap(find.text('Option A'));
    await tester.pump();
    await tester.tap(find.text('Continue').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));

    await tester.tap(find.text('Confirm'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));

    await tester.tap(find.text('Finish'));
    await tester.pump();

    expect(backend.submitCount, 1);
    expect(find.byType(CircularProgressIndicator), findsWidgets);

    await tester.tap(find.text('Finish'));
    await tester.pump();
    expect(backend.submitCount, 1);

    backend.submitCompleter!.complete();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));

    expect(find.text('Completed'), findsOneWidget);
    await tester.tap(find.text('Completed'));
    await tester.pump();
    expect(backend.submitCount, 1);
  });
}
