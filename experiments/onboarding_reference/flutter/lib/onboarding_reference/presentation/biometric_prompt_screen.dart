import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    final hPad = size.width < 360 ? 20.0 : 24.0;

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
                _buildContent(),
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

  Widget _buildContent() {
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

        const Text(
          'Login com biometria?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: QInvWeb3Tokens.fontSans,
            fontSize: QInvWeb3Tokens.fontSizeHeadlineM,
            fontWeight: FontWeight.w500,
            color: QInvWeb3Tokens.textHeading,
            height: 1.2,
            letterSpacing: -0.2,
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          'Use sua digital ou reconhecimento facial para entrar rapidamente nos próximos acessos.',
          textAlign: TextAlign.center,
          style: TextStyle(
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
          label: 'Sim, usar biometria',
          onPressed: () {
            HapticFeedback.mediumImpact();
            onEnabled();
          },
        ),
        const SizedBox(height: 16),
        QInvButton(
          label: 'Não, obrigado',
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
