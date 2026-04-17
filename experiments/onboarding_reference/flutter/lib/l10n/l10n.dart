import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

export 'app_localizations.dart';

/// Convenience extension for accessing [AppLocalizations] from [BuildContext].
///
/// Usage: `context.l10n.ctaContinue`
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
