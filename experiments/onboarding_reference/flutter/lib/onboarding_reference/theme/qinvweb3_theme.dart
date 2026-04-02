import 'package:flutter/material.dart';

import 'qinvweb3_tokens.dart';

class QInvWeb3Theme {
  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);

    final scheme = ColorScheme.fromSeed(
      seedColor: QInvWeb3Tokens.primary,
      brightness: Brightness.dark,
      background: QInvWeb3Tokens.background,
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
          fontFamily: 'Plus Jakarta Sans',
          color: QInvWeb3Tokens.textHeading,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          fontFamily: 'Plus Jakarta Sans',
          color: QInvWeb3Tokens.textHeading,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontFamily: 'Plus Jakarta Sans',
          color: QInvWeb3Tokens.foreground,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: base.textTheme.bodyLarge?.copyWith(
          fontFamily: 'Plus Jakarta Sans',
          color: QInvWeb3Tokens.textSecondary,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          fontFamily: 'Plus Jakarta Sans',
          color: QInvWeb3Tokens.textSecondary,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: base.textTheme.bodySmall?.copyWith(
          fontFamily: 'Plus Jakarta Sans',
          color: QInvWeb3Tokens.textMuted,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: base.textTheme.labelLarge?.copyWith(
          fontFamily: 'Plus Jakarta Sans',
          color: QInvWeb3Tokens.foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: QInvWeb3Tokens.input,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(QInvWeb3Tokens.radiusCard),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(QInvWeb3Tokens.radiusCard),
          borderSide: const BorderSide(color: QInvWeb3Tokens.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(QInvWeb3Tokens.radiusCard),
          borderSide: const BorderSide(color: QInvWeb3Tokens.ring, width: 1.4),
        ),
        hintStyle: const TextStyle(color: QInvWeb3Tokens.textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: QInvWeb3Tokens.primary,
          foregroundColor: QInvWeb3Tokens.primaryForeground,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(QInvWeb3Tokens.radiusCard),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: QInvWeb3Tokens.foreground,
          side: const BorderSide(color: QInvWeb3Tokens.border),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(QInvWeb3Tokens.radiusCard),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w600,
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
      useMaterial3: true,
    );
  }
}
