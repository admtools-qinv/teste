import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/l10n.dart';
import '../services/auth/auth_service.dart';
import '../theme/qinvweb3_tokens.dart';
import 'widgets/glass_input_field.dart';
import 'widgets/glass_widgets.dart';
import 'widgets/qinv_button.dart';
import 'widgets/qinv_error_banner.dart';

/// Email + password login screen.
///
/// Does NOT navigate itself — calls [onLoginSuccess] with the [AuthResult]
/// and the email used, letting the parent decide where to go (e.g. whether
/// to show the biometric prompt first).
///
/// Usage:
/// ```dart
/// EmailPasswordScreen(
///   authService: myAuthService,
///   initialEmail: store.savedEmail,
///   onLoginSuccess: (result, email) async {
///     await store.saveEmail(email);
///     await store.saveToken(result.token);
///     // navigate…
///   },
/// )
/// ```
class EmailPasswordScreen extends StatefulWidget {
  final AuthService authService;
  final String? initialEmail;
  final Future<void> Function(AuthResult result, String email) onLoginSuccess;

  const EmailPasswordScreen({
    super.key,
    required this.authService,
    required this.onLoginSuccess,
    this.initialEmail,
  });

  @override
  State<EmailPasswordScreen> createState() => _EmailPasswordScreenState();
}

class _EmailPasswordScreenState extends State<EmailPasswordScreen> {
  late final TextEditingController _emailCtrl;
  final TextEditingController _passwordCtrl = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _busy = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController(text: widget.initialEmail ?? '');
    // If email is pre-filled, focus password directly.
    if (widget.initialEmail != null && widget.initialEmail!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _passwordFocus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      !_busy &&
      _emailCtrl.text.trim().isNotEmpty &&
      _passwordCtrl.text.isNotEmpty;

  Future<void> _submit() async {
    if (!_canSubmit) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _busy = true;
      _errorMessage = null;
    });

    try {
      final result = await widget.authService.login(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      if (!mounted) return;
      await widget.onLoginSuccess(result, _emailCtrl.text.trim());
    } on AuthException catch (e) {
      if (!mounted) return;
      HapticFeedback.vibrate();
      setState(() => _errorMessage = e.message);
    } catch (_) {
      if (!mounted) return;
      HapticFeedback.vibrate();
      setState(() => _errorMessage = context.l10n.connectionError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

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
                const SizedBox(height: 12),
                _BackButton(),
                const Spacer(flex: 2),
                _buildHeader(),
                const SizedBox(height: 36),
                _buildForm(),
                const Spacer(flex: 3),
                QInvButton(
                  label: context.l10n.signIn,
                  busy: _busy,
                  onPressed: _canSubmit ? _submit : null,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          context.l10n.welcomeBack,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: QInvWeb3Tokens.fontSans,
            fontSize: QInvWeb3Tokens.fontSizeHeadlineL,
            fontWeight: FontWeight.w500,
            color: QInvWeb3Tokens.textHeading,
            height: 1.2,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.welcomeBackSubtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: QInvWeb3Tokens.fontSans,
            fontSize: QInvWeb3Tokens.fontSizeBody,
            fontWeight: FontWeight.w400,
            color: QInvWeb3Tokens.textMuted,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassInputField(
          controller: _emailCtrl,
          focusNode: _emailFocus,
          label: context.l10n.emailLabel,
          hint: context.l10n.emailHint,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          enabled: !_busy,
          onSubmitted: (_) => _passwordFocus.requestFocus(),
          onChanged: (_) => setState(() => _errorMessage = null),
        ),
        const SizedBox(height: 16),
        GlassInputField(
          controller: _passwordCtrl,
          focusNode: _passwordFocus,
          label: context.l10n.passwordLabel,
          hint: '••••••••',
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          enabled: !_busy,
          onSubmitted: (_) => _submit(),
          onChanged: (_) => setState(() => _errorMessage = null),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: QInvWeb3Tokens.textMuted,
              size: 20,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        AnimatedSize(
          duration: QInvWeb3Tokens.transitionAll,
          curve: Curves.easeInOut,
          child: _errorMessage != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: QInvErrorBanner(message: _errorMessage!),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ── Back button ──────────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Semantics(
        button: true,
        label: context.l10n.tooltipBack,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).maybePop();
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.07),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: QInvWeb3Tokens.textMuted,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

