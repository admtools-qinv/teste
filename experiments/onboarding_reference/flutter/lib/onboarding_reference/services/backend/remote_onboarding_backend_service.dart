import 'onboarding_backend_service.dart';

/// Skeleton HTTP implementation of [OnboardingBackendService].
///
/// Copy this class into your project, add your preferred HTTP client
/// (e.g. `dio` or the `http` package), and replace each TODO block with
/// the real API call. The endpoint patterns below follow REST conventions
/// and should be adjusted to match your actual backend routes.
///
/// ```dart
/// // Wiring example in your app:
/// OnboardingScreen(
///   steps: defaultOnboardingSteps,
///   backend: RemoteOnboardingBackendService(
///     baseUrl: 'https://api.yourapp.com/v1',
///     headers: {'Authorization': 'Bearer $token'},
///   ),
/// )
/// ```
class RemoteOnboardingBackendService implements OnboardingBackendService {
  final String baseUrl;
  final Map<String, String> headers;

  const RemoteOnboardingBackendService({
    required this.baseUrl,
    this.headers = const {'Content-Type': 'application/json'},
  });

  @override
  Future<OnboardingSessionDto> startSession() async {
    // TODO: POST $baseUrl/onboarding/sessions
    //
    // Expected response body:
    //   { "session_id": "<uuid>" }
    //
    // Example using the `http` package:
    //   final res = await http.post(
    //     Uri.parse('$baseUrl/onboarding/sessions'),
    //     headers: headers,
    //   );
    //   _assertOk(res);
    //   return OnboardingSessionDto.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    throw UnimplementedError(
      'RemoteOnboardingBackendService.startSession — '
      'implement POST $baseUrl/onboarding/sessions',
    );
  }

  @override
  Future<void> saveAnswer({
    required String sessionId,
    required String stepId,
    required dynamic value,
  }) async {
    // TODO: POST $baseUrl/onboarding/sessions/$sessionId/answers
    //
    // Expected request body:
    //   { "step_id": "$stepId", "value": <value> }
    //
    // Example:
    //   final res = await http.post(
    //     Uri.parse('$baseUrl/onboarding/sessions/$sessionId/answers'),
    //     headers: headers,
    //     body: jsonEncode({'step_id': stepId, 'value': value}),
    //   );
    //   _assertOk(res);
    throw UnimplementedError(
      'RemoteOnboardingBackendService.saveAnswer — '
      'implement POST $baseUrl/onboarding/sessions/$sessionId/answers',
    );
  }

  @override
  Future<SubmitResultDto> submitAll({
    required String sessionId,
    required Map<String, dynamic> answers,
  }) async {
    // TODO: POST $baseUrl/onboarding/sessions/$sessionId/submit
    //
    // Expected request body: the full answers map as JSON.
    // Expected response body:
    //   { "success": true, "redirect_url": "myapp://home" }
    //
    // Example:
    //   final res = await http.post(
    //     Uri.parse('$baseUrl/onboarding/sessions/$sessionId/submit'),
    //     headers: headers,
    //     body: jsonEncode(answers),
    //   );
    //   _assertOk(res);
    //   return SubmitResultDto.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    throw UnimplementedError(
      'RemoteOnboardingBackendService.submitAll — '
      'implement POST $baseUrl/onboarding/sessions/$sessionId/submit',
    );
  }

  @override
  Future<void> clearAnswer({
    required String sessionId,
    required String stepId,
  }) async {
    // TODO: DELETE $baseUrl/onboarding/sessions/$sessionId/answers/$stepId
    //
    // Example:
    //   final res = await http.delete(
    //     Uri.parse('$baseUrl/onboarding/sessions/$sessionId/answers/$stepId'),
    //     headers: headers,
    //   );
    //   _assertOk(res);
    throw UnimplementedError(
      'RemoteOnboardingBackendService.clearAnswer — '
      'implement DELETE $baseUrl/onboarding/sessions/$sessionId/answers/$stepId',
    );
  }

  // Helper — uncomment when you add an HTTP client:
  // void _assertOk(http.Response res) {
  //   if (res.statusCode < 200 || res.statusCode >= 300) {
  //     throw Exception('HTTP ${res.statusCode}: ${res.body}');
  //   }
  // }
}
