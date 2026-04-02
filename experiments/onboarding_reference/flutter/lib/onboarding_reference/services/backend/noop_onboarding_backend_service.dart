import 'onboarding_backend_service.dart';

class NoopOnboardingBackendService implements OnboardingBackendService {
  @override
  Future<void> clearAnswer({required String stepId}) async {}

  @override
  Future<void> saveAnswer({required String stepId, required dynamic value}) async {}

  @override
  Future<void> startSession() async {}

  @override
  Future<void> submitAll(Map<String, dynamic> answers) async {}
}
