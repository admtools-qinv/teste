import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../l10n/l10n.dart';
import '../data/voice_timestamps.dart';
import '../flow/onboarding_flow_controller.dart';
import '../models/country.dart';
import '../models/onboarding_step.dart';
import '../services/analytics/onboarding_analytics_service.dart';
import '../services/backend/onboarding_backend_service.dart';
import '../services/ip_geo_service.dart';
import '../services/suitability_scorer.dart';
import '../services/viacep_service.dart';
import '../services/voice_service.dart';
import '../theme/qinvweb3_tokens.dart';
import '../validation/onboarding_validator.dart';
import 'widgets/analysing_content.dart';
import 'widgets/glass_circle_button.dart';
import 'widgets/glass_widgets.dart';
import 'widgets/karaoke_text.dart';
import 'widgets/onboarding_option_card.dart';
import 'widgets/phone_frame.dart';
import 'widgets/phone_input_field.dart';
import 'widgets/phone_mask_formatter.dart';
import 'widgets/pin_input_widget.dart';
import 'widgets/press_logos_marquee.dart';
import 'widgets/qinv_button.dart';
import 'widgets/qinv_error_banner.dart';
import 'widgets/qinv_review_tile.dart';
import 'widgets/qinv_text_field.dart';
import 'widgets/showcase_reviews.dart';

class OnboardingScreen extends StatefulWidget {
  final List<OnboardingStep> steps;
  final VoiceService voiceService;
  final OnboardingBackendService backend;
  final OnboardingAnalyticsService analytics;
  final VoidCallback? onExit;
  final Future<void> Function(Map<String, dynamic> answers)? onCompletion;
  final bool showBackground;
  final ViaCepService? viaCepService;

