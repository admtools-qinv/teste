import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onboarding_reference/onboarding_reference.dart';

import '../helpers/fake_services.dart';
import '../helpers/pump_helpers.dart';
import '../helpers/test_app.dart';

void main() {
  testWidgets('shows first step content', (tester) async {
    // Use filtered steps (no showcase) so the intro/welcome step is first.
    // Steps need l10n, so we build them inside a Builder that has context.
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: QInvWeb3Theme.dark(),
        home: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return OnboardingScreen(
              steps: onboardingStepsFor(l10n, AuthMethod.emailPassword, country: IpGeoService.detectCountry()),
              voiceService: NullVoiceService(),
              backend: FakeOnboardingBackendService(),
              analytics: FakeOnboardingAnalyticsService(trackEvents: false),
            );
          },
        ),
      ),
    );

    await pumpAnimations(tester);

    // The welcome step concatenates title + titleItalic ("Let's get you\nstarted.")
    expect(find.textContaining("Let's get you"), findsOneWidget);
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
      buildTestApp(
        home: OnboardingScreen(
          steps: steps,
          voiceService: NullVoiceService(),
          backend: FakeOnboardingBackendService(),
          analytics: FakeOnboardingAnalyticsService(trackEvents: false),
        ),
      ),
    );

    await pumpAnimations(tester);

    expect(find.text('Intro'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await pumpAnimations(tester);
    expect(find.text('Choice step'), findsOneWidget);
    expect(find.text('Option A'), findsOneWidget);
  });

  testWidgets('rehydrates a selected single choice when going back', (tester) async {
    final backend = FakeOnboardingBackendService();

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
      buildTestApp(
        home: OnboardingScreen(
          steps: steps,
          voiceService: NullVoiceService(),
          backend: backend,
          analytics: FakeOnboardingAnalyticsService(trackEvents: false),
        ),
      ),
    );

    await pumpAnimations(tester);

    await tester.tap(find.text('Continue').first);
    await pumpAnimations(tester);

    await tester.tap(find.text('Option A'));
    await tester.pump();
    await tester.tap(find.text('Continue').last);
    await pumpAnimations(tester);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await pumpAnimations(tester);

    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    await tester.tap(find.text('Continue').last);
    await pumpAnimations(tester);
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets('disables final submit while busy and prevents double completion', (tester) async {
    final backend = FakeOnboardingBackendService(submitCompleter: Completer<void>());

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
      buildTestApp(
        home: OnboardingScreen(
          steps: steps,
          voiceService: NullVoiceService(),
          backend: backend,
          analytics: FakeOnboardingAnalyticsService(trackEvents: false),
        ),
      ),
    );

    await pumpAnimations(tester);

    await tester.tap(find.text('Continue').first);
    await pumpAnimations(tester);

    await tester.tap(find.text('Option A'));
    await tester.pump();
    await tester.tap(find.text('Continue').last);
    await pumpAnimations(tester);

    await tester.tap(find.text('Confirm'));
    await pumpAnimations(tester);

    await tester.tap(find.text('Finish'));
    await tester.pump();

    expect(backend.submitCount, 1);
    expect(find.byType(CircularProgressIndicator), findsWidgets);

    // While busy the button shows 'Finishing…'; AbsorbPointer blocks the tap.
    await tester.tap(find.text('Finishing…'));
    await tester.pump();
    expect(backend.submitCount, 1);

    backend.submitCompleter!.complete();
    await pumpAnimations(tester);

    expect(find.text('Completed'), findsOneWidget);
    await tester.tap(find.text('Completed'));
    await tester.pump();
    expect(backend.submitCount, 1);
  });
}
