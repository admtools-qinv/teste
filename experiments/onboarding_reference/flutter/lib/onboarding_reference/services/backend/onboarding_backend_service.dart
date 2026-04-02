abstract class OnboardingBackendService {
  Future<void> startSession();
  Future<void> saveAnswer({required String stepId, required dynamic value});
  Future<void> submitAll(Map<String, dynamic> answers);
  Future<void> clearAnswer({required String stepId});
}
