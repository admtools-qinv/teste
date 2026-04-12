import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/qinvweb3_tokens.dart';
import 'widgets/glass_widgets.dart';
import 'widgets/qinv_button.dart';

class LoginScreen extends StatelessWidget {
  final VoidCallback? onGoogleAuth;
  final VoidCallback? onSignUp;
  final VoidCallback? onLogin;
  final String title;
  final List<String> accentPhrases;
  final String subtitle;
  final bool showBackground;

  const LoginScreen({
    super.key,
    this.onGoogleAuth,
    this.onSignUp,
    this.onLogin,
    this.showBackground = true,
    this.title = 'Your wealth,',
    this.accentPhrases = const [
      'always growing.',
      'on autopilot.',
      'working for you.',
      'never sleeping.',
    ],
    this.subtitle = 'Start in minutes, grow for years.',
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final hPad = size.width < 360 ? 20.0 : 24.0;

    final content = SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: hPad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(flex: 3),
            _buildHero(),
            const Spacer(flex: 2),
            _buildCtas(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor:
          showBackground ? QInvWeb3Tokens.background : Colors.transparent,
      body: showBackground ? GlassBackground(child: content) : content,
    );
  }

  Widget _buildHero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Static title
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: QInvWeb3Tokens.fontSans,
            fontSize: 28,
            fontWeight: FontWeight.w500,
            color: QInvWeb3Tokens.textHeading,
            height: 1.2,
            letterSpacing: -0.2,
          ),
        ),

        const SizedBox(height: 2),

        // Animated typewriter accent
        _TypewriterAccent(phrases: accentPhrases),

        const SizedBox(height: 18),

        // Subtitle
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: QInvWeb3Tokens.fontSans,
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: QInvWeb3Tokens.textMuted,
            height: 1.6,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }

  Widget _buildCtas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _GoogleButton(onPressed: onGoogleAuth),
        const SizedBox(height: 16),
        const _OrDivider(),
        const SizedBox(height: 16),
        QInvButton(
          label: 'Sign up',
          onPressed: onSignUp,
        ),
        const SizedBox(height: 28),
        _LoginLink(onLogin: onLogin),
      ],
    );
  }
}

// ── Typewriter accent ─────────────────────────────────────────────

class _TypewriterAccent extends StatefulWidget {
  final List<String> phrases;

  const _TypewriterAccent({required this.phrases});

  @override
  State<_TypewriterAccent> createState() => _TypewriterAccentState();
}

class _TypewriterAccentState extends State<_TypewriterAccent> {
  int _phraseIndex = 0;
  int _charCount = 0;
  bool _isDeleting = false;
  bool _cursorVisible = true;
  Timer? _typeTimer;
  Timer? _cursorTimer;

  @override
  void initState() {
    super.initState();
    _cursorTimer = Timer.periodic(
      const Duration(milliseconds: 530),
      (_) { if (mounted) setState(() => _cursorVisible = !_cursorVisible); },
    );
    _schedule(const Duration(milliseconds: 600));
  }

  @override
  void dispose() {
    _typeTimer?.cancel();
    _cursorTimer?.cancel();
    super.dispose();
  }

  void _schedule(Duration delay) {
    _typeTimer?.cancel();
    _typeTimer = Timer(delay, _onTick);
  }

  void _onTick() {
    if (!mounted) return;
    final phrase = widget.phrases[_phraseIndex];

    if (!_isDeleting) {
      if (_charCount < phrase.length) {
        setState(() => _charCount++);
        _schedule(Duration(milliseconds: _charCount == phrase.length ? 2000 : 72));
      } else {
        setState(() => _isDeleting = true);
        _schedule(const Duration(milliseconds: 44));
      }
    } else {
      if (_charCount > 0) {
        setState(() => _charCount--);
        _schedule(Duration(milliseconds: _charCount == 0 ? 260 : 44));
      } else {
        setState(() {
          _isDeleting = false;
          _phraseIndex = (_phraseIndex + 1) % widget.phrases.length;
        });
        _schedule(const Duration(milliseconds: 72));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final phrase = widget.phrases[_phraseIndex];
    final visible = phrase.substring(0, _charCount);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          visible,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: QInvWeb3Tokens.fontSerif,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w400,
            fontSize: 48,
            color: QInvWeb3Tokens.primaryLight,
            height: 1.18,
          ),
        ),
        // Blinking cursor
        AnimatedOpacity(
          opacity: _cursorVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 80),
          child: Container(
            width: 2.5,
            height: 40,
            margin: const EdgeInsets.only(left: 3, top: 4),
            decoration: BoxDecoration(
              color: QInvWeb3Tokens.primaryLight,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: QInvWeb3Tokens.primaryLight.withValues(alpha: 0.60),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Google auth button ───────────────────────────────────────────

class _GoogleButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _GoogleButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final borderRadius = BorderRadius.circular(QInvWeb3Tokens.radiusButton);

    return Semantics(
      button: true,
      label: 'Continue with Google',
      enabled: enabled,
      child: AnimatedOpacity(
        duration: QInvWeb3Tokens.transitionAll,
        opacity: enabled ? 1.0 : 0.55,
        child: ClipRRect(
          borderRadius: borderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: enabled
                    ? () {
                        HapticFeedback.mediumImpact();
                        onPressed!();
                      }
                    : null,
                borderRadius: borderRadius,
                splashColor: Colors.white.withValues(alpha: 0.06),
                highlightColor: Colors.transparent,
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: borderRadius,
                    color: Colors.white.withValues(alpha: 0.07),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'packages/onboarding_reference/assets/google_icon.svg',
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Continue with Google',
                        style: TextStyle(
                          fontFamily: QInvWeb3Tokens.fontUI,
                          fontSize: QInvWeb3Tokens.fontSizeLabel,
                          fontWeight: FontWeight.w600,
                          color: QInvWeb3Tokens.textHeading,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── "or" divider ─────────────────────────────────────────────────

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.10),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or',
            style: TextStyle(
              fontFamily: QInvWeb3Tokens.fontUI,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: QInvWeb3Tokens.textMuted,
              letterSpacing: 0.2,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.10),
          ),
        ),
      ],
    );
  }
}

// ── "Already have an account? Sign in" link ──────────────────────

class _LoginLink extends StatelessWidget {
  final VoidCallback? onLogin;

  const _LoginLink({this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Already have an account? Sign in',
      child: GestureDetector(
        onTap: onLogin != null
            ? () {
                HapticFeedback.lightImpact();
                onLogin!();
              }
            : null,
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text.rich(
            TextSpan(
              style: TextStyle(
                fontFamily: QInvWeb3Tokens.fontUI,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: QInvWeb3Tokens.textMuted,
                height: 1.5,
              ),
              children: [
                TextSpan(text: 'Already have an account? '),
                TextSpan(
                  text: 'Sign in',
                  style: TextStyle(
                    color: QInvWeb3Tokens.primaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
