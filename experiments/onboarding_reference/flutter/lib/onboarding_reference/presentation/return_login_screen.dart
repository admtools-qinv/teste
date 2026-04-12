import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/auth/biometric_auth_service.dart';
import '../theme/qinvweb3_tokens.dart';
import 'widgets/glass_input_field.dart';
import 'widgets/glass_widgets.dart';
import 'widgets/pin_input_widget.dart';
import 'widgets/qinv_button.dart';

/// Tela de login para usuário retornante (sessão expirada, app reaberto).
///
/// Exibe saudação personalizada + painel inferior. Ao tocar "Acessar conta":
/// - Se [biometricService] disponível → dispara biometria direto (sem sheet).
/// - Se falhar ou não houver biometria → abre bottom sheet com PIN numérico.
///
/// Callbacks:
/// - [onSuccess] — autenticação concluída; parent navega para o home.
/// - [onForgotPassword] — usuário pediu redefinição de senha.
/// - [onSwitchAccount] — usuário não é o dono desta conta salva.
class ReturnLoginScreen extends StatefulWidget {
  final String displayName;
  final String email;
  final BiometricAuthService? biometricService;
  final Future<bool> Function(String pin) onPinSubmit;
  final VoidCallback onSuccess;
  final VoidCallback? onForgotPassword;
  final VoidCallback? onSwitchAccount;

  const ReturnLoginScreen({
    super.key,
    required this.displayName,
    required this.email,
    required this.onPinSubmit,
    required this.onSuccess,
    this.biometricService,
    this.onForgotPassword,
    this.onSwitchAccount,
  });

  @override
  State<ReturnLoginScreen> createState() => _ReturnLoginScreenState();
}

class _ReturnLoginScreenState extends State<ReturnLoginScreen> {
  bool _biometricBusy = false;
  // Fica true após falha/cancelamento — mostra fallback "Usar senha"
  bool _biometricFailed = false;

  bool get _hasBiometric => widget.biometricService != null;

