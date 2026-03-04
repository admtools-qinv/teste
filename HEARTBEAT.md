# HEARTBEAT.md — Checklist Proativa

## A cada heartbeat, verificar (rotacionar):

- [ ] Checar status do Kanban server (porta 9090) — reiniciar se caiu
- [ ] Ler `memory/` dos últimos 2 dias pra manter contexto
- [ ] Verificar se tem daily note de hoje, criar se não existir
- [ ] Checar se gateway tá rodando (`openclaw gateway status`)

## 🔒 Security Checks (rotacionar, 2-4x por dia):
- [ ] Verificar que gateway está rodando e bound em loopback (`ss -tlnp | grep 3000` ou `openclaw gateway status`)
- [ ] Checar permissões do diretório de credenciais (deve ser 700): `stat -c '%a' ~/.openclaw/credentials 2>/dev/null || echo 'dir não existe'`
- [ ] Quick security audit: `openclaw security audit` (sem --deep pra economizar tempo)

## Semanal (1x):
- [ ] Revisar MEMORY.md — atualizar com insights recentes
- [ ] Checar updates do OpenClaw (`npm show openclaw version`)
