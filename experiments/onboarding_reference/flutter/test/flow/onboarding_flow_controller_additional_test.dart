import 'package:flutter_test/flutter_test.dart';
import 'package:onboarding_reference/onboarding_reference.dart';

import '../helpers/fake_services.dart';

void main() {
  test('initialize clears busy state on failure', () async {
    const steps = [
      OnboardingStep(
        id: 'welcome',
        type: OnboardingStepType.intro,
        title: 't',
        caption: 'c',
        voiceText: 'v',
      ),
    ];

    final controller = makeTestController(
      steps: steps,
      backend: FakeOnboardingBackendService(startSessionError: Exception('boom')),
    );

    final initialized = await controller.initialize();
    expect(initialized, isFalse);
    expect(controller.isBusy, isFalse);
    expect(controller.serviceError, isNotNull);
  });

  test('empty steps are rejected by assertion', () {
    expect(
      () => makeTestController(steps: const []),
      throwsA(isA<AssertionError>()),
    );
  });

  test('optional answers can be cleared and do not advance stale data', () async {
    const steps = [
      OnboardingStep(
        id: 'nickname',
        type: OnboardingStepType.textInput,
        title: 't',
        caption: 'c',
        voiceText: 'v',
        required: false,
      ),
      OnboardingStep(
        id: 'done',
        type: OnboardingStepType.completion,
        title: 't2',
        caption: 'c2',
        voiceText: 'v2',
      ),
    ];

    final controller = makeTestController(steps: steps);

    await controller.initialize();
    final first = await controller.advanceCurrentStep(inputValue: 'Nick');
    expect(first, isTrue);
    expect(controller.session.answers['nickname'], 'Nick');

    controller.index = 0;
    final cleared = await controller.advanceCurrentStep(inputValue: '');
    expect(cleared, isTrue);
    expect(controller.session.answers.containsKey('nickname'), isFalse);
  });

  test('clearing optional answer requests backend clear and resets validation', () async {
    const steps = [
      OnboardingStep(
        id: 'nickname',
        type: OnboardingStepType.textInput,
        title: 't',
        caption: 'c',
        voiceText: 'v',
        required: false,
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
    final controller = makeTestController(steps: steps, backend: backend);

    await controller.initialize();
    await controller.advanceCurrentStep(inputValue: 'Nick');
    controller.index = 0;

    final cleared = await controller.advanceCurrentStep(inputValue: '');
    expect(cleared, isTrue);
    expect(backend.cleared, contains('nickname'));
    expect(controller.validationError, isNull);
  });

  test('optional single choice can be skipped without blocking progress', () async {
    const steps = [
      OnboardingStep(
        id: 'choice',
        type: OnboardingStepType.singleChoice,
        title: 't',
        caption: 'c',
        voiceText: 'v',
        required: false,
        options: [
          OnboardingOption(id: 'a', label: 'A'),
        ],
      ),
      OnboardingStep(
        id: 'done',
        type: OnboardingStepType.completion,
        title: 't2',
        caption: 'c2',
        voiceText: 'v2',
      ),
    ];

    final controller = makeTestController(steps: steps);

    await controller.initialize();

    final advanced = await controller.advanceCurrentStep();
    expect(advanced, isTrue);
    expect(controller.current.id, 'done');
    expect(controller.session.answers.containsKey('choice'), isFalse);
  });
}
