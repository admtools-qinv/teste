# Rotação de Sessão e Credenciais — Guia de Procedimentos

## Quando Rotacionar

- **Exposição de credenciais** — qualquer secret vazado em log, chat ou repositório
- **Atividade suspeita** — logins não reconhecidos, comandos estranhos, tráfego anômalo
- **Achados de auditoria** — qualquer finding de segurança que comprometa tokens/chaves
- **Rotação preventiva** — a cada 90 dias como boa prática

## Passos para Rotação

1. **Parar o gateway:**
   ```bash
   openclaw gateway stop
   ```

2. **Regenerar token do gateway:**
   - Editar `openclaw.json`
   - Gerar novo token seguro (ex: `openssl rand -hex 32`)
   - Substituir o valor do token existente

3. **Rotacionar chaves de API expostas:**
   - AWS: Gerar novas access keys no IAM Console, revogar as antigas
   - Telegram bot token: Usar /revoke no @BotFather, gerar novo
   - Quaisquer outras API keys comprometidas

4. **Reiniciar o gateway:**
   ```bash
   openclaw gateway start
   ```

5. **Re-parear nodes:**
   - Todos os nodes precisarão ser pareados novamente com o novo token
   - Verificar com `openclaw nodes status`

6. **Registrar o incidente:**
   - Criar arquivo em `memory/incidents/YYYY-MM-DD-descricao.md`
   - Incluir: o que aconteceu, quando, ações tomadas, status

## Checklist Pós-Rotação

- [ ] Gateway está rodando (`openclaw gateway status`)
- [ ] Novo token está funcional (testar conexão)
- [ ] Chaves antigas foram **revogadas** (não apenas substituídas)
- [ ] Nodes re-pareados e respondendo
- [ ] Nenhum secret antigo em logs ou arquivos de configuração
- [ ] Incidente documentado em `memory/incidents/`
- [ ] MEMORY.md atualizado se relevante
- [ ] Verificar `.bash_history` e limpar se contiver secrets:
  ```bash
  history -c && history -w
  ```
