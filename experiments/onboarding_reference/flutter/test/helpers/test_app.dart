import 'package:flutter/material.dart';
import 'package:onboarding_reference/onboarding_reference.dart';

/// Wraps [home] in a MaterialApp configured with l10n and the dark theme.
Widget buildTestApp({required Widget home}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: QInvWeb3Theme.dark(),
    home: home,
  );
}
