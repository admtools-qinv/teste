import 'dart:async';
import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../data/voice_timestamps.dart';
import '../flow/onboarding_flow_controller.dart';
import '../models/country.dart';
import '../models/onboarding_step.dart';
import '../services/analytics/onboarding_analytics_service.dart';
import '../services/backend/onboarding_backend_service.dart';
import '../services/ip_geo_service.dart';
import '../services/voice_service.dart';
import '../theme/qinvweb3_tokens.dart';
import 'widgets/glass_widgets.dart';
import 'widgets/phone_input_field.dart';
import 'widgets/pin_input_widget.dart';
import 'widgets/qinv_button.dart';
import 'widgets/qinv_error_banner.dart';
import 'widgets/qinv_review_tile.dart';
import 'widgets/qinv_text_field.dart';

class OnboardingScreen extends StatefulWidget {
  final List<OnboardingStep> steps;
  final VoiceService voiceService;
  final OnboardingBackendService backend;
  final OnboardingAnalyticsService analytics;
  final VoidCallback? onExit;
  final Future<void> Function(Map<String, dynamic> answers)? onCompletion;
  final bool showBackground;

  const OnboardingScreen({
    super.key,
    required this.steps,
    required this.voiceService,
    required this.backend,
    required this.analytics,
    this.onExit,
    this.onCompletion,
    this.showBackground = true,
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

  @override
  void initState() {
    super.initState();
    controller = OnboardingFlowController(
      steps: widget.steps,
      backend: widget.backend,
      analytics: widget.analytics,
    );
    inputController = TextEditingController();
    inputFocusNode = FocusNode();
    _detectedCountry = IpGeoService.detectCountry();
    unawaited(_bootstrap());
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
    inputController.dispose();
    inputFocusNode.dispose();
    unawaited(widget.voiceService.dispose());
    controller.dispose();
    super.dispose();
  }

  void _syncStepState(OnboardingStep step) {
    if (_syncedStepId == step.id) return;
    _syncedStepId = step.id;

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
      Future.delayed(const Duration(milliseconds: 500), () {
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
    final inputValue = (step.type == OnboardingStepType.phoneInput ||
            step.type == OnboardingStepType.pinInput)
        ? (_drafts[step.id] ?? '').trim()
        : inputController.text.trim();
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
      Future.delayed(const Duration(milliseconds: 500), () {
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
              duration: const Duration(milliseconds: 500),
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
                    blurRadius: 8,
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
    return Semantics(
      header: true,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              step.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: step.titleItalic == null
                    ? QInvWeb3Tokens.fontSerif
                    : QInvWeb3Tokens.fontSans,
                fontSize: 32,
                fontWeight: FontWeight.w500,
                color: QInvWeb3Tokens.textHeading,
                height: 1.10,
                letterSpacing: -0.3,
              ),
            ),
            if (step.titleItalic != null) ...[
              const SizedBox(height: 2),
              Text(
                step.titleItalic!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: QInvWeb3Tokens.fontSerif,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                  fontSize: QInvWeb3Tokens.fontSizeTitleAccent,
                  color: QInvWeb3Tokens.primaryLight,
                  height: 1.20,
                  letterSpacing: 0.0,
                ),
              ),
            ],
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
      child: _OptionCard(
        label: option.label,
        selected: selected,
        enabled: !controller.isBusy,
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
        final inputType = step.type == OnboardingStepType.verificationCode
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
              onChanged: (value) => _drafts[step.id] = value,
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
        return _AnalysingContent(
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
                    'Your suitability score',
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
                          profile?.label ?? 'Investor Profile',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: QInvWeb3Tokens.textHeading,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          profile?.description ?? 'Complete the questionnaire to see your profile.',
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
                        'Crypto can be volatile. Based on your answers, we recommend starting small.',
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
          duration: const Duration(milliseconds: 300),
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
        return const _ShowcaseWelcome();
      case 'showcaseAnalysis':
      case 'showcaseAI':
        return const SizedBox.shrink(); // handled by _buildShowcaseMockupZone
      case 'showcaseReviews':
        return const _ShowcaseReviews();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildShowcaseMockupZone(
    BuildContext context,
    OnboardingStep step,
    double hPad,
  ) {
    return Expanded(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        reverseDuration: const Duration(milliseconds: 200),
        transitionBuilder: _stepTransitionBuilder,
        child: Stack(
          key: ValueKey(step.id),
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            // Phone mockup — extends edge-to-edge, fades at bottom
            Positioned(
              top: 110,
              left: -hPad,
              right: -hPad,
              bottom: 0,
              child: _ShowcaseMockup(
                assetPath: _showcaseMockupAsset(step)!,
              ),
            ),
            // Title floats above the image
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildTitle(context, step),
            ),
          ],
        ),
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
        label = step.primaryCtaLabel ?? 'Continue';
        enabled = !isBlocked;
      case OnboardingStepType.intro:
        label = controller.isBusy
            ? 'Loading…'
            : (step.primaryCtaLabel ?? 'Continue');
        enabled = !isBlocked;
      case OnboardingStepType.singleChoice:
        label = controller.isBusy
            ? 'Saving…'
            : (step.primaryCtaLabel ?? 'Continue');
        enabled =
            !isBlocked && !(step.required && selectedOptionId == null);
      case OnboardingStepType.textInput:
      case OnboardingStepType.phoneInput:
      case OnboardingStepType.verificationCode:
        label = controller.isBusy
            ? 'Saving…'
            : (step.primaryCtaLabel ?? 'Continue');
        enabled = !isBlocked;
      case OnboardingStepType.pinInput:
        label = controller.isBusy
            ? 'Saving…'
            : (step.primaryCtaLabel ?? 'Continue');
        enabled = !isBlocked && (_drafts[step.id]?.length ?? 0) == 6;
      case OnboardingStepType.review:
        label = controller.isBusy
            ? 'Submitting…'
            : (controller.isCompleted
                ? 'Completed'
                : (step.primaryCtaLabel ?? 'Confirm'));
        enabled = !isBlocked;
      case OnboardingStepType.analysing:
        return const SizedBox.shrink();
      case OnboardingStepType.completion:
        label = controller.isCompleted
            ? 'Completed'
            : (controller.isBusy
                ? 'Finishing…'
                : (step.primaryCtaLabel ?? 'Finish'));
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
        voiceReady ? step.voiceText : 'Narration unavailable.';

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: voiceReady && !_voiceMuted && voiceTimestamps.containsKey(step.id)
                    ? _KaraokeText(
                        timings: voiceTimestamps[step.id]!,
                        positionMsStream: widget.voiceService.positionMsStream,
                      )
                    : Text(
                        narrationText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: QInvWeb3Tokens.fontUI,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: QInvWeb3Tokens.textMuted,
                          height: 1.50,
                        ),
                      ),
              ),
              if (voiceReady) ...[
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(
                    _voiceMuted
                        ? Icons.volume_off_rounded
                        : Icons.volume_up_rounded,
                    size: 14,
                    semanticLabel: _voiceMuted ? 'Ativar narração' : 'Desativar narração',
                  ),
                  color: _voiceMuted
                      ? QInvWeb3Tokens.textMuted
                      : QInvWeb3Tokens.primaryLight,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    unawaited(_toggleMute());
                  },
                  tooltip: _voiceMuted ? 'Ativar som' : 'Desativar som',
                ),
              ],
            ],
          ),
        ],
      ),
    );
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
        final hPad = size.width < 360 ? 20.0 : 24.0;
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
                  hPad, 16, hPad, 16 + bottomInset,
                ),
                child: AbsorbPointer(
                  absorbing: controller.isBusy,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Zone A — Back arrow + Progress (dots for showcase, bar for rest)
                      if (controller.isShowcase)
                        _buildShowcaseDots(controller.showcaseIndex, controller.showcaseCount)
                      else
                        Row(
                          children: [
                            if (controller.hasPrevious && !controller.isShowcase)
                              Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back_rounded),
                                  color: QInvWeb3Tokens.textMuted,
                                  iconSize: 20,
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                  tooltip: 'Back',
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
                                child: IconButton(
                                  icon: const Icon(Icons.close_rounded),
                                  color: QInvWeb3Tokens.textMuted,
                                  iconSize: 20,
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                  tooltip: 'Close',
                                  onPressed: controller.isBusy
                                      ? null
                                      : () {
                                          HapticFeedback.lightImpact();
                                          widget.onExit!();
                                        },
                                ),
                              ),
                            Expanded(child: _buildProgress(context, progressValue)),
                          ],
                        ),
                      const SizedBox(height: 32),

                      // Zone B + C — Content area
                      if (_isShowcaseMockupStep(step))
                        _buildShowcaseMockupZone(context, step, hPad)
                      else
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
                                        blurSigma: 20,
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
              ? GlassBackground(child: screenContent)
              : screenContent,
        );
      },
    );
  }
}

