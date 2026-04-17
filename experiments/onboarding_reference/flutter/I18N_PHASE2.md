# i18n — Phase 2: Remaining Work

**Status:** Step content, validator, and controller localized (items 1-3 done).  
**Goal:** Full pt-BR support + localize remaining content.

---

## 1. Onboarding step content (`default_steps.dart`) — DONE

~100 strings across 19 steps migrated from `const` to `AppLocalizations`.

### What changed

- `const defaultOnboardingSteps` → `buildOnboardingSteps(AppLocalizations l10n)`
- `onboardingStepsFor(method)` → `onboardingStepsFor(l10n, method)`
- `showcaseSteps` getter → `showcaseSteps(l10n)` function
- ~100 ARB keys added to `app_en.arb` (prefix `step*`)
- All callers updated: `example/lib/main.dart`, both test files
- `OnboardingStep` model unchanged (non-const instances)

---

## 2. Validator messages (`onboarding_validator.dart`) — DONE

8 hardcoded English strings migrated to `AppLocalizations`.

### What changed

- `DefaultOnboardingValidator()` → `DefaultOnboardingValidator(AppLocalizations l10n)` (Option A)
- `OnboardingFlowController` `validator` parameter changed from optional to `required`
- `OnboardingScreen` creates the controller in `didChangeDependencies` (instead of `initState`) so `context.l10n` is available
- 8 ARB keys added to `app_en.arb` (prefix `validation*`)
- All test files updated to pass `DefaultOnboardingValidator(AppLocalizationsEn())`

---

## 3. Flow controller error messages (`onboarding_flow_controller.dart`) — DONE

3 hardcoded `serviceError` strings migrated to `AppLocalizations`.

### What changed

- `OnboardingFlowController` now takes `required AppLocalizations l10n`
- 3 hardcoded strings replaced with `l10n.flowInitError`, `l10n.flowSaveError`, `l10n.flowContinueError`
- 3 ARB keys added to `app_en.arb` (prefix `flow*`)
- `OnboardingScreen` passes `context.l10n` to the controller
- All test files updated to pass `l10n: AppLocalizationsEn()`

---

## 4. Fill `app_pt.arb`

Translate all 77 existing keys in `app_en.arb` to pt-BR. The file exists at `lib/l10n/app_pt.arb` with only `@@locale`.

Add the step content and validator keys from items 1-3 above to both ARB files.

---

## 5. Voice text localization

Each step has a `voiceText` field used for TTS narration + karaoke sync. Localizing voice requires:

- Translated `voiceText` strings (covered by item 1)
- New audio files per locale (`assets/audio/pt/`, `assets/audio/en/`)
- New karaoke timestamps per locale (`voice_timestamps.dart` per locale)
- `AssetVoiceService` needs locale-aware asset path resolution

---

## Execution order

1. ~~Steps content (item 1) — biggest chunk, mechanical work~~ ✅
2. ~~Validator (item 2) — pass `l10n` to `DefaultOnboardingValidator`~~ ✅
3. ~~Controller (item 3) — same approach, 3 strings~~ ✅
4. Add keys to ARB files — mechanical (step + validator + controller keys done)
5. Translate `app_pt.arb` (item 4) — needs human/translator
6. Voice assets (item 5) — needs new audio recordings

Items 1-4 can be done in one PR. Item 5 is translation work. Item 6 is a separate effort.
