# Flutter package — production-grade onboarding reference

This package contains a production-minded onboarding flow reference built for handoff.

## Included
- full onboarding flow
- stateful controller with validation
- input widgets
- review screen
- error states
- captions and voice service abstraction
- backend and analytics stubs
- unit tests and widget tests
- design system theme

## How to use
- wire a real `OnboardingBackendService`
- wire a real `OnboardingAnalyticsService`
- wire a real `VoiceService` if you do not want the default TTS implementation
- replace mock values in `default_steps.dart` with real product data

## Quality expectations
- all transitions gated by validation
- invalid inputs blocked
- no business backend hardcoded in UI
- tests should pass before shipping
