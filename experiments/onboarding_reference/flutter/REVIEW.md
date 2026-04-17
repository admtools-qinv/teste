# Onboarding Reference — Code Review

**Data:** 2026-04-17 (atualizado)  
**Testes:** 109 passed, 0 failed  
**Analyze:** 6 issues (antes: 8 → 25)

---

## Correções Aplicadas

### 1. Teste falhando — "shows first step content"

**Arquivo:** `test/widget/onboarding_screen_test.dart:53`

**Causa raiz:** O teste usava `defaultOnboardingSteps` que começa com steps de showcase (`showcaseWelcome`), mas as assertions verificavam o conteúdo do step `welcome` (intro). Após a adição dos showcase steps, o primeiro step visível mudou de `"Let's get you"` para `"Invest in crypto\non autopilot."`.

Além disso, o step `welcome` tem `titleItalic: 'started.'`, fazendo o widget renderizar `"Let's get you\nstarted."` como texto único — `find.text("Let's get you")` nunca encontraria match.

**Correção:**
- Trocado `defaultOnboardingSteps` por `onboardingStepsFor(AuthMethod.emailPassword)` que filtra showcase steps
- Trocado `find.text()` por `find.textContaining()` para o título com `titleItalic`

### 2. Example test quebrado — 17 erros de análise

**Arquivo:** `example/test/widget_test.dart`

**Causa raiz:** Template padrão do Flutter (`Counter increments smoke test`) referenciando `MyApp` com counter que não existe. O `pubspec.yaml` do example não tinha `flutter_test` em `dev_dependencies`.

**Correção:**
- Reescrito o teste como smoke test mínimo que verifica que `ExampleApp` existe
- Adicionado `flutter_test` ao `dev_dependencies` do example
- Simplificado `analysis_options.yaml` do example para herdar do parent

---

## Issues Restantes (6)

### Warnings (2)

| # | Arquivo | Issue |
|---|---------|-------|
| 1 | `example/analysis_options.yaml:10` | URI `flutter_lints/flutter.yaml` não encontrado |
| 2 | `onboarding_flow_controller_additional_test.dart:88` | Mock não usado: `_FlakySaveBackend` |

~~`onboarding_screen.dart:8` — Import `flutter_svg` não usado~~ → **Removido**  
~~`onboarding_screen.dart:1829` — Classe morta `_RatingLaurelBadge`~~ → **Removida**

### Info (4)

| # | Arquivo | Issue |
|---|---------|-------|
| 3-5 | `press_logos_marquee.dart:33-37` | `prefer_const_constructors` (3x) |
| 6 | `biometric_login_screen_test.dart:213` | `no_leading_underscores_for_local_identifiers` |

---

## Cobertura de Testes — Lacunas

| Componente | Testes | Prioridade |
|-----------|--------|-----------|
| `SuitabilityScorer` | Nenhum — scoring logic, profiles, edge cases | Alta |
| `PhoneMaskFormatter` | Nenhum — formatação por país | Alta |
| `OnboardingSession` model | Nenhum — copyWith, serialization | Média |
| `PinInputWidget` | Nenhum — entrada, delete, completion callback | Média |
| `SlideToUpdateSlider` | Nenhum — threshold 0.88, haptics, reset | Média |
| `UpdateModal` | Nenhum — review items, edit flow | Média |
| `AssetVoiceService` | Nenhum — playback, position stream, dispose | Baixa |
| `FlutterTtsVoiceService` | Nenhum — fallback, language config | Baixa |
| `IpGeoService` | Nenhum — HTTP call, fallback country | Baixa |
| `GlassWidgets` | Nenhum — rendering, backdrop filter | Baixa |
| `InteractiveGridPattern` | Nenhum — touch response, animation | Baixa |
| `LoginScreen` | Nenhum — Google auth, navigation | Baixa |
| `ReturnLoginScreen` | Nenhum — credential loading, biometric trigger | Baixa |
| `SignInSheet` | Nenhum — option selection | Baixa |
| `Country` / `countries.dart` | Nenhum — data integrity, lookup | Baixa |

---

## Pontos de Melhoria — Código

### Alta Prioridade