  const OnboardingScreen({
    super.key,
    required this.steps,
    required this.voiceService,
    required this.backend,
    required this.analytics,
    this.onExit,
    this.onCompletion,
    this.showBackground = true,
    this.viaCepService,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final OnboardingFlowController controller;
  late final TextEditingController inputController;
  late final FocusNode inputFocusNode;
  final Map<String, String> _drafts = {};
  String? selectedOptionId;
  bool voiceReady = false;
  bool _voiceMuted = false;
  String? _syncedStepId;
  Country? _detectedCountry;
  bool _initialized = false;
  Map<String, List<WordTiming>> _timings = const {};
  ViaCepResult? _cepResult;
  bool _cepLoading = false;
  String? _cepError;
  Timer? _cepDebounce;

  @override
  void initState() {
    super.initState();
    inputController = TextEditingController();
    inputFocusNode = FocusNode();
    _detectedCountry = IpGeoService.detectCountry();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _timings = voiceTimestampsFor(Localizations.localeOf(context).languageCode);
    if (!_initialized) {
      _initialized = true;
      controller = OnboardingFlowController(
        steps: widget.steps,
        backend: widget.backend,
        analytics: widget.analytics,
        validator: DefaultOnboardingValidator(context.l10n),
        l10n: context.l10n,
      );
      unawaited(_bootstrap());
    }
  }

  Future<void> _bootstrap() async {
    await controller.initialize();
    if (!mounted) return;
    if (controller.serviceError != null) {
      setState(() {});
      return;
    }
    try {
      await widget.voiceService.initialize();
      if (!mounted) return;
      voiceReady = true;
      setState(() {});
      if (!_voiceMuted) {
        await widget.voiceService.speak(controller.current.voiceText, stepId: controller.current.id);
      }
    } catch (_) {
      if (!mounted) return;
      voiceReady = false;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _cepDebounce?.cancel();
    inputController.dispose();
    inputFocusNode.dispose();
    unawaited(widget.voiceService.dispose());
    controller.dispose();
    super.dispose();
  }

  void _onCepChanged(String value) {
    _drafts[controller.current.id] = value;
    _cepDebounce?.cancel();
    final digits = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length < 8) {
      if (_cepResult != null || _cepError != null) {
        setState(() {
          _cepResult = null;
          _cepError = null;
        });
      }
      return;
    }
    _cepDebounce = Timer(const Duration(milliseconds: 300), () {
      _lookupCep(value);
    });
  }

  Future<void> _lookupCep(String cep) async {
    final service = widget.viaCepService;
    if (service == null) return;
    setState(() {
      _cepLoading = true;
      _cepError = null;
    });
    final result = await service.lookup(cep);
    if (!mounted) return;
    setState(() {
      _cepLoading = false;
      _cepResult = result;
      _cepError = result == null ? context.l10n.stepCepAddressNotFound : null;
    });
  }

  void _syncStepState(OnboardingStep step) {
    if (_syncedStepId == step.id) return;
    _syncedStepId = step.id;

    // Reset CEP state when leaving/entering a different step.
    _cepResult = null;
    _cepLoading = false;
    _cepError = null;
    _cepDebounce?.cancel();

    if (step.type == OnboardingStepType.singleChoice) {
      final stored = controller.session.answers[step.id]?.toString();
      final validIds = step.options.map((o) => o.id).toSet();
      selectedOptionId =
          stored != null && validIds.contains(stored) ? stored : null;
      return;
    }

    selectedOptionId = null;

    if (step.type == OnboardingStepType.textInput ||
        step.type == OnboardingStepType.phoneInput ||
        step.type == OnboardingStepType.verificationCode) {
      final draft = _drafts[step.id];
      final value =
          draft ?? controller.session.answers[step.id]?.toString() ?? '';
      inputController.text = value;
      inputController.selection =
          TextSelection.collapsed(offset: value.length);
    }
  }

  Future<void> _goBack() async {
    final moved = await controller.previous();
    if (!mounted || !moved) return;
    setState(() {});
    final current = controller.current;
    if (current.type == OnboardingStepType.textInput ||
        current.type == OnboardingStepType.phoneInput ||
        current.type == OnboardingStepType.verificationCode) {
      Future.delayed(QInvWeb3Tokens.delayInputFocus, () {
        if (mounted) inputFocusNode.requestFocus();
      });
    }
    if (!_voiceMuted) await widget.voiceService.speak(current.voiceText, stepId: current.id);
  }

  Future<void> _toggleMute() async {
    setState(() => _voiceMuted = !_voiceMuted);
    if (_voiceMuted) {
      HapticFeedback.lightImpact();
      await widget.voiceService.stop();
    } else {
      HapticFeedback.lightImpact();
      await widget.voiceService.speak(
        controller.current.voiceText,
        stepId: controller.current.id,
      );
    }
  }

  Future<void> _submitCurrentStep() async {
    final step = controller.current;
    final Object inputValue;
    if (step.inputKind == OnboardingInputKind.cep && _cepResult != null) {
      inputValue = _cepResult!.toMap();
    } else if (step.type == OnboardingStepType.phoneInput ||
        step.type == OnboardingStepType.pinInput) {
      inputValue = (_drafts[step.id] ?? '').trim();
    } else {
      inputValue = inputController.text.trim();
    }
    final ok = await controller.advanceCurrentStep(
      inputValue: inputValue,
      selectedOptionId: selectedOptionId,
    );

    if (!mounted || !ok) {
      setState(() {});
      return;
    }

    if (controller.isCompleted) {
      setState(() {});
      if (widget.onCompletion != null) {
        await widget.onCompletion!(controller.session.answers);
      }
      return;
    }

    if (step.type == OnboardingStepType.textInput ||
        step.type == OnboardingStepType.phoneInput ||
        step.type == OnboardingStepType.verificationCode) {
      _drafts.remove(step.id);
      inputController.clear();
      inputFocusNode.unfocus();
    }
    if (step.type == OnboardingStepType.pinInput) {
      _drafts.remove(step.id);
    }

    selectedOptionId = null;
    setState(() {});

    final next = controller.current;
    if (next.type == OnboardingStepType.textInput ||
        next.type == OnboardingStepType.verificationCode) {
      Future.delayed(QInvWeb3Tokens.delayInputFocus, () {
        if (mounted) inputFocusNode.requestFocus();
      });
    } else {
      inputFocusNode.unfocus();
    }

    if (!_voiceMuted) {
      await widget.voiceService.speak(controller.current.voiceText, stepId: controller.current.id);
    }
  }

  // ── Zone A: Progress ────────────────────────────────────────

  Widget _buildProgress(BuildContext context, double progressValue) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Container(
              height: 2,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            AnimatedContainer(
              duration: QInvWeb3Tokens.transitionSlow,
              curve: Curves.easeOutCubic,
              height: 2,
              width: constraints.maxWidth * progressValue.clamp(0.0, 1.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [QInvWeb3Tokens.primary, QInvWeb3Tokens.primaryLight],
                ),
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: QInvWeb3Tokens.primary.withValues(alpha: 0.55),
                    blurRadius: QInvWeb3Tokens.blurGlow,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Step Transition ──────────────────────────────────────────

  Widget _stepTransitionBuilder(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,       // entering: aparece suavemente
        reverseCurve: Curves.easeIn, // exiting: evaporação rápida
      ),
      child: child,
    );
  }

  // ── Zone B: Title ───────────────────────────────────────────

  Widget _buildTitle(BuildContext context, OnboardingStep step) {
    final isWelcome = step.id == 'showcaseWelcome';
    return Semantics(
      header: true,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isWelcome)
              ShaderMask(
                blendMode: BlendMode.modulate,
                shaderCallback: (bounds) => const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Color(0x66FFFFFF),
                  ],
                  stops: [0.3, 1.0],
                ).createShader(bounds),
                child: Text(
                  step.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: QInvWeb3Tokens.fontSans,
                    fontSize: 40,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.10,
                    letterSpacing: -0.5,
                  ),
                ),
              )
            else
              ShaderMask(
                blendMode: BlendMode.modulate,
                shaderCallback: (bounds) => const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Color(0x66FFFFFF),
                  ],
                  stops: [0.3, 1.0],
                ).createShader(bounds),
                child: Text(
                  step.titleItalic != null
                      ? '${step.title} ${step.titleItalic}'
                      : step.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: QInvWeb3Tokens.fontSans,
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.10,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            if (step.caption.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                step.caption,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: QInvWeb3Tokens.fontSans,
                  fontSize: QInvWeb3Tokens.fontSizeSubtitle,
                  fontWeight: FontWeight.w400,
                  color: QInvWeb3Tokens.textMuted,
                  height: 1.55,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ],
        )
            .animate()
            .slideY(begin: 0.03, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
      ),
    );
  }

  // ── Zone C: Interactive content ─────────────────────────────

  Widget _buildOption(OnboardingStep step, OnboardingOption option, int index) {
    final selected = selectedOptionId == option.id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: OnboardingOptionCard(
        label: option.label,
        subtitle: option.subtitle,
        selected: selected,
        enabled: !controller.isBusy,
        assetPath: option.assetPath,
        onTap: controller.isBusy
            ? null
            : () {
                selectedOptionId =
                    selected && !step.required ? null : option.id;
                setState(() {});
              },
      ),
    )
        .animate(delay: Duration(milliseconds: 60 + 40 * index))
        .slideY(begin: 0.05, end: 0, duration: 320.ms, curve: Curves.easeOutCubic);
  }

  Widget? _buildInteractiveContent(OnboardingStep step) {
    switch (step.type) {
      case OnboardingStepType.showcase:
        return _buildShowcaseContent(step);

      case OnboardingStepType.intro:
        return null;

      case OnboardingStepType.singleChoice:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 0; i < step.options.length; i++)
              _buildOption(step, step.options[i], i),
          ],
        );

      case OnboardingStepType.pinInput:
        return Column(
          children: [
            PinInputWidget(
              key: ValueKey('pin_${step.id}'),
              enabled: !controller.isBusy,
              onChanged: (digits) => _drafts[step.id] = digits,
              onComplete: (_) => unawaited(_submitCurrentStep()),
            ),
            if (controller.validationError != null) ...[
              const SizedBox(height: 12),
              QInvErrorBanner(message: controller.validationError!),
            ],
          ],
        );

      case OnboardingStepType.phoneInput:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PhoneInputField(
              controller: inputController,
              initialCountry: _detectedCountry,
              enabled: !controller.isBusy,
              onChanged: (value) => _drafts[step.id] = value,
              onSubmitted: () => unawaited(_submitCurrentStep()),
            ),
            if (controller.validationError != null) ...[
              const SizedBox(height: 12),
              QInvErrorBanner(message: controller.validationError!),
            ],
          ],
        );

      case OnboardingStepType.textInput:
      case OnboardingStepType.verificationCode:
        final isCep = step.inputKind == OnboardingInputKind.cep;
        final inputType = step.type == OnboardingStepType.verificationCode ||
                isCep
            ? TextInputType.number
            : step.inputKind == OnboardingInputKind.email
                ? TextInputType.emailAddress
                : TextInputType.text;
        final action = step.type == OnboardingStepType.verificationCode
            ? TextInputAction.done
            : TextInputAction.next;
        final maxLength =
            step.type == OnboardingStepType.verificationCode ? 6 : null;
        final hasError = controller.validationError != null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            QInvTextField(
              controller: inputController,
              focusNode: inputFocusNode,
              hintText: step.placeholder,
              keyboardType: inputType,
              autofocus: false,
              enabled: !controller.isBusy,
              maxLength: maxLength,
              textInputAction: action,
              semanticsLabel: step.title,
              semanticsHint: step.placeholder,
              inputFormatters: isCep
                  ? const [PhoneMaskFormatter('#####-###')]
                  : null,
              onChanged: isCep
                  ? _onCepChanged
                  : (value) => _drafts[step.id] = value,
              onSubmitted: (_) => unawaited(_submitCurrentStep()),
              textStyle: step.type == OnboardingStepType.verificationCode
                  ? const TextStyle(
                      fontFamily: QInvWeb3Tokens.fontUI,
                      fontSize: QInvWeb3Tokens.fontSizeOtp,
                      fontWeight: FontWeight.w600,
                      color: QInvWeb3Tokens.textHeading,
                      letterSpacing: 8.0,
                      height: 1.20,
                    )
                  : null,
            ),
            if (isCep && _cepLoading)
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: QInvWeb3Tokens.primaryLight,
                  ),
                ),
              ),
            if (isCep && _cepResult != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  '${_cepResult!.logradouro.isNotEmpty ? '${_cepResult!.logradouro}, ' : ''}'
                  '${_cepResult!.bairro.isNotEmpty ? '${_cepResult!.bairro} — ' : ''}'
                  '${_cepResult!.localidade} - ${_cepResult!.uf}',
                  style: const TextStyle(
                    fontFamily: QInvWeb3Tokens.fontUI,
                    fontSize: 14,
                    color: QInvWeb3Tokens.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            if (isCep && _cepError != null && !_cepLoading)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  _cepError!,
                  style: const TextStyle(
                    fontFamily: QInvWeb3Tokens.fontUI,
                    fontSize: 13,
                    color: Color(0xFFF0A040),
                    height: 1.4,
                  ),
                ),
              ),
            if (hasError) ...[
              const SizedBox(height: 12),
              QInvErrorBanner(message: controller.validationError!),
            ],
          ],
        );

      case OnboardingStepType.review:
        final items = controller.reviewItems;
        final isInteractionBlocked =
            controller.isBusy || controller.isCompleted;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final item in items)
              QInvReviewTile(
                label: item.label,
                value: item.value,
                onEdit: isInteractionBlocked
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        final idx = widget.steps.indexWhere(
                            (s) => s.id == item.stepId);
                        if (idx < 0) return;
                        if (!controller.jumpToStepIndex(idx)) return;
                        _syncedStepId = null;
                        setState(() {});
                      },
              ),
            if (controller.validationError != null) ...[
              const SizedBox(height: 12),
              QInvErrorBanner(message: controller.validationError!),
            ],
          ],
        );

      case OnboardingStepType.analysing:
        return AnalysingContent(
          onComplete: () => unawaited(_submitCurrentStep()),
        );

      case OnboardingStepType.completion:
        final result = controller.suitabilityResult;
        final profile = result?.profile;
        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: _tintedCardDecoration(QInvWeb3Tokens.primary),
              child: Column(
                children: [
                  Text(
                    '${result?.score ?? 0} / 100',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: QInvWeb3Tokens.primaryLight,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.suitabilityScoreLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: QInvWeb3Tokens.textMuted,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: _tintedCardDecoration(QInvWeb3Tokens.primary),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.verified_rounded,
                      color: QInvWeb3Tokens.primaryLight, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _localizedProfileLabel(context, profile),
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: QInvWeb3Tokens.textHeading,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _localizedProfileDescription(context, profile),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: QInvWeb3Tokens.textSecondary,
                                height: 1.50,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (result != null && result.showVolatilityWarning) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: _tintedCardDecoration(QInvWeb3Tokens.destructive),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: QInvWeb3Tokens.destructive, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        context.l10n.volatilityWarning,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: QInvWeb3Tokens.destructive,
                              height: 1.50,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
    }
  }

  // ── Showcase helpers ────────────────────────────────────────

  Widget _buildShowcaseDots(int activeIndex, int total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = i == activeIndex;
        return AnimatedContainer(
          duration: QInvWeb3Tokens.transitionAll,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isActive
                ? QInvWeb3Tokens.primaryLight
                : Colors.white.withValues(alpha: 0.20),
          ),
        );
      }),
    );
  }

  bool _isShowcaseMockupStep(OnboardingStep step) =>
      step.id == 'showcaseAnalysis' || step.id == 'showcaseAI';

  String? _showcaseMockupAsset(OnboardingStep step) {
    switch (step.id) {
      case 'showcaseAnalysis':
        return 'assets/showcase/showcase_analysis.png';
      case 'showcaseAI':
        return 'assets/showcase/showcase_ai_chat.png';
      default:
        return null;
    }
  }

  Widget _buildShowcaseContent(OnboardingStep step) {
    switch (step.id) {
      case 'showcaseWelcome':
        return const SizedBox.shrink();
      case 'showcaseAnalysis':
      case 'showcaseAI':
        return const SizedBox.shrink(); // handled by _buildShowcaseMockupZone
      case 'showcaseReviews':
        return const ShowcaseReviews();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildShowcaseMockupZone(
    BuildContext context,
    OnboardingStep step,
    double hPad,
  ) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final phoneWidth = (screenWidth * QInvWeb3Tokens.phoneWidthRatio).clamp(220.0, 280.0);

    return Expanded(
      child: AnimatedSwitcher(
        duration: QInvWeb3Tokens.transitionMedium,
        reverseDuration: QInvWeb3Tokens.transitionFast,
        transitionBuilder: _stepTransitionBuilder,
        child: Align(
          key: ValueKey(step.id),
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: phoneWidth,
            child: PhoneFrame(
              assetPath: _showcaseMockupAsset(step)!,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShowcaseMockupTitle(OnboardingStep step) {
    final text = step.titleItalic != null
        ? '${step.title} ${step.titleItalic}'
        : step.title;
    return ShaderMask(
      blendMode: BlendMode.modulate,
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white,
          Color(0x66FFFFFF),
        ],
        stops: [0.3, 1.0],
      ).createShader(bounds),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: QInvWeb3Tokens.fontSans,
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          height: 1.20,
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  Widget _buildShowcaseReviewsZone(OnboardingStep step) {
    return Expanded(
      child: Column(
        children: [
          const Spacer(),
          const ShowcaseReviews(),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ShaderMask(
              blendMode: BlendMode.modulate,
              shaderCallback: (bounds) => const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Color(0x66FFFFFF),
                ],
                stops: [0.3, 1.0],
              ).createShader(bounds),
              child: Text(
                step.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: QInvWeb3Tokens.fontSans,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  height: 1.20,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _tintedCardDecoration(Color tint) => BoxDecoration(
        color: tint.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(QInvWeb3Tokens.radiusCard),
        border: Border.all(color: tint.withValues(alpha: 0.30)),
      );

  // ── Zone D: CTA button ──────────────────────────────────────

  Widget _buildCTA(OnboardingStep step) {
    final isBlocked = controller.isBusy || controller.isCompleted;

    final String label;
    final bool enabled;

    switch (step.type) {
      case OnboardingStepType.showcase:
        label = step.primaryCtaLabel ?? context.l10n.ctaContinue;
        enabled = !isBlocked;
      case OnboardingStepType.intro:
        label = controller.isBusy
            ? context.l10n.ctaLoading
            : (step.primaryCtaLabel ?? context.l10n.ctaContinue);
        enabled = !isBlocked;
      case OnboardingStepType.singleChoice:
        label = controller.isBusy
            ? context.l10n.ctaSaving
            : (step.primaryCtaLabel ?? context.l10n.ctaContinue);
        enabled =
            !isBlocked && !(step.required && selectedOptionId == null);
      case OnboardingStepType.textInput:
      case OnboardingStepType.phoneInput:
      case OnboardingStepType.verificationCode:
        label = controller.isBusy
            ? context.l10n.ctaSaving
            : (step.primaryCtaLabel ?? context.l10n.ctaContinue);
        enabled = !isBlocked;
      case OnboardingStepType.pinInput:
        label = controller.isBusy
            ? context.l10n.ctaSaving
            : (step.primaryCtaLabel ?? context.l10n.ctaContinue);
        enabled = !isBlocked && (_drafts[step.id]?.length ?? 0) == 6;
      case OnboardingStepType.review:
        label = controller.isBusy
            ? context.l10n.ctaSubmitting
            : (controller.isCompleted
                ? context.l10n.ctaCompleted
                : (step.primaryCtaLabel ?? context.l10n.ctaConfirm));
        enabled = !isBlocked;
      case OnboardingStepType.analysing:
        return const SizedBox.shrink();
      case OnboardingStepType.completion:
        label = controller.isCompleted
            ? context.l10n.ctaCompleted
            : (controller.isBusy
                ? context.l10n.ctaFinishing
                : (step.primaryCtaLabel ?? context.l10n.ctaFinish));
        enabled = !isBlocked && !controller.isCompleted;
    }

    return QInvButton(
      label: label,
      busy: controller.isBusy,
      selected: controller.isCompleted &&
          step.type == OnboardingStepType.completion,
      onPressed: enabled ? _submitCurrentStep : null,
    );
  }

  // ── Zone E: Footer (narration + back) ───────────────────────

  Widget _buildFooter(BuildContext context, OnboardingStep step) {
    final narrationText =
        voiceReady ? step.voiceText : context.l10n.narrationUnavailable;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.07),
            width: 1.0,
          ),
        ),
      ),
      child: voiceReady && _timings.containsKey(step.id)
          ? KaraokeText(
              timings: _timings[step.id]!,
              positionMsStream: _voiceMuted
                  ? const Stream<int>.empty()
                  : widget.voiceService.positionMsStream,
            )
          : Text(
              narrationText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: QInvWeb3Tokens.fontUI,
                fontSize: 12,
                color: QInvWeb3Tokens.textMuted,
                height: 1.50,
              ),
            ),
    );
  }


  String _localizedProfileLabel(BuildContext context, SuitabilityProfile? profile) {
    final l10n = context.l10n;
    if (profile == null) return l10n.investorProfileFallback;
    return switch (profile) {
      SuitabilityProfile.conservative => l10n.profileConservative,
      SuitabilityProfile.moderate => l10n.profileModerate,
      SuitabilityProfile.aggressive => l10n.profileAggressive,
    };
  }

  String _localizedProfileDescription(BuildContext context, SuitabilityProfile? profile) {
    final l10n = context.l10n;
    if (profile == null) return l10n.investorProfileIncomplete;
    return switch (profile) {
      SuitabilityProfile.conservative => l10n.profileConservativeDesc,
      SuitabilityProfile.moderate => l10n.profileModerateDesc,
      SuitabilityProfile.aggressive => l10n.profileAggressiveDesc,
    };
  }

  // ── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final step = controller.current;
        _syncStepState(step);

        final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
        final size = MediaQuery.sizeOf(context);
        final hPad = QInvWeb3Tokens.responsiveHPad(size.width);
        final showcaseCount = controller.showcaseCount;
        final nonShowcaseTotal = widget.steps.length - showcaseCount;
        final nonShowcaseIndex = controller.index - showcaseCount;
        final progressValue = nonShowcaseTotal <= 0
            ? 0.0
            : (nonShowcaseIndex + 1).clamp(0, nonShowcaseTotal) / nonShowcaseTotal;

        final interactiveContent = _buildInteractiveContent(step);

        final screenContent = SafeArea(
              child: AnimatedPadding(
                duration: QInvWeb3Tokens.transitionAll,
                padding: EdgeInsets.fromLTRB(
                  step.id == 'showcaseReviews' ? 0 : hPad,
                  16,
                  step.id == 'showcaseReviews' ? 0 : hPad,
                  16 + bottomInset,
                ),
                child: AbsorbPointer(
                  absorbing: controller.isBusy,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Zone A — Back arrow + Progress (dots for showcase, bar for rest)
                      if (controller.isShowcase)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: step.id == 'showcaseReviews' ? hPad : 0,
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 56), // balance for sound button
                              Expanded(
                                child: _buildShowcaseDots(controller.showcaseIndex, controller.showcaseCount),
                              ),
                              if (voiceReady)
                                GlassCircleButton(
                                  icon: _voiceMuted
                                      ? Icons.volume_off_rounded
                                      : Icons.volume_up_rounded,
                                  tooltip: _voiceMuted ? context.l10n.tooltipUnmute : context.l10n.tooltipMute,
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    unawaited(_toggleMute());
                                  },
                                )
                              else
                                const SizedBox(width: 56),
                            ],
                          ),
                        )
                      else
                        Row(
                          children: [
                            if (controller.hasPrevious && !controller.isShowcase)
                              Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: GlassCircleButton(
                                  icon: Icons.arrow_back_rounded,
                                  tooltip: context.l10n.tooltipBack,
                                  onPressed: (controller.isBusy || controller.isCompleted || step.type == OnboardingStepType.analysing)
                                      ? null
                                      : () {
                                          HapticFeedback.lightImpact();
                                          _goBack();
                                        },
                                ),
                              )
                            else if (widget.onExit != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: GlassCircleButton(
                                  icon: Icons.close_rounded,
                                  tooltip: context.l10n.tooltipClose,
                                  onPressed: controller.isBusy
                                      ? null
                                      : () {
                                          HapticFeedback.lightImpact();
                                          widget.onExit!();
                                        },
                                ),
                              ),
                            Expanded(child: _buildProgress(context, progressValue)),
                            if (voiceReady)
                              Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: GlassCircleButton(
                                  icon: _voiceMuted
                                      ? Icons.volume_off_rounded
                                      : Icons.volume_up_rounded,
                                  tooltip: _voiceMuted ? context.l10n.tooltipUnmute : context.l10n.tooltipMute,
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    unawaited(_toggleMute());
                                  },
                                ),
                              ),
                          ],
                        ),
                      const SizedBox(height: 32),

                      // Zone B + C — Content area
                      if (_isShowcaseMockupStep(step)) ...[
                        _buildShowcaseMockupZone(context, step, hPad),
                        const SizedBox(height: 24),
                        _buildShowcaseMockupTitle(step),
                      ] else if (step.id == 'showcaseReviews') ...[
                        _buildShowcaseReviewsZone(step),
                      ] else
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            reverseDuration: const Duration(milliseconds: 200),
                            transitionBuilder: _stepTransitionBuilder,
                            child: SingleChildScrollView(
                              key: ValueKey(step.id),
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (step.id != 'showcaseReviews')
                                    _buildTitle(context, step),

                                  if (controller.serviceError != null) ...[
                                    const SizedBox(height: 16),
                                    QInvErrorBanner(
                                        message: controller.serviceError!),
                                  ],

                                  if (interactiveContent != null) ...[
                                    const SizedBox(height: 24),
                                    if (step.type == OnboardingStepType.pinInput)
                                      interactiveContent
                                          .animate(delay: 60.ms)
                                          .slideY(begin: 0.04, end: 0, duration: 360.ms, curve: Curves.easeOutCubic)
                                    else if (step.type == OnboardingStepType.showcase ||
                                             step.type == OnboardingStepType.singleChoice ||
                                             step.type == OnboardingStepType.analysing)
                                      interactiveContent
                                    else
                                      GlassCard(
                                        fillColor:
                                            Colors.white.withValues(alpha: 0.06),
                                        borderColor:
                                            Colors.white.withValues(alpha: 0.10),
                                        blurSigma: QInvWeb3Tokens.blurGlass,
                                        padding: const EdgeInsets.all(20),
                                        child: interactiveContent,
                                      )
                                          .animate(delay: 60.ms)
                                          .slideY(begin: 0.04, end: 0, duration: 360.ms, curve: Curves.easeOutCubic),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),

                      SizedBox(height: bottomInset > 0 ? 12 : 24),

                      // Press logos — just above CTA on welcome step
                      if (step.id == 'showcaseWelcome') ...[
                        const PressLogosMarquee(),
                        const SizedBox(height: 36),
                      ],

                      // Zone D — CTA button
                      _buildCTA(step),

                      // Zone E — Footer (animated show/hide with keyboard)
                      ClipRect(
                        child: AnimatedSize(
                          duration: QInvWeb3Tokens.transitionAll,
                          curve: Curves.easeOutCubic,
                          child: bottomInset == 0
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(height: 16),
                                    _buildFooter(context, step),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );

        return Scaffold(
          backgroundColor: widget.showBackground
              ? QInvWeb3Tokens.background
              : Colors.transparent,
          resizeToAvoidBottomInset: false,
          body: widget.showBackground
              ? GlassBackground(
                  showOrbs: !controller.isShowcase,
                  showGrid: controller.isShowcase,
                  child: screenContent,
                )
              : screenContent,
        );
      },
    );
  }
}

