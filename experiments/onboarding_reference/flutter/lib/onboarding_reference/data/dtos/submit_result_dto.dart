/// Returned by [OnboardingBackendService.submitAll].
///
/// [success] indicates whether the server accepted the submission.
/// [redirectUrl] is an optional deep-link or URL the host app should navigate
/// to after a successful onboarding (e.g. `myapp://home`).
class SubmitResultDto {
  final bool success;
  final String? redirectUrl;

  const SubmitResultDto({required this.success, this.redirectUrl});

  factory SubmitResultDto.fromJson(Map<String, dynamic> json) {
    return SubmitResultDto(
      success: json['success'] as bool,
      redirectUrl: json['redirect_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        if (redirectUrl != null) 'redirect_url': redirectUrl,
      };
}
