import 'onboarding_backend_service.dart';

/// No-op implementation of [OnboardingBackendService].
///
/// All calls succeed silently. Use this during UI development or widget tests
/// when a real backend is not needed.
class NoopOnboardingBackendService implements OnboardingBackendService {
  @override
  Future<OnboardingSessionDto> startSession() async {
    return const OnboardingSessionDto(sessionId: 'noop-session');
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
