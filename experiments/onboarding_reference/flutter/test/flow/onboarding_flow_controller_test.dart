import 'package:flutter_test/flutter_test.dart';
import 'package:onboarding_reference/l10n/app_localizations_en.dart';
import 'package:onboarding_reference/onboarding_reference.dart';

class _FakeBackend implements OnboardingBackendService {
  final Map<String, dynamic> saved = {};
  final List<String> cleared = [];
  bool started = false;
  bool submitted = false;

  @override
  Future<void> clearAnswer({required String sessionId, required String stepId}) async {
    cleared.add(stepId);
    saved.remove(stepId);
  }

  @override
  Future<void> saveAnswer({
    required String sessionId,
    required String stepId,
    required dynamic value,
  }) async {
    saved[stepId] = value;
  }

  @override
  Future<OnboardingSessionDto> startSession() async {
    started = true;
    return const OnboardingSessionDto(sessionId: 'test-session');
  }

  @override
  Future<SubmitResultDto> submitAll({
    required String sessionId,
    required Map<String, dynamic> answers,
  }) async {
    submitted = true;
    return const SubmitResultDto(success: true);
  }
}

class _FakeAnalytics implements OnboardingAnalyticsService {
  final List<String> events = [];

  @override
  Future<void> trackEvent(String name, {Map<String, dynamic>? properties}) async {
    events.add(name);
  }
}

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

    final backend = _FakeBackend();
    final analytics = _FakeAnalytics();
    final controller = OnboardingFlowController(
      steps: steps,
      backend: backend,
      analytics: analytics,
      validator: DefaultOnboardingValidator(AppLocalizationsEn()),
      l10n: AppLocalizationsEn(),
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
