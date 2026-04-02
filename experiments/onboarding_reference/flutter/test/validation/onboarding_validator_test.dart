import 'package:flutter_test/flutter_test.dart';
import 'package:onboarding_reference/onboarding_reference.dart';

void main() {
  group('DefaultOnboardingValidator', () {
    test('validates text, phone, verification code and single choice', () {
      const textStep = OnboardingStep(
        id: 'email',
        type: OnboardingStepType.textInput,
        title: 'Email',
        caption: 'Email caption',
        voiceText: 'Email voice',
        inputKind: OnboardingInputKind.email,
      );

      const phoneStep = OnboardingStep(
        id: 'phone',
        type: OnboardingStepType.phoneInput,
        title: 'Phone',
        caption: 'Phone caption',
        voiceText: 'Phone voice',
        inputKind: OnboardingInputKind.phone,
      );

      const codeStep = OnboardingStep(
        id: 'code',
        type: OnboardingStepType.verificationCode,
        title: 'Code',
        caption: 'Code caption',
        voiceText: 'Code voice',
      );

      const choiceStep = OnboardingStep(
        id: 'choice',
        type: OnboardingStepType.singleChoice,
        title: 'Choice',
        caption: 'Choice caption',
        voiceText: 'Choice voice',
        options: [
          OnboardingOption(id: 'a', label: 'A'),
          OnboardingOption(id: 'b', label: 'B'),
        ],
      );

      final validator = DefaultOnboardingValidator();

      expect(validator.validate(textStep, 'user@example.com'), isNull);
      expect(validator.validate(textStep, 'invalid'), isNotNull);
      expect(validator.validate(phoneStep, '+55 11 99999-0000'), isNull);
      expect(validator.validate(codeStep, '123456'), isNull);
      expect(validator.validate(choiceStep, 'a'), isNull);
      expect(validator.validate(choiceStep, 'z'), isNotNull);
    });
  });
}
