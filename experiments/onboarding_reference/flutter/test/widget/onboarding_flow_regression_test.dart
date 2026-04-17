import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onboarding_reference/onboarding_reference.dart';

void main() {
  testWidgets('buildOnboardingSteps contains enough steps for a full onboarding reference', (tester) async {
    late List<OnboardingStep> steps;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            steps = buildOnboardingSteps(AppLocalizations.of(context)!);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(steps.length, greaterThanOrEqualTo(7));
  });
}
