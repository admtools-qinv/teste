import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt')
  ];

  /// Default continue button label
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get ctaContinue;

  /// No description provided for @ctaLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get ctaLoading;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @tooltipReplayNarration.
  ///
  /// In en, this message translates to:
  /// **'Replay narration'**
  String get tooltipReplayNarration;

  /// No description provided for @semanticsNarrationCaption.
  ///
  /// In en, this message translates to:
  /// **'Narration caption'**
  String get semanticsNarrationCaption;

  /// No description provided for @semanticsError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get semanticsError;

  /// No description provided for @semanticsLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get semanticsLoading;

  /// No description provided for @semanticsSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get semanticsSelected;

  /// No description provided for @ctaSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get ctaSaving;

  /// No description provided for @ctaSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting…'**
  String get ctaSubmitting;

  /// No description provided for @ctaCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get ctaCompleted;

  /// No description provided for @ctaConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get ctaConfirm;

  /// No description provided for @ctaFinishing.
  ///
  /// In en, this message translates to:
  /// **'Finishing…'**
  String get ctaFinishing;

  /// No description provided for @ctaFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get ctaFinish;

  /// No description provided for @tooltipUnmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get tooltipUnmute;

  /// No description provided for @tooltipMute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get tooltipMute;

  /// No description provided for @tooltipBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get tooltipBack;

  /// No description provided for @tooltipClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get tooltipClose;

  /// No description provided for @narrationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Narration unavailable.'**
  String get narrationUnavailable;

  /// No description provided for @suitabilityScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Your suitability score'**
  String get suitabilityScoreLabel;

  /// No description provided for @investorProfileFallback.
  ///
  /// In en, this message translates to:
  /// **'Investor Profile'**
  String get investorProfileFallback;

  /// No description provided for @investorProfileIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Complete the questionnaire to see your profile.'**
  String get investorProfileIncomplete;

  /// No description provided for @volatilityWarning.
  ///
  /// In en, this message translates to:
  /// **'Crypto can be volatile. Based on your answers, we recommend starting small.'**
  String get volatilityWarning;

  /// No description provided for @profileConservative.
  ///
  /// In en, this message translates to:
  /// **'Conservative Investor'**
  String get profileConservative;

  /// No description provided for @profileModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate Investor'**
  String get profileModerate;

  /// No description provided for @profileAggressive.
  ///
  /// In en, this message translates to:
  /// **'Aggressive Investor'**
  String get profileAggressive;

  /// No description provided for @profileConservativeDesc.
  ///
  /// In en, this message translates to:
  /// **'Focus on stability. BTC, ETH, and stablecoins.'**
  String get profileConservativeDesc;

  /// No description provided for @profileModerateDesc.
  ///
  /// In en, this message translates to:
  /// **'Balanced approach. Top coins with selective risk.'**
  String get profileModerateDesc;

  /// No description provided for @profileAggressiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Full access to all features and asset classes.'**
  String get profileAggressiveDesc;

  /// No description provided for @analysingExperience.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your experience…'**
  String get analysingExperience;

  /// No description provided for @analysingGoals.
  ///
  /// In en, this message translates to:
  /// **'Evaluating your goals…'**
  String get analysingGoals;

  /// No description provided for @analysingRisk.
  ///
  /// In en, this message translates to:
  /// **'Calculating risk tolerance…'**
  String get analysingRisk;

  /// No description provided for @analysingProfile.
  ///
  /// In en, this message translates to:
  /// **'Preparing your investor profile…'**
  String get analysingProfile;

  /// No description provided for @biometricLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Biometric login?'**
  String get biometricLoginTitle;

  /// No description provided for @biometricLoginDescription.
  ///
  /// In en, this message translates to:
  /// **'Use your fingerprint or face recognition to sign in quickly next time.'**
  String get biometricLoginDescription;

  /// No description provided for @biometricEnable.
  ///
  /// In en, this message translates to:
  /// **'Yes, use biometrics'**
  String get biometricEnable;

  /// No description provided for @biometricSkip.
  ///
  /// In en, this message translates to:
  /// **'No, thanks'**
  String get biometricSkip;

  /// No description provided for @biometricReason.
  ///
  /// In en, this message translates to:
  /// **'Use your biometrics to sign in to Qinv'**
  String get biometricReason;

  /// No description provided for @biometricCancelled.
  ///
  /// In en, this message translates to:
  /// **'Authentication cancelled. Try again.'**
  String get biometricCancelled;

  /// No description provided for @biometricUnexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error. Try again.'**
  String get biometricUnexpectedError;

  /// No description provided for @biometricNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Biometrics not available on this device.'**
  String get biometricNotAvailable;

  /// No description provided for @biometricNotEnrolled.
  ///
  /// In en, this message translates to:
  /// **'No biometrics enrolled. Set them up in device Settings.'**
  String get biometricNotEnrolled;

  /// No description provided for @biometricLockedOut.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Wait a moment and try again.'**
  String get biometricLockedOut;

  /// No description provided for @biometricPermanentlyLocked.
  ///
  /// In en, this message translates to:
  /// **'Biometrics locked. Use your device passcode to unlock.'**
  String get biometricPermanentlyLocked;

  /// No description provided for @biometricPasscodeNotSet.
  ///
  /// In en, this message translates to:
  /// **'Set a PIN or passcode on your device to use biometrics.'**
  String get biometricPasscodeNotSet;

  /// No description provided for @biometricUnknownError.
  ///
  /// In en, this message translates to:
  /// **'Authentication error. Try again or use your password.'**
  String get biometricUnknownError;

  /// No description provided for @biometricVerifying.
  ///
  /// In en, this message translates to:
  /// **'Verifying…'**
  String get biometricVerifying;

  /// No description provided for @biometricTapToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Tap to sign in'**
  String get biometricTapToSignIn;

  /// No description provided for @biometricAuthLabel.
  ///
  /// In en, this message translates to:
  /// **'Authenticate with biometrics'**
  String get biometricAuthLabel;

  /// No description provided for @biometricUsePasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Use password instead of biometrics'**
  String get biometricUsePasswordLabel;

  /// No description provided for @biometricUsePassword.
  ///
  /// In en, this message translates to:
  /// **'Use password instead'**
  String get biometricUsePassword;

  /// No description provided for @returnCouldNotVerify.
  ///
  /// In en, this message translates to:
  /// **'Could not verify'**
  String get returnCouldNotVerify;

  /// No description provided for @returnTapToRetry.
  ///
  /// In en, this message translates to:
  /// **'Tap to try again'**
  String get returnTapToRetry;

  /// No description provided for @returnUsePassword.
  ///
  /// In en, this message translates to:
  /// **'Use password'**
  String get returnUsePassword;

  /// No description provided for @returnNotYou.
  ///
  /// In en, this message translates to:
  /// **'Not you?'**
  String get returnNotYou;

  /// No description provided for @returnGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, {displayName}'**
  String returnGreeting(String displayName);

  /// No description provided for @returnAccessAccount.
  ///
  /// In en, this message translates to:
  /// **'Access account'**
  String get returnAccessAccount;

  /// No description provided for @returnEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get returnEnterPassword;

  /// No description provided for @returnIncorrectPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password. Try again.'**
  String get returnIncorrectPassword;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection error. Try again.'**
  String get connectionError;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot my password'**
  String get forgotPassword;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account'**
  String get signInTitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get emailHint;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @welcomeBackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your email and password'**
  String get welcomeBackSubtitle;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'••••••••'**
  String get passwordHint;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Your wealth,'**
  String get loginTitle;

  /// No description provided for @loginAccent1.
  ///
  /// In en, this message translates to:
  /// **'always growing.'**
  String get loginAccent1;

  /// No description provided for @loginAccent2.
  ///
  /// In en, this message translates to:
  /// **'on autopilot.'**
  String get loginAccent2;

  /// No description provided for @loginAccent3.
  ///
  /// In en, this message translates to:
  /// **'working for you.'**
  String get loginAccent3;

  /// No description provided for @loginAccent4.
  ///
  /// In en, this message translates to:
  /// **'never sleeping.'**
  String get loginAccent4;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start in minutes, grow for years.'**
  String get loginSubtitle;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @orDivider.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get orDivider;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @updateTitle.
  ///
  /// In en, this message translates to:
  /// **'It\'s time for an upgrade'**
  String get updateTitle;

  /// No description provided for @updateDescription.
  ///
  /// In en, this message translates to:
  /// **'Your QINV app just got better. We\'ve made some improvements and resolved some issues for a smoother experience.'**
  String get updateDescription;

  /// No description provided for @updateDismissLabel.
  ///
  /// In en, this message translates to:
  /// **'Dismiss update'**
  String get updateDismissLabel;

  /// No description provided for @slideToUpdate.
  ///
  /// In en, this message translates to:
  /// **'Slide to update'**
  String get slideToUpdate;

  /// No description provided for @stepShowcaseWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Invest in crypto\non autopilot.'**
  String get stepShowcaseWelcomeTitle;

  /// No description provided for @stepShowcaseWelcomeCaption.
  ///
  /// In en, this message translates to:
  /// **'The same intelligence used by major\ninstitutions, now accessible to any investor.'**
  String get stepShowcaseWelcomeCaption;

  /// No description provided for @stepShowcaseWelcomeVoice.
  ///
  /// In en, this message translates to:
  /// **'Hey, I\'m Neo, your AI investing copilot. I turn market data into clear actions so you can invest with confidence.'**
  String get stepShowcaseWelcomeVoice;

  /// No description provided for @stepShowcaseWelcomeCta.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get stepShowcaseWelcomeCta;

  /// No description provided for @stepShowcaseAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Buy, hold, or wait?\nLet data decide.'**
  String get stepShowcaseAnalysisTitle;

  /// No description provided for @stepShowcaseAnalysisVoice.
  ///
  /// In en, this message translates to:
  /// **'Pick any crypto and instantly see if it\'s bullish or bearish.'**
  String get stepShowcaseAnalysisVoice;

  /// No description provided for @stepShowcaseAnalysisCta.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get stepShowcaseAnalysisCta;

  /// No description provided for @stepShowcaseAITitle.
  ///
  /// In en, this message translates to:
  /// **'Ask. Analyze.\nCopilot executes.'**
  String get stepShowcaseAITitle;

  /// No description provided for @stepShowcaseAIVoice.
  ///
  /// In en, this message translates to:
  /// **'I monitor the market in real time and adapt your strategy as things change. Cool, right?'**
  String get stepShowcaseAIVoice;

  /// No description provided for @stepShowcaseAICta.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get stepShowcaseAICta;

  /// No description provided for @stepShowcaseReviewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Loved by investors.\nBuilt for you.'**
  String get stepShowcaseReviewsTitle;

  /// No description provided for @stepShowcaseReviewsVoice.
  ///
  /// In en, this message translates to:
  /// **'Don\'t just take my word for it, see what our users are saying.'**
  String get stepShowcaseReviewsVoice;

  /// No description provided for @stepShowcaseReviewsCta.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get stepShowcaseReviewsCta;

  /// No description provided for @reviewTitle1.
  ///
  /// In en, this message translates to:
  /// **'Smart portfolios really work!'**
  String get reviewTitle1;

  /// No description provided for @reviewBody1.
  ///
  /// In en, this message translates to:
  /// **'I\'ve tried many brokers, but QINV stood out with its AI. It optimizes my investments strategically and transparently.'**
  String get reviewBody1;

  /// No description provided for @reviewAuthor1.
  ///
  /// In en, this message translates to:
  /// **'IanCastro'**
  String get reviewAuthor1;

  /// No description provided for @reviewTitle2.
  ///
  /// In en, this message translates to:
  /// **'Super intuitive!'**
  String get reviewTitle2;

  /// No description provided for @reviewBody2.
  ///
  /// In en, this message translates to:
  /// **'I was a crypto beginner and afraid of making mistakes. QINV guided me clearly from my very first investment.'**
  String get reviewBody2;

  /// No description provided for @reviewAuthor2.
  ///
  /// In en, this message translates to:
  /// **'Ana B.'**
  String get reviewAuthor2;

  /// No description provided for @reviewTitle3.
  ///
  /// In en, this message translates to:
  /// **'Easy and practical'**
  String get reviewTitle3;

  /// No description provided for @reviewBody3.
  ///
  /// In en, this message translates to:
  /// **'First time investing and couldn\'t be happier. Easy to invest, track returns, and withdrawals are super fast!'**
  String get reviewBody3;

  /// No description provided for @reviewAuthor3.
  ///
  /// In en, this message translates to:
  /// **'Cla_RR'**
  String get reviewAuthor3;

  /// No description provided for @reviewTitle4.
  ///
  /// In en, this message translates to:
  /// **'Effortless investing'**
  String get reviewTitle4;

  /// No description provided for @reviewBody4.
  ///
  /// In en, this message translates to:
  /// **'The app helps me invest in diverse cryptos without prior knowledge. It analyzes the market and diversifies for me.'**
  String get reviewBody4;

  /// No description provided for @reviewAuthor4.
  ///
  /// In en, this message translates to:
  /// **'Thiagosdep'**
  String get reviewAuthor4;

  /// No description provided for @reviewTitle5.
  ///
  /// In en, this message translates to:
  /// **'Reliable'**
  String get reviewTitle5;

  /// No description provided for @reviewBody5.
  ///
  /// In en, this message translates to:
  /// **'First time investing in crypto and it was amazing! Instant withdrawals add real credibility.'**
  String get reviewBody5;

  /// No description provided for @reviewAuthor5.
  ///
  /// In en, this message translates to:
  /// **'manusilvasilv'**
  String get reviewAuthor5;

  /// No description provided for @reviewTitle6.
  ///
  /// In en, this message translates to:
  /// **'Best crypto app'**
  String get reviewTitle6;

  /// No description provided for @reviewBody6.
  ///
  /// In en, this message translates to:
  /// **'Simple interface, great AI suggestions. I feel confident investing now. Highly recommended!'**
  String get reviewBody6;

  /// No description provided for @reviewAuthor6.
  ///
  /// In en, this message translates to:
  /// **'Pedro_LF'**
  String get reviewAuthor6;

  /// No description provided for @stepWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get you'**
  String get stepWelcomeTitle;

  /// No description provided for @stepWelcomeTitleItalic.
  ///
  /// In en, this message translates to:
  /// **'started.'**
  String get stepWelcomeTitleItalic;

  /// No description provided for @stepWelcomeCaption.
  ///
  /// In en, this message translates to:
  /// **'Ready in just a few steps.'**
  String get stepWelcomeCaption;

  /// No description provided for @stepWelcomeVoice.
  ///
  /// In en, this message translates to:
  /// **'Okay, let\'s get you set up.'**
  String get stepWelcomeVoice;

  /// No description provided for @stepWelcomeCta.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get stepWelcomeCta;

  /// No description provided for @stepAccountTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your'**
  String get stepAccountTypeTitle;

  /// No description provided for @stepAccountTypeTitleItalic.
  ///
  /// In en, this message translates to:
  /// **'account.'**
  String get stepAccountTypeTitleItalic;

  /// No description provided for @stepAccountTypeCaption.
  ///
  /// In en, this message translates to:
  /// **'This determines where your assets are custodied.'**
  String get stepAccountTypeCaption;

  /// No description provided for @stepAccountTypeVoice.
  ///
  /// In en, this message translates to:
  /// **'First, choose your account type. National or global?'**
  String get stepAccountTypeVoice;

  /// No description provided for @stepAccountTypeReview.
  ///
  /// In en, this message translates to:
  /// **'Account type'**
  String get stepAccountTypeReview;

  /// No description provided for @stepAccountTypeOptNational.
  ///
  /// In en, this message translates to:
  /// **'National account'**
  String get stepAccountTypeOptNational;

  /// No description provided for @stepAccountTypeOptNationalSub.
  ///
  /// In en, this message translates to:
  /// **'Crypto asset portfolios · Custody in BRL · Foxbit as custodian'**
  String get stepAccountTypeOptNationalSub;

  /// No description provided for @stepAccountTypeOptGlobal.
  ///
  /// In en, this message translates to:
  /// **'Global account'**
  String get stepAccountTypeOptGlobal;

  /// No description provided for @stepAccountTypeOptGlobalSub.
  ///
  /// In en, this message translates to:
  /// **'Crypto asset & tokenized stock portfolios · Custody in USD · BingX as custodian'**
  String get stepAccountTypeOptGlobalSub;

  /// No description provided for @stepPepTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you a politically'**
  String get stepPepTitle;

  /// No description provided for @stepPepTitleItalic.
  ///
  /// In en, this message translates to:
  /// **'exposed person?'**
  String get stepPepTitleItalic;

  /// No description provided for @stepPepCaption.
  ///
  /// In en, this message translates to:
  /// **'Required by Brazilian financial regulations.'**
  String get stepPepCaption;

  /// No description provided for @stepPepVoice.
  ///
  /// In en, this message translates to:
  /// **'Are you a politically exposed person? This is a regulatory requirement.'**
  String get stepPepVoice;

  /// No description provided for @stepPepReview.
  ///
  /// In en, this message translates to:
  /// **'PEP'**
  String get stepPepReview;

  /// No description provided for @stepPepOptNo.
  ///
  /// In en, this message translates to:
  /// **'No, I am not'**
  String get stepPepOptNo;

  /// No description provided for @stepPepOptYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, I am'**
  String get stepPepOptYes;

  /// No description provided for @stepCepTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s your'**
  String get stepCepTitle;

  /// No description provided for @stepCepTitleItalic.
  ///
  /// In en, this message translates to:
  /// **'postal code?'**
  String get stepCepTitleItalic;

  /// No description provided for @stepCepCaption.
  ///
  /// In en, this message translates to:
  /// **'We\'ll use this to verify your address.'**
  String get stepCepCaption;

  /// No description provided for @stepCepVoice.
  ///
  /// In en, this message translates to:
  /// **'What\'s your postal code?'**
  String get stepCepVoice;

  /// No description provided for @stepCepPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'00000-000'**
  String get stepCepPlaceholder;

  /// No description provided for @stepCepReview.
  ///
  /// In en, this message translates to:
  /// **'CEP'**
  String get stepCepReview;

  /// No description provided for @stepCepAddressNotFound.
  ///
  /// In en, this message translates to:
  /// **'CEP not found. Please check and try again.'**
  String get stepCepAddressNotFound;

  /// No description provided for @stepCepAddressError.
  ///
  /// In en, this message translates to:
  /// **'Could not look up address. You can continue anyway.'**
  String get stepCepAddressError;

  /// No description provided for @validationInvalidCep.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid CEP (8 digits).'**
  String get validationInvalidCep;

  /// No description provided for @stepExperienceTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s your investing'**
  String get stepExperienceTitle;

  /// No description provided for @stepExperienceTitleItalic.
  ///
  /// In en, this message translates to:
  /// **'experience?'**
  String get stepExperienceTitleItalic;

  /// No description provided for @stepExperienceCaption.
  ///
  /// In en, this message translates to:
  /// **'We\'ll tailor your experience.'**
  String get stepExperienceCaption;

  /// No description provided for @stepExperienceVoice.
  ///
  /// In en, this message translates to:
  /// **'What\'s your investing experience?'**
  String get stepExperienceVoice;

  /// No description provided for @stepExperienceOptNone.
  ///
  /// In en, this message translates to:
  /// **'Never invested'**
  String get stepExperienceOptNone;

  /// No description provided for @stepExperienceOptBasic.
  ///
  /// In en, this message translates to:
  /// **'Little experience'**
  String get stepExperienceOptBasic;

  /// No description provided for @stepExperienceOptIntermediate.
  ///
  /// In en, this message translates to:
  /// **'A few years of experience'**
  String get stepExperienceOptIntermediate;

  /// No description provided for @stepExperienceOptAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Extensive experience'**
  String get stepExperienceOptAdvanced;

  /// No description provided for @stepGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s your'**
  String get stepGoalTitle;

  /// No description provided for @stepGoalTitleItalic.
  ///
  /// In en, this message translates to:
  /// **'financial goal?'**
  String get stepGoalTitleItalic;

  /// No description provided for @stepGoalCaption.
  ///
  /// In en, this message translates to:
  /// **'Pick what matters most to you.'**
  String get stepGoalCaption;

  /// No description provided for @stepGoalVoice.
  ///
  /// In en, this message translates to:
  /// **'What\'s your financial goal?'**
  String get stepGoalVoice;

  /// No description provided for @stepGoalOptPreserve.
  ///
  /// In en, this message translates to:
  /// **'Protect what I already have'**
  String get stepGoalOptPreserve;

  /// No description provided for @stepGoalOptIncome.
  ///
  /// In en, this message translates to:
  /// **'Generate passive income'**
  String get stepGoalOptIncome;

  /// No description provided for @stepGoalOptGrow.
  ///
  /// In en, this message translates to:
  /// **'Grow my wealth over time'**
  String get stepGoalOptGrow;

  /// No description provided for @stepGoalOptAggressive.
  ///
  /// In en, this message translates to:
  /// **'Maximize returns at higher risk'**
  String get stepGoalOptAggressive;

  /// No description provided for @stepTimeHorizonTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s your investment'**
  String get stepTimeHorizonTitle;

  /// No description provided for @stepTimeHorizonTitleItalic.
  ///
  /// In en, this message translates to:
  /// **'time horizon?'**
  String get stepTimeHorizonTitleItalic;

  /// No description provided for @stepTimeHorizonCaption.
  ///
  /// In en, this message translates to:
  /// **'Longer horizons can handle more volatility.'**
  String get stepTimeHorizonCaption;

  /// No description provided for @stepTimeHorizonVoice.
  ///
  /// In en, this message translates to:
  /// **'What\'s your investment time horizon?'**
  String get stepTimeHorizonVoice;

  /// No description provided for @stepTimeHorizonReview.
  ///
  /// In en, this message translates to:
  /// **'Time horizon'**
  String get stepTimeHorizonReview;

  /// No description provided for @stepTimeHorizonOptShort.
  ///
  /// In en, this message translates to:
  /// **'Within 1 year'**
  String get stepTimeHorizonOptShort;

  /// No description provided for @stepTimeHorizonOptMid.
  ///
  /// In en, this message translates to:
  /// **'1 to 3 years'**
  String get stepTimeHorizonOptMid;

  /// No description provided for @stepTimeHorizonOptLong.
  ///
  /// In en, this message translates to:
  /// **'3 to 7 years'**
  String get stepTimeHorizonOptLong;

  /// No description provided for @stepTimeHorizonOptVeryLong.
  ///
  /// In en, this message translates to:
  /// **'More than 7 years'**
  String get stepTimeHorizonOptVeryLong;

  /// No description provided for @stepComfortTitle.
  ///
  /// In en, this message translates to:
  /// **'How do you handle'**
  String get stepComfortTitle;

  /// No description provided for @stepComfortTitleItalic.
  ///
  /// In en, this message translates to:
  /// **'market swings?'**
  String get stepComfortTitleItalic;

  /// No description provided for @stepComfortCaption.
  ///
  /// In en, this message translates to:
  /// **'No wrong answers here.'**
  String get stepComfortCaption;

  /// No description provided for @stepComfortVoice.
  ///
  /// In en, this message translates to:
  /// **'How do you handle market swings?'**
  String get stepComfortVoice;

  /// No description provided for @stepComfortOptLow.
  ///
  /// In en, this message translates to:
  /// **'I prefer stability above all'**
  String get stepComfortOptLow;

  /// No description provided for @stepComfortOptMediumLow.
  ///
  /// In en, this message translates to:
  /// **'I can accept small fluctuations'**
  String get stepComfortOptMediumLow;

  /// No description provided for @stepComfortOptMedium.
  ///
  /// In en, this message translates to:
  /// **'A balanced approach works for me'**
  String get stepComfortOptMedium;

  /// No description provided for @stepComfortOptHigh.
  ///
  /// In en, this message translates to:
  /// **'I can handle the ups and downs'**
  String get stepComfortOptHigh;

  /// No description provided for @stepLossReactionTitle.
  ///
  /// In en, this message translates to:
  /// **'If your wealth drops'**
  String get stepLossReactionTitle;

  /// No description provided for @stepLossReactionTitleItalic.
  ///
  /// In en, this message translates to:
  /// **'20 percent, you…'**
  String get stepLossReactionTitleItalic;

  /// No description provided for @stepLossReactionCaption.
  ///
  /// In en, this message translates to:
  /// **'Be honest — there are no wrong answers.'**
  String get stepLossReactionCaption;

  /// No description provided for @stepLossReactionVoice.
  ///
  /// In en, this message translates to:
  /// **'If your wealth dropped 20 percent, what would you do?'**
  String get stepLossReactionVoice;

  /// No description provided for @stepLossReactionReview.
  ///
  /// In en, this message translates to:
  /// **'Loss reaction'**
  String get stepLossReactionReview;

  /// No description provided for @stepLossReactionOptPanic.
  ///
  /// In en, this message translates to:
  /// **'Sell everything immediately'**
  String get stepLossReactionOptPanic;

  /// No description provided for @stepLossReactionOptReduce.
  ///
  /// In en, this message translates to:
  /// **'Sell some to reduce exposure'**
  String get stepLossReactionOptReduce;

  /// No description provided for @stepLossReactionOptHold.
  ///
  /// In en, this message translates to:
  /// **'Hold and wait for recovery'**
  String get stepLossReactionOptHold;

  /// No description provided for @stepLossReactionOptBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy more at the lower price'**
  String get stepLossReactionOptBuy;

  /// No description provided for @stepAllocationTitle.
  ///
  /// In en, this message translates to:
  /// **'How much savings'**
  String get stepAllocationTitle;

  /// No description provided for @stepAllocationTitleItalic.
  ///
  /// In en, this message translates to:
  /// **'are you investing?'**
  String get stepAllocationTitleItalic;

  /// No description provided for @stepAllocationCaption.
  ///
  /// In en, this message translates to:
  /// **'Helps us understand your overall exposure.'**
  String get stepAllocationCaption;

  /// No description provided for @stepAllocationVoice.
  ///
  /// In en, this message translates to:
  /// **'How much savings are you investing?'**
  String get stepAllocationVoice;

  /// No description provided for @stepAllocationReview.
  ///
  /// In en, this message translates to:
  /// **'Portfolio share'**
  String get stepAllocationReview;

  /// No description provided for @stepAllocationOptVeryLow.
  ///
  /// In en, this message translates to:
  /// **'Less than 10%'**
  String get stepAllocationOptVeryLow;

  /// No description provided for @stepAllocationOptLow.
  ///
  /// In en, this message translates to:
  /// **'10% to 25%'**
  String get stepAllocationOptLow;

  /// No description provided for @stepAllocationOptMedium.
  ///
  /// In en, this message translates to:
  /// **'25% to 50%'**
  String get stepAllocationOptMedium;

  /// No description provided for @stepAllocationOptHigh.
  ///
  /// In en, this message translates to:
  /// **'More than 50%'**
  String get stepAllocationOptHigh;

  /// No description provided for @stepFullNameTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s your'**
  String get stepFullNameTitle;

  /// No description provided for @stepFullNameTitleItalic.
  ///
  /// In en, this message translates to:
  /// **'full name?'**
  String get stepFullNameTitleItalic;

  /// No description provided for @stepFullNameCaption.
  ///
  /// In en, this message translates to:
  /// **'As it appears on your official ID.'**
  String get stepFullNameCaption;

  /// No description provided for @stepFullNameVoice.
  ///
  /// In en, this message translates to:
  /// **'What\'s your full name?'**
  String get stepFullNameVoice;

  /// No description provided for @stepFullNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'John Doe'**
  String get stepFullNamePlaceholder;

  /// No description provided for @stepFullNameReview.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get stepFullNameReview;

  /// No description provided for @stepEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s your'**
  String get stepEmailTitle;

  /// No description provided for @stepEmailTitleItalic.
  ///
  /// In en, this message translates to:
  /// **'email address?'**
  String get stepEmailTitleItalic;

  /// No description provided for @stepEmailCaption.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send a verification code.'**
  String get stepEmailCaption;

  /// No description provided for @stepEmailVoice.
  ///
  /// In en, this message translates to:
  /// **'What\'s your personal email address?'**
  String get stepEmailVoice;

  /// No description provided for @stepEmailPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get stepEmailPlaceholder;

  /// No description provided for @stepEmailReview.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get stepEmailReview;

  /// No description provided for @stepEmailCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your'**
  String get stepEmailCodeTitle;

  /// No description provided for @stepEmailCodeTitleItalic.
  ///
  /// In en, this message translates to:
  /// **'email.'**
  String get stepEmailCodeTitleItalic;

  /// No description provided for @stepEmailCodeCaption.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code we sent you.'**
  String get stepEmailCodeCaption;

  /// No description provided for @stepEmailCodeVoice.
  ///
  /// In en, this message translates to:
  /// **'Check your email. We\'ve sent you a code.'**
  String get stepEmailCodeVoice;

  /// No description provided for @stepEmailCodePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'000000'**
  String get stepEmailCodePlaceholder;

  /// No description provided for @stepEmailCodeReview.
  ///
  /// In en, this message translates to:
  /// **'Email verified'**
  String get stepEmailCodeReview;

  /// No description provided for @stepPhoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Add your'**
  String get stepPhoneTitle;

  /// No description provided for @stepPhoneTitleItalic.
  ///
  /// In en, this message translates to:
  /// **'phone number.'**
  String get stepPhoneTitleItalic;

  /// No description provided for @stepPhoneCaption.
  ///
  /// In en, this message translates to:
  /// **'Used for two-factor authentication only.'**
  String get stepPhoneCaption;

  /// No description provided for @stepPhoneVoice.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number with country and area code.'**
  String get stepPhoneVoice;

  /// No description provided for @stepPhonePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'+1 555 000 0000'**
  String get stepPhonePlaceholder;

  /// No description provided for @stepPhoneReview.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get stepPhoneReview;

  /// No description provided for @stepPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your'**
  String get stepPinTitle;

  /// No description provided for @stepPinTitleItalic.
  ///
  /// In en, this message translates to:
  /// **'password.'**
  String get stepPinTitleItalic;

  /// No description provided for @stepPinCaption.
  ///
  /// In en, this message translates to:
  /// **'Used to authorize transactions.'**
  String get stepPinCaption;

  /// No description provided for @stepPinVoice.
  ///
  /// In en, this message translates to:
  /// **'We are almost there. Let\'s create your password!'**
  String get stepPinVoice;

  /// No description provided for @stepPinReview.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get stepPinReview;

  /// No description provided for @stepConfirmPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm your'**
  String get stepConfirmPinTitle;

  /// No description provided for @stepConfirmPinTitleItalic.
  ///
  /// In en, this message translates to:
  /// **'password.'**
  String get stepConfirmPinTitleItalic;

  /// No description provided for @stepConfirmPinCaption.
  ///
  /// In en, this message translates to:
  /// **'Enter the same password again.'**
  String get stepConfirmPinCaption;

  /// No description provided for @stepConfirmPinVoice.
  ///
  /// In en, this message translates to:
  /// **'Okay! Let\'s confirm your password.'**
  String get stepConfirmPinVoice;

  /// No description provided for @stepConfirmPinReview.
  ///
  /// In en, this message translates to:
  /// **'PIN confirmed'**
  String get stepConfirmPinReview;

  /// No description provided for @stepAnalysingTitle.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your'**
  String get stepAnalysingTitle;

  /// No description provided for @stepAnalysingTitleItalic.
  ///
  /// In en, this message translates to:
  /// **'investor profile.'**
  String get stepAnalysingTitleItalic;

  /// No description provided for @stepAnalysingCaption.
  ///
  /// In en, this message translates to:
  /// **'Just a moment while we crunch the numbers.'**
  String get stepAnalysingCaption;

  /// No description provided for @stepAnalysingVoice.
  ///
  /// In en, this message translates to:
  /// **'Almost there! We\'re creating your investor profile.'**
  String get stepAnalysingVoice;

  /// No description provided for @stepTrialTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re all set.'**
  String get stepTrialTitle;

  /// No description provided for @stepTrialTitleItalic.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get started.'**
  String get stepTrialTitleItalic;

  /// No description provided for @stepTrialCaption.
  ///
  /// In en, this message translates to:
  /// **'Your account is ready. Time to invest.'**
  String get stepTrialCaption;

  /// No description provided for @stepTrialVoice.
  ///
  /// In en, this message translates to:
  /// **'You\'re all set. Let\'s get started!'**
  String get stepTrialVoice;

  /// No description provided for @stepTrialCta.
  ///
  /// In en, this message translates to:
  /// **'Start investing'**
  String get stepTrialCta;

  /// Error when onboarding session fails to start
  ///
  /// In en, this message translates to:
  /// **'Unable to initialize onboarding.'**
  String get flowInitError;

  /// Error when saving an answer fails
  ///
  /// In en, this message translates to:
  /// **'Unable to save answer.'**
  String get flowSaveError;

  /// Error when advancing to the next step fails
  ///
  /// In en, this message translates to:
  /// **'Unable to continue onboarding.'**
  String get flowContinueError;

  /// No description provided for @validationSelectOption.
  ///
  /// In en, this message translates to:
  /// **'Please select one option.'**
  String get validationSelectOption;

  /// No description provided for @validationFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get validationFieldRequired;

  /// No description provided for @validationInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get validationInvalidEmail;

  /// No description provided for @validationInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number.'**
  String get validationInvalidPhone;

  /// No description provided for @validationInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code.'**
  String get validationInvalidCode;

  /// No description provided for @validationEnterPin.
  ///
  /// In en, this message translates to:
  /// **'Please enter your PIN.'**
  String get validationEnterPin;

  /// No description provided for @validationPinLength.
  ///
  /// In en, this message translates to:
  /// **'PIN must be exactly 6 digits.'**
  String get validationPinLength;

  /// No description provided for @validationPinMismatch.
  ///
  /// In en, this message translates to:
  /// **'PINs don\'t match. Please try again.'**
  String get validationPinMismatch;

  /// Label above press logos section
  ///
  /// In en, this message translates to:
  /// **'Featured by'**
  String get featuredBy;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
