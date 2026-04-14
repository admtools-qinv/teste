import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:onboarding_reference/onboarding_reference.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final store = LocalCredentialStore(prefs: prefs);
  runApp(ExampleApp(store: store));
}

class ExampleApp extends StatelessWidget {
  final LocalCredentialStore store;

  const ExampleApp({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: QInvWeb3Theme.dark(),
      home: _AppEntry(store: store),
    );
  }
}

// ── Entry point ───────────────────────────────────────────────────

class _AppEntry extends StatelessWidget {
  final LocalCredentialStore store;
  final _auth = _ExampleAuthService();

  _AppEntry({required this.store});

  @override
  Widget build(BuildContext context) {
    if (store.savedEmail != null) {
      final name = store.displayName ?? store.savedEmail!.split('@').first;
      final isGoogle = store.isGoogleUser;
      return ReturnLoginScreen(
        displayName: name,
        email: store.savedEmail!,
        biometricService:
            store.isBiometricEnabled ? LocalAuthBiometricService() : null,
        // Google users don't have a PIN — only biometric or re-auth via Google.
        onPinSubmit: isGoogle
            ? null
            : (pin) async {
                await Future<void>.delayed(const Duration(milliseconds: 600));
                return pin.length == 6;
              },
        onSuccess: () => _goHome(context),
        onForgotPassword: isGoogle ? null : () => _goToPassword(context, store.savedEmail!),
        onSwitchAccount: () async {
          await store.clearAll();
          if (!context.mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(builder: (_) => _AppEntry(store: store)),
          );
        },
      );
    }

    return _LandingWithTransition(
      onGoogleAuth: () => _pushGoogleOnboarding(context),
      onLogin: () => _showSignIn(context),
      onSignUpCompletion: (answers) async {
        final email = answers['email']?.toString() ?? '';
        final name = answers['fullName']?.toString() ?? email.split('@').first;
        await store.saveEmail(email);
        await store.saveDisplayName(name);
        await store.saveToken('signup-token-example');
        await store.saveAuthMethod('emailPassword');
        if (!context.mounted) return;
        await _handlePostLogin(context);
      },
    );
  }

  Future<void> _pushGoogleOnboarding(BuildContext context) async {
    // Step 1: Google Sign-In
    final googleSignIn = GoogleSignIn(
      scopes: ['email'],
      serverClientId:
          '234657807436-lspj40mggavc13ab00utrnm2jgefpp1p.apps.googleusercontent.com',
    );
    final GoogleSignInAccount? account;
    try {
      account = await googleSignIn.signIn();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao conectar com Google: $e')),
      );
      return;
    }

    if (account == null) return; // user cancelled

    final googleEmail = account.email;
    final googleName = account.displayName ?? '';

    if (!context.mounted) return;

    // Step 2: Onboarding with remaining steps (profile questions, phone, etc.)
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) => OnboardingScreen(
          steps: onboardingStepsFor(AuthMethod.google),
          voiceService: AssetVoiceService(),
          backend: _ExampleBackend(),
          analytics: _ExampleAnalytics(),
          onExit: () {
            googleSignIn.signOut(); // cleanup on cancel
            Navigator.of(ctx).pop();
          },
          onCompletion: (answers) async {
            final name = answers['fullName']?.toString() ?? googleName;
            await store.saveEmail(googleEmail);
            await store.saveDisplayName(name.isNotEmpty ? name : 'Usuário');
            await store.saveToken('google-token-example');
            await store.saveAuthMethod('google');
            if (!ctx.mounted) return;
            Navigator.of(ctx).pop();
            await _handlePostLogin(ctx);
          },
        ),
      ),
    );
  }

  Future<void> _showSignIn(BuildContext context) async {
    await showSignInSheet(
      context: context,
      authService: _auth,
      onLoginSuccess: (result, email) async {
        await store.saveEmail(email);
        await store.saveToken(result.token);
        await store.saveDisplayName('Fabricio');
        if (!context.mounted) return;
        await _handlePostLogin(context);
      },
    );
  }

  Future<void> _handlePostLogin(BuildContext context) async {
    if (!store.hasBiometricBeenAsked) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => BiometricPromptScreen(
            onEnabled: () async {
              await store.setBiometricEnabled(enabled: true);
              if (!context.mounted) return;
              _goHome(context);
            },
            onSkipped: () async {
              await store.setBiometricEnabled(enabled: false);
              if (!context.mounted) return;
              _goHome(context);
            },
          ),
        ),
      );
    } else {
      _goHome(context);
    }
  }

  void _goToPassword(BuildContext context, String email) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EmailPasswordScreen(
          authService: _auth,
          initialEmail: email,
          onLoginSuccess: (result, _) async {
            await store.saveToken(result.token);
            if (!context.mounted) return;
            await _handlePostLogin(context);
          },
        ),
      ),
    );
  }

  void _goHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (routeContext) => _FakeHomeScreen(
          displayName: store.displayName ?? 'Usuário',
          onLogout: () async {
            await store.clearAll();
            if (!routeContext.mounted) return;
            Navigator.of(routeContext).pushAndRemoveUntil(
              MaterialPageRoute<void>(
                builder: (_) => _AppEntry(store: store),
              ),
              (_) => false,
            );
          },
        ),
      ),
      (_) => false,
    );
  }
}

