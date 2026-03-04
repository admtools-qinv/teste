# Plano: Resolver 3 Gaps Reais

## Gap 1: Web Search (Brave API Key)

### Problema
`web_search` retorna erro `missing_brave_api_key`. Sem isso, não consigo pesquisar na web.

### Análise
- OpenClaw suporta: Brave (default), Perplexity, Gemini, Grok
- Auto-detecção por ordem: Brave → Gemini → Perplexity → Grok
- Configuração: `BRAVE_API_KEY` env var OU `tools.web.search.apiKey` no config
- Brave free tier: 2000 queries/mês (suficiente pro nosso uso)
- **Alternativa**: Se Aragorn já tem GEMINI_API_KEY, pode usar Gemini sem custo adicional

### Plano
1. Verificar se já tem alguma API key de search (Gemini, etc.) no ambiente
2. Se não: pedir pro Aragorn criar em https://brave.com/search/api/
3. Configurar via `openclaw configure --section web` ou direto no JSON
4. Testar com uma busca simples
5. Verificar rate limits

### Dependência: **Aragorn precisa fornecer API key** (não posso criar conta por ele)

---

## Gap 2: Git Identity

### Problema
Commits saem como `Ubuntu <ubuntu@ivi-fabricio...>` — sem identificação útil.

### Análise
- Nenhum `user.name` ou `user.email` configurado (global ou local)
- Aragorn = Fabricio
- Bom ter email real pra caso de remote futuro

### Plano
1. Perguntar nome/email pro git (ou usar defaults razoáveis)
2. `git config --global user.name "Fabricio"` (ou nome completo)
3. `git config --global user.email "email@example.com"`
4. Opcionalmente: `git commit --amend --reset-author` nos commits existentes
5. Verificar com `git log --oneline`

### Dependência: **Aragorn precisa confirmar nome/email**

---

## Gap 3: Compaction + Memory Flush

### Problema
- Compaction está em modo `safeguard` (mínimo)
- Sem `memoryFlush` configurado — quando sessão compacta, pode perder contexto sem salvar
- Modelo tem 200k ctx, então compaction é raro, mas quando acontece é catastrófico sem flush

### Análise (da documentação)
- `memoryFlush` é um turn silencioso pré-compaction que manda o modelo salvar notas em memory/
- Config em `agents.defaults.compaction.memoryFlush`
- Campos: `enabled`, `softThresholdTokens`, `systemPrompt`, `prompt`
- `reserveTokensFloor` define margem de segurança (default 20000)

### Plano
1. Configurar compaction completa no openclaw.json:
```json
{
  "compaction": {
    "mode": "safeguard",
    "reserveTokensFloor": 20000,
    "memoryFlush": {
      "enabled": true,
      "softThresholdTokens": 4000,
      "systemPrompt": "Session nearing compaction. Store durable memories now.",
      "prompt": "Write any lasting notes to memory/YYYY-MM-DD.md. Include key decisions, context, and lessons. Reply with NO_REPLY if nothing to store."
    }
  }
}
```
2. Reiniciar gateway (ou aguardar próximo restart)
3. Verificar com `openclaw status --deep` que a config foi aplicada

### Dependência: **Nenhuma** — posso executar sozinho

---

## Review do Plano

### ✅ O que está bom
- Gap 3 é totalmente autônomo, pode executar agora
- Planos são incrementais e reversíveis

### ⚠️ Ajustes necessários
- Gap 1: Devo verificar PRIMEIRO se o Aragorn já tem alguma key (Gemini?) que funcione
- Gap 2: Posso sugerir defaults (nome do workspace = Clawdemir pro bot, Fabricio pro user)
- Gap 3: O prompt de flush deve ser em português pra manter consistência

### Versão ajustada do Gap 3 prompt:
```
"systemPrompt": "Sessão próxima de compaction. Salve memórias duráveis agora.",
"prompt": "Escreva notas importantes em memory/YYYY-MM-DD.md. Inclua decisões-chave, contexto e lições. Responda NO_REPLY se não há nada pra salvar."
```

## Ordem de Execução
1. **Gap 3** (autônomo) → agente executa direto
2. **Gap 1** (precisa input) → agente prepara tudo, pede API key
3. **Gap 2** (precisa input) → agente prepara, pede nome/email
