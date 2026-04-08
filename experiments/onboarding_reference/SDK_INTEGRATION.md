# onboarding_reference — Integração como SDK

Este package é consumido como dependência git. Você nunca copia o código — só aponta para o repo e atualiza quando quiser.

---

## 1. Adicionar ao pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter

  onboarding_reference:
    git:
      url: https://github.com/IVIAI-QINV/qinv-fabricio.git
      path: experiments/onboarding_reference/flutter
      ref: master
```

---

## 2. Declarar as fontes

Na seção `flutter:` do seu `pubspec.yaml`:

```yaml
flutter:
  uses-material-design: true

  fonts:
    - family: PlayfairDisplay
      fonts:
        - asset: packages/onboarding_reference/fonts/PlayfairDisplay-Regular.ttf
          weight: 400
        - asset: packages/onboarding_reference/fonts/PlayfairDisplay-SemiBold.ttf
          weight: 600
        - asset: packages/onboarding_reference/fonts/PlayfairDisplay-Bold.ttf
          weight: 700
        - asset: packages/onboarding_reference/fonts/PlayfairDisplay-Italic.ttf
          weight: 400
          style: italic
        - asset: packages/onboarding_reference/fonts/PlayfairDisplay-BoldItalic.ttf
          weight: 700
          style: italic
    - family: LibreBaskerville
      fonts:
        - asset: packages/onboarding_reference/fonts/LibreBaskerville-Regular.ttf
          weight: 400
        - asset: packages/onboarding_reference/fonts/LibreBaskerville-Bold.ttf
          weight: 700
        - asset: packages/onboarding_reference/fonts/LibreBaskerville-Italic.ttf
          weight: 400
          style: italic
```

---

## 3. Instalar

```bash
flutter pub get
```

---

## 4. Usar no app

```dart
import 'package:onboarding_reference/onboarding_reference.dart';

// Sem API (modo teste):
OnboardingScreen(
  steps: defaultOnboardingSteps,
  backend: NoopOnboardingBackendService(),
  onCompleted: (answers) {
    // answers é um Map<String, dynamic> com todas as respostas
    print(answers);
  },
)

// Com API real (quando estiver pronto):
OnboardingScreen(
  steps: defaultOnboardingSteps,
  backend: RemoteOnboardingBackendService(
    baseUrl: 'https://api.seuapp.com/v1',
    headers: {'Authorization': 'Bearer $token'},
  ),
  onCompleted: (answers) {},
)
```

---

## 5. Atualizar quando houver nova versão

Sempre que o repo for atualizado, rode:

```bash
flutter pub upgrade onboarding_reference
```

---

## Acesso ao repo (privado)

O repo é privado. Configure o acesso de uma das formas abaixo:

**HTTPS (token GitHub):**
Autentique com um Personal Access Token no GitHub. O Git vai pedir as credenciais na primeira vez.

**SSH (recomendado):**
Troque a URL no `pubspec.yaml` por:
```yaml
url: git@github.com:IVIAI-QINV/qinv-fabricio.git
```
Garanta que sua chave SSH está cadastrada em github.com/settings/keys.