// ── Landing com transição estilo Alinea ──────────────────────────
//
// Coreografia dramática em 4 fases:
// Fase 1 (0–500ms):   Conteúdo LoginScreen dissolve + encolhe (pull-in)
// Fase 2 (200–800ms): Orbs pulsam/brilham — glow overlay intensifica
// Fase 3 (500–1100ms): Conteúdo OnboardingScreen materializa com slide-up
// Fase 4 (700–1100ms): Glow dissipa, tela nova domina

class _LandingWithTransition extends StatefulWidget {
  final VoidCallback onGoogleAuth;
  final VoidCallback onLogin;
  final Future<void> Function(Map<String, dynamic> answers)? onSignUpCompletion;

  const _LandingWithTransition({
    required this.onGoogleAuth,
    required this.onLogin,
    this.onSignUpCompletion,
  });

  @override
  State<_LandingWithTransition> createState() => _LandingWithTransitionState();
}

class _LandingWithTransitionState extends State<_LandingWithTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _exitCtrl;

  @override
  void initState() {
    super.initState();
    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _exitCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    HapticFeedback.mediumImpact();
    unawaited(_exitCtrl.forward());
    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    _pushOnboarding();
  }

  void _pushOnboarding() {
    Navigator.of(context)
        .push(
          PageRouteBuilder<void>(
            transitionDuration: const Duration(milliseconds: 1400),
            reverseTransitionDuration: const Duration(milliseconds: 500),
            opaque: false,
            pageBuilder: (ctx, _, __) => OnboardingScreen(
              steps: defaultOnboardingSteps,
              voiceService: AssetVoiceService(),
              backend: _ExampleBackend(),
              analytics: _ExampleAnalytics(),
              onExit: () => Navigator.of(ctx).pop(),
              onCompletion: widget.onSignUpCompletion != null
                  ? (answers) async {
                      Navigator.of(ctx).pop();
                      await widget.onSignUpCompletion!(answers);
                    }
                  : null,
              showBackground: false,
            ),
            transitionsBuilder: (ctx, animation, _, child) {
              // Fase 3: conteúdo novo entra com fade + slide visível
              final contentIn = CurvedAnimation(
                parent: animation,
                curve: const Interval(0.40, 0.82, curve: Curves.easeOut),
                reverseCurve: const Interval(0.0, 0.4, curve: Curves.easeIn),
              );
              final slideUp = Tween<Offset>(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: const Interval(0.38, 0.88, curve: Curves.easeOutCubic),
              ));

              return Stack(
                children: [
                  // Fase 2+4: glow overlay — orbs "pulsam"
                  IgnorePointer(
                    child: AnimatedBuilder(
                      animation: animation,
                      builder: (_, __) => CustomPaint(
                        painter: _GlowPulsePainter(t: animation.value),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),

                  // Fase 3: conteúdo novo materializa
                  SlideTransition(
                    position: slideUp,
                    child: FadeTransition(opacity: contentIn, child: child),
                  ),
                ],
              );
            },
          ),
        )
        .then((_) {
          if (mounted) _exitCtrl.reverse();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Camada 1: GlassBackground persistente
        const GlassBackground(child: SizedBox.expand()),

        // Camada 2: Conteúdo LoginScreen — dissolve + encolhe (pull-in)
        AnimatedBuilder(
          animation: _exitCtrl,
          builder: (_, child) {
            final t = CurvedAnimation(
              parent: _exitCtrl,
              curve: Curves.easeIn,
            ).value;
            return Opacity(
              opacity: 1.0 - t,
              child: Transform.scale(
                scale: 1.0 - (t * 0.08), // encolhe até 92%
                child: child,
              ),
            );
          },
          child: LoginScreen(
            showBackground: false,
            onGoogleAuth: widget.onGoogleAuth,
            onSignUp: _handleSignUp,
            onLogin: widget.onLogin,
          ),
        ),
      ],
    );
  }
}

