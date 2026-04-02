import 'dart:async';

import 'package:flutter/material.dart';

import '../flow/onboarding_flow_controller.dart';
import '../models/onboarding_step.dart';
import '../services/backend/onboarding_backend_service.dart';
import '../services/analytics/onboarding_analytics_service.dart';
import '../services/voice_service.dart';
import '../theme/qinvweb3_tokens.dart';
import 'widgets/glass_widgets.dart';
import 'widgets/qinv_button.dart';
import 'widgets/qinv_caption_bar.dart';
import 'widgets/qinv_error_banner.dart';
import 'widgets/qinv_review_tile.dart';
import 'widgets/qinv_step_card.dart';
import 'widgets/qinv_text_field.dart';

class OnboardingScreen extends StatefulWidget {
  final List<OnboardingStep> steps;
  final VoiceService voiceService;
  final OnboardingBackendService backend;
  final OnboardingAnalyticsService analytics;

  const OnboardingScreen({
    super.key,
    required this.steps,
    required this.voiceService,
    required this.backend,
    required this.analytics,
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
  String? _syncedStepId;

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
      await widget.voiceService.speak(controller.current.voiceText);
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
    unawaited(widget.voiceService.stop());
    controller.dispose();
    super.dispose();
  }

  void _syncStepState(OnboardingStep step) {
    if (_syncedStepId == step.id) {
      return;
    }

    _syncedStepId = step.id;

    if (step.type == OnboardingStepType.singleChoice) {
      final stored = controller.session.answers[step.id]?.toString();
      final validIds = step.options.map((option) => option.id).toSet();
      selectedOptionId = stored != null && validIds.contains(stored) ? stored : null;
      return;
    }

    selectedOptionId = null;

    if (step.type == OnboardingStepType.textInput ||
        step.type == OnboardingStepType.phoneInput ||
        step.type == OnboardingStepType.verificationCode) {
      final draft = _drafts[step.id];
      final value = draft ?? controller.session.answers[step.id]?.toString() ?? '';
      inputController.text = value;
      inputController.selection = TextSelection.collapsed(offset: value.length);
    }
  }

  void _clearTransientSelection() {
    selectedOptionId = null;
  }

  Future<void> _goBack() async {
    final moved = await controller.previous();
    if (!mounted || !moved) return;
    setState(() {});
    await widget.voiceService.speak(controller.current.voiceText);
  }

  Future<void> _submitCurrentStep() async {
    final step = controller.current;
    final inputValue = inputController.text.trim();
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
      return;
    }

    if (step.type == OnboardingStepType.textInput ||
        step.type == OnboardingStepType.phoneInput ||
        step.type == OnboardingStepType.verificationCode) {
      _drafts.remove(step.id);
      inputController.clear();
      inputFocusNode.unfocus();
    }

    _clearTransientSelection();
    setState(() {});

    if (controller.hasNext) {
      await widget.voiceService.speak(controller.current.voiceText);
    }
  }

