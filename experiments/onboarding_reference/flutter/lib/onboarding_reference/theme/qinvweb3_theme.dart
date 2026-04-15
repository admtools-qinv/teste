import 'package:flutter/material.dart';

import 'qinvweb3_tokens.dart';

class QInvWeb3Theme {
  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);

    final scheme = ColorScheme.fromSeed(
      seedColor: QInvWeb3Tokens.primary,
      brightness: Brightness.dark,
      surface: QInvWeb3Tokens.cardBgDropdown,
    ).copyWith(
      primary: QInvWeb3Tokens.primary,
      onPrimary: QInvWeb3Tokens.primaryForeground,
      secondary: QInvWeb3Tokens.primaryLight,
      onSecondary: QInvWeb3Tokens.foreground,
      surface: QInvWeb3Tokens.cardBgDropdown,
      onSurface: QInvWeb3Tokens.foreground,
      error: QInvWeb3Tokens.destructive,
      onError: QInvWeb3Tokens.destructiveForeground,
    );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: QInvWeb3Tokens.background,
      textTheme: base.textTheme.copyWith(
        headlineLarge: base.textTheme.headlineLarge?.copyWith(
          fontFamily: QInvWeb3Tokens.fontUI,
          fontSize: QInvWeb3Tokens.fontSizeHeadlineL,
          fontWeight: FontWeight.w600,
          color: QInvWeb3Tokens.textHeading,
          height: 1.08,
          letterSpacing: -0.7,
        ),
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          fontFamily: QInvWeb3Tokens.fontUI,
          fontSize: QInvWeb3Tokens.fontSizeHeadlineM,
          fontWeight: FontWeight.w600,
          color: QInvWeb3Tokens.textHeading,
          height: 1.10,
          letterSpacing: -0.6,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontFamily: QInvWeb3Tokens.fontUI,
          fontSize: 17.0,
          fontWeight: FontWeight.w600,
          color: QInvWeb3Tokens.foreground,
          height: 1.25,
          letterSpacing: -0.2,
        ),
        bodyLarge: base.textTheme.bodyLarge?.copyWith(
          fontFamily: QInvWeb3Tokens.fontUI,
          fontSize: QInvWeb3Tokens.fontSizeBody,
          fontWeight: FontWeight.w400,
          color: QInvWeb3Tokens.textSecondary,
          height: 1.55,
          letterSpacing: 0.15,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          fontFamily: QInvWeb3Tokens.fontUI,
          fontSize: QInvWeb3Tokens.fontSizeSubtitle,
          fontWeight: FontWeight.w400,
          color: QInvWeb3Tokens.textSecondary,
          height: 1.50,
          letterSpacing: 0.1,
        ),
        bodySmall: base.textTheme.bodySmall?.copyWith(
          fontFamily: QInvWeb3Tokens.fontUI,
          fontSize: QInvWeb3Tokens.fontSizeSmall,
          fontWeight: FontWeight.w400,
          color: QInvWeb3Tokens.textMuted,
          height: 1.40,
          letterSpacing: 0.2,
        ),
        labelLarge: base.textTheme.labelLarge?.copyWith(
          fontFamily: QInvWeb3Tokens.fontUI,
          fontSize: QInvWeb3Tokens.fontSizeLabel,
          fontWeight: FontWeight.w600,
          color: QInvWeb3Tokens.foreground,
          height: 1.0,
          letterSpacing: 0.3,
        ),
        labelMedium: base.textTheme.labelMedium?.copyWith(
          fontFamily: QInvWeb3Tokens.fontUI,
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
          color: QInvWeb3Tokens.textSecondary,
          height: 1.0,
          letterSpacing: 0.4,
        ),
        labelSmall: base.textTheme.labelSmall?.copyWith(
          fontFamily: QInvWeb3Tokens.fontUI,
          fontSize: QInvWeb3Tokens.fontSizeLabelS,
          fontWeight: FontWeight.w600,
          color: QInvWeb3Tokens.textMuted,
          height: 1.0,
          letterSpacing: 0.5,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0x12FFFFFF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(QInvWeb3Tokens.radiusInput),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(QInvWeb3Tokens.radiusInput),
          borderSide: const BorderSide(color: Color(0x1AFFFFFF), width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(QInvWeb3Tokens.radiusInput),
          borderSide: const BorderSide(color: QInvWeb3Tokens.primaryLight, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(QInvWeb3Tokens.radiusInput),
          borderSide: const BorderSide(color: QInvWeb3Tokens.destructive, width: 1.0),
        ),
        hintStyle: const TextStyle(
          fontFamily: QInvWeb3Tokens.fontUI,
          fontSize: QInvWeb3Tokens.fontSizeInputHint,
          fontWeight: FontWeight.w400,
          color: Color(0x4DFFFFFF),
          letterSpacing: 0.1,
        ),
        labelStyle: const TextStyle(
          fontFamily: QInvWeb3Tokens.fontUI,
          fontSize: 13.0,
          fontWeight: FontWeight.w500,
          color: QInvWeb3Tokens.textSecondary,
          letterSpacing: 0.3,
        ),
        floatingLabelStyle: const TextStyle(
          fontFamily: QInvWeb3Tokens.fontUI,
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
          color: QInvWeb3Tokens.primaryLight,
        ),
        helperStyle: const TextStyle(
          fontFamily: QInvWeb3Tokens.fontUI,
          fontSize: QInvWeb3Tokens.fontSizeInputHelper,
          fontWeight: FontWeight.w400,
          color: QInvWeb3Tokens.textMuted,
          letterSpacing: 0.2,
        ),
        counterStyle: const TextStyle(
          fontFamily: QInvWeb3Tokens.fontUI,
          fontSize: 11.0,
          fontWeight: FontWeight.w400,
          color: QInvWeb3Tokens.textMuted,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: QInvWeb3Tokens.primary,
          foregroundColor: QInvWeb3Tokens.primaryForeground,
          minimumSize: const Size.fromHeight(54),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(QInvWeb3Tokens.radiusButton),
          ),
          textStyle: const TextStyle(
            fontFamily: QInvWeb3Tokens.fontUI,
            fontSize: QInvWeb3Tokens.fontSizeLabel,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: QInvWeb3Tokens.foreground,
          side: const BorderSide(color: QInvWeb3Tokens.border),
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(QInvWeb3Tokens.radiusButton),
          ),
          textStyle: const TextStyle(
            fontFamily: QInvWeb3Tokens.fontUI,
            fontSize: QInvWeb3Tokens.fontSizeLabel,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: QInvWeb3Tokens.cardBgLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(QInvWeb3Tokens.radiusCard),
          side: const BorderSide(color: QInvWeb3Tokens.border),
        ),
      ),
      dividerTheme: const DividerThemeData(color: QInvWeb3Tokens.border),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: QInvWeb3Tokens.primary,
        linearTrackColor: QInvWeb3Tokens.border,
      ),
    );
  }
}
