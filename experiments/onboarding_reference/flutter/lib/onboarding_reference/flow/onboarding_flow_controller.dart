import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/onboarding_review_item.dart';
import '../models/onboarding_session.dart';
import '../models/onboarding_step.dart';
import '../services/analytics/onboarding_analytics_service.dart';
import '../services/backend/onboarding_backend_service.dart';
import '../services/suitability_scorer.dart';
import '../validation/onboarding_validator.dart';

class OnboardingFlowController extends ChangeNotifier {
  final List<OnboardingStep> steps;
  final OnboardingBackendService backend;
  final OnboardingAnalyticsService analytics;
  final OnboardingValidator validator;

  int index = 0;
  bool isBusy = false;
  bool _disposed = false;
  bool _completed = false;
  String? validationError;
  String? serviceError;
  OnboardingSession session = const OnboardingSession();
  SuitabilityResult? _suitabilityResult;
  String _sessionId = '';

  SuitabilityResult? get suitabilityResult => _suitabilityResult;

  OnboardingFlowController({
    required this.steps,
    required this.backend,
    required this.analytics,
    OnboardingValidator? validator,
  })  : assert(steps.isNotEmpty, 'Onboarding steps must not be empty.'),
        validator = validator ?? DefaultOnboardingValidator();

  OnboardingStep get current => steps[index];
  bool get hasNext => index < steps.length - 1;
  bool get hasPrevious => index > 0;
  bool get isCompleted => _completed;
  bool get isShowcase => current.type == OnboardingStepType.showcase;
  int get showcaseCount =>
      steps.where((s) => s.type == OnboardingStepType.showcase).length;
  int get showcaseIndex =>
      steps.sublist(0, index + 1).where((s) => s.type == OnboardingStepType.showcase).length - 1;

  List<OnboardingReviewItem> get reviewItems {
    final items = <OnboardingReviewItem>[];

    for (final step in steps) {
      if (step.type == OnboardingStepType.showcase ||
          step.type == OnboardingStepType.intro ||
          step.type == OnboardingStepType.completion ||
          step.type == OnboardingStepType.review ||
          step.type == OnboardingStepType.analysing) {
        continue;
      }

      final rawValue = session.answers[step.id];
      if (rawValue == null) continue;

      final value = step.sensitive
          ? _redactValue()
          : _reviewValueForStep(step, rawValue.toString());

      items.add(
        OnboardingReviewItem(
          stepId: step.id,
          label: step.reviewLabel ?? step.title,
          value: value,
        ),
      );
    }

    return items;
  }

  String _reviewValueForStep(OnboardingStep step, String rawValue) {
    if (step.type != OnboardingStepType.singleChoice) return rawValue;

    for (final option in step.options) {
      if (option.id == rawValue) {
        return option.label;
      }
    }

    return rawValue;
  }

  String _redactValue() => '••••';

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  Future<void> _trackEventSafe(String name, {Map<String, dynamic>? properties}) async {
    try {
      await analytics.trackEvent(name, properties: properties);
    } catch (_) {
      // analytics must never block the flow
    }
  }

  Map<String, dynamic> _sanitizedAnswers() {
    final sanitized = <String, dynamic>{};
    for (final step in steps) {
      final rawValue = session.answers[step.id];
      if (rawValue == null) continue;

      if (step.sensitive) {
        sanitized[step.id] = _redactValue();
        continue;
      }

      sanitized[step.id] = rawValue;
    }
    return sanitized;
  }

  Future<bool> initialize() async {
    isBusy = true;
    serviceError = null;
    _notify();

    try {
      final dto = await backend.startSession();
      _sessionId = dto.sessionId;
      unawaited(_trackEventSafe('onboarding_started'));
      return true;
    } catch (_) {
      serviceError = 'Unable to initialize onboarding.';
      return false;
    } finally {
      isBusy = false;
      _notify();
    }
  }

  Future<bool> validateCurrentStep([Object? value]) async {
    final candidate = value ?? session.answers[current.id];
    final error = validator.validate(
      current,
      candidate,
      sessionAnswers: session.answers,
    );
    validationError = error;
    _notify();
    return error == null;
  }

