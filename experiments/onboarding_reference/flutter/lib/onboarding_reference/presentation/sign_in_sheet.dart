import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/auth/auth_service.dart';
import '../theme/qinvweb3_tokens.dart';
import 'widgets/glass_input_field.dart';
import 'widgets/pin_input_widget.dart';
import 'widgets/qinv_button.dart';

/// Bottom sheet multi-passo para login de usuário sem sessão salva.
///
/// Passo 1: e-mail
/// Passo 2: senha numérica (PIN) com teclado customizado
///
/// Uso via [showSignInSheet]:
/// ```dart
/// await showSignInSheet(
///   context: context,
///   authService: myService,
///   onLoginSuccess: (result, email) async { ... },
/// );
/// ```
Future<void> showSignInSheet({
  required BuildContext context,
  required AuthService authService,
  required Future<void> Function(AuthResult result, String email) onLoginSuccess,
  VoidCallback? onForgotPassword,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.72),
    builder: (_) => SignInSheet(
      authService: authService,
      onLoginSuccess: onLoginSuccess,
      onForgotPassword: onForgotPassword,
    ),
  );
}

class SignInSheet extends StatefulWidget {
  final AuthService authService;
  final Future<void> Function(AuthResult result, String email) onLoginSuccess;
  final VoidCallback? onForgotPassword;

  const SignInSheet({
    super.key,
    required this.authService,
    required this.onLoginSuccess,
    this.onForgotPassword,
  });

  @override
  State<SignInSheet> createState() => _SignInSheetState();
}

enum _Step { email, pin }

class _SignInSheetState extends State<SignInSheet> {
  _Step _step = _Step.email;
  String _email = '';
  bool _busy = false;
  String? _error;
  Key _pinKey = UniqueKey();

  // ── Step 1: e-mail ────────────────────────────────────────────────

  void _continueWithEmail(String email) {
    final trimmed = email.trim();
    if (trimmed.isEmpty) return;
    // Validação mínima — evita avançar sem um email no formato básico.
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmed)) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _email = trimmed;
      _step = _Step.pin;
      _error = null;
    });
  }

  // ── Step 2: PIN ───────────────────────────────────────────────────

  Future<void> _submitPin(String pin) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final result = await widget.authService.login(
        email: _email,
        password: pin,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      await widget.onLoginSuccess(result, _email);
    } on AuthException catch (e) {
      if (!mounted) return;
      HapticFeedback.vibrate();
      setState(() {
        _busy = false;
        _error = e.message;
        _pinKey = UniqueKey();
      });
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

  void _goBack() {
    HapticFeedback.lightImpact();
    setState(() {
      _step = _Step.email;
      _error = null;
    });
  }

  // ── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Container(
        decoration: BoxDecoration(
          color: QInvWeb3Tokens.background,
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
          ),
        ),
        // Sobe com o teclado nativo em ambos os passos.
        padding: EdgeInsets.only(
          bottom: viewInsets.bottom > 0
              ? viewInsets.bottom + 16
              : (bottomPad > 0 ? bottomPad + 8 : 24),
        ),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          child: _step == _Step.email
              ? _EmailStep(
                  key: const ValueKey('email'),
                  onContinue: _continueWithEmail,
                )
              : _PinStep(
                  key: const ValueKey('pin'),
                  email: _email,
                  pinKey: _pinKey,
                  busy: _busy,
                  error: _error,
                  onSubmit: _submitPin,
                  onBack: _goBack,
                  onForgotPassword: widget.onForgotPassword,
                ),
        ),
      ),
    );
  }
}

// ── Passo 1: e-mail ───────────────────────────────────────────────────

class _EmailStep extends StatefulWidget {
  final void Function(String email) onContinue;

  const _EmailStep({super.key, required this.onContinue});

  @override
  State<_EmailStep> createState() => _EmailStepState();
}

class _EmailStepState extends State<_EmailStep> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  bool get _canContinue {
    final t = _ctrl.text.trim();
    return t.isNotEmpty && RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t);
  }

  void _submit() {
    if (!_canContinue) return;
    HapticFeedback.mediumImpact();
    widget.onContinue(_ctrl.text);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const QInvHandleBar(),

          const SizedBox(height: 28),

          const Text(
            'Entrar na sua conta',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: QInvWeb3Tokens.fontUI,
              fontWeight: FontWeight.w400,
              fontSize: 22,
              color: QInvWeb3Tokens.textHeading,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 28),

          GlassInputField(
            controller: _ctrl,
            focusNode: _focus,
            label: 'E-mail',
            hint: 'seu@email.com',
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            onSubmitted: (_) => _submit(),
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: 20),

          QInvButton(
            label: 'Continuar',
            onPressed: _canContinue ? _submit : null,
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── Passo 2: PIN ──────────────────────────────────────────────────────

class _PinStep extends StatelessWidget {
  final String email;
  final Key pinKey;
  final bool busy;
  final String? error;
  final Future<void> Function(String pin) onSubmit;
  final VoidCallback onBack;
  final VoidCallback? onForgotPassword;

  const _PinStep({
    super.key,
    required this.email,
    required this.pinKey,
    required this.busy,
    required this.onSubmit,
    required this.onBack,
    this.error,
    this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar + botão voltar
          Stack(
            alignment: Alignment.center,
            children: [
              const QInvHandleBar(),
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: onBack,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: QInvWeb3Tokens.textMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

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

          // Erro animado
          AnimatedSize(
            duration: QInvWeb3Tokens.transitionAll,
            curve: Curves.easeInOut,
            child: error != null
                ? Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      error!,
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

          const SizedBox(height: 16),

          // PIN dots + teclado
          AnimatedOpacity(
            duration: QInvWeb3Tokens.transitionAll,
            opacity: busy ? 0.45 : 1.0,
            child: PinInputWidget(
              key: pinKey,
              enabled: !busy,
              onComplete: onSubmit,
            ),
          ),

          const SizedBox(height: 16),

          // Chip do e-mail — abaixo do teclado, protegido contra overflow
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.person_outline_rounded,
                  size: 13,
                  color: QInvWeb3Tokens.textMuted,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    email,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: QInvWeb3Tokens.fontUI,
                      fontSize: QInvWeb3Tokens.fontSizeSmall,
                      fontWeight: FontWeight.w400,
                      color: QInvWeb3Tokens.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          if (onForgotPassword != null)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onForgotPassword!();
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  'Esqueci minha senha',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: QInvWeb3Tokens.fontUI,
                    fontSize: QInvWeb3Tokens.fontSizeSubtitle,
                    fontWeight: FontWeight.w400,
                    color: QInvWeb3Tokens.primaryLight,
                    height: 1.5,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
