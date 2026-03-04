# MEMORY.md — Clawdemir Long-Term Memory

## Aragorn (Fabricio)
- Timezone: America/Sao_Paulo (UTC-3)
- Servidor Azure: ubuntu@20.55.98.19 (SSH com PEM)
- Port forwards: 7070→18789 (Control UI), 9090→9090 (Kanban)
- Design system: QInvWeb3 (Plus Jakarta Sans, dark theme)
- Exige qualidade real, não aceita trabalho superficial
- Prefere eu gerenciar tarefas, não ele
- Accent: vermelho OpenClaw (#E8453C), bg: #1F1F1F

## Infraestrutura
- Kanban server: porta 9090, Node.js + SQLite
- Kanban DB: /home/ubuntu/.openclaw/workspace/kanban.db
- Kanban app: /home/ubuntu/.openclaw/workspace/kanban-app/
- Server precisa NODE_PATH=$(npm root -g) para rodar
- Gateway CSP bloqueia inline — sempre usar arquivos externos
- Sub-agents com problema de pairing — precisa investigar

## Lições
- Nunca servir static files do diretório control-ui (SPA conflicts)
- Service workers do Control UI persistem em localhost
- Aragorn não muda SSH facilmente — adaptar infra ao setup dele
- Qualidade > velocidade — ele prefere esperar horas por resultado bom
