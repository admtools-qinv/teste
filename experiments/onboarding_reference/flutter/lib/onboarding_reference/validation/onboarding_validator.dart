import '../models/onboarding_step.dart';

abstract class OnboardingValidator {
  String? validate(OnboardingStep step, Object? value);
}

class DefaultOnboardingValidator implements OnboardingValidator {
  static final RegExp _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final RegExp _phone = RegExp(r'^\+?[0-9][0-9\s-]{6,}$');
  static final RegExp _code = RegExp(r'^\d{6}$');

  @override
  String? validate(OnboardingStep step, Object? value) {
    switch (step.type) {
      case OnboardingStepType.intro:
      case OnboardingStepType.completion:
      case OnboardingStepType.review:
        return null;
      case OnboardingStepType.singleChoice:
        final selected = value?.toString();
        final validIds = step.options.map((option) => option.id).toSet();
        if (selected == null || selected.isEmpty) {
          return step.required ? 'Please select one option.' : null;
        }
        if (!validIds.contains(selected)) {
          return 'Please select one option.';
        }
        return null;
      case OnboardingStepType.textInput:
        final text = value?.toString().trim() ?? '';
        if (text.isEmpty) {
          return step.required ? 'This field is required.' : null;
        }
        if (step.inputKind == OnboardingInputKind.email && !_email.hasMatch(text)) {
          return 'Enter a valid email address.';
        }
        return null;
      case OnboardingStepType.phoneInput:
        final text = value?.toString().trim() ?? '';
        if (text.isEmpty) {
          return step.required ? 'This field is required.' : null;
        }
        if (!_phone.hasMatch(text)) return 'Enter a valid phone number.';
        return null;
      case OnboardingStepType.verificationCode:
        final text = value?.toString().trim() ?? '';
        if (text.isEmpty) {
          return step.required ? 'This field is required.' : null;
        }
        if (!_code.hasMatch(text)) return 'Enter the 6-digit code.';
        return null;
    }
  }
}
