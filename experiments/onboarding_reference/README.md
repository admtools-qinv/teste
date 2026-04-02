# Onboarding Reference — Complete Flutter package

## Objetivo
Pacote isolado para reproduzir o fluxo inteiro de onboarding em Flutter, com telas, inputs, captions, voz, analytics e backend prontos para integração futura.

## O que está incluído
- fluxo completo de etapas
- telas e widgets de base
- inputs e review
- captions sincronizadas
- serviço de voz plugável
- backend stub para integração futura
- analytics stub para eventos
- tema QInvWeb3 aplicado

## O que o dev precisa fazer depois
- trocar stubs por backend real
- conectar autenticação/validação
- integrar TTS definitivo, se necessário
- substituir qualquer placeholder por componentes finais
- adicionar assets e ilustrações definitivas

## Estrutura
- `flow/` — controller e regras do fluxo
- `design-system/` — tokens e documentação
- `flutter/` — package Flutter com implementação

## Handoff
O diretório está pronto para virar zip e ser enviado ao dev front sem depender do restante do workspace.
