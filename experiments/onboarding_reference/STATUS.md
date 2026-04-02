# Status técnico atual

## Implementado
- fluxo onboarding com controller
- validação de email, telefone, código e choice
- tela principal com progress, captions e erro
- widgets base (button, text field, review tile, error banner, caption bar)
- stubs para backend e analytics
- TTS abstrato e implementação Flutter TTS
- testes unitários e widget tests iniciais
- tema e tokens do QInvWeb3

## Observações
- pacote ainda precisa ser executado em Flutter real para validar compilação final
- ideal revisar motion/spacing/keyboard insets em device real
- validar ajuste fino de captions com voice pacing

## Próximos checkpoints
1. rodar `flutter test`
2. rodar app exemplo
3. revisar layout em telas pequenas
4. revisar estado final de completion / submit