// ── Option Card ─────────────────────────────────────────────────

class _OptionCard extends StatelessWidget {
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  const _OptionCard({
    required this.label,
    required this.selected,
    required this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      constraints: const BoxConstraints(minHeight: 58),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(QInvWeb3Tokens.radiusOption),
        color: selected
            ? QInvWeb3Tokens.primary.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.04),
        border: Border.all(
          color: selected
              ? QInvWeb3Tokens.primaryLight.withValues(alpha: 0.70)
              : Colors.white.withValues(alpha: 0.09),
          width: selected ? 1.5 : 1.0,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: QInvWeb3Tokens.primary.withValues(alpha: 0.28),
                  blurRadius: 20,
                  spreadRadius: -2,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled && onTap != null
              ? () {
                  HapticFeedback.lightImpact();
                  onTap!();
                }
              : null,
          borderRadius: BorderRadius.circular(QInvWeb3Tokens.radiusOption),
          splashColor: QInvWeb3Tokens.primary.withValues(alpha: 0.08),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: QInvWeb3Tokens.fontUI,
                      fontSize: 15.0,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w500,
                      color: selected
                          ? Colors.white
                          : QInvWeb3Tokens.textSecondary,
                      height: 1.35,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: Tween<double>(begin: 0.6, end: 1.0).animate(
                      CurvedAnimation(
                          parent: animation, curve: Curves.easeOutBack),
                    ),
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check_rounded,
                          key: ValueKey('check'),
                          color: QInvWeb3Tokens.primaryLight,
                          size: 16,
                        )
                      : Container(
                          key: const ValueKey('empty'),
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.20),
                              width: 1.5,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Analysing Content ─────────────────────────────────────────

class _AnalysingContent extends StatefulWidget {
  final VoidCallback onComplete;
  const _AnalysingContent({required this.onComplete});

  @override
  State<_AnalysingContent> createState() => _AnalysingContentState();
}

class _AnalysingContentState extends State<_AnalysingContent>
    with SingleTickerProviderStateMixin {
  static const _messages = [
    'Analyzing your experience…',
    'Evaluating your goals…',
    'Calculating risk tolerance…',
    'Preparing your investor profile…',
  ];

  static const _totalDuration = Duration(milliseconds: 4500);

  late final AnimationController _ctrl;
  late final Animation<double> _progress;
  int _msgIndex = 0;
  Timer? _msgTimer;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: _totalDuration);
    _progress = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic);