  @override
  void initState() {
    super.initState();
    if (_hasBiometric) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _triggerBiometric());
    }
  }

  Future<void> _triggerBiometric() async {
    if (_biometricBusy || !_hasBiometric) return;
    setState(() {
      _biometricBusy = true;
      _biometricFailed = false;
    });

    try {
      final available = await widget.biometricService!.isAvailable();
      if (!available || !mounted) {
        setState(() {
          _biometricBusy = false;
          _biometricFailed = true;
        });
        return;
      }

      final ok = await widget.biometricService!.authenticate(
        localizedReason: 'Use sua biometria para entrar na Qinv',
      );

      if (!mounted) return;
      if (ok) {
        HapticFeedback.mediumImpact();
        widget.onSuccess();
      } else {
        // Usuário cancelou — mostra opção de usar senha
        setState(() => _biometricFailed = true);
      }
    } on BiometricException {
      if (mounted) setState(() => _biometricFailed = true);
    } catch (_) {
      if (mounted) setState(() => _biometricFailed = true);
    } finally {
      if (mounted) setState(() => _biometricBusy = false);
    }
  }

  Future<void> _openPinSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      builder: (_) => _PinSheet(
        onSubmit: widget.onPinSubmit,
        onSuccess: widget.onSuccess,
        onForgotPassword: widget.onForgotPassword,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: QInvWeb3Tokens.background,
      body: GlassBackground(
        child: Stack(
          children: [
            // ── Modo biometria: minimalista, diálogo abre sozinho ───
            if (_hasBiometric)
              Positioned.fill(
                child: _BiometricWaitView(
                  busy: _biometricBusy,
                  failed: _biometricFailed,
                  onRetry: _triggerBiometric,
                  onUsePin: _openPinSheet,
                  onSwitchAccount: widget.onSwitchAccount,
                  bottomPadding: bottom,
                ),
              )
            // ── Sem biometria: painel com saudação + botão ──────────
            else
              Align(
                alignment: Alignment.bottomCenter,
                child: _BottomPanel(
                  displayName: widget.displayName,
                  email: widget.email,
                  onAccessTap: _openPinSheet,
                  onSwitchAccount: widget.onSwitchAccount,
                  bottomPadding: bottom,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── View minimalista enquanto aguarda/após falha biométrica ──────────

class _BiometricWaitView extends StatelessWidget {
  final bool busy;
  final bool failed;
  final VoidCallback onRetry;
  final VoidCallback onUsePin;
  final VoidCallback? onSwitchAccount;
  final double bottomPadding;

  const _BiometricWaitView({
    required this.busy,
    required this.failed,
    required this.onRetry,
    required this.onUsePin,
    required this.bottomPadding,
    this.onSwitchAccount,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(32, 0, 32, bottomPadding > 0 ? bottomPadding + 16 : 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Ícone de biometria
            AnimatedOpacity(
              duration: QInvWeb3Tokens.transitionAll,
              opacity: busy ? 0.4 : 1.0,
              child: GestureDetector(
                onTap: busy ? null : onRetry,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                    border: Border.all(
                      color: QInvWeb3Tokens.primaryLight.withValues(alpha: failed ? 0.25 : 0.45),
                      width: 1.5,
                    ),
                    boxShadow: failed
                        ? []
                        : [
                            BoxShadow(
                              color: QInvWeb3Tokens.primary.withValues(alpha: 0.30),
                              blurRadius: 28,
                            ),
                          ],
                  ),
                  child: busy
                      ? const Padding(
                          padding: EdgeInsets.all(22),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              QInvWeb3Tokens.primaryLight,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.fingerprint_rounded,
                          size: 36,
                          color: failed
                              ? QInvWeb3Tokens.textMuted
                              : QInvWeb3Tokens.primaryLight,
                        ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Texto de estado
            Text(
              busy
                  ? 'Verificando...'
                  : failed
                      ? 'Não foi possível verificar'
                      : 'Toque para tentar novamente',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: QInvWeb3Tokens.fontUI,
                fontSize: QInvWeb3Tokens.fontSizeSmall,
                fontWeight: FontWeight.w400,
                color: QInvWeb3Tokens.textMuted,
              ),
            ),

            const SizedBox(height: 28),

            // Link "Usar senha" — só aparece após falha
            AnimatedOpacity(
              duration: QInvWeb3Tokens.transitionAll,
              opacity: failed ? 1.0 : 0.0,
              child: IgnorePointer(
                ignoring: !failed,
                child: _TextLink(label: 'Usar senha', onTap: onUsePin),
              ),
            ),

            const SizedBox(height: 12),

            if (onSwitchAccount != null)
              _TextLink(
                label: 'Não é você?',
                onTap: onSwitchAccount!,
                muted: true,
              ),
          ],
        ),
      ),
    );
  }
}

// ── Painel inferior (sem biometria) ──────────────────────────────────

class _BottomPanel extends StatelessWidget {
  final String displayName;
  final String email;
  final VoidCallback onAccessTap;
  final VoidCallback? onSwitchAccount;
  final double bottomPadding;

  const _BottomPanel({
    required this.displayName,
    required this.email,
    required this.onAccessTap,
    required this.bottomPadding,
    this.onSwitchAccount,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            24, 28, 24,
            bottomPadding > 0 ? bottomPadding + 12 : 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Olá, $displayName',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: QInvWeb3Tokens.fontSerif,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                  fontSize: 28,
                  color: QInvWeb3Tokens.textHeading,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                email,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: QInvWeb3Tokens.fontUI,
                  fontSize: QInvWeb3Tokens.fontSizeSmall,
                  fontWeight: FontWeight.w400,
                  color: QInvWeb3Tokens.textMuted,
                ),
              ),

              const SizedBox(height: 28),

              QInvButton(
                label: 'Acessar conta',
                onPressed: onAccessTap,
              ),

              const SizedBox(height: 20),

              if (onSwitchAccount != null)
                _TextLink(
                  label: 'Não é você?',
                  onTap: onSwitchAccount!,
                  muted: true,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── PIN bottom sheet ─────────────────────────────────────────────────

class _PinSheet extends StatefulWidget {
  final Future<bool> Function(String pin) onSubmit;
  final VoidCallback onSuccess;
  final VoidCallback? onForgotPassword;

  const _PinSheet({
    required this.onSubmit,
    required this.onSuccess,
    this.onForgotPassword,
  });

  @override
  State<_PinSheet> createState() => _PinSheetState();
}

class _PinSheetState extends State<_PinSheet> {
  bool _busy = false;
  String? _error;
  // Key força rebuild do PinInputWidget quando precisamos resetar os dots.
  Key _pinKey = UniqueKey();

  Future<void> _onComplete(String pin) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final ok = await widget.onSubmit(pin);
      if (!mounted) return;

      if (ok) {
        HapticFeedback.mediumImpact();
        Navigator.of(context).pop();
        widget.onSuccess();
      } else {
        HapticFeedback.vibrate();
        setState(() {
          _busy = false;
          _error = 'Senha incorreta. Tente novamente.';
          _pinKey = UniqueKey(); // reseta os dots
        });
      }
    } catch (_) {
      if (!mounted) return;
      HapticFeedback.vibrate();
      setState(() {
        _busy = false;
        _error = 'Erro de conexão. Tente novamente.';
        _pinKey = UniqueKey();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Container(
          decoration: BoxDecoration(
            color: QInvWeb3Tokens.background,
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
            ),
          ),
          padding: EdgeInsets.fromLTRB(24, 32, 24, bottom > 0 ? bottom + 8 : 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const QInvHandleBar(),

              const SizedBox(height: 28),

              // Título
              const Text(
                'Insira sua senha',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: QInvWeb3Tokens.fontUI,
                  fontWeight: FontWeight.w400,
                  fontSize: 22,
                  color: QInvWeb3Tokens.textHeading,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 8),

              // Mensagem de erro animada
              AnimatedSize(
                duration: QInvWeb3Tokens.transitionAll,
                curve: Curves.easeInOut,
                child: _error != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: QInvWeb3Tokens.fontUI,
                            fontSize: QInvWeb3Tokens.fontSizeSmall,
                            fontWeight: FontWeight.w400,
                            color: QInvWeb3Tokens.destructive,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 20),

              // PIN widget (dots + teclado customizado)
              AnimatedOpacity(
                duration: QInvWeb3Tokens.transitionAll,
                opacity: _busy ? 0.45 : 1.0,
                child: PinInputWidget(
                  key: _pinKey,
                  enabled: !_busy,
                  onComplete: _onComplete,
                ),
              ),

              const SizedBox(height: 12),

              // Link "Esqueci minha senha"
              if (widget.onForgotPassword != null)
                _TextLink(
                  label: 'Esqueci minha senha',
                  onTap: widget.onForgotPassword!,
                ),
            ],
          ),
        ),
    );
  }
}

// ── Link de texto reutilizável ────────────────────────────────────────

class _TextLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool muted;

  const _TextLink({
    required this.label,
    required this.onTap,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: QInvWeb3Tokens.fontUI,
              fontSize: QInvWeb3Tokens.fontSizeSubtitle,
              fontWeight: FontWeight.w400,
              color: muted
                  ? QInvWeb3Tokens.textMuted
                  : QInvWeb3Tokens.primaryLight,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
