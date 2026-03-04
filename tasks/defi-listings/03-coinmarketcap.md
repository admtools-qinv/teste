# 03 — CoinMarketCap: Listagem de Token

> **Projeto:** QINV — Crypto Index Fund na Base Network
> **Token:** QINDEX
> **Vault (Proxy):** `0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d`
> **Chain:** Base (chainId 8453)
> **Website:** https://qinv.ai | **App:** https://app.qinv.ai

---

## 📌 Visão Geral

### O que é CoinMarketCap

CoinMarketCap (CMC) é a **maior plataforma de dados crypto do mundo** (propriedade da Binance). Agrega preços, volume, market cap e rankings de milhares de tokens. É referência para mídia, investidores institucionais e reguladores.

### Por que importa para o QINV

- **A maior referência de dados crypto** — Site mais visitado do setor
- **Credibilidade institucional** — Investidores e fundos usam CMC como fonte primária
- **Integração com Binance** — Dados do CMC alimentam o ecossistema Binance
- **Widget e API** — Amplamente integrado em sites, apps e plataformas
- **Gratuito** — Processo de listagem é gratuito (ignorar "consultores" que cobram)

### Impacto vs Esforço

| Aspecto | Detalhe |
|---------|---------|
| Impacto | ⭐⭐⭐⭐ |
| Dificuldade | Baixa (formulário online) |
| Custo | Grátis |
| Tempo estimado | 4-12 semanas (CMC é notoriamente lento) |

---

## ✅ Pré-requisitos Específicos

- [ ] **Contrato verificado no BaseScan** (ver `00-prerequisites.md`) — OBRIGATÓRIO
- [ ] **Token sendo negociado em pelo menos 1 exchange** (DEX conta)
- [ ] **Volume de trading real** — CMC é MAIS RÍGIDO que CoinGecko nisso
- [ ] **Website funcional** com documentação completa
- [ ] **Block explorer funcional** (BaseScan ✅)
- [ ] **Supply data acessível on-chain** — `totalSupply()`, `decimals()`, `balanceOf()`
- [ ] **Email com domínio próprio** — NÃO usar Gmail/Hotmail
- [ ] **De preferência, já listado no CoinGecko** — Ajuda na credibilidade

---

## 🔧 Passo a Passo Completo

### Passo 1: Acessar o Formulário

**URL de suporte:** https://support.coinmarketcap.com/hc/en-us/articles/360043659351

**Formulário direto:** https://www.coinmarketcap.com/currencies/listing/

### Passo 2: Preencher os Campos

| Campo | Valor sugerido para QINV |
|-------|--------------------------|
| **Subject** | "New Cryptocurrency Listing Request - QINDEX" |
| **Requester email** | team@qinv.ai |
| **Relationship to project** | "Founder" ou "Core Team" |
| **Project name** | QINV |
| **Token/Coin symbol** | QINDEX |
| **One-liner description** | "Crypto index fund on Base providing diversified exposure via a single vault token" |
| **Detailed description** | [Descrição completa — ver abaixo] |
| **Platform** | Base |
| **Contract address** | 0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d |
| **Number of decimal places** | [Verificar no contrato — provavelmente 18] |
| **Date of launch** | [Data real do deploy] |
| **Is the project a fork?** | [Sim/Não — se sim, qual] |
| **Website** | https://qinv.ai |
| **Whitepaper** | [URL da documentação/whitepaper] |
| **Explorer** | https://basescan.org/token/0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d |
| **Source code** | [URL do GitHub público] |
| **Community** | [Discord, Telegram — URLs] |
| **Twitter** | [URL do Twitter do projeto] |
| **Max supply** | [Valor ou "Unlimited" se não tiver cap] |
| **Total supply** | [Valor on-chain — ler de totalSupply()] |
| **Circulating supply** | [Valor real ou "Self-reported"] |
| **Supply API endpoint** | [Se tiver — ver seção abaixo] |
| **Exchange(s)** | "Uniswap V3 (Base)", "Aerodrome (Base)", etc. |
| **Trading pair(s)** | QINDEX/WETH, QINDEX/USDC, etc. |

### Descrição detalhada sugerida:

```
QINV is a decentralized crypto index fund built natively on Base, Coinbase's Layer 2 network.

Through the QINDEX vault token, investors gain diversified exposure to a curated basket of
top digital assets without the complexity of managing multiple positions. Simply deposit into
the vault and receive QINDEX tokens representing your proportional share of the fund.

Key features:
- Fully on-chain, non-custodial, and transparent
- Built on Base (Coinbase L2) for low fees and fast transactions
- Single token exposure to a diversified crypto portfolio
- Auditable holdings visible on BaseScan at any time

Category: DeFi, Index Fund, Asset Management
```

