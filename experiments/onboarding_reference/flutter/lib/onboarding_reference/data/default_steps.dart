import '../../l10n/l10n.dart';

import '../models/country.dart';
import '../models/onboarding_step.dart';

/// Método de autenticação usado no cadastro.
enum AuthMethod { emailPassword, google }

/// IDs dos steps pulados no fluxo Google (email/verificação/PIN já resolvidos).
const _googleSkipIds = {'email', 'emailCode', 'pin', 'confirmPin'};

/// IDs dos steps exclusivos para usuários no Brasil.
const _brazilOnlyIds = {'accountType', 'pep', 'cep'};

/// Retorna os steps de onboarding filtrados por método de autenticação e país.
/// Showcase steps são sempre excluídos — são exibidos antes da tela de login.
/// O step [accountType] só aparece quando [country] é BR.
List<OnboardingStep> onboardingStepsFor(
  AppLocalizations l10n,
  AuthMethod method, {
  Country? country,
}) {
  final isBrazil = country?.code == 'BR';
  var steps = buildOnboardingSteps(l10n)
      .where((s) => s.type != OnboardingStepType.showcase);
  if (!isBrazil) {
    steps = steps.where((s) => !_brazilOnlyIds.contains(s.id));
  }
  if (method == AuthMethod.google) {
    return steps.where((s) => !_googleSkipIds.contains(s.id)).toList();
  }
  return steps.toList();
}

/// Steps de showcase (tour/overview pré-login).
List<OnboardingStep> showcaseSteps(AppLocalizations l10n) =>
    buildOnboardingSteps(l10n)
        .where((s) => s.type == OnboardingStepType.showcase)
        .toList();

