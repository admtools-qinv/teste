# 02 — CoinGecko: Listagem de Token

> **Projeto:** QINV — Crypto Index Fund na Base Network
> **Token:** QINDEX
> **Vault (Proxy):** `0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d`
> **Chain:** Base (chainId 8453)
> **Website:** https://qinv.ai | **App:** https://app.qinv.ai

---

## 📌 Visão Geral

### O que é CoinGecko

CoinGecko é a **segunda maior plataforma de dados crypto do mundo** (atrás apenas do CoinMarketCap). Agrega preços, volume, market cap e dados de mais de 14.000 tokens. É amplamente usado por investidores, traders, e integrado com centenas de apps e serviços.

### Por que importa para o QINV

- **Visibilidade massiva** — Milhões de visitantes mensais buscando tokens
- **Preço padronizado** — Apps como Zerion, MetaMask e wallets puxam preços do CoinGecko
- **API pública** — Desenvolvedores usam a API do CoinGecko em seus projetos
- **Credibilidade** — "Estar no CoinGecko" é um marco para qualquer projeto
- **Gratuito** — Processo de listagem é totalmente gratuito
- **Cascata** — Zerion tracka tokens automaticamente se estiverem no CoinGecko

### Impacto vs Esforço

| Aspecto | Detalhe |
|---------|---------|
| Impacto | ⭐⭐⭐⭐⭐ (máximo) |
| Dificuldade | Baixa (formulário online) |
| Custo | Grátis |
| Tempo estimado | 2-8 semanas |

---

## ✅ Pré-requisitos Específicos

- [ ] **Contrato verificado no BaseScan** (ver `00-prerequisites.md`) — OBRIGATÓRIO
- [ ] **Token sendo negociado em pelo menos 1 DEX** (Uniswap, Aerodrome, etc. na Base)
- [ ] **Pool com liquidez razoável** — Mínimo ~$5k-$10k recomendado
- [ ] **Volume de trading real** — CoinGecko verifica volume. Sem wash trading!
- [ ] **Website funcional** com informações do projeto
- [ ] **Token sem mecânica de tax exótica** — Tax tokens e honeypots são mais difíceis
- [ ] **Supply data correto on-chain** — `totalSupply()`, `decimals()`, etc.

---

## 🔧 Passo a Passo Completo

### Passo 1: Verificar se já existe pool ativo

Antes de submeter, confirmar que o QINDEX tem trading ativo:

1. Checar no Uniswap: `https://app.uniswap.org/tokens/base/0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d`
2. Ou no DEXScreener: `https://dexscreener.com/base/0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d`
3. Anotar:
   - Endereço do pool/pair
   - Par de trading (ex: QINDEX/WETH)
   - Volume 24h
   - Liquidez total

### Passo 2: Acessar o Formulário

**URL:** https://www.coingecko.com/en/coins/listing

### Passo 3: Preencher os Campos

| Campo | Valor sugerido para QINV |
|-------|--------------------------|
| **Contact email** | team@qinv.ai |
| **Requester relationship** | "I am the founder/team member of the project" |
| **Project name** | QINV |
| **Token symbol** | QINDEX |
| **Project launch date** | [Data real do deploy na Base] |
| **Project description** | "QINV is a decentralized crypto index fund built natively on Base, Coinbase's Layer 2 network. Through the QINDEX vault token, investors gain diversified exposure to a curated basket of top digital assets without the complexity of managing multiple positions. Simply deposit into the vault and receive QINDEX tokens representing your proportional share of the fund. The fund is fully on-chain, non-custodial, and transparent." |
| **Platform** | Base |
| **Contract address** | 0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d |
| **Decimal places** | [Verificar no contrato — provavelmente 18] |
| **Block explorer URL** | https://basescan.org/token/0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d |
| **Website** | https://qinv.ai |
| **Whitepaper/Docs** | [URL da documentação] |
| **Twitter** | [URL do Twitter do projeto] |
| **Discord/Telegram** | [URLs das comunidades] |
| **Trading pairs** | QINDEX/WETH no Uniswap Base (ou DEX relevante) |
| **DEX contract/pair address** | [Endereço do pool na DEX — obter no DEXScreener] |

### Passo 4: Submeter e Aguardar

- Após submissão, CoinGecko envia email de confirmação
- **NÃO reenviar** o formulário — isso pode atrasar o processo
- Guardar o email de confirmação com o ticket/referência

---

## 💡 Dicas Cruciais para Aprovação