  Widget _buildOption(OnboardingStep step, OnboardingOption option) {
    final selected = selectedOptionId == option.id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: QInvButton(
        label: option.label,
        outline: true,
        busy: controller.isBusy,
        selected: selected,
        onPressed: controller.isBusy
            ? null
            : () {
                selectedOptionId = selected && !step.required ? null : option.id;
                setState(() {});
              },
      ),
    );
  }

  Widget _buildStepContent(OnboardingStep step) {
    final isInteractionBlocked = controller.isBusy || controller.isCompleted;

    switch (step.type) {
      case OnboardingStepType.intro:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            QInvButton(
              label: controller.isBusy ? 'Loading…' : (step.primaryCtaLabel ?? 'Continue'),
              busy: controller.isBusy,
              onPressed: isInteractionBlocked ? null : _submitCurrentStep,
            ),
          ],
        );
      case OnboardingStepType.singleChoice:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            ...step.options.map((option) => _buildOption(step, option)),
            const SizedBox(height: 4),
            QInvButton(
              label: controller.isBusy ? 'Saving…' : (step.primaryCtaLabel ?? 'Continue'),
              busy: controller.isBusy,
              selected: selectedOptionId != null,
              onPressed: isInteractionBlocked || (step.required && selectedOptionId == null) ? null : _submitCurrentStep,
            ),
          ],
        );
      case OnboardingStepType.textInput:
      case OnboardingStepType.phoneInput:
      case OnboardingStepType.verificationCode:
        final inputType = step.type == OnboardingStepType.verificationCode
            ? TextInputType.number
            : step.inputKind == OnboardingInputKind.email
                ? TextInputType.emailAddress
                : step.inputKind == OnboardingInputKind.phone
                    ? TextInputType.phone
                    : TextInputType.text;

        final action = step.type == OnboardingStepType.verificationCode
            ? TextInputAction.done
            : TextInputAction.next;

        final maxLength = step.type == OnboardingStepType.verificationCode ? 6 : null;

        final hasError = controller.validationError != null;
        final helperText = step.required ? 'Required' : 'Optional';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            QInvTextField(
              controller: inputController,
              labelText: null,
              hintText: step.placeholder,
              helperText: helperText,
              keyboardType: inputType,
              autofocus: true,
              enabled: !controller.isBusy,
              maxLength: maxLength,
              textInputAction: action,
              semanticsLabel: step.title,
              semanticsHint: step.placeholder,
              onChanged: (value) => _drafts[step.id] = value,
              onSubmitted: (_) => unawaited(_submitCurrentStep()),
            ),
            if (hasError) ...[
              const SizedBox(height: 12),
              QInvErrorBanner(message: controller.validationError!),
            ],
            const SizedBox(height: 16),
            QInvButton(
              label: controller.isBusy ? 'Saving…' : (step.primaryCtaLabel ?? 'Continue'),
              busy: controller.isBusy,
              onPressed: isInteractionBlocked ? null : _submitCurrentStep,
            ),
          ],
        );
      case OnboardingStepType.review:
        final items = controller.reviewItems;
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
                        final stepIndex = widget.steps.indexWhere((candidate) => candidate.id == item.stepId);
                        if (stepIndex < 0) return;
                        if (!controller.jumpToStepIndex(stepIndex)) return;
                        _syncedStepId = null;
                        setState(() {});
                      },
            ),
            if (controller.validationError != null) ...[
              const SizedBox(height: 12),
              QInvErrorBanner(message: controller.validationError!),
            ],
            const SizedBox(height: 8),
            QInvButton(
              label: controller.isBusy ? 'Submitting…' : (controller.isCompleted ? 'Completed' : (step.primaryCtaLabel ?? 'Confirm')),
              busy: controller.isBusy,
              onPressed: isInteractionBlocked ? null : _submitCurrentStep,
            ),
          ],
        );
      case OnboardingStepType.completion:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Semantics(
              container: true,
              label: 'Onboarding complete',
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: QInvWeb3Tokens.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(QInvWeb3Tokens.radiusCard),
                  border: Border.all(color: QInvWeb3Tokens.primary.withValues(alpha: 0.35)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.verified_rounded, color: QInvWeb3Tokens.primaryLight),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Everything is ready. You can safely close this flow.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: QInvWeb3Tokens.textSecondary,
                              height: 1.35,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            QInvButton(
              label: controller.isCompleted ? 'Completed' : (controller.isBusy ? 'Finishing…' : (step.primaryCtaLabel ?? 'Finish')),
              busy: controller.isBusy,
              selected: controller.isCompleted,
              onPressed: isInteractionBlocked || controller.isCompleted ? null : _submitCurrentStep,
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final step = controller.current;
        _syncStepState(step);

        final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
        final size = MediaQuery.sizeOf(context);
        final isCompact = size.width < 360;
        final horizontalPadding = isCompact ? 16.0 : 20.0;
        final verticalPadding = isCompact ? 16.0 : 20.0;
        final contentSpacing = isCompact ? 16.0 : 24.0;
        final cardPadding = isCompact ? 18.0 : 24.0;
        final progressValue = widget.steps.isEmpty ? 0.0 : (controller.index + 1) / widget.steps.length;
        final stepLabel = controller.isCompleted ? 'Complete' : 'Step ${controller.index + 1} of ${widget.steps.length}';

        final body = CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      label: stepLabel,
                      value: '${(progressValue * 100).round()} percent',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9999),
                        child: LinearProgressIndicator(
                          minHeight: 6,
                          value: progressValue,
                          backgroundColor: QInvWeb3Tokens.border,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            controller.isCompleted ? QInvWeb3Tokens.primaryLight : QInvWeb3Tokens.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    controller.isCompleted ? 'Done' : '${controller.index + 1}/${widget.steps.length}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: QInvWeb3Tokens.textMuted,
                        ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: contentSpacing)),
            SliverFillRemaining(
              hasScrollBody: true,
              child: AnimatedSwitcher(
                duration: QInvWeb3Tokens.transitionAll,
                child: SingleChildScrollView(
                  key: ValueKey(step.id),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  physics: const BouncingScrollPhysics(),
                  child: QInvStepCard(
                    padding: EdgeInsets.all(cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Semantics(
                          header: true,
                          child: Text(
                            step.title,
                            textAlign: step.type == OnboardingStepType.singleChoice ||
                                    step.type == OnboardingStepType.review ||
                                    step.type == OnboardingStepType.completion
                                ? TextAlign.left
                                : TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: QInvWeb3Tokens.textHeading,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          step.caption,
                          textAlign: step.type == OnboardingStepType.singleChoice ||
                                  step.type == OnboardingStepType.review ||
                                  step.type == OnboardingStepType.completion
                              ? TextAlign.left
                              : TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: QInvWeb3Tokens.textSecondary,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: step.required ? Alignment.centerLeft : Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: (step.required ? QInvWeb3Tokens.primary : QInvWeb3Tokens.textMuted).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: (step.required ? QInvWeb3Tokens.primary : QInvWeb3Tokens.border).withValues(alpha: 0.65),
                              ),
                            ),
                            child: Text(
                              step.required ? 'Required' : 'Optional',
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: step.required ? QInvWeb3Tokens.primaryLight : QInvWeb3Tokens.textMuted,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (controller.serviceError != null) ...[
                          QInvErrorBanner(message: controller.serviceError!),
                          const SizedBox(height: 12),
                        ],
                        _buildStepContent(step),
                        if (controller.isBusy) ...[
                          const SizedBox(height: 16),
                          const LinearProgressIndicator(minHeight: 2),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: contentSpacing)),
            SliverToBoxAdapter(
              child: QInvCaptionBar(
                text: voiceReady ? step.voiceText : 'Narration unavailable.',
                onReplay: voiceReady ? () => unawaited(widget.voiceService.speak(step.voiceText)) : null,
              ),
            ),
            if (controller.hasPrevious) ...[
              SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverToBoxAdapter(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: (controller.isBusy || controller.isCompleted) ? null : _goBack,
                    child: const Text('Back'),
                  ),
                ),
              ),
            ],
          ],
        );

        return Scaffold(
          backgroundColor: QInvWeb3Tokens.background,
          body: GlassBackground(
            child: SafeArea(
              child: AnimatedPadding(
                duration: QInvWeb3Tokens.transitionAll,
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  verticalPadding,
                  horizontalPadding,
                  verticalPadding + bottomInset,
                ),
                child: AbsorbPointer(
                  absorbing: controller.isBusy || controller.isCompleted,
                  child: body,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
