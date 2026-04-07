import '../../data/dtos/onboarding_session_dto.dart';
import '../../data/dtos/submit_result_dto.dart';

export '../../data/dtos/onboarding_session_dto.dart';
export '../../data/dtos/submit_result_dto.dart';

/// Contract between the onboarding flow and the host app's backend.
///
/// Implement this interface to connect the onboarding to a real API.
/// Use [NoopOnboardingBackendService] during development or UI testing.
/// Use [RemoteOnboardingBackendService] as a starting point for HTTP integration.
abstract class OnboardingBackendService {
  /// Creates a new onboarding session on the server.
  ///
  /// Called once before the first step is shown. Returns an
  /// [OnboardingSessionDto] whose [sessionId] is forwarded to every
  /// subsequent call so the server can correlate answers.
  Future<OnboardingSessionDto> startSession();

  /// Persists a single answer for [stepId] under the given [sessionId].
  ///
  /// Called each time the user advances a step with a non-empty answer.
  Future<void> saveAnswer({
    required String sessionId,
    required String stepId,
    required dynamic value,
  });

  /// Finalises the onboarding session and submits all collected [answers].
  ///
  /// Called once when the user completes the last step. Returns a
  /// [SubmitResultDto] indicating success and an optional deep-link.
  Future<SubmitResultDto> submitAll({
    required String sessionId,
    required Map<String, dynamic> answers,
  });

  /// Removes a previously saved answer for [stepId] from the session.
  ///
  /// Called when the user clears an optional field and goes back.
  Future<void> clearAnswer({
    required String sessionId,
    required String stepId,
  });
}
