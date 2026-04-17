import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/l10n.dart';
import '../theme/qinvweb3_tokens.dart';
import 'widgets/glass_widgets.dart';
import 'widgets/qinv_button.dart';

/// Shown once after the first successful email/password login.
///
/// Asks the user if they want to use biometric authentication for
/// future logins. Never shown again after [onEnabled] or [onSkipped]
/// is called — the caller must call [LocalCredentialStore.setBiometricEnabled]
/// (or [markBiometricAsked]) before navigating away.
class BiometricPromptScreen extends StatelessWidget {
  final VoidCallback onEnabled;
  final VoidCallback onSkipped;

  const BiometricPromptScreen({
    super.key,
    required this.onEnabled,
    required this.onSkipped,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final hPad = QInvWeb3Tokens.responsiveHPad(size.width);

    return Scaffold(
      backgroundColor: QInvWeb3Tokens.background,
      body: GlassBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 3),
                _buildContent(context),
                const Spacer(flex: 2),
                _buildActions(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      children: [
        // Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: QInvWeb3Tokens.primary.withValues(alpha: 0.14),
            border: Border.all(
              color: QInvWeb3Tokens.primaryLight.withValues(alpha: 0.30),
              width: 1.5,
            ),
          ),
          child: const Icon(
            Icons.fingerprint_rounded,
            size: 40,
            color: QInvWeb3Tokens.primaryLight,
          ),
        ),

        const SizedBox(height: 28),

        Text(
          context.l10n.biometricLoginTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: QInvWeb3Tokens.fontSans,
            fontSize: QInvWeb3Tokens.fontSizeHeadlineM,
            fontWeight: FontWeight.w500,
            color: QInvWeb3Tokens.textHeading,
            height: 1.2,
            letterSpacing: -0.2,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          context.l10n.biometricLoginDescription,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: QInvWeb3Tokens.fontSans,
            fontSize: QInvWeb3Tokens.fontSizeBody,
            fontWeight: FontWeight.w400,
            color: QInvWeb3Tokens.textMuted,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QInvButton(
          label: context.l10n.biometricEnable,
          onPressed: () {
            HapticFeedback.mediumImpact();
            onEnabled();
          },
        ),
        const SizedBox(height: 16),
        QInvButton(
          label: context.l10n.biometricSkip,
          outline: true,
          onPressed: () {
            HapticFeedback.lightImpact();
            onSkipped();
          },
        ),
      ],
    );
  }
}
