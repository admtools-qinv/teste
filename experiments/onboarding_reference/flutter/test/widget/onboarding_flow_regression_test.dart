import 'package:flutter_test/flutter_test.dart';
import 'package:onboarding_reference/onboarding_reference.dart';

void main() {
  test('mock flow contains enough steps for a full onboarding reference', () {
    expect(defaultOnboardingSteps.length, greaterThanOrEqualTo(7));
  });
}
