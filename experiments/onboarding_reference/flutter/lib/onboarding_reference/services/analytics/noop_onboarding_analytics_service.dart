import 'onboarding_analytics_service.dart';

class NoopOnboardingAnalyticsService implements OnboardingAnalyticsService {
  @override
  Future<void> trackEvent(String name, {Map<String, dynamic>? properties}) async {}
}
