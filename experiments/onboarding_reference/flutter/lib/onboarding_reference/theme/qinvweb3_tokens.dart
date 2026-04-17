import 'package:flutter/material.dart';

class QInvWeb3Tokens {
  static const background = Color(0xFF121314);
  static const foreground = Color(0xFFFFFFFF);

  static const primary = Color(0xFF7D39EB);
  static const primaryLight = Color(0xFFB080FF);
  static const primaryForeground = Color(0xFFFFFFFF);

  static const destructive = Color(0xFFF87171);
  static const destructiveForeground = Color(0xFFFFFFFF);

  static const textHeading = Color(0xFFF5F7FA);
  static const textSecondary = Color(0xFFDCDFE5);
  static const textMuted = Color(0xFFB0B5BF);

  static const border = Color(0xFF2E3138);
  static const input = Color(0xFF2E3138);
  static const ring = Color(0xFF7D39EB);

  static const cardBgLight = Color.fromRGBO(143, 155, 179, 0.06);
  static const cardBgDropdown = Color.fromRGBO(31, 31, 35, 0.90);

  // Radius
  static const double radiusCard = 20.0;
  static const double radiusButton = 999.0;
  static const double radiusInput = 14.0;
  static const double radiusOption = 16.0;

  // Typography scale
  static const double fontSizeHeadlineL = 28.0;
  static const double fontSizeHeadlineM = 26.0;
  static const double fontSizeTitleAccent = 36.0;
  static const double fontSizeBody = 15.0;
  static const double fontSizeSubtitle = 14.0;
  static const double fontSizeSmall = 13.0;
  static const double fontSizeLabel = 15.0;
  static const double fontSizeLabelS = 11.0;
  static const double fontSizeInput = 16.0;
  static const double fontSizeInputHint = 15.0;
  static const double fontSizeInputHelper = 12.0;
  static const double fontSizeOtp = 22.0;

  static const transitionAll = Duration(milliseconds: 300);
  static const transitionStep = Duration(milliseconds: 450);
  static const transitionFast = Duration(milliseconds: 200);
  static const transitionMedium = Duration(milliseconds: 400);
  static const transitionSlow = Duration(milliseconds: 500);
  static const transitionSnap = Duration(milliseconds: 380);
  static const transitionModal = Duration(milliseconds: 350);
  static const delayInputFocus = Duration(milliseconds: 500);
  static const delayHapticDouble = Duration(milliseconds: 80);

  // Layout
  static const double breakpointCompact = 360.0;
  static const double paddingPageCompact = 20.0;
  static const double paddingPage = 24.0;
  static const double phoneWidthRatio = 0.72;

  // Slider
  static const double sliderThreshold = 0.88;

  // Blur
  static const double blurGlow = 8.0;
  static const double blurGlass = 20.0;
  static const double blurCard = 28.0;
  static const double blurModal = 24.0;

  /// Returns the horizontal page padding based on screen width.
  static double responsiveHPad(double screenWidth) =>
      screenWidth < breakpointCompact ? paddingPageCompact : paddingPage;

  // Font families (package-prefixed so they resolve from the library bundle)
  static const String fontSerif = 'packages/onboarding_reference/PlayfairDisplay';
  static const String fontUI = 'packages/onboarding_reference/PlusJakartaSans';
  static const String fontSans = 'packages/onboarding_reference/PlusJakartaSans';
}