1. ~~**`onboarding_screen.dart` (~1900 linhas)** — arquivo muito grande.~~ → **Resolvido (1913 → 1083 linhas, -43%)**
   - Extraídos 7 widgets para arquivos individuais em `widgets/`:
     - `glass_circle_button.dart` — `GlassCircleButton`
     - `onboarding_option_card.dart` — `OnboardingOptionCard`
     - `analysing_content.dart` — `AnalysingContent`
     - `karaoke_text.dart` — `KaraokeText`
     - `press_logos_marquee.dart` — `PressLogosMarquee`
     - `phone_frame.dart` — `PhoneFrame`
     - `showcase_reviews.dart` — `ShowcaseReviews`, `InfiniteMarquee`, `ReviewCard`
   - Removido código morto: `_RatingLaurelBadge`, `_LaurelBranch`
   - Removidos imports não usados: `flutter_svg`, `dart:math`, `flutter/scheduler.dart`

2. ~~**Magic numbers** — durations (450ms, 300ms, 200ms), thresholds (0.88 no slider), pixel values hardcoded em ~50 locais.~~ → **Resolvido**
   - Adicionadas 17 constantes em `QInvWeb3Tokens`: durations (`transitionFast/Medium/Slow/Snap/Modal`, `delayInputFocus`, `delayHapticDouble`), layout (`breakpointCompact`, `paddingPage/Compact`, `phoneWidthRatio`), slider (`sliderThreshold`), blur (`blurGlow/Glass/Card/Modal`)
   - Adicionado helper `responsiveHPad()` para o padrão repetido de padding responsivo
   - Atualizados 13 arquivos para usar as constantes nomeadas

~~3. **`KaraokeText` StreamBuilder** — rebuilda a cada milissegundo durante playback de áudio.~~ → **Resolvido:** stream mapeado para `activeIndex` com `.distinct()` — rebuild só ocorre quando a palavra ativa muda.

### Média Prioridade

~~4. **Sem i18n** — textos hardcoded mix PT/EN (validator em inglês, app em português). Externalizar strings com `intl` ou `slang`.~~ → **Resolvido**
   - Adicionado `flutter_localizations` + `intl` + `flutter: generate: true`
   - Criado `l10n.yaml`, `lib/l10n/app_en.arb` (77 keys), `lib/l10n/app_pt.arb` (stub)
   - Todas as strings PT-BR convertidas para EN
   - Widgets de apresentação usam `AppLocalizations` via `context.l10n`
   - Extension helper `AppLocalizationsX` em `lib/l10n/l10n.dart`
   - Testes atualizados com `localizationsDelegates` + assertions em inglês
   - **Pendente Fase 2:** preencher `app_pt.arb`, localizar conteúdo dos steps (`default_steps.dart`), validator messages

~~5. **Mensagens de validação inconsistentes** — `DefaultOnboardingValidator` usa mensagens em inglês ("Invalid email"), mas o app usa português ("Erro de conexão").~~ → **Resolvido** — todo o app agora está em inglês

6. **`BiometricLoginScreen._authenticate()`** — dispara em `initState` sem verificar se a tela está realmente visível. Pode causar double-auth em mount/unmount rápido.

7. **Review tiles em `Column`** — deveria usar `ListView.builder()` ou `SliverList` para listas grandes.

### Baixa Prioridade

8. **Sem retry logic** — falhas de backend são logadas mas sem tentativa de retry para erros transientes.

9. **PIN em `_drafts`** — armazenado temporariamente como string em memória durante input. Considerar limpar em lifecycle events (`didChangeAppLifecycleState`).

10. **Voice service falhas silenciosas** — `FlutterTtsVoiceService` silencia erros de plugin ausente. `AssetVoiceService` não trata arquivos de áudio corrompidos.

---

## Resumo

| Métrica | Início | Review | Refactor |
|---------|--------|--------|----------|
| Testes passando | 108/109 | 109/109 | **109/109** |
| Testes falhando | 1 | 0 | **0** |
| Erros de análise | 17 | 0 | **0** |
| Warnings | 4 | 3 | **2** |
| Info | 4 | 5 | **4** |
| Total issues | 25 | 8 | **6** → **6** |
| `onboarding_screen.dart` | 1913 loc | 1913 loc | **1083 loc** |