1. **Volume de trading REAL é essencial** — CoinGecko tem ferramentas anti-wash-trading. Volume fake = rejeição + possível ban.

2. **Supply data precisa bater perfeitamente:**
   - `totalSupply()` no contrato = o que você declara no form
   - `decimals()` precisa estar correto
   - Se tiver circulatingSupply, deve ser verificável

3. **Se já estiver no DefiLlama, MENCIONAR** — "QINV is tracked on DefiLlama: https://defillama.com/protocol/qinv" — isso adiciona credibilidade significativa.

4. **Nunca mentir sobre nada** — Informação falsa = ban permanente do CoinGecko.

5. **Preencher TODOS os campos** — Formulários incompletos vão pro final da fila.

6. **Email com domínio próprio** — `team@qinv.ai` >> `qinvproject@gmail.com`

---

## 🚀 Programa Fast Track (Listagem Acelerada)

CoinGecko oferece review acelerado para projetos que atendem critérios:

| Critério | Status QINV |
|----------|-------------|
| TVL > $1M | ❌ (~$22 atualmente) |
| Listado em CEX | ❌ |
| Audit de empresa reconhecida | ❓ Verificar |
| Parceiros/investidores relevantes | ❓ Verificar |
| Grande comunidade | ❓ Verificar |

**Conclusão para QINV:** Provavelmente entrará pela fila normal, a menos que haja parceiros ou audit significativo.

---

## ⚠️ Motivos Comuns de Rejeição

| Motivo | Como evitar |
|--------|------------|
| Sem liquidez/volume | Garantir pool ativo com liquidez mínima de ~$5k |
| Contrato não verificado | Verificar ANTES de submeter (ver `00-prerequisites.md`) |
| Projeto muito novo | CoinGecko pode esperar semanas para projetos < 1 mês |
| Info incompleta | Preencher absolutamente TODOS os campos |
| Token com mecânica suspeita | Tax tokens, honeypots, rebases exóticos são red flags |
| Submissão duplicada | Não reenviar se já foi submetido |
| Supply data inconsistente | Garantir que números on-chain batem com o declarado |

---

## 📬 Pós-Listagem

### Primeiros passos após aprovação

1. **Acessar o CoinGecko Developer Dashboard** para gerenciar a listagem
2. **Adicionar/atualizar logo** — Upload de alta qualidade
3. **Verificar links** — Site, Twitter, Discord, Docs
4. **Adicionar categorias** — Solicitar inclusão em:
   - "Index" / "Index Tokens"
   - "DeFi"
   - "Base Ecosystem"
5. **Verificar supply data** — Confirmar que market cap e supply estão corretos

### Manutenção contínua

- Atualizar informações quando houver mudanças (novo site, novos links)
- Monitorar se o preço está sendo trackado corretamente
- Verificar se o volume reportado bate com a realidade
- Responder a eventuais solicitações do time do CoinGecko

### Integração com outras plataformas

Após listagem no CoinGecko:
- **Zerion** — Começará a trackar o token automaticamente (preço + balance)
- **DefiLlama** — Adicionar o CoinGecko ID no PR/protocolo
- **CoinMarketCap** — Mencionar a listagem no CoinGecko na submissão
- **Wallets** — MetaMask, Trust Wallet e outros usam preço do CoinGecko

---

## 📅 Timeline Detalhada

| Etapa | Tempo estimado |
|-------|---------------|
| Preparar materiais | 1-2 horas |
| Preencher formulário | 30 min |
| Confirmação de recebimento | 1-3 dias |
| Review inicial | 1-2 semanas |
| Aprovação/Rejeição | 1-6 semanas adicionais |
| **Total** | **2-8 semanas** |

**Nota:** Projetos com mais tração (TVL, volume, comunidade) são priorizados. Com TVL baixo (~$22), pode levar mais tempo.

---

## 🔗 Links e Referências

| Recurso | URL |
|---------|-----|
| Formulário de Listagem | https://www.coingecko.com/en/coins/listing |
| CoinGecko Developer Dashboard | https://www.coingecko.com/en/developers/dashboard |
| CoinGecko API | https://www.coingecko.com/en/api |
| FAQ de Listagem | https://www.coingecko.com/en/faq |
| DEXScreener (verificar pool) | https://dexscreener.com/base/0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d |
| BaseScan - QINV | https://basescan.org/address/0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d |
| Website QINV | https://qinv.ai |
| App QINV | https://app.qinv.ai |
