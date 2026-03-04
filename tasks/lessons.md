# Lessons Learned — Clawdemir

> Após QUALQUER correção do Aragorn, registrar aqui. Revisar no início de cada sessão.

## Formato
```
### [YYYY-MM-DD] Título curto
- **Erro:** O que fiz errado
- **Causa raiz:** Por que aconteceu
- **Regra:** Nova regra pra prevenir
- **Contexto:** Projeto/tarefa relacionada
```

## Lições

### [2026-02-20] Gateway CSP bloqueia inline
- **Erro:** Tentei servir HTML com inline styles/scripts pelo gateway
- **Causa raiz:** CSP restritivo do OpenClaw gateway
- **Regra:** Sempre usar arquivos externos pra CSS/JS. Nunca inline.
- **Contexto:** Kanban dashboard

### [2026-02-20] Service workers persistem em localhost
- **Erro:** Requests interceptados por service worker do Control UI
- **Causa raiz:** Service worker registrado no mesmo localhost
- **Regra:** Usar porta separada pra apps custom. Nunca servir do diretório control-ui.
- **Contexto:** Kanban dashboard

### [2026-02-24] Não colocar timeout baixo em subagents de pesquisa/escrita
- **Erro:** Defini runTimeoutSeconds=300 pra tarefas de pesquisa que precisavam de mais tempo
- **Causa raiz:** Assumi que 5 min seria suficiente pra criar 11 arquivos detalhados
- **Regra:** Subagents de pesquisa/escrita pesada: usar runTimeoutSeconds=600+ ou não definir timeout. Só usar timeout curto pra tarefas simples e previsíveis.
- **Contexto:** DeFi listings guide — 7 de 11 arquivos criados antes do timeout

### [2026-02-20] Adaptar ao setup do usuário
- **Erro:** Sugeri mudar config SSH do Aragorn
- **Causa raiz:** Assumi que ele mudaria setup facilmente
- **Regra:** Adaptar infraestrutura ao que o usuário já tem. Não pedir pra mudar workflow dele.
- **Contexto:** Setup SSH/port forwarding