---

## 📊 Self-Reported Circulating Supply

CoinMarketCap permite "self-reported" supply. Para dados mais precisos e automáticos:

### Opção 1: Endpoint API (Recomendado)

Criar um endpoint que retorne o circulating supply:

```
GET https://api.qinv.ai/circulating-supply
→ Response: 1000000 (número puro, sem formatação)
```

```
GET https://api.qinv.ai/total-supply
→ Response: 10000000
```

### Opção 2: Cálculo On-Chain

```
Circulating Supply = totalSupply() - balanceOf(excludedAddresses)
```

Endereços excluídos tipicamente:
- Treasury
- Team vesting
- Burn address (0x0000...dead)
- Contratos de lock

### Opção 3: Self-Reported

Se não tiver endpoint, marcar como "Self-reported" e informar o valor manualmente. CMC permite isso mas prefere dados automatizados.

---

## 💡 Dicas Cruciais para Aprovação

1. **CMC é MUITO mais lento que CoinGecko** — Paciência é essencial. Não reenviar.

2. **NÃO pagar "consultores" que prometem listagem rápida** — São SCAM. O processo do CMC é gratuito.

3. **Volume de trading real ajuda DEMAIS** — CMC prioriza tokens com volume consistente.

4. **Se já estiver no CoinGecko/DefiLlama, MENCIONAR:**
   ```
   "QINDEX is already tracked on:
   - CoinGecko: https://www.coingecko.com/en/coins/qindex
   - DefiLlama: https://defillama.com/protocol/qinv"
   ```

5. **Email com domínio próprio** — `team@qinv.ai` passa muito mais confiança que Gmail.

6. **Supply data consistente** — Os números PRECISAM bater entre o form, o contrato e o explorer.

7. **Documentação completa** — CMC valoriza projetos com whitepaper/docs detalhados.

---

## ⚠️ Motivos Comuns de Rejeição

| Motivo | Como evitar |
|--------|------------|
| Volume insuficiente | CMC exige volume real e consistente |
| Supply data inconsistente | Números on-chain devem bater com o declarado |
| Projeto muito novo sem tração | CMC prioriza projetos com comunidade ativa |
| Info incompleta ou errada | Preencher ABSOLUTAMENTE todos os campos |
| Sem exchange listing verificável | Ter pelo menos 1 DEX com pool ativo |
| Contrato não verificado | Verificar antes de submeter |
| Email genérico (Gmail) | Usar email com domínio do projeto |
| Reenvio do formulário | Não resubmeter — atrasa o processo |

---

## 📬 Pós-Listagem

### Primeiros passos após aprovação

1. **Verificar dados** — Market cap, supply, preço estão corretos?
2. **Adicionar logo** — Upload pelo dashboard do CMC
3. **Atualizar links** — Site, Twitter, Discord, Docs
4. **Categorias** — Solicitar inclusão em:
   - "DeFi"
   - "Index Tokens"
   - "Base Ecosystem"
5. **Conectar supply API** — Se criou o endpoint, vincular

### Manutenção contínua

- Atualizar informações quando houver mudanças
- Monitorar se preço e volume estão corretos
- Responder solicitações do time CMC prontamente
- Manter supply data atualizado

### Integração com outras plataformas

Após listagem no CMC:
- **DefiLlama** — Adicionar o CoinMarketCap ID no protocolo
- **Portfólios** — Usuários poderão trackar QINDEX em apps que usam CMC API
- **Mídia** — Dados do CMC são usados por jornalistas e analistas

---

## 📅 Timeline Detalhada

| Etapa | Tempo estimado |
|-------|---------------|
| Preparar materiais e supply API | 1-2 dias |
| Preencher formulário | 1 hora |
| Confirmação de recebimento | 1-7 dias |
| Review inicial | 2-4 semanas |
| Aprovação/Rejeição | 2-8 semanas adicionais |
| **Total** | **4-12 semanas** |

**Nota:** CMC é notoriamente lento. Pode demorar meses para projetos menores. Ter CoinGecko listing primeiro ajuda a acelerar.

---

## 🔗 Links e Referências

| Recurso | URL |
|---------|-----|
| Formulário de Listagem | https://www.coinmarketcap.com/currencies/listing/ |
| Artigo de Suporte | https://support.coinmarketcap.com/hc/en-us/articles/360043659351 |
| CMC API | https://coinmarketcap.com/api/ |
| Metodologia CMC | https://support.coinmarketcap.com/hc/en-us/categories/360002344932 |
| BaseScan - QINV | https://basescan.org/address/0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d |
| Website QINV | https://qinv.ai |
| App QINV | https://app.qinv.ai |
