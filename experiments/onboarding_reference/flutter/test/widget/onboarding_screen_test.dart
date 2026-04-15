import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onboarding_reference/onboarding_reference.dart';

class _TestBackend implements OnboardingBackendService {
  int submitCount = 0;
  Completer<void>? submitCompleter;

  @override
  Future<void> clearAnswer({required String sessionId, required String stepId}) async {}

  @override
  Future<void> saveAnswer({
    required String sessionId,
    required String stepId,
    required dynamic value,
  }) async {}

  @override
  Future<OnboardingSessionDto> startSession() async {
    return const OnboardingSessionDto(sessionId: 'test-session');
  }

  @override
  Future<SubmitResultDto> submitAll({
    required String sessionId,
    required Map<String, dynamic> answers,
  }) async {
    submitCount += 1;
    final completer = submitCompleter;
    if (completer != null && !completer.isCompleted) {
      await completer.future;
    }
    return const SubmitResultDto(success: true);
  }
}

class _TestAnalytics implements OnboardingAnalyticsService {
  @override
  Future<void> trackEvent(String name, {Map<String, dynamic>? properties}) async {}
}

/// Pumps enough frames to settle finite flutter_animate animations
/// without blocking on GlassBackground's infinite orb loop.
Future<void> _pumpAnimations(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
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

    await _pumpAnimations(tester);

    expect(find.text("Let's get you"), findsOneWidget);
    expect(find.text('Ready in just a few steps.'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
    expect(find.byType(QInvButton), findsWidgets);
  });

  testWidgets('advances from intro to singleChoice on Continue tap', (tester) async {
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
        title: 'Choice step',
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

    await _pumpAnimations(tester);

    expect(find.text('Intro'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await _pumpAnimations(tester);
    expect(find.text('Choice step'), findsOneWidget);
    expect(find.text('Option A'), findsOneWidget);
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

    await _pumpAnimations(tester);

    await tester.tap(find.text('Continue').first);
    await _pumpAnimations(tester);

    await tester.tap(find.text('Option A'));
    await tester.pump();
    await tester.tap(find.text('Continue').last);
    await _pumpAnimations(tester);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await _pumpAnimations(tester);

    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    await tester.tap(find.text('Continue').last);
    await _pumpAnimations(tester);
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

    await _pumpAnimations(tester);

    await tester.tap(find.text('Continue').first);
    await _pumpAnimations(tester);

    await tester.tap(find.text('Option A'));
    await tester.pump();
    await tester.tap(find.text('Continue').last);
    await _pumpAnimations(tester);

    await tester.tap(find.text('Confirm'));
    await _pumpAnimations(tester);

    await tester.tap(find.text('Finish'));
    await tester.pump();

    expect(backend.submitCount, 1);
    expect(find.byType(CircularProgressIndicator), findsWidgets);

    // While busy the button shows 'Finishing…'; AbsorbPointer blocks the tap.
    await tester.tap(find.text('Finishing…'));
    await tester.pump();
    expect(backend.submitCount, 1);

    backend.submitCompleter!.complete();
    await _pumpAnimations(tester);

    expect(find.text('Completed'), findsOneWidget);
    await tester.tap(find.text('Completed'));
    await tester.pump();
    expect(backend.submitCount, 1);
  });
}