  Future<bool> _saveAnswer(String stepId, Object? value) async {
    try {
      await backend.saveAnswer(sessionId: _sessionId, stepId: stepId, value: value);
      session = session.copyWithAnswer(stepId, value);
      validationError = null;
      serviceError = null;
      return true;
    } catch (_) {
      serviceError = 'Unable to save answer.';
      return false;
    } finally {
      _notify();
    }
  }

  Future<bool> advanceCurrentStep({Object? inputValue, String? selectedOptionId}) async {
    if (isBusy) return false;
    isBusy = true;
    serviceError = null;
    _notify();

    try {
      final step = current;

      if (_completed) {
        return false;
      }

      // Showcase steps: no data to save, just advance.
      if (step.type == OnboardingStepType.showcase) {
        // skip validation and saving
      } else if (step.type == OnboardingStepType.singleChoice) {
        final value = selectedOptionId;
        if (value == null || value.isEmpty) {
          if (step.required) {
            if (!await validateCurrentStep(value)) return false;
            return false;
          }
          if (session.answers.containsKey(step.id)) {
            await backend.clearAnswer(sessionId: _sessionId, stepId: step.id);
          }
          session = session.copyWithoutAnswer(step.id);
          validationError = null;
        } else {
          if (!await validateCurrentStep(value)) return false;
          if (!await _saveAnswer(step.id, value)) return false;
        }
      } else if (step.type == OnboardingStepType.textInput ||
          step.type == OnboardingStepType.phoneInput ||
          step.type == OnboardingStepType.verificationCode ||
          step.type == OnboardingStepType.pinInput) {
        final candidate = inputValue?.toString().trim();
        if (candidate == null || candidate.isEmpty) {
          if (step.required) {
            if (!await validateCurrentStep(candidate)) return false;
            return false;
          }
          if (session.answers.containsKey(step.id)) {
            await backend.clearAnswer(sessionId: _sessionId, stepId: step.id);
          }
          session = session.copyWithoutAnswer(step.id);
          validationError = null;
        } else {
          if (!await validateCurrentStep(candidate)) return false;
          if (!await _saveAnswer(step.id, candidate)) return false;
        }
      } else {
        if (!await validateCurrentStep()) return false;
      }

      if (!hasNext) {
        _suitabilityResult ??= SuitabilityScorer.compute(steps, session.answers);
        await backend.submitAll(
          sessionId: _sessionId,
          answers: {
            ...session.answers,
            'suitabilityScore': _suitabilityResult!.score,
            'suitabilityProfile': _suitabilityResult!.profile.name,
          },
        );
        _completed = true;
        isBusy = false;
        _notify();
        unawaited(_trackEventSafe('onboarding_completed', properties: {
          ..._sanitizedAnswers(),
          'suitabilityScore': _suitabilityResult!.score,
          'suitabilityProfile': _suitabilityResult!.profile.name,
        }));
        return true;
      }

      unawaited(_trackEventSafe('onboarding_step_completed', properties: {
        'stepId': current.id,
        'stepType': current.type.name,
      }));

      // Pre-compute suitability score before showing the completion step
      if (steps[index + 1].type == OnboardingStepType.completion ||
          steps[index + 1].type == OnboardingStepType.analysing) {
        _suitabilityResult = SuitabilityScorer.compute(steps, session.answers);
      }

      index += 1;
      validationError = null;
      return true;
    } catch (_) {
      serviceError = 'Unable to continue onboarding.';
      return false;
    } finally {
      isBusy = false;
      _notify();
    }
  }

  bool jumpToStepIndex(int stepIndex) {
    if (isBusy) return false;
    if (stepIndex < 0 || stepIndex >= steps.length) return false;
    index = stepIndex;
    validationError = null;
    serviceError = null;
    _notify();
    return true;
  }

  Future<bool> previous() async {
    if (!hasPrevious || isBusy) return false;
    index -= 1;
    validationError = null;
    serviceError = null;
    _notify();
    return true;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
