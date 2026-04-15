import '../models/onboarding_step.dart';

/// Método de autenticação usado no cadastro.
enum AuthMethod { emailPassword, google }

/// IDs dos steps pulados no fluxo Google (email/verificação/PIN já resolvidos).
const _googleSkipIds = {'email', 'emailCode', 'pin', 'confirmPin'};

/// Retorna os steps de onboarding filtrados por método de autenticação.
List<OnboardingStep> onboardingStepsFor(AuthMethod method) {
  if (method == AuthMethod.emailPassword) return defaultOnboardingSteps;
  return defaultOnboardingSteps
      .where((s) => !_googleSkipIds.contains(s.id))
      .toList();
}

const defaultOnboardingSteps = <OnboardingStep>[
  // ── Investment profile ─────────────────────────────────────────

  OnboardingStep(
    id: 'welcome',
    type: OnboardingStepType.intro,
    title: "Let's get you",
    titleItalic: 'started.',
    caption: 'Ready in just a few steps.',
    voiceText: "Hey! Welcome. Let's get you started!",
    primaryCtaLabel: 'Get started',
  ),
  OnboardingStep(
    id: 'experience',
    type: OnboardingStepType.singleChoice,
    title: 'How long have you',
    titleItalic: 'been investing?',
    caption: "We'll tailor your experience.",
    voiceText: 'How long have you been investing?',
    options: [
      OnboardingOption(id: 'none', label: 'No experience yet', score: 0),
      OnboardingOption(id: 'basic', label: "I've dabbled a little", score: 5),
      OnboardingOption(id: 'intermediate', label: 'A few years of experience', score: 10),
      OnboardingOption(id: 'advanced', label: 'I know my way around', score: 15),
    ],
  ),
  OnboardingStep(
    id: 'goal',
    type: OnboardingStepType.singleChoice,
    title: "What's your",
    titleItalic: 'financial goal?',
    caption: 'Pick what matters most to you.',
    voiceText: "What's your financial goal?",
    options: [
      OnboardingOption(id: 'preserve', label: 'Protect what I already have', score: 0),
      OnboardingOption(id: 'income', label: 'Generate passive income', score: 8),
      OnboardingOption(id: 'grow', label: 'Grow my wealth over time', score: 15),
      OnboardingOption(id: 'aggressive', label: 'Maximize returns at higher risk', score: 20),
    ],
  ),
  OnboardingStep(
    id: 'timeHorizon',
    type: OnboardingStepType.singleChoice,
    title: 'When might you need',
    titleItalic: 'this money back?',
    caption: 'Longer horizons can handle more volatility.',
    voiceText: 'When might you need this money back?',
    reviewLabel: 'Time horizon',
    options: [
      OnboardingOption(id: 'short', label: 'Within 1 year', score: 0),
      OnboardingOption(id: 'mid', label: '1 to 3 years', score: 5),
      OnboardingOption(id: 'long', label: '3 to 7 years', score: 10),
      OnboardingOption(id: 'very_long', label: 'More than 7 years', score: 15),
    ],
  ),
  OnboardingStep(
    id: 'comfort',
    type: OnboardingStepType.singleChoice,
    title: 'How do you handle',
    titleItalic: 'market swings?',
    caption: 'No wrong answers here.',
    voiceText: 'How do you handle market swings?',
    options: [
      OnboardingOption(id: 'low', label: 'I prefer stability above all', score: 0),
      OnboardingOption(id: 'medium_low', label: 'I can accept small fluctuations', score: 5),
      OnboardingOption(id: 'medium', label: 'A balanced approach works for me', score: 10),
      OnboardingOption(id: 'high', label: 'I can handle the ups and downs', score: 15),
    ],
  ),
  OnboardingStep(
    id: 'lossReaction',
    type: OnboardingStepType.singleChoice,
    title: 'If your portfolio drops',
    titleItalic: '20%, you would…',
    caption: 'Be honest — there are no wrong answers.',
    voiceText: 'If your portfolio dropped 20 percent, what would you do?',
    reviewLabel: 'Loss reaction',
    options: [
      OnboardingOption(id: 'panic', label: 'Sell everything immediately', score: 0),
      OnboardingOption(id: 'reduce', label: 'Sell some to reduce exposure', score: 8),
      OnboardingOption(id: 'hold', label: 'Hold and wait for recovery', score: 15),
      OnboardingOption(id: 'buy', label: 'Buy more at the lower price', score: 20),
    ],
  ),
  OnboardingStep(
    id: 'allocation',
    type: OnboardingStepType.singleChoice,
    title: 'What portion of savings',
    titleItalic: 'is this investment?',
    caption: 'Helps us understand your overall exposure.',
    voiceText: 'What portion of your savings is this investment?',
    reviewLabel: 'Portfolio share',
    options: [
      OnboardingOption(id: 'very_low', label: 'Less than 10%', score: 15),
      OnboardingOption(id: 'low', label: '10% to 25%', score: 10),
      OnboardingOption(id: 'medium', label: '25% to 50%', score: 5),
      OnboardingOption(id: 'high', label: 'More than 50%', score: 0),
    ],
  ),

  // ── Personal information ───────────────────────────────────────

  OnboardingStep(
    id: 'fullName',
    type: OnboardingStepType.textInput,
    title: "What's your",
    titleItalic: 'full name?',
    caption: 'As it appears on your official ID.',
    voiceText: "What's your full name? Nice to meet you, by the way.",
    placeholder: 'John Doe',
    inputKind: OnboardingInputKind.name,
    reviewLabel: 'Full name',
  ),
  OnboardingStep(
    id: 'email',
    type: OnboardingStepType.textInput,
    title: "What's your",
    titleItalic: 'email address?',
    caption: "We'll send a verification code.",
    voiceText: "What's your email address?",
    placeholder: 'you@example.com',
    inputKind: OnboardingInputKind.email,
    reviewLabel: 'Email',
    sensitive: false,
  ),
  OnboardingStep(
    id: 'emailCode',
    type: OnboardingStepType.verificationCode,
    title: 'Check your',
    titleItalic: 'email.',
    caption: 'Enter the 6-digit code we sent you.',
    voiceText: "Check your email. We've sent you a code.",
    placeholder: '000000',
    reviewLabel: 'Email verified',
    sensitive: true,
  ),
  OnboardingStep(
    id: 'phone',
    type: OnboardingStepType.phoneInput,
    title: 'Add your',
    titleItalic: 'phone number.',
    caption: 'Used for two-factor authentication only.',
    voiceText: 'Enter your phone number with country and area code.',
    placeholder: '+1 555 000 0000',
    inputKind: OnboardingInputKind.phone,
    reviewLabel: 'Phone',
    sensitive: true,
  ),
  OnboardingStep(
    id: 'pin',
    type: OnboardingStepType.pinInput,
    title: 'Create your',
    titleItalic: '6-digit PIN.',
    caption: 'Used to authorize transactions.',
    voiceText: "We are almost there. Let's create your password!",
    reviewLabel: 'PIN',
    sensitive: true,
  ),
  OnboardingStep(
    id: 'confirmPin',
    type: OnboardingStepType.pinInput,
    title: 'Confirm your',
    titleItalic: 'PIN.',
    caption: 'Enter the same PIN again.',
    voiceText: "Okay! Let's confirm your password.",
    reviewLabel: 'PIN confirmed',
    sensitive: true,
    matchesStepId: 'pin',
  ),

  // ── Completion ─────────────────────────────────────────────────

  OnboardingStep(
    id: 'trial',
    type: OnboardingStepType.completion,
    title: "You're all set.",
    titleItalic: "Let's get started.",
    caption: 'Your account is ready. Time to invest.',
    voiceText: "You're all set. Let's get started!",
    primaryCtaLabel: 'Start investing',
  ),
];