    _msgTimer = Timer.periodic(const Duration(milliseconds: 1100), (_) {
      if (!mounted) return;
      setState(() => _msgIndex = (_msgIndex + 1) % _messages.length);
    });

    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_done) {
        _done = true;
        _msgTimer?.cancel();
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) widget.onComplete();
        });
      }
    });

    _ctrl.forward();
  }

  @override
  void dispose() {
    _msgTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      builder: (context, _) {
        final pct = (_progress.value * 100).round();
        return Column(
          children: [
            const SizedBox(height: 32),
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: _progress.value,
                      strokeWidth: 4.0,
                      backgroundColor:
                          QInvWeb3Tokens.primary.withValues(alpha: 0.15),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        QInvWeb3Tokens.primaryLight,
                      ),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Text(
                    '$pct%',
                    style: const TextStyle(
                      fontFamily: QInvWeb3Tokens.fontUI,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: QInvWeb3Tokens.textHeading,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.15),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: child,
                ),
              ),
              child: Text(
                _messages[_msgIndex],
                key: ValueKey<int>(_msgIndex),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: QInvWeb3Tokens.fontUI,
                  fontSize: QInvWeb3Tokens.fontSizeSubtitle,
                  fontWeight: FontWeight.w500,
                  color: QInvWeb3Tokens.textMuted,
                  height: 1.55,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Karaoke Text ───────────────────────────────────────────────

class _KaraokeText extends StatelessWidget {
  final List<WordTiming> timings;
  final Stream<int> positionMsStream;

  const _KaraokeText({
    required this.timings,
    required this.positionMsStream,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: positionMsStream,
      initialData: -1,
      builder: (context, snapshot) {
        final posMs = snapshot.data ?? -1;

        // Find the active word based on current playback position.
        int activeIndex = -1;
        if (posMs >= 0) {
          for (int i = 0; i < timings.length; i++) {
            if (posMs >= timings[i].startMs && posMs < timings[i].endMs) {
              activeIndex = i;
              break;
            }
            // Between words (gap): keep previous word highlighted.
            if (i < timings.length - 1 &&
                posMs >= timings[i].endMs &&
                posMs < timings[i + 1].startMs) {
              activeIndex = i;
              break;
            }
          }
        }

        return RichText(
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            style: const TextStyle(
              fontFamily: QInvWeb3Tokens.fontUI,
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: QInvWeb3Tokens.textMuted,
              height: 1.50,
            ),
            children: [
              for (int i = 0; i < timings.length; i++) ...[
                if (i > 0) const TextSpan(text: ' '),
                TextSpan(
                  text: timings[i].word,
                  style: i == activeIndex
                      ? TextStyle(
                          color: QInvWeb3Tokens.textHeading,
                          backgroundColor:
                              QInvWeb3Tokens.primary.withValues(alpha: 0.30),
                        )
                      : i < activeIndex
                          ? const TextStyle(color: QInvWeb3Tokens.textHeading)
                          : null,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ── Showcase: Welcome ────────────────────────────────────────────

class _ShowcaseWelcome extends StatelessWidget {
  const _ShowcaseWelcome();
  static const _package = 'onboarding_reference';

  static const _pressLogos = [
    'logos/forbes.png',
    'logos/cointelegraph.png',
    'logos/exame.png',
    'logos/infomoney.png',
    'logos/valor.png',
    'logos/istoe.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        // QINV wordmark logo
        SvgPicture.asset(
          'assets/qinv_wordmark.svg',
          package: _package,
          width: 160,
          colorFilter: const ColorFilter.mode(
            Colors.white,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(height: 32),
        // Press logos — infinite auto-scroll marquee
        SizedBox(
          height: 24,
          child: _InfiniteMarquee(
            velocity: 30,
            itemCount: _pressLogos.length,
            separatorWidth: 40,
            itemBuilder: (index) => Opacity(
              opacity: 0.5,
              child: SizedBox(
                height: 16,
                child: Image.asset(
                  'assets/${_pressLogos[index]}',
                  package: _package,
                  height: 16,
                  fit: BoxFit.contain,
                  color: QInvWeb3Tokens.textMuted,
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Showcase: App Mockup ─────────────────────────────────────────

class _ShowcaseMockup extends StatelessWidget {
  final String assetPath;
  static const _package = 'onboarding_reference';

  const _ShowcaseMockup({required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.white, Colors.transparent],
          stops: [0.0, 0.55, 1.0],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(36),
          topRight: Radius.circular(36),
        ),
        child: Image.asset(
          assetPath,
          package: _package,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    )
        .animate()
        .slideY(begin: 0.08, end: 0, duration: 620.ms, curve: Curves.easeOutCubic)
        .fadeIn(duration: 500.ms);
  }
}

// ── Showcase: Reviews ────────────────────────────────────────────

class _ReviewData {
  final String author;
  final String title;
  final String body;
  final int stars;

  const _ReviewData({
    required this.author,
    required this.title,
    required this.body,
    // ignore: unused_element_parameter
    this.stars = 5,
  });
}

class _ShowcaseReviews extends StatelessWidget {
  const _ShowcaseReviews();

  static const _reviews = [
    _ReviewData(
      author: 'IanCastro',
      title: 'Smart portfolios really work!',
      body:
          "I've tried many brokers, but QINV stood out with its AI. It optimizes my investments strategically and transparently.",
    ),
    _ReviewData(
      author: 'Ana B.',
      title: 'Super intuitive!',
      body:
          'I was a crypto beginner and afraid of making mistakes. QINV guided me clearly from my very first investment.',
    ),
    _ReviewData(
      author: 'Cla_RR',
      title: 'Easy and practical',
      body:
          "First time investing and couldn't be happier. Easy to invest, track returns, and withdrawals are super fast!",
    ),
    _ReviewData(
      author: 'Thiagosdep',
      title: 'Effortless investing',
      body:
          'The app helps me invest in diverse cryptos without prior knowledge. It analyzes the market and diversifies for me.',
    ),
    _ReviewData(
      author: 'manusilvasilv',
      title: 'Reliable',
      body:
          'First time investing in crypto and it was amazing! Instant withdrawals add real credibility.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Custom serif title
        const Text(
          'Loved by our',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: QInvWeb3Tokens.fontSerif,
            fontSize: 38,
            fontWeight: FontWeight.w500,
            color: QInvWeb3Tokens.textHeading,
            height: 1.10,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'investors',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: QInvWeb3Tokens.fontSerif,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w400,
            fontSize: 44,
            color: QInvWeb3Tokens.primaryLight,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 24),
        // Review cards — infinite auto-scroll marquee
        SizedBox(
          height: 240,
          child: _InfiniteMarquee(
            velocity: 22,
            itemCount: _reviews.length,
            separatorWidth: 16,
            itemBuilder: (index) => _ReviewCard(review: _reviews[index]),
          ),
        ),
        const SizedBox(height: 24),
        // Laurel rating badge
        const _RatingLaurelBadge(),
      ],
    );
  }
}

// ── Infinite auto-scroll marquee ─────────────────────────────────

class _InfiniteMarquee extends StatefulWidget {
  final double velocity; // pixels per second
  final int itemCount;
  final double separatorWidth;
  final Widget Function(int index) itemBuilder;

  const _InfiniteMarquee({
    required this.velocity,
    required this.itemCount,
    required this.separatorWidth,
    required this.itemBuilder,
  });

  @override
  State<_InfiniteMarquee> createState() => _InfiniteMarqueeState();
}

class _InfiniteMarqueeState extends State<_InfiniteMarquee>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    if (!_scrollController.hasClients) {
      _lastTick = elapsed;
      return;
    }

    final dt = (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;

    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) return;

    var newOffset = _scrollController.offset + widget.velocity * dt;

    // When we've scrolled past the first "set" of items, jump back seamlessly
    final halfMax = maxScroll / 2;
    if (newOffset >= halfMax) {
      newOffset -= halfMax;
    }

    _scrollController.jumpTo(newOffset);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We render 3x the items so there's always content visible during the loop
    final totalItems = widget.itemCount * 3;
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          Colors.transparent,
          Colors.white,
          Colors.white,
          Colors.transparent,
        ],
        stops: [0.0, 0.05, 0.95, 1.0],
      ).createShader(bounds),
      blendMode: BlendMode.dstIn,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: totalItems,
        separatorBuilder: (_, __) =>
            SizedBox(width: widget.separatorWidth),
        itemBuilder: (_, index) =>
            widget.itemBuilder(index % widget.itemCount),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final _ReviewData review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stars
          Row(
            children: List.generate(
              review.stars,
              (_) => const Icon(Icons.star_rounded,
                  color: Color(0xFFFFC107), size: 16),
            ),
          ),
          const SizedBox(height: 10),
          // Title
          Text(
            review.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: QInvWeb3Tokens.fontUI,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: QInvWeb3Tokens.textHeading,
              height: 1.30,
            ),
          ),
          const SizedBox(height: 8),
          // Body
          Expanded(
            child: Text(
              review.body,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: QInvWeb3Tokens.fontUI,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: QInvWeb3Tokens.textSecondary,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Author
          Text(
            'by ${review.author}',
            style: const TextStyle(
              fontFamily: QInvWeb3Tokens.fontUI,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: QInvWeb3Tokens.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Laurel rating badge ──────────────────────────────────────────

class _RatingLaurelBadge extends StatelessWidget {
  const _RatingLaurelBadge();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const _LaurelBranch(mirrored: false),
        const SizedBox(width: 12),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                5,
                (_) => const Icon(Icons.star_rounded,
                    color: Color(0xFFFFC107), size: 14),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '4.8',
              style: TextStyle(
                fontFamily: QInvWeb3Tokens.fontSerif,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: QInvWeb3Tokens.textHeading,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'APP STORE',
              style: TextStyle(
                fontFamily: QInvWeb3Tokens.fontUI,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: QInvWeb3Tokens.textMuted,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        const _LaurelBranch(mirrored: true),
      ],
    );
  }
}

class _LaurelBranch extends StatelessWidget {
  final bool mirrored;
  const _LaurelBranch({required this.mirrored});

  @override
  Widget build(BuildContext context) {
    const leafColor = Color(0x66B080FF); // primaryLight at ~40% opacity

    Widget leaf(double angleDeg, {double size = 16}) {
      return Transform.rotate(
        angle: angleDeg * pi / 180,
        child: Icon(Icons.eco_rounded, size: size, color: leafColor),
      );
    }

    final branch = SizedBox(
      width: 32,
      height: 52,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(top: 0, left: 6, child: leaf(-45, size: 15)),
          Positioned(top: 14, left: 3, child: leaf(-25, size: 16)),
          Positioned(top: 30, left: 5, child: leaf(-10, size: 15)),
        ],
      ),
    );

    return mirrored
        ? Transform.scale(scaleX: -1, child: branch)
        : branch;
  }
}
