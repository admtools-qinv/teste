import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/onboarding_review_item.dart';
import '../models/onboarding_session.dart';
import '../models/onboarding_step.dart';
import '../services/analytics/onboarding_analytics_service.dart';
import '../services/backend/onboarding_backend_service.dart';
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

  List<OnboardingReviewItem> get reviewItems {
    final items = <OnboardingReviewItem>[];

    for (final step in steps) {
      if (step.type == OnboardingStepType.intro ||
          step.type == OnboardingStepType.completion ||
          step.type == OnboardingStepType.review) {
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
      await backend.startSession();
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
    final error = validator.validate(current, candidate);
    validationError = error;
    _notify();
    return error == null;
  }

  Future<bool> _saveAnswer(String stepId, Object? value) async {
    try {
      await backend.saveAnswer(stepId: stepId, value: value);
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

      if (step.type == OnboardingStepType.singleChoice) {
        final value = selectedOptionId;
        if (value == null || value.isEmpty) {
          if (step.required) {
            if (!await validateCurrentStep(value)) return false;
            return false;
          }
          if (session.answers.containsKey(step.id)) {
            await backend.clearAnswer(stepId: step.id);
          }
          session = session.copyWithoutAnswer(step.id);
          validationError = null;
        } else {
          if (!await validateCurrentStep(value)) return false;
          if (!await _saveAnswer(step.id, value)) return false;
        }
      } else if (step.type == OnboardingStepType.textInput ||
          step.type == OnboardingStepType.phoneInput ||
          step.type == OnboardingStepType.verificationCode) {
        final candidate = inputValue?.toString().trim();
        if (candidate == null || candidate.isEmpty) {
          if (step.required) {
            if (!await validateCurrentStep(candidate)) return false;
            return false;
          }
          if (session.answers.containsKey(step.id)) {
            await backend.clearAnswer(stepId: step.id);
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
        await backend.submitAll(session.answers);
        _completed = true;
        isBusy = false;
        _notify();
        unawaited(_trackEventSafe('onboarding_completed', properties: _sanitizedAnswers()));
        return true;
      }

      unawaited(_trackEventSafe('onboarding_step_completed', properties: {
        'stepId': current.id,
        'stepType': current.type.name,
      }));

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
