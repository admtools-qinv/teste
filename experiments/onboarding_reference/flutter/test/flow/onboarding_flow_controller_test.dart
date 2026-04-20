import 'package:flutter_test/flutter_test.dart';
import 'package:onboarding_reference/onboarding_reference.dart';

import '../helpers/fake_services.dart';

void main() {
  test('controller advances only with valid answers', () async {
    const steps = [
      OnboardingStep(
        id: 'email',
        type: OnboardingStepType.textInput,
        title: 't',
        caption: 'c',
        voiceText: 'v',
        inputKind: OnboardingInputKind.email,
      ),
      OnboardingStep(
        id: 'done',
        type: OnboardingStepType.completion,
        title: 't2',
        caption: 'c2',
        voiceText: 'v2',
      ),
    ];

    final backend = FakeOnboardingBackendService();
    final analytics = FakeOnboardingAnalyticsService();
    final controller = makeTestController(
      steps: steps,
      backend: backend,
      analytics: analytics,
    );

    final initialized = await controller.initialize();
    expect(initialized, isTrue);
    expect(backend.started, isTrue);
    expect(controller.current.id, 'email');

    final movedWithInvalid = await controller.advanceCurrentStep(inputValue: 'invalid');
    expect(movedWithInvalid, isFalse);
    expect(controller.current.id, 'email');
    expect(controller.validationError, isNotNull);

    final movedWithValid = await controller.advanceCurrentStep(inputValue: 'user@example.com');
    expect(movedWithValid, isTrue);
    expect(controller.current.id, 'done');
    expect(analytics.events, contains('onboarding_step_completed'));
  });
}