// ── Glow pulse painter ───────────────────────────────────────────
//
// Simula os orbs do GlassBackground "pulsando" durante a transição.
// Um brilho suave roxo/azul irradia do centro-superior da tela,
// intensifica no meio da transição e dissipa no final.
// Sem bordas duras — tudo é gradiente radial com transparência.

class _GlowPulsePainter extends CustomPainter {
  final double t;

  const _GlowPulsePainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0.05 || t >= 0.92) return;

    // Curva de intensidade: sobe suave, pico em ~40%, desce gradual
    final double intensity;
    if (t < 0.40) {
      intensity = Curves.easeOut.transform((t / 0.40).clamp(0.0, 1.0));
    } else if (t < 0.80) {
      intensity = Curves.easeIn.transform(
        1.0 - ((t - 0.40) / 0.40).clamp(0.0, 1.0),
      );
    } else {
      intensity = 0.0;
    }

    if (intensity <= 0.02) return;

    final center = Offset(size.width * 0.4, size.height * 0.3);
    final maxRadius = size.height * 0.7;
    final radius = maxRadius * (0.5 + 0.5 * Curves.easeOutCubic.transform(
      t.clamp(0.0, 0.6) / 0.6,
    ));

    // Glow principal — roxo suave
    final shader = RadialGradient(
      colors: [
        Color.fromRGBO(159, 122, 234, intensity * 0.35), // roxo orb
        Color.fromRGBO(124, 58, 237, intensity * 0.20),  // violeta
        Color.fromRGBO(96, 165, 250, intensity * 0.10),  // azul sutil
        Colors.transparent,
      ],
      stops: const [0.0, 0.35, 0.65, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, Paint()..shader = shader);

    // Glow secundário — canto inferior oposto, mais sutil
    final center2 = Offset(size.width * 0.7, size.height * 0.75);
    final radius2 = maxRadius * 0.5;
    final shader2 = RadialGradient(
      colors: [
        Color.fromRGBO(244, 114, 182, intensity * 0.18), // rosa orb
        Color.fromRGBO(124, 58, 237, intensity * 0.08),
        Colors.transparent,
      ],
      stops: const [0.0, 0.45, 1.0],
    ).createShader(Rect.fromCircle(center: center2, radius: radius2));

    canvas.drawCircle(center2, radius2, Paint()..shader = shader2);
  }

  @override
  bool shouldRepaint(_GlowPulsePainter old) => old.t != t;
}

// ── Fake home screen ─────────────────────────────────────────────

class _FakeHomeScreen extends StatelessWidget {
  final String displayName;
  final VoidCallback onLogout;

  const _FakeHomeScreen({
    required this.displayName,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QInvWeb3Tokens.background,
      body: GlassBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Olá, $displayName',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: QInvWeb3Tokens.fontSerif,
                    fontStyle: FontStyle.italic,
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                    color: QInvWeb3Tokens.textHeading,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Você está logado.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: QInvWeb3Tokens.fontUI,
                    fontSize: QInvWeb3Tokens.fontSizeSubtitle,
                    color: QInvWeb3Tokens.textMuted,
                  ),
                ),
                const SizedBox(height: 40),
                QInvButton(
                  label: 'Sair',
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    onLogout();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Stubs ─────────────────────────────────────────────────────────

class _ExampleAuthService implements AuthService {
  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (password == 'wrong') {
      throw const AuthException('E-mail ou senha incorretos.');
    }
    return const AuthResult(token: 'noop-token-example');
  }

  @override
  Future<void> logout({required String token}) async {}
}

class _ExampleBackend implements OnboardingBackendService {
  @override
  Future<OnboardingSessionDto> startSession() async =>
      const OnboardingSessionDto(sessionId: 'example-session');

  @override
  Future<void> saveAnswer({
    required String sessionId,
    required String stepId,
    required dynamic value,
  }) async {}

  @override
  Future<SubmitResultDto> submitAll({
    required String sessionId,
    required Map<String, dynamic> answers,
  }) async =>
      const SubmitResultDto(success: true);

  @override
  Future<void> clearAnswer({
    required String sessionId,
    required String stepId,
  }) async {}
}

class _ExampleAnalytics implements OnboardingAnalyticsService {
  @override
  Future<void> trackEvent(String name,
      {Map<String, dynamic>? properties}) async {}
}
