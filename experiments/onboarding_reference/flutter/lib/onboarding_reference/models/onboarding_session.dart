class OnboardingSession {
  final Map<String, dynamic> answers;

  const OnboardingSession({this.answers = const {}});

  OnboardingSession copyWithAnswer(String key, Object? value) {
    final next = Map<String, dynamic>.from(answers)..[key] = value;
    return OnboardingSession(answers: next);
  }

  OnboardingSession copyWithoutAnswer(String key) {
    if (!answers.containsKey(key)) {
      return this;
    }

    final next = Map<String, dynamic>.from(answers)..remove(key);
    return OnboardingSession(answers: next);
  }
}
