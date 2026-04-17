// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get ctaContinue => 'Continue';

  @override
  String get ctaLoading => 'Loading…';

  @override
  String get ctaSaving => 'Saving…';

  @override
  String get ctaSubmitting => 'Submitting…';

  @override
  String get ctaCompleted => 'Completed';

  @override
  String get ctaConfirm => 'Confirm';

  @override
  String get ctaFinishing => 'Finishing…';

  @override
  String get ctaFinish => 'Finish';

  @override
  String get tooltipUnmute => 'Unmute';

  @override
  String get tooltipMute => 'Mute';

  @override
  String get tooltipBack => 'Back';

  @override
  String get tooltipClose => 'Close';

  @override
  String get narrationUnavailable => 'Narration unavailable.';

  @override
  String get suitabilityScoreLabel => 'Your suitability score';

  @override
  String get investorProfileFallback => 'Investor Profile';

  @override
  String get investorProfileIncomplete =>
      'Complete the questionnaire to see your profile.';

  @override
  String get volatilityWarning =>
      'Crypto can be volatile. Based on your answers, we recommend starting small.';

  @override
  String get profileConservative => 'Conservative Investor';

  @override
  String get profileModerate => 'Moderate Investor';

  @override
  String get profileAggressive => 'Aggressive Investor';

  @override
  String get profileConservativeDesc =>
      'Focus on stability. BTC, ETH, and stablecoins.';

  @override
  String get profileModerateDesc =>
      'Balanced approach. Top coins with selective risk.';

  @override
  String get profileAggressiveDesc =>
      'Full access to all features and asset classes.';

  @override
  String get analysingExperience => 'Analyzing your experience…';

  @override
  String get analysingGoals => 'Evaluating your goals…';

  @override
  String get analysingRisk => 'Calculating risk tolerance…';

  @override
  String get analysingProfile => 'Preparing your investor profile…';

  @override
  String get biometricLoginTitle => 'Biometric login?';

  @override
  String get biometricLoginDescription =>
      'Use your fingerprint or face recognition to sign in quickly next time.';

  @override
  String get biometricEnable => 'Yes, use biometrics';

  @override
  String get biometricSkip => 'No, thanks';

  @override
  String get biometricReason => 'Use your biometrics to sign in to Qinv';

  @override
  String get biometricCancelled => 'Authentication cancelled. Try again.';

  @override
  String get biometricUnexpectedError => 'Unexpected error. Try again.';

  @override
  String get biometricNotAvailable =>
      'Biometrics not available on this device.';

  @override
  String get biometricNotEnrolled =>
      'No biometrics enrolled. Set them up in device Settings.';

  @override
  String get biometricLockedOut =>
      'Too many attempts. Wait a moment and try again.';

  @override
  String get biometricPermanentlyLocked =>
      'Biometrics locked. Use your device passcode to unlock.';

  @override
  String get biometricPasscodeNotSet =>
      'Set a PIN or passcode on your device to use biometrics.';

  @override
  String get biometricUnknownError =>
      'Authentication error. Try again or use your password.';

  @override
  String get biometricVerifying => 'Verifying…';

  @override
  String get biometricTapToSignIn => 'Tap to sign in';

  @override
  String get biometricAuthLabel => 'Authenticate with biometrics';

  @override
  String get biometricUsePasswordLabel => 'Use password instead of biometrics';

  @override
  String get biometricUsePassword => 'Use password instead';

  @override
  String get returnCouldNotVerify => 'Could not verify';

  @override
  String get returnTapToRetry => 'Tap to try again';

  @override
  String get returnUsePassword => 'Use password';

  @override
  String get returnNotYou => 'Not you?';

  @override
  String returnGreeting(String displayName) {
    return 'Hello, $displayName';
  }

  @override
  String get returnAccessAccount => 'Access account';

  @override
  String get returnEnterPassword => 'Enter your password';

  @override
  String get returnIncorrectPassword => 'Incorrect password. Try again.';

  @override
  String get connectionError => 'Connection error. Try again.';

  @override
  String get forgotPassword => 'Forgot my password';

  @override
  String get signInTitle => 'Sign in to your account';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get welcomeBackSubtitle => 'Sign in with your email and password';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => '••••••••';

  @override
  String get signIn => 'Sign in';

  @override
  String get loginTitle => 'Your wealth,';

  @override
  String get loginAccent1 => 'always growing.';

  @override
  String get loginAccent2 => 'on autopilot.';

  @override
  String get loginAccent3 => 'working for you.';

  @override
  String get loginAccent4 => 'never sleeping.';

  @override
  String get loginSubtitle => 'Start in minutes, grow for years.';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get signUp => 'Sign up';

  @override
  String get orDivider => 'or';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get updateTitle => 'It\'s time for an upgrade';

  @override
  String get updateDescription =>
      'Your QINV app just got better. We\'ve made some improvements and resolved some issues for a smoother experience.';

  @override
  String get updateDismissLabel => 'Dismiss update';

  @override
  String get slideToUpdate => 'Slide to update';

  @override
  String get stepShowcaseWelcomeTitle => 'Invest in crypto\non autopilot.';

  @override
  String get stepShowcaseWelcomeCaption =>
      'The same intelligence used by major\ninstitutions, now accessible to any investor.';

  @override
  String get stepShowcaseWelcomeVoice =>
      'Hey! I\'m Neo, your investment copilot. Let me show you around.';

  @override
  String get stepShowcaseWelcomeCta => 'Continue';

  @override
  String get stepShowcaseAnalysisTitle =>
      'Buy, hold, or wait?\nLet data decide.';

  @override
  String get stepShowcaseAnalysisVoice =>
      'I analyze the market in real time so you can make smarter decisions.';

  @override
  String get stepShowcaseAnalysisCta => 'Continue';

  @override
  String get stepShowcaseAITitle => 'Ask. Analyze.\nCopilot executes.';

  @override
  String get stepShowcaseAIVoice =>
      'Access any crypto asset and get the algorithm\'s recommendation in seconds: Bullish or Bearish.';

  @override
  String get stepShowcaseAICta => 'Continue';

  @override
  String get stepShowcaseReviewsTitle => 'Loved by investors.\nBuilt for you.';

  @override
  String get stepShowcaseReviewsVoice =>
      'Don\'t just take my word for it — see what our investors are saying.';

  @override
  String get stepShowcaseReviewsCta => 'Get started';

  @override
  String get stepWelcomeTitle => 'Let\'s get you';

  @override
  String get stepWelcomeTitleItalic => 'started.';

  @override
  String get stepWelcomeCaption => 'Ready in just a few steps.';

  @override
  String get stepWelcomeVoice => 'Hey! Welcome. Let\'s get you started!';

  @override
  String get stepWelcomeCta => 'Get started';

  @override
  String get stepAccountTypeTitle => 'Choose your';

  @override
  String get stepAccountTypeTitleItalic => 'account type.';

  @override
  String get stepAccountTypeCaption =>
      'This determines where your assets are custodied.';

  @override
  String get stepAccountTypeVoice =>
      'First, choose your account type. National or global?';

  @override
  String get stepAccountTypeReview => 'Account type';

  @override
  String get stepAccountTypeOptNational => 'National account';

  @override
  String get stepAccountTypeOptGlobal => 'Global account';

  @override
  String get stepPepTitle => 'Are you a politically';

  @override
  String get stepPepTitleItalic => 'exposed person?';

  @override
  String get stepPepCaption => 'Required by Brazilian financial regulations.';

  @override
  String get stepPepVoice =>
      'Are you a politically exposed person? This is a regulatory requirement.';

  @override
  String get stepPepReview => 'PEP';

  @override
  String get stepPepOptNo => 'No, I am not';

  @override
  String get stepPepOptYes => 'Yes, I am';

  @override
  String get stepCepTitle => 'What\'s your';

  @override
  String get stepCepTitleItalic => 'postal code?';

  @override
  String get stepCepCaption => 'We\'ll use this to verify your address.';

  @override
  String get stepCepVoice => 'What\'s your postal code?';

  @override
  String get stepCepPlaceholder => '00000-000';

  @override
  String get stepCepReview => 'CEP';

  @override
  String get stepCepAddressNotFound =>
      'CEP not found. Please check and try again.';

  @override
  String get stepCepAddressError =>
      'Could not look up address. You can continue anyway.';

  @override
  String get validationInvalidCep => 'Enter a valid CEP (8 digits).';

  @override
  String get stepExperienceTitle => 'How long have you';

  @override
  String get stepExperienceTitleItalic => 'been investing?';

  @override
  String get stepExperienceCaption => 'We\'ll tailor your experience.';

  @override
  String get stepExperienceVoice => 'How long have you been investing?';

  @override
  String get stepExperienceOptNone => 'No experience yet';

  @override
  String get stepExperienceOptBasic => 'I\'ve dabbled a little';

  @override
  String get stepExperienceOptIntermediate => 'A few years of experience';

  @override
  String get stepExperienceOptAdvanced => 'I know my way around';

  @override
  String get stepGoalTitle => 'What\'s your';

  @override
  String get stepGoalTitleItalic => 'financial goal?';

  @override
  String get stepGoalCaption => 'Pick what matters most to you.';

  @override
  String get stepGoalVoice => 'What\'s your financial goal?';

  @override
  String get stepGoalOptPreserve => 'Protect what I already have';

  @override
  String get stepGoalOptIncome => 'Generate passive income';

  @override
  String get stepGoalOptGrow => 'Grow my wealth over time';

  @override
  String get stepGoalOptAggressive => 'Maximize returns at higher risk';

  @override
  String get stepTimeHorizonTitle => 'When might you need';

  @override
  String get stepTimeHorizonTitleItalic => 'this money back?';

  @override
  String get stepTimeHorizonCaption =>
      'Longer horizons can handle more volatility.';

  @override
  String get stepTimeHorizonVoice => 'When might you need this money back?';

  @override
  String get stepTimeHorizonReview => 'Time horizon';

  @override
  String get stepTimeHorizonOptShort => 'Within 1 year';

  @override
  String get stepTimeHorizonOptMid => '1 to 3 years';

  @override
  String get stepTimeHorizonOptLong => '3 to 7 years';

  @override
  String get stepTimeHorizonOptVeryLong => 'More than 7 years';

  @override
  String get stepComfortTitle => 'How do you handle';

  @override
  String get stepComfortTitleItalic => 'market swings?';

  @override
  String get stepComfortCaption => 'No wrong answers here.';

  @override
  String get stepComfortVoice => 'How do you handle market swings?';

  @override
  String get stepComfortOptLow => 'I prefer stability above all';

  @override
  String get stepComfortOptMediumLow => 'I can accept small fluctuations';

  @override
  String get stepComfortOptMedium => 'A balanced approach works for me';

  @override
  String get stepComfortOptHigh => 'I can handle the ups and downs';

  @override
  String get stepLossReactionTitle => 'If your portfolio drops';

  @override
  String get stepLossReactionTitleItalic => '20 percent, you…';

  @override
  String get stepLossReactionCaption =>
      'Be honest — there are no wrong answers.';

  @override
  String get stepLossReactionVoice =>
      'If your portfolio dropped 20 percent, what would you do?';

  @override
  String get stepLossReactionReview => 'Loss reaction';

  @override
  String get stepLossReactionOptPanic => 'Sell everything immediately';

  @override
  String get stepLossReactionOptReduce => 'Sell some to reduce exposure';

  @override
  String get stepLossReactionOptHold => 'Hold and wait for recovery';

  @override
  String get stepLossReactionOptBuy => 'Buy more at the lower price';

  @override
  String get stepAllocationTitle => 'How much savings';

  @override
  String get stepAllocationTitleItalic => 'are you investing?';

  @override
  String get stepAllocationCaption =>
      'Helps us understand your overall exposure.';

  @override
  String get stepAllocationVoice => 'How much savings are you investing?';

  @override
  String get stepAllocationReview => 'Portfolio share';

  @override
  String get stepAllocationOptVeryLow => 'Less than 10%';

  @override
  String get stepAllocationOptLow => '10% to 25%';

  @override
  String get stepAllocationOptMedium => '25% to 50%';

  @override
  String get stepAllocationOptHigh => 'More than 50%';

  @override
  String get stepFullNameTitle => 'What\'s your';

  @override
  String get stepFullNameTitleItalic => 'full name?';

  @override
  String get stepFullNameCaption => 'As it appears on your official ID.';

  @override
  String get stepFullNameVoice =>
      'What\'s your full name? Nice to meet you, by the way.';

  @override
  String get stepFullNamePlaceholder => 'John Doe';

  @override
  String get stepFullNameReview => 'Full name';

  @override
  String get stepEmailTitle => 'What\'s your';

  @override
  String get stepEmailTitleItalic => 'email address?';

  @override
  String get stepEmailCaption => 'We\'ll send a verification code.';

  @override
  String get stepEmailVoice => 'What\'s your email address?';

  @override
  String get stepEmailPlaceholder => 'you@example.com';

  @override
  String get stepEmailReview => 'Email';

  @override
  String get stepEmailCodeTitle => 'Check your';

  @override
  String get stepEmailCodeTitleItalic => 'email.';

  @override
  String get stepEmailCodeCaption => 'Enter the 6-digit code we sent you.';

  @override
  String get stepEmailCodeVoice => 'Check your email. We\'ve sent you a code.';

  @override
  String get stepEmailCodePlaceholder => '000000';

  @override
  String get stepEmailCodeReview => 'Email verified';

  @override
  String get stepPhoneTitle => 'Add your';

  @override
  String get stepPhoneTitleItalic => 'phone number.';

  @override
  String get stepPhoneCaption => 'Used for two-factor authentication only.';

  @override
  String get stepPhoneVoice =>
      'Enter your phone number with country and area code.';

  @override
  String get stepPhonePlaceholder => '+1 555 000 0000';

  @override
  String get stepPhoneReview => 'Phone';

  @override
  String get stepPinTitle => 'Create your';

  @override
  String get stepPinTitleItalic => 'password.';

  @override
  String get stepPinCaption => 'Used to authorize transactions.';

  @override
  String get stepPinVoice =>
      'We are almost there. Let\'s create your password!';

  @override
  String get stepPinReview => 'PIN';

  @override
  String get stepConfirmPinTitle => 'Confirm your';

  @override
  String get stepConfirmPinTitleItalic => 'password.';

  @override
  String get stepConfirmPinCaption => 'Enter the same password again.';

  @override
  String get stepConfirmPinVoice => 'Okay! Let\'s confirm your password.';

  @override
  String get stepConfirmPinReview => 'PIN confirmed';

  @override
  String get stepAnalysingTitle => 'Analyzing your';

  @override
  String get stepAnalysingTitleItalic => 'investor profile.';

  @override
  String get stepAnalysingCaption =>
      'Just a moment while we crunch the numbers.';

  @override
  String get stepAnalysingVoice =>
      'Almost there! We\'re building your investor profile.';

  @override
  String get stepTrialTitle => 'You\'re all set.';

  @override
  String get stepTrialTitleItalic => 'Let\'s get started.';

  @override
  String get stepTrialCaption => 'Your account is ready. Time to invest.';

  @override
  String get stepTrialVoice => 'You\'re all set. Let\'s get started!';

  @override
  String get stepTrialCta => 'Start investing';

  @override
  String get flowInitError => 'Unable to initialize onboarding.';

  @override
  String get flowSaveError => 'Unable to save answer.';

  @override
  String get flowContinueError => 'Unable to continue onboarding.';

  @override
  String get validationSelectOption => 'Please select one option.';

  @override
  String get validationFieldRequired => 'This field is required.';

  @override
  String get validationInvalidEmail => 'Enter a valid email address.';

  @override
  String get validationInvalidPhone => 'Enter a valid phone number.';

  @override
  String get validationInvalidCode => 'Enter the 6-digit code.';

  @override
  String get validationEnterPin => 'Please enter your PIN.';

  @override
  String get validationPinLength => 'PIN must be exactly 6 digits.';

  @override
  String get validationPinMismatch => 'PINs don\'t match. Please try again.';
}
