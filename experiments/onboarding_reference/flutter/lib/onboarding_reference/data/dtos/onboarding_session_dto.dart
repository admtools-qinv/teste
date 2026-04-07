/// Returned by [OnboardingBackendService.startSession].
///
/// The [sessionId] must be forwarded to every subsequent backend call so the
/// server can correlate answers with the same onboarding session.
class OnboardingSessionDto {
  final String sessionId;

  const OnboardingSessionDto({required this.sessionId});

  factory OnboardingSessionDto.fromJson(Map<String, dynamic> json) {
    return OnboardingSessionDto(
      sessionId: json['session_id'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'session_id': sessionId};
}
