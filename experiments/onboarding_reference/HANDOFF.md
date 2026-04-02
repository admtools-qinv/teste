# Handoff — Onboarding Reference

## O que este pacote entrega
Implementação completa de referência do onboarding em Flutter, com fluxo, telas, inputs, review, captions, voz e pontos de integração com backend.

## Como integrar
1. Copiar o conteúdo de `flutter/` para o repo móvel final.
2. Substituir `NoopOnboardingBackendService` pelo backend real.
3. Substituir `NoopOnboardingAnalyticsService` pelos eventos reais.
4. Injetar `FlutterTtsVoiceService` ou outro provedor de voz.
5. Conectar o design system final se houver divergência do tema atual.

## Arquivos principais
- `flutter/lib/onboarding_reference/presentation/onboarding_screen.dart`
- `flutter/lib/onboarding_reference/flow/onboarding_flow_controller.dart`
- `flutter/lib/onboarding_reference/data/default_steps.dart`
- `flutter/lib/onboarding_reference/theme/qinvweb3_theme.dart`
- `flutter/lib/onboarding_reference/services/backend/*`
- `flutter/lib/onboarding_reference/services/analytics/*`

## Observação
O fluxo já está separado para facilitar exportação por ZIP e posterior migração para o repo do app.
