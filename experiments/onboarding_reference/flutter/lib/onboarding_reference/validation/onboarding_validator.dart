import '../../l10n/l10n.dart';
import '../models/onboarding_step.dart';

abstract class OnboardingValidator {
  String? validate(
    OnboardingStep step,
    Object? value, {
    Map<String, dynamic> sessionAnswers,
  });
}

class DefaultOnboardingValidator implements OnboardingValidator {
  final AppLocalizations l10n;

  DefaultOnboardingValidator(this.l10n);

  static final RegExp _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final RegExp _phone = RegExp(r'^\+?[0-9][0-9\s-]{6,}$');
  static final RegExp _cep = RegExp(r'^\d{5}-?\d{3}$');
  static final RegExp _code = RegExp(r'^\d{6}$');
  static final RegExp _pin = RegExp(r'^\d{6}$');

  @override
  String? validate(
    OnboardingStep step,
    Object? value, {
    Map<String, dynamic> sessionAnswers = const {},
  }) {
    switch (step.type) {
      case OnboardingStepType.showcase:
      case OnboardingStepType.intro:
      case OnboardingStepType.completion:
      case OnboardingStepType.review:
      case OnboardingStepType.analysing:
        return null;

      case OnboardingStepType.singleChoice:
        final selected = value?.toString();
        final validIds = step.options.map((o) => o.id).toSet();
        if (selected == null || selected.isEmpty) {
          return step.required ? l10n.validationSelectOption : null;
        }
        if (!validIds.contains(selected)) return l10n.validationSelectOption;
        return null;

      case OnboardingStepType.textInput:
        final text = value?.toString().trim() ?? '';
        if (text.isEmpty) {
          return step.required ? l10n.validationFieldRequired : null;
        }
        if (step.inputKind == OnboardingInputKind.email &&
            !_email.hasMatch(text)) {
          return l10n.validationInvalidEmail;
        }
        if (step.inputKind == OnboardingInputKind.cep &&
            !_cep.hasMatch(text)) {
          return l10n.validationInvalidCep;
        }
        return null;

      case OnboardingStepType.phoneInput:
        final text = value?.toString().trim() ?? '';
        if (text.isEmpty) {
          return step.required ? l10n.validationFieldRequired : null;
        }
        if (!_phone.hasMatch(text)) return l10n.validationInvalidPhone;
        return null;

      case OnboardingStepType.verificationCode:
        final text = value?.toString().trim() ?? '';
        if (text.isEmpty) {
          return step.required ? l10n.validationFieldRequired : null;
        }
        if (!_code.hasMatch(text)) return l10n.validationInvalidCode;
        return null;

      case OnboardingStepType.pinInput:
        final text = value?.toString().trim() ?? '';
        if (text.isEmpty) {
          return step.required ? l10n.validationEnterPin : null;
        }
        if (!_pin.hasMatch(text)) return l10n.validationPinLength;
        if (step.matchesStepId != null) {
          final original = sessionAnswers[step.matchesStepId]?.toString();
          if (original != null && original != text) {
            return l10n.validationPinMismatch;
          }
        }
        return null;
    }
  }
}
