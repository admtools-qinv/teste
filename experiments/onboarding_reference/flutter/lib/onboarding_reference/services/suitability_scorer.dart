import '../models/onboarding_step.dart';

enum SuitabilityProfile {
  conservative,
  moderate,
  aggressive;

  String get label => switch (this) {
        conservative => 'Conservative Investor',
        moderate => 'Moderate Investor',
        aggressive => 'Aggressive Investor',
      };

  String get description => switch (this) {
        conservative => 'Focus on stability. BTC, ETH, and stablecoins.',
        moderate => 'Balanced approach. Top coins with selective risk.',
        aggressive => 'Full access to all features and asset classes.',
      };
}

class SuitabilityResult {
  final int score;
  final SuitabilityProfile profile;

  const SuitabilityResult({
    required this.score,
    required this.profile,
  });

  bool get showVolatilityWarning => score <= SuitabilityScorer._warningThreshold;
}

class SuitabilityScorer {
  static const _moderateThreshold = 36;
  static const _aggressiveThreshold = 71;
  static const _warningThreshold = 15;

  static SuitabilityResult compute(
    List<OnboardingStep> steps,
    Map<String, dynamic> answers,
  ) {
    var total = 0;

    for (final step in steps) {
      if (step.type != OnboardingStepType.singleChoice) continue;
      if (step.options.every((o) => o.score == 0)) continue;

      final answerId = answers[step.id];
      if (answerId == null) continue;

      for (final option in step.options) {
        if (option.id == answerId) {
          total += option.score;
          break;
        }
      }
    }

    assert(total >= 0 && total <= 100,
        'Suitability score $total out of expected 0–100 range');
    total = total.clamp(0, 100);

    final profile = total >= _aggressiveThreshold
        ? SuitabilityProfile.aggressive
        : total >= _moderateThreshold
            ? SuitabilityProfile.moderate
            : SuitabilityProfile.conservative;

    return SuitabilityResult(score: total, profile: profile);
  }
}
