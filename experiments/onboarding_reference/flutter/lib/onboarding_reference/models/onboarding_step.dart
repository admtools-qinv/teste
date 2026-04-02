enum OnboardingStepType {
  intro,
  singleChoice,
  textInput,
  phoneInput,
  verificationCode,
  review,
  completion,
}

enum OnboardingInputKind {
  email,
  phone,
}

class OnboardingOption {
  final String id;
  final String label;

  const OnboardingOption({
    required this.id,
    required this.label,
  });
}

class OnboardingStep {
  final String id;
  final OnboardingStepType type;
  final String title;
  final String? reviewLabel;
  final String caption;
  final String voiceText;
  final List<OnboardingOption> options;
  final String? primaryCtaLabel;
  final String? placeholder;
  final OnboardingInputKind? inputKind;
  final bool required;
  final bool sensitive;

  const OnboardingStep({
    required this.id,
    required this.type,
    required this.title,
    this.reviewLabel,
    required this.caption,
    required this.voiceText,
    this.options = const [],
    this.primaryCtaLabel,
    this.placeholder,
    this.inputKind,
    this.required = true,
    this.sensitive = false,
  });
}
