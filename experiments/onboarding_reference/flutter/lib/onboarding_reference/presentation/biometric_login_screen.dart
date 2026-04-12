import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/auth/biometric_auth_service.dart';
import '../theme/qinvweb3_tokens.dart';
import 'widgets/glass_widgets.dart';

/// Shown when the user has previously enabled biometric login.
///
/// Automatically triggers the biometric prompt on mount.
/// Provides a "use password instead" fallback link.
///
/// Callbacks:
/// - [onSuccess] — biometric auth succeeded; parent navigates to home.
/// - [onFallbackToPassword] — user chose password or biometrics unavailable;
///   parent should push [EmailPasswordScreen] with the saved email.
///
/// **iOS:** ensure `NSFaceIDUsageDescription` is present in `Info.plist`.
/// **Android:** `USE_BIOMETRIC` + `USE_FINGERPRINT` permissions are required.
class BiometricLoginScreen extends StatefulWidget {
  final String email;
  final BiometricAuthService biometricService;
  final VoidCallback onSuccess;
  final VoidCallback onFallbackToPassword;

  const BiometricLoginScreen({
    super.key,
    required this.email,
    required this.biometricService,
    required this.onSuccess,
    required this.onFallbackToPassword,
  });

  @override
  State<BiometricLoginScreen> createState() => _BiometricLoginScreenState();
}

class _BiometricLoginScreenState extends State<BiometricLoginScreen> {
  bool _busy = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Trigger immediately so the user doesn't have to tap.
    WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
  }

  Future<void> _authenticate() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _errorMessage = null;
    });

    try {
      final available = await widget.biometricService.isAvailable();
      if (!mounted) return;

      if (!available) {
        setState(() {
          _busy = false;
          _errorMessage = _messageFor(BiometricFailureReason.notAvailable);
        });
        return;
      }

      final authenticated = await widget.biometricService.authenticate(
        localizedReason: 'Use sua biometria para entrar na Qinv',
      );
      if (!mounted) return;

      if (authenticated) {
        HapticFeedback.mediumImpact();
        widget.onSuccess();
      } else {
        setState(() => _errorMessage = 'Autenticação cancelada. Tente novamente.');
      }
    } on BiometricException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = _messageFor(e.reason));
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Erro inesperado. Tente novamente.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _messageFor(BiometricFailureReason reason) {
    switch (reason) {
      case BiometricFailureReason.notAvailable:
        return 'Biometria não disponível neste dispositivo.';
      case BiometricFailureReason.notEnrolled:
        return 'Nenhuma biometria cadastrada. Configure nas Configurações do dispositivo.';
      case BiometricFailureReason.lockedOut:
        return 'Muitas tentativas. Aguarde um momento e tente novamente.';
      case BiometricFailureReason.permanentlyLockedOut:
        return 'Biometria bloqueada. Use sua senha do dispositivo para desbloquear.';
      case BiometricFailureReason.passcodeNotSet:
        return 'Defina um PIN ou senha no dispositivo para usar biometria.';
      case BiometricFailureReason.unknown:
        return 'Erro na autenticação. Tente novamente ou use sua senha.';
    }
  }

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
                const Spacer(flex: 2),
                _buildContent(),
                const Spacer(flex: 3),
                _buildPasswordLink(),
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
        // Email chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.person_outline_rounded,
                size: 15,
                color: QInvWeb3Tokens.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                widget.email,
                style: const TextStyle(
                  fontFamily: QInvWeb3Tokens.fontUI,
                  fontSize: QInvWeb3Tokens.fontSizeSmall,
                  fontWeight: FontWeight.w400,
                  color: QInvWeb3Tokens.textSecondary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 36),

        // Biometric button
        Semantics(
          button: true,
          label: 'Autenticar com biometria',
          child: GestureDetector(
            onTap: _busy ? null : _authenticate,
            child: AnimatedContainer(
              duration: QInvWeb3Tokens.transitionAll,
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    QInvWeb3Tokens.primary.withValues(alpha: _busy ? 0.30 : 0.22),
                    QInvWeb3Tokens.primary.withValues(alpha: 0.06),
                  ],
                ),
                border: Border.all(
                  color: QInvWeb3Tokens.primaryLight.withValues(
                    alpha: _busy ? 0.20 : 0.40,
                  ),
                  width: 1.5,
                ),
                boxShadow: _busy
                    ? []
                    : [
                        BoxShadow(
                          color: QInvWeb3Tokens.primary.withValues(alpha: 0.30),
                          blurRadius: 32,
                          spreadRadius: 2,
                        ),
                      ],
              ),
              child: _busy
                  ? const Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            QInvWeb3Tokens.primaryLight),
                      ),
                    )
                  : const Icon(
                      Icons.fingerprint_rounded,
                      size: 48,
                      color: QInvWeb3Tokens.primaryLight,
                    ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        Text(
          _busy ? 'Verificando...' : 'Toque para entrar',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: QInvWeb3Tokens.fontSans,
            fontSize: QInvWeb3Tokens.fontSizeBody,
            fontWeight: FontWeight.w400,
            color: QInvWeb3Tokens.textMuted,
            height: 1.5,
          ),
        ),

        // Error message (animated)
        AnimatedSize(
          duration: QInvWeb3Tokens.transitionAll,
          curve: Curves.easeInOut,
          child: _errorMessage != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 20, left: 8, right: 8),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: QInvWeb3Tokens.fontUI,
                      fontSize: QInvWeb3Tokens.fontSizeSmall,
                      fontWeight: FontWeight.w400,
                      color: QInvWeb3Tokens.destructive,
                      height: 1.4,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildPasswordLink() {
    return Semantics(
      button: true,
      label: 'Usar senha em vez da biometria',
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onFallbackToPassword();
        },
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Usar senha em vez disso',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: QInvWeb3Tokens.fontUI,
              fontSize: QInvWeb3Tokens.fontSizeSubtitle,
              fontWeight: FontWeight.w400,
              color: QInvWeb3Tokens.textMuted,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
