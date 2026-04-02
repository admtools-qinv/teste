abstract class OnboardingAnalyticsService {
  Future<void> trackEvent(String name, {Map<String, dynamic>? properties});
}