List<OnboardingStep> buildOnboardingSteps(AppLocalizations l10n) => [
  // ── Showcase (pre-sign-up overview) ────────────────────────────

  OnboardingStep(
    id: 'showcaseWelcome',
    type: OnboardingStepType.showcase,
    title: l10n.stepShowcaseWelcomeTitle,
    caption: l10n.stepShowcaseWelcomeCaption,
    voiceText: l10n.stepShowcaseWelcomeVoice,
    primaryCtaLabel: l10n.stepShowcaseWelcomeCta,
    required: false,
  ),
  OnboardingStep(
    id: 'showcaseAnalysis',
    type: OnboardingStepType.showcase,
    title: l10n.stepShowcaseAnalysisTitle,
    caption: '',
    voiceText: l10n.stepShowcaseAnalysisVoice,
    primaryCtaLabel: l10n.stepShowcaseAnalysisCta,
    required: false,
  ),
  OnboardingStep(
    id: 'showcaseAI',
    type: OnboardingStepType.showcase,
    title: l10n.stepShowcaseAITitle,
    caption: '',
    voiceText: l10n.stepShowcaseAIVoice,
    primaryCtaLabel: l10n.stepShowcaseAICta,
    required: false,
  ),
  OnboardingStep(
    id: 'showcaseReviews',
    type: OnboardingStepType.showcase,
    title: l10n.stepShowcaseReviewsTitle,
    caption: '',
    voiceText: l10n.stepShowcaseReviewsVoice,
    primaryCtaLabel: l10n.stepShowcaseReviewsCta,
    required: false,
  ),

  // ── Investment profile ─────────────────────────────────────────

  OnboardingStep(
    id: 'welcome',
    type: OnboardingStepType.intro,
    title: l10n.stepWelcomeTitle,
    titleItalic: l10n.stepWelcomeTitleItalic,
    caption: l10n.stepWelcomeCaption,
    voiceText: l10n.stepWelcomeVoice,
    primaryCtaLabel: l10n.stepWelcomeCta,
  ),
  OnboardingStep(
    id: 'accountType',
    type: OnboardingStepType.singleChoice,
    title: l10n.stepAccountTypeTitle,
    titleItalic: l10n.stepAccountTypeTitleItalic,
    caption: l10n.stepAccountTypeCaption,
    voiceText: l10n.stepAccountTypeVoice,
    reviewLabel: l10n.stepAccountTypeReview,
    options: [
      OnboardingOption(id: 'national', label: l10n.stepAccountTypeOptNational, assetPath: 'assets/account_national.svg'),
      OnboardingOption(id: 'global', label: l10n.stepAccountTypeOptGlobal, assetPath: 'assets/account_global.svg'),
    ],
  ),
  OnboardingStep(
    id: 'pep',
    type: OnboardingStepType.singleChoice,
    title: l10n.stepPepTitle,
    titleItalic: l10n.stepPepTitleItalic,
    caption: l10n.stepPepCaption,
    voiceText: l10n.stepPepVoice,
    reviewLabel: l10n.stepPepReview,
    options: [
      OnboardingOption(id: 'no', label: l10n.stepPepOptNo),
      OnboardingOption(id: 'yes', label: l10n.stepPepOptYes),
    ],
  ),
  OnboardingStep(
    id: 'cep',
    type: OnboardingStepType.textInput,
    title: l10n.stepCepTitle,
    titleItalic: l10n.stepCepTitleItalic,
    caption: l10n.stepCepCaption,
    voiceText: l10n.stepCepVoice,
    placeholder: l10n.stepCepPlaceholder,
    inputKind: OnboardingInputKind.cep,
    reviewLabel: l10n.stepCepReview,
  ),
  OnboardingStep(
    id: 'experience',
    type: OnboardingStepType.singleChoice,
    title: l10n.stepExperienceTitle,
    titleItalic: l10n.stepExperienceTitleItalic,
    caption: l10n.stepExperienceCaption,
    voiceText: l10n.stepExperienceVoice,
    options: [
      OnboardingOption(id: 'none', label: l10n.stepExperienceOptNone, score: 0),
      OnboardingOption(id: 'basic', label: l10n.stepExperienceOptBasic, score: 5),
      OnboardingOption(id: 'intermediate', label: l10n.stepExperienceOptIntermediate, score: 10),
      OnboardingOption(id: 'advanced', label: l10n.stepExperienceOptAdvanced, score: 15),
    ],
  ),
  OnboardingStep(
    id: 'goal',
    type: OnboardingStepType.singleChoice,
    title: l10n.stepGoalTitle,
    titleItalic: l10n.stepGoalTitleItalic,
    caption: l10n.stepGoalCaption,
    voiceText: l10n.stepGoalVoice,
    options: [
      OnboardingOption(id: 'preserve', label: l10n.stepGoalOptPreserve, score: 0),
      OnboardingOption(id: 'income', label: l10n.stepGoalOptIncome, score: 8),
      OnboardingOption(id: 'grow', label: l10n.stepGoalOptGrow, score: 15),
      OnboardingOption(id: 'aggressive', label: l10n.stepGoalOptAggressive, score: 20),
    ],
  ),
  OnboardingStep(
    id: 'timeHorizon',
    type: OnboardingStepType.singleChoice,
    title: l10n.stepTimeHorizonTitle,
    titleItalic: l10n.stepTimeHorizonTitleItalic,
    caption: l10n.stepTimeHorizonCaption,
    voiceText: l10n.stepTimeHorizonVoice,
    reviewLabel: l10n.stepTimeHorizonReview,
    options: [
      OnboardingOption(id: 'short', label: l10n.stepTimeHorizonOptShort, score: 0),
      OnboardingOption(id: 'mid', label: l10n.stepTimeHorizonOptMid, score: 5),
      OnboardingOption(id: 'long', label: l10n.stepTimeHorizonOptLong, score: 10),
      OnboardingOption(id: 'very_long', label: l10n.stepTimeHorizonOptVeryLong, score: 15),
    ],
  ),
  OnboardingStep(
    id: 'comfort',
    type: OnboardingStepType.singleChoice,
    title: l10n.stepComfortTitle,
    titleItalic: l10n.stepComfortTitleItalic,
    caption: l10n.stepComfortCaption,
    voiceText: l10n.stepComfortVoice,
    options: [
      OnboardingOption(id: 'low', label: l10n.stepComfortOptLow, score: 0),
      OnboardingOption(id: 'medium_low', label: l10n.stepComfortOptMediumLow, score: 5),
      OnboardingOption(id: 'medium', label: l10n.stepComfortOptMedium, score: 10),
      OnboardingOption(id: 'high', label: l10n.stepComfortOptHigh, score: 15),
    ],
  ),
  OnboardingStep(
    id: 'lossReaction',
    type: OnboardingStepType.singleChoice,
    title: l10n.stepLossReactionTitle,
    titleItalic: l10n.stepLossReactionTitleItalic,
    caption: l10n.stepLossReactionCaption,
    voiceText: l10n.stepLossReactionVoice,
    reviewLabel: l10n.stepLossReactionReview,
    options: [
      OnboardingOption(id: 'panic', label: l10n.stepLossReactionOptPanic, score: 0),
      OnboardingOption(id: 'reduce', label: l10n.stepLossReactionOptReduce, score: 8),
      OnboardingOption(id: 'hold', label: l10n.stepLossReactionOptHold, score: 15),
      OnboardingOption(id: 'buy', label: l10n.stepLossReactionOptBuy, score: 20),
    ],
  ),
  OnboardingStep(
    id: 'allocation',
    type: OnboardingStepType.singleChoice,
    title: l10n.stepAllocationTitle,
    titleItalic: l10n.stepAllocationTitleItalic,
    caption: l10n.stepAllocationCaption,
    voiceText: l10n.stepAllocationVoice,
    reviewLabel: l10n.stepAllocationReview,
    options: [
      OnboardingOption(id: 'very_low', label: l10n.stepAllocationOptVeryLow, score: 15),
      OnboardingOption(id: 'low', label: l10n.stepAllocationOptLow, score: 10),
      OnboardingOption(id: 'medium', label: l10n.stepAllocationOptMedium, score: 5),
      OnboardingOption(id: 'high', label: l10n.stepAllocationOptHigh, score: 0),
    ],
  ),

  // ── Personal information ───────────────────────────────────────

  OnboardingStep(
    id: 'fullName',
    type: OnboardingStepType.textInput,
    title: l10n.stepFullNameTitle,
    titleItalic: l10n.stepFullNameTitleItalic,
    caption: l10n.stepFullNameCaption,
    voiceText: l10n.stepFullNameVoice,
    placeholder: l10n.stepFullNamePlaceholder,
    inputKind: OnboardingInputKind.name,
    reviewLabel: l10n.stepFullNameReview,
  ),
  OnboardingStep(
    id: 'email',
    type: OnboardingStepType.textInput,
    title: l10n.stepEmailTitle,
    titleItalic: l10n.stepEmailTitleItalic,
    caption: l10n.stepEmailCaption,
    voiceText: l10n.stepEmailVoice,
    placeholder: l10n.stepEmailPlaceholder,
    inputKind: OnboardingInputKind.email,
    reviewLabel: l10n.stepEmailReview,
    sensitive: false,
  ),
  OnboardingStep(
    id: 'emailCode',
    type: OnboardingStepType.verificationCode,
    title: l10n.stepEmailCodeTitle,
    titleItalic: l10n.stepEmailCodeTitleItalic,
    caption: l10n.stepEmailCodeCaption,
    voiceText: l10n.stepEmailCodeVoice,
    placeholder: l10n.stepEmailCodePlaceholder,
    reviewLabel: l10n.stepEmailCodeReview,
    sensitive: true,
  ),
  OnboardingStep(
    id: 'phone',
    type: OnboardingStepType.phoneInput,
    title: l10n.stepPhoneTitle,
    titleItalic: l10n.stepPhoneTitleItalic,
    caption: l10n.stepPhoneCaption,
    voiceText: l10n.stepPhoneVoice,
    placeholder: l10n.stepPhonePlaceholder,
    inputKind: OnboardingInputKind.phone,
    reviewLabel: l10n.stepPhoneReview,
    sensitive: true,
  ),
  OnboardingStep(
    id: 'pin',
    type: OnboardingStepType.pinInput,
    title: l10n.stepPinTitle,
    titleItalic: l10n.stepPinTitleItalic,
    caption: l10n.stepPinCaption,
    voiceText: l10n.stepPinVoice,
    reviewLabel: l10n.stepPinReview,
    sensitive: true,
  ),
  OnboardingStep(
    id: 'confirmPin',
    type: OnboardingStepType.pinInput,
    title: l10n.stepConfirmPinTitle,
    titleItalic: l10n.stepConfirmPinTitleItalic,
    caption: l10n.stepConfirmPinCaption,
    voiceText: l10n.stepConfirmPinVoice,
    reviewLabel: l10n.stepConfirmPinReview,
    sensitive: true,
    matchesStepId: 'pin',
  ),

  // ── Analysis ───────────────────────────────────────────────────

  OnboardingStep(
    id: 'analysing',
    type: OnboardingStepType.analysing,
    title: l10n.stepAnalysingTitle,
    titleItalic: l10n.stepAnalysingTitleItalic,
    caption: l10n.stepAnalysingCaption,
    voiceText: l10n.stepAnalysingVoice,
    required: false,
  ),

  // ── Completion ─────────────────────────────────────────────────

  OnboardingStep(
    id: 'trial',
    type: OnboardingStepType.completion,
    title: l10n.stepTrialTitle,
    titleItalic: l10n.stepTrialTitleItalic,
    caption: l10n.stepTrialCaption,
    voiceText: l10n.stepTrialVoice,
    primaryCtaLabel: l10n.stepTrialCta,
  ),
];
