import 'package:flutter_test/flutter_test.dart';
import 'package:onboarding_reference/l10n/app_localizations_en.dart';
import 'package:onboarding_reference/onboarding_reference.dart';

class _FailingBackend implements OnboardingBackendService {
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
    throw Exception('boom');
  }

  @override
  Future<SubmitResultDto> submitAll({
    required String sessionId,
    required Map<String, dynamic> answers,
  }) async {
    return const SubmitResultDto(success: true);
  }
}

class _NoopAnalytics implements OnboardingAnalyticsService {
  @override
  Future<void> trackEvent(String name, {Map<String, dynamic>? properties}) async {}
}

class _NoopBackend implements OnboardingBackendService {
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
    return const SubmitResultDto(success: true);
  }
}

class _TrackingBackend implements OnboardingBackendService {
  final List<String> cleared = [];

  @override
  Future<void> clearAnswer({required String sessionId, required String stepId}) async {
    cleared.add(stepId);
  }

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
    return const SubmitResultDto(success: true);
  }
}

class _FlakySaveBackend implements OnboardingBackendService {
  bool failNextSave = true;
  int saveCalls = 0;

  @override
  Future<void> clearAnswer({required String sessionId, required String stepId}) async {}

  @override
  Future<void> saveAnswer({
    required String sessionId,
    required String stepId,
    required dynamic value,
  }) async {
    saveCalls += 1;
    if (failNextSave) {
      failNextSave = false;
      throw Exception('save failed');
    }
  }

  @override
  Future<OnboardingSessionDto> startSession() async {
    return const OnboardingSessionDto(sessionId: 'test-session');
  }

  @override
  Future<SubmitResultDto> submitAll({
    required String sessionId,
    required Map<String, dynamic> answers,
  }) async {
    return const SubmitResultDto(success: true);
  }
}

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

    final controller = OnboardingFlowController(
      steps: steps,
      backend: _FailingBackend(),
      analytics: _NoopAnalytics(),
      validator: DefaultOnboardingValidator(AppLocalizationsEn()),
      l10n: AppLocalizationsEn(),
    );

    final initialized = await controller.initialize();
    expect(initialized, isFalse);
    expect(controller.isBusy, isFalse);
    expect(controller.serviceError, isNotNull);
  });

  test('empty steps are rejected by assertion', () {
    expect(
      () => OnboardingFlowController(
        steps: const [],
        backend: _NoopBackend(),
        analytics: _NoopAnalytics(),
        validator: DefaultOnboardingValidator(AppLocalizationsEn()),
        l10n: AppLocalizationsEn(),
      ),
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

    final controller = OnboardingFlowController(
      steps: steps,
      backend: _NoopBackend(),
      analytics: _NoopAnalytics(),
      validator: DefaultOnboardingValidator(AppLocalizationsEn()),
      l10n: AppLocalizationsEn(),
    );

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

    final backend = _TrackingBackend();
    final controller = OnboardingFlowController(
      steps: steps,
      backend: backend,
      analytics: _NoopAnalytics(),
      validator: DefaultOnboardingValidator(AppLocalizationsEn()),
      l10n: AppLocalizationsEn(),
    );

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

    final controller = OnboardingFlowController(
      steps: steps,
      backend: _NoopBackend(),
      analytics: _NoopAnalytics(),
      validator: DefaultOnboardingValidator(AppLocalizationsEn()),
      l10n: AppLocalizationsEn(),
    );

    await controller.initialize();

    final advanced = await controller.advanceCurrentStep();
    expect(advanced, isTrue);
    expect(controller.current.id, 'done');
    expect(controller.session.answers.containsKey('choice'), isFalse);
  });
}
