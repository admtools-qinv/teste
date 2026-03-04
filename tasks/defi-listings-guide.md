# Guia Completo de Listagem — QINV / QINDEX

> **Projeto:** QINV — Crypto Index Fund na Base Network
> **Token:** QINDEX
> **Vault Contract:** `0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d`
> **Chain:** Base (chainId: 8453)
> **Última atualização:** 2026-02-24

---

## 📋 Preparação Global (Fazer ANTES de Qualquer Listagem)

Antes de submeter qualquer coisa, tenha esses materiais prontos:

### Checklist de Assets

- [ ] **Logo em SVG** (quadrado, mínimo 128×128px, bordas arredondadas ficam bem)
- [ ] **Logo em PNG** (256×256px e 64×64px — alguns sites pedem PNG)
- [ ] **Descrição curta** (máx 200 chars): ex. "QINV is a crypto index fund on Base offering diversified exposure via the QINDEX vault token."
- [ ] **Descrição longa** (2-3 parágrafos explicando o produto, estratégia, diferencial)
- [ ] **Website** com domínio próprio (HTTPS obrigatório)
- [ ] **Twitter/X** ativo com posts recentes
- [ ] **Discord ou Telegram** da comunidade
- [ ] **Docs/Gitbook** com documentação técnica
- [ ] **Contrato verificado no BaseScan** — absolutamente essencial
- [ ] **Audit report** (se tiver — acelera MUITO aprovações)
- [ ] **Endereço de email oficial** (ex: team@qinv.xyz)
- [ ] **GitHub público** com código do contrato

### Verificação do Contrato no BaseScan

Se ainda não verificou:
1. Ir em https://basescan.org/address/0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d
2. Aba "Contract" → "Verify and Publish"
3. Escolher o compiler version correto e colar o source code
4. Isso é **pré-requisito** pra quase todas as plataformas

---

## 🏆 Ordem de Prioridade

| # | Plataforma | Impacto | Dificuldade | Custo | Tempo |
|---|-----------|---------|-------------|-------|-------|
| 1 | DefiLlama | ⭐⭐⭐⭐⭐ | Média (código) | Grátis | 2-7 dias |
| 2 | CoinGecko | ⭐⭐⭐⭐⭐ | Baixa (form) | Grátis | 2-8 semanas |
| 3 | Base Ecosystem | ⭐⭐⭐⭐ | Baixa (PR) | Grátis | 1-4 semanas |
| 4 | CoinMarketCap | ⭐⭐⭐⭐ | Baixa (form) | Grátis* | 4-12 semanas |
| 5 | DappRadar | ⭐⭐⭐ | Baixa (form) | Grátis/Pago | 1-4 semanas |
| 6 | Zapper | ⭐⭐⭐ | Alta (técnica) | Grátis | 2-8 semanas |
| 7 | Zerion | ⭐⭐⭐ | Alta (técnica) | Grátis | 2-8 semanas |
| 8 | Safe Apps | ⭐⭐ | Alta (dev) | Grátis | 4-12 semanas |
| 9 | Coinbase Wallet | ⭐⭐ | Incerta | Grátis | Indefinido |

**Fazer 1-3 primeiro (paralelo), depois 4-5, depois 6-9.**

---

## 1. DefiLlama — Tracking de TVL

### Por que é prioridade #1
DefiLlama é O padrão da indústria pra TVL. CoinGecko e CoinMarketCap puxam dados de lá. Estar no DefiLlama = credibilidade instantânea.

### Processo: Pull Request no GitHub

**URL:** https://github.com/DefiLlama/DefiLlama-Adapters

### Passo a Passo

#### 1.1 Fork do Repositório

```bash
# Clonar o fork
git clone https://github.com/SEU-USER/DefiLlama-Adapters.git
cd DefiLlama-Adapters
npm install
```

#### 1.2 Criar o Adapter

Criar arquivo: `projects/qinv/index.js`

Para um vault/index fund na Base, o adapter precisa ler o TVL on-chain. Aqui está um exemplo baseado no padrão de vaults (como Yearn):

```javascript
const { sumTokens2 } = require('../helper/unwrapLPs');

// Vault principal do QINV na Base
const QINV_VAULT = '0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d';

async function tvl(api) {
  // Opção A: Se o vault tem uma função totalAssets() que retorna o valor total
  // e uma função asset() que retorna o token base
  // const totalAssets = await api.call({ abi: 'uint256:totalAssets', target: QINV_VAULT });
  // const asset = await api.call({ abi: 'address:asset', target: QINV_VAULT });
  // api.add(asset, totalAssets);

  // Opção B: Se o vault detém múltiplos tokens (index fund)
  // Listar os tokens que o vault contém e usar sumTokens2
  // Isso lê os balances ERC20 diretamente do contrato
  const tokens = [
    // Adicionar aqui os endereços dos tokens que o vault detém na Base
    // Exemplo:
    // '0x4200000000000000000000000000000000000006', // WETH
    // '0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913', // USDC
    // '0x50c5725949A6F0c72E6C4a641F24049A917DB0Cb', // DAI
  ];

  return sumTokens2({
    api,
    owner: QINV_VAULT,
    tokens,
    // Se o vault também tem ETH nativo:
    // fetchCoValentTokens: true,
  });

  // Opção C: Se o vault tem getUnderlyingBalances() ou similar
  // Adaptar conforme a ABI real do contrato
}

module.exports = {
  methodology: 'TVL is calculated by summing all underlying assets held in the QINV vault contract.',
  base: {
    tvl,
  },
};
```

**⚠️ IMPORTANTE:** Adaptar o código acima para a ABI real do contrato vault. Verificar no BaseScan quais funções o vault expõe:
- Se for ERC-4626: usar `totalAssets()` + `asset()`
- Se for multi-asset: listar os tokens e usar `sumTokens2` com `owner`
- Se tiver função customizada (ex: `getHoldings()`): adaptar

#### 1.3 Testar Localmente

```bash
# Testar o adapter (deve retornar TVL sem erros)
node test.js projects/qinv/index.js

# Se precisar de RPC customizada, criar .env:
# BASE_RPC="https://mainnet.base.org"
```

O teste deve printar algo como:
```
base --- tvl --- 
{
  "0x4200000000000000000000000000000000000006": "1500000000000000000",
  "0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913": "5000000000"
}
```

#### 1.4 Submeter PR

Ir em https://github.com/DefiLlama/DefiLlama-Adapters/compare e criar PR do seu fork.

**OBRIGATÓRIO:** Marcar ✅ "Allow edits by maintainers"

#### Template do PR (preencher todos os campos):

```markdown
##### Name (to be shown on DefiLlama):
QINV

##### Twitter Link:
https://twitter.com/QINV_HANDLE

##### List of audit links if any:
[Link do audit se existir, ou "No audit yet"]

##### Website Link:
https://qinv.xyz

##### Logo (High resolution, will be shown with rounded borders):
[URL direta para a logo SVG/PNG - hospedar no GitHub ou site]

##### Current TVL:
$XXX,XXX (atualizar com valor real)

##### Treasury Addresses (if the protocol has treasury):
[Endereço da treasury se tiver, ou N/A]

##### Chain:
Base

##### Coingecko ID:
[Deixar vazio se não listado ainda]

##### Coinmarketcap ID:
[Deixar vazio se não listado ainda]

##### Short Description (to be shown on DefiLlama):
QINV is a crypto index fund on Base providing diversified exposure to top digital assets through the QINDEX vault token.

##### Token address and ticker if any:
QINDEX - 0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d (Base)

##### Category:
Indexes

##### Oracle Provider(s):
[Especificar qual oracle usa, ex: Chainlink, Pyth, ou "None"]

##### Forked from:
[Se fork de outro protocolo, mencionar. Se original: "No"]

##### Methodology:
TVL is calculated by reading the underlying token balances held in the QINV vault contract on Base.
```

### Motivos Comuns de Rejeição

1. **TVL calculado via fetch/API** — DefiLlama exige que TVL seja lido on-chain. Nunca usar fetch() no adapter
2. **package-lock.json editado** — Não fazer commit deste arquivo
3. **npm packages adicionais** — Não adicionar dependências, usar só o SDK deles
4. **"Allow edits by maintainers" desmarcado** — Eles editam adapters frequentemente
5. **TVL muito baixo** — Não tem mínimo oficial, mas <$10k pode ser ignorado
6. **Logo faltando ou baixa qualidade**

### Pós-Listagem

- TVL aparece em ~24h após merge (pode demorar mais)
- Se >24h, pedir no Discord: https://discord.defillama.com/
- Para atualizar info do protocolo depois: editar em https://github.com/DefiLlama/defillama-server/blob/master/defi/src/protocols/data2.ts
- Monitorar se o adapter quebra (DefiLlama desativa adapters que dão erro)

### Timeline
- PR review: 1-3 dias úteis
- Merge: 2-5 dias
- Aparecer no UI: +24h após merge
- **Total: ~2-7 dias**

---

## 2. CoinGecko — Listagem de Token

### Por que é prioridade #2
CoinGecko é a segunda maior plataforma de dados crypto. Ter o QINDEX listado lá = visibilidade massiva, dados de preço padronizados, e integração automática com centenas de apps.

### Processo: Formulário Online

**URL do formulário:** https://www.coingecko.com/en/coins/listing

### Passo a Passo

#### 2.1 Pré-requisitos

- [ ] Token já sendo negociado em pelo menos 1 DEX (ex: Uniswap, Aerodrome na Base)
- [ ] Pool com liquidez razoável (mínimo ~$5k-10k recomendado)
- [ ] Contrato verificado no BaseScan
- [ ] Website funcional com info do projeto
- [ ] Token não ser rebase ou ter mecânica de tax exótica (esses são mais difíceis)

#### 2.2 Preenchimento do Formulário

Acessar: **https://www.coingecko.com/en/coins/listing**

Campos a preencher:

| Campo | O que colocar |
|-------|--------------|
| **Contact email** | team@qinv.xyz |
| **Requester relationship** | "I am the founder/team member of the project" |
| **Project name** | QINV |
| **Token symbol** | QINDEX |
| **Project launch date** | [Data real do deploy] |
| **Project description** | Descrição longa do projeto |
| **Platform/Contract address** | Base / 0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d |
| **Decimal places** | [Verificar no contrato, provavelmente 18] |
| **Block explorer URL** | https://basescan.org/token/0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d |
| **Website** | https://qinv.xyz |
| **Whitepaper/Docs** | [URL da documentação] |
| **Twitter** | [URL do Twitter] |
| **Discord/Telegram** | [URLs] |
| **Trading pairs** | [Listar pares: ex. QINDEX/WETH no Uniswap Base] |
| **DEX contract/pair address** | [Endereço do pool na DEX] |

#### 2.3 Dicas Cruciais

1. **Token PRECISA ter volume de trading real** — CoinGecko verifica isso. Sem wash trading.
2. **Supply data precisa bater** — totalSupply(), circulatingSupply se tiver, etc.
3. **Se tiver no DefiLlama, mencionar** — ajuda na credibilidade
4. **Não mentir sobre nada** — rejeição por info falsa = ban permanente

### Motivos Comuns de Rejeição

1. **Sem liquidez/volume** — Precisa ter trading ativo em DEX
2. **Contrato não verificado** — Obrigatório ter source code público
3. **Projeto muito novo** — CoinGecko pode esperar semanas pra projetos < 1 mês
4. **Info incompleta** — Preencher TODOS os campos
5. **Token com mecânica suspeita** — Tax tokens, honeypots, etc.
6. **Duplicata** — Se o token já foi submetido por outra pessoa

### Listagem Acelerada

CoinGecko tem um programa "Fast Track" para projetos com:
- TVL significativo (>$1M ajuda muito)
- Listagem em CEX
- Audit de empresa reconhecida
- Parceiros/investidores relevantes

Sem isso, a fila normal pode demorar semanas.

### Pós-Listagem

- Atualizar info pelo CoinGecko developer dashboard
- Adicionar logo, links, categorias
- Verificar se supply data está correto
- Pedir inclusão na categoria "Index" ou "DeFi"

### Timeline
- Submissão → Review: 1-2 semanas
- Review → Listagem: 1-6 semanas adicionais
- **Total: 2-8 semanas** (pode ser mais rápido com tração)

---

## 3. Base Ecosystem Directory

### Por que é prioridade #3
Estar na página oficial do ecossistema Base (https://base.org/ecosystem) = selo de aprovação do próprio time da Base/Coinbase. Alto valor de credibilidade, e geralmente rápido.

### Processo: Pull Request no GitHub

**URL do repositório:** https://github.com/base-org/web

O diretório do ecossistema é um JSON em:
`apps/web/src/data/ecosystem.json`

### Passo a Passo

#### 3.1 Fork e Clone

```bash
git clone https://github.com/SEU-USER/web.git
cd web
```

#### 3.2 Adicionar Entry no JSON

Editar `apps/web/src/data/ecosystem.json` e adicionar um objeto seguindo o formato exato:

```json
{
  "name": "QINV",
  "description": "A crypto index fund providing diversified exposure to top digital assets through the QINDEX vault token. Invest in the market with a single token.",
  "url": "https://qinv.xyz",
  "imageUrl": "/images/partners/qinv.webp",
  "category": "defi",
  "subcategory": "index"
}
```

**Categorias válidas observadas:** `defi`, `consumer`, `infra`, `onchain-game`
**Subcategorias DeFi observadas:** `dex`, `lending`, `bridge`, `dex aggregator`, `index`, `yield`, `derivatives`

#### 3.3 Adicionar Logo

- Colocar a imagem em `apps/web/public/images/partners/qinv.webp`
- Formato preferido: WebP
- Tamanho: ~200×200px funciona bem
- Pode ser PNG se necessário

#### 3.4 Submeter PR

```bash
git checkout -b add-qinv-ecosystem
git add .
git commit -m "feat: add QINV to ecosystem directory"
git push origin add-qinv-ecosystem
```

Na PR description:

```markdown
## Add QINV to Base Ecosystem

**Project:** QINV - Crypto Index Fund
**Category:** DeFi / Index
**Website:** https://qinv.xyz
**Contract:** 0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d

QINV is a crypto index fund built natively on Base, offering diversified exposure
to top digital assets through the QINDEX vault token.

- Live on Base mainnet since [DATA]
- TVL: $XXX,XXX
- [Link para DefiLlama se já listado]
```

### Motivos Comuns de Rejeição
1. **Projeto não está live na Base** — Precisa estar deployed e funcional
2. **Logo em formato errado** — Usar WebP ou PNG, tamanho adequado
3. **Descrição muito longa/curta** — Manter conciso e informativo
4. **Categoria errada**
5. **JSON mal formatado** — Validar com `jq` antes de commitar

### Timeline
- PR review: 1-2 semanas
- **Total: 1-4 semanas**

---

## 4. CoinMarketCap — Listagem de Token

### Processo: Formulário Online

**URL:** https://support.coinmarketcap.com/hc/en-us/articles/360043659351
**Form direto:** https://www.coinmarketcap.com/currencies/listing/

### Passo a Passo

#### 4.1 Pré-requisitos

- [ ] Token sendo negociado em pelo menos 1 exchange (DEX conta)
- [ ] Volume de trading real (CMC é mais rígido que CoinGecko nisso)
- [ ] Website funcional com documentação
- [ ] Contrato verificado
- [ ] Block explorer funcional (BaseScan ✅)
- [ ] Supply data acessível on-chain (totalSupply, etc.)

#### 4.2 Campos do Formulário

| Campo | O que colocar |
|-------|--------------|
| **Subject** | "New Cryptocurrency Listing Request - QINDEX" |
| **Requester email** | team@qinv.xyz |
| **Relationship to project** | "Founder" ou "Core Team" |
| **Project name** | QINV |
| **Token/Coin symbol** | QINDEX |
| **One-liner description** | "Crypto index fund on Base providing diversified exposure via a single vault token" |
| **Detailed description** | [Descrição completa] |
| **Platform** | Base |
| **Contract address** | 0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d |
| **Number of decimal places** | [Verificar no contrato] |
| **Date of launch** | [Data real] |
| **Is the project a fork?** | [Sim/Não e qual] |
| **Website** | https://qinv.xyz |
| **Whitepaper** | [URL] |
| **Explorer** | https://basescan.org/token/0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d |
| **Source code** | [GitHub URL] |
| **Community** | [Discord, Telegram] |
| **Twitter** | [URL] |
| **Max supply** | [Valor ou "Unlimited"] |
| **Total supply** | [Valor on-chain] |
| **Circulating supply** | [Valor real ou "Self-reported"] |
| **Supply API endpoint** | [Se tiver endpoint que retorna supply] |
| **Exchange(s)** | [Listar: "Uniswap V3 (Base)", "Aerodrome", etc.] |
| **Trading pair(s)** | [QINDEX/WETH, QINDEX/USDC, etc.] |

#### 4.3 Self-Reported Circulating Supply

CMC permite "self-reported" supply. Ideal é ter:
1. Um endpoint API que retorne o circulating supply: `GET https://api.qinv.xyz/circulating-supply`
2. Ou usar on-chain: `totalSupply() - balanceOf(excludedAddresses)`

#### 4.4 Dicas

1. **CMC é MUITO mais lento que CoinGecko** — paciência
2. **Não pagar "consultores" que prometem listagem rápida** — são scam
3. **Ter volume real de trading ajuda demais**
4. **Se já estiver no CoinGecko/DefiLlama, mencionar na application**
5. **Email com domínio próprio** (não Gmail) passa mais confiança

### Motivos Comuns de Rejeição

1. **Volume insuficiente** — CMC é rígido com isso
2. **Supply data inconsistente** — Certifique-se que os números batem
3. **Projeto muito novo sem tração** — CMC prioriza projetos com comunidade
4. **Info incompleta ou errada**
5. **Sem exchange listing verificável**

### Timeline
- **Total: 4-12 semanas** (CMC é notoriamente lento)
- Pode demorar meses para projetos menores
- Listagem no CoinGecko primeiro pode ajudar a acelerar

---

## 5. DappRadar — Tracking de DApps

### Processo: Formulário Online

**URL:** https://dappradar.com/dashboard/submit-dapp

### Passo a Passo

#### 5.1 Criar Conta

1. Ir em https://dappradar.com
2. Criar conta (pode usar wallet connect)
3. Acessar Developer Dashboard

#### 5.2 Formulário de Submissão

Campos a preencher:

| Campo | O que colocar |
|-------|--------------|
| **DApp name** | QINV |
| **Category** | DeFi |
| **Sub-category** | Asset Management / Index |
| **Short description** | Crypto index fund on Base - diversified exposure via QINDEX token |
| **Full description** | [Descrição completa] |
| **Website URL** | https://qinv.xyz |
| **Blockchain** | Base |
| **Contract addresses** | 0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d |
| **Logo** | [Upload PNG/SVG] |
| **Social links** | [Twitter, Discord, etc.] |

#### 5.3 DappRadar Boost (Opcional/Pago)

DappRadar tem opção paga ("Boost") pra maior visibilidade:
- **Listing básico:** Gratuito
- **Boost:** Pago (varia, geralmente $500-$2000/mês)
- **Featured:** Mais caro, destaque na homepage

Para começar, o listing gratuito é suficiente.

### Motivos Comuns de Rejeição
1. **DApp não funcional** — Precisa estar live e usável
2. **Sem smart contract interação** — Precisa ter on-chain activity
3. **Logo/descrição de baixa qualidade**

### Timeline
- **Review: 1-2 semanas**
- **Total: 1-4 semanas**

---

## 6. Zapper — Portfolio Tracking

### Por que importa
Zapper mostra posições de DeFi no portfolio dos usuários. Se alguém tem QINDEX, aparece com o valor correto e detalhes.

### Processo: Integração Técnica

Zapper usa seu próprio sistema de interpreters para decodar posições DeFi.

#### 6.1 Método Principal: Zapper Studio

**URL:** https://github.com/Zapper-fi/studio

Zapper Studio é o repositório onde integrações de protocolo são adicionadas.

#### 6.2 Passos

1. **Fork** https://github.com/Zapper-fi/studio
2. **Criar app module** seguindo a estrutura existente

```
src/apps/qinv/
├── qinv.module.ts
├── qinv.definition.ts
├── contracts/
│   ├── index.ts
│   └── abis/qinv-vault.json
└── base/
    └── qinv.vault.token-fetcher.ts
```

3. **Definição do app:**

```typescript
// qinv.definition.ts
import { Register } from '~app-toolkit/decorators';
import { appDefinition, AppDefinition } from '~app/app.definition';

export const QINV_DEFINITION = appDefinition({
  id: 'qinv',
  name: 'QINV',
  description: 'Crypto index fund on Base',
  url: 'https://qinv.xyz',
  groups: {
    vault: {
      id: 'vault',
      type: 'TOKEN' as const,
      label: 'Vault',
    },
  },
  tags: ['index-fund', 'vault'],
  keywords: ['index', 'defi'],
  links: {
    twitter: 'https://twitter.com/QINV_HANDLE',
    discord: 'https://discord.gg/QINV',
  },
  supportedNetworks: {
    base: ['vault'],
  },
});
```

4. **Token fetcher** para o vault (lê balance dos usuários)

5. **Submeter PR** com testes

#### 6.3 Método Alternativo: Contato Direto

Se a integração técnica for complexa demais:
1. Entrar no Discord do Zapper
2. Abrir ticket no canal #integrations
3. Descrever o protocolo e pedir ajuda

#### 6.4 Requisito Implícito
- TVL significativo (>$100k ajuda a ser priorizado)
- Contratos verificados
- ABI pública

### Timeline
- **Desenvolvimento: 1-2 semanas**
- **Review: 2-6 semanas**
- **Total: 2-8 semanas**

---

## 7. Zerion — Portfolio Tracking

### Processo: DeFi SDK Adapter + Discord

**GitHub:** https://github.com/zeriontech/defi-sdk

Zerion tem +8000 protocolos integrados. A integração é feita via:

#### 7.1 Opção A: PR no DeFi SDK

O DeFi SDK usa smart contracts "adapters" on-chain. Para tokens simples (ERC-20) o tracking é automático se o token tiver preço no CoinGecko.

**Se o QINDEX já está no CoinGecko → Zerion provavelmente já tracka automaticamente.**

Para posições DeFi complexas (mostrar underlying assets):

1. Criar adapter contract seguindo docs: https://github.com/zeriontech/defi-sdk/blob/router/docs/creating-your-adapters/index.md
2. Submeter PR

#### 7.2 Opção B: Contato via Discord

1. Entrar no Discord Zerion: https://zerion.io/discord
2. Procurar canal de integrações/dev
3. Descrever o protocolo e pedir integração
4. Email alternativo: inbox@zerion.io

#### 7.3 O que preparar

- ABI do contrato vault
- Explicação de como o vault funciona (deposit/withdraw/underlying)
- Lista de tokens que o vault pode conter
- Endereço do contrato na Base

### Dica Importante
Para **portfolio tracking básico** (mostrar QINDEX com valor em USD):
- Basta estar listado no CoinGecko com preço
- Zerion puxa dados do CoinGecko automaticamente
- Não precisa de integração customizada pra isso

Para **mostrar underlying assets** (ex: "Seu QINDEX = 30% ETH + 20% BTC + ..."):
- Aí sim precisa de integração customizada

### Timeline
- **Token simples com CoinGecko: Automático**
- **Integração DeFi customizada: 2-8 semanas**

---

## 8. Safe (Gnosis Safe) Apps

### Por que importa
Se o QINV tem operações de deposit/withdraw, ter um Safe App permite que multisigs e DAOs invistam no QINV diretamente pela interface Safe.

### Processo: Formulário + Desenvolvimento + PR

#### 8.1 Pré-Requisito: Pre-Assessment Form

**⚠️ Desde 01/01/2024, é OBRIGATÓRIO preencher o formulário primeiro.**

**URL:** https://forms.gle/PcDcaVx715LKrrQs8

Não abrir issue no GitHub sem preencher esse form primeiro — será rejeitado.

#### 8.2 Desenvolvimento do Safe App

Usar o template oficial:

```bash
npx create-react-app qinv-safe-app --template @safe-global/cra-template-safe-app
cd qinv-safe-app
```

**Requisitos técnicos:**

1. **manifest.json** na raiz do build:
```json
{
  "name": "QINV Index Fund",
  "iconPath": "qinv-logo.svg",
  "description": "Invest in diversified crypto exposure through the QINV index fund. Deposit and withdraw from the QINDEX vault."
}
```
- Nome: máximo 50 caracteres
- Ícone: SVG quadrado, mínimo 128×128px
- Descrição: máximo 200 caracteres

2. **CORS configurado** no hosting — Safe precisa acessar o manifest.json

3. **Auto-connect** — O app deve detectar automaticamente que está rodando dentro do Safe e conectar a wallet correta

4. **Safe Apps SDK:**
```bash
npm install @safe-global/safe-apps-sdk @safe-global/safe-apps-provider
```

5. **Tracking parameters:**
```
https://qinv.xyz/safe-app/?utm_source=SafeWallet
```

#### 8.3 Requisitos para Aprovação

| Requisito | Detalhe |
|-----------|---------|
| **Audit** | Smart contracts devem ter audit externo. Se usam contratos de terceiros, estes devem ser auditados |
| **Source code** | Enviar link do repo (público ou convite pro privado) |
| **Test plan** | Lista de features + fluxo de teste para QA do Safe |
| **Contract ABI** | Para decodificação de transações (verificar no Sourcify ou fornecer JSON) |
| **Video walkthrough** | Recomendado mas não obrigatório |

#### 8.4 Fluxo de Aprovação

1. ✅ Preencher pre-assessment form
2. 📧 Receber resposta do time Safe
3. 🛠️ Desenvolver o app seguindo os requisitos
4. 🧪 App vai para staging: `https://safe-wallet-web.dev.5afe.dev`
5. 🔍 QA pelo time do Safe
6. 🚀 Deploy em produção

#### 8.5 Testar Antes de Submeter

Qualquer pessoa pode testar um Safe App como "Custom App":
1. Ir em https://app.safe.global
2. Apps → Add custom app
3. Colar a URL do app hospedado
4. Testar todas as funcionalidades

### Timeline
- **Pre-assessment: 1-2 semanas pra resposta**
- **Desenvolvimento: 1-4 semanas**
- **Review + QA: 2-6 semanas**
- **Total: 4-12 semanas**

---

## 9. Coinbase Wallet Discovery

### Status Atual

Coinbase Wallet não tem um processo público e bem documentado de submissão de DApps como as outras plataformas. A integração acontece de formas indiretas:

#### 9.1 Caminhos Possíveis

1. **Base Ecosystem Listing (Item #3)** — Estar na página base.org/ecosystem é o caminho mais direto pra visibilidade no ecossistema Coinbase

2. **Coinbase Asset Listing** — Para listagem do token na exchange Coinbase:
   - URL: https://listing.coinbase.com/
   - Processo altamente seletivo
   - Geralmente requer TVL significativo, comunidade ativa, compliance
   - **Não recomendado tentar agora** — focar em crescer primeiro

3. **Coinbase Wallet DApp Browser** — O wallet mostra DApps baseado em:
   - Popularidade e uso
   - Listagem no Base ecosystem
   - Integração com WalletConnect/Coinbase Wallet SDK

#### 9.2 Ação Recomendada

1. Integrar Coinbase Wallet SDK no site do QINV:
```bash
npm install @coinbase/wallet-sdk
```
2. Completar a listagem no Base Ecosystem (item #3)
3. Quando TVL crescer, avaliar submissão formal

### Timeline
- **Indireto via Base Ecosystem: 1-4 semanas**
- **Listagem direta na Coinbase: Indefinido, depende de tração**

---

## 📝 Templates Prontos

### Template: Email de Introdução (para contatos diretos)

```
Subject: QINV - Crypto Index Fund on Base - Integration Request

Hi team,

I'm [NOME], founder of QINV, a crypto index fund built natively on Base network.

QINV offers diversified exposure to top digital assets through the QINDEX vault
token (0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d).

Key stats:
- TVL: $XXX,XXX
- Users: XXX
- Live since: [DATA]
- Chain: Base (Coinbase L2)
- Verified contract: https://basescan.org/address/0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d

We'd love to explore integration with [PLATAFORMA]. Happy to provide any
technical details, ABIs, or documentation needed.

Links:
- Website: https://qinv.xyz
- Docs: [URL]
- Twitter: [URL]
- GitHub: [URL]

Best regards,
[NOME]
```

### Template: Descrição Curta (200 chars)

```
QINV is a crypto index fund on Base offering diversified exposure to top digital assets through the QINDEX vault token. One token, full market coverage.
```

### Template: Descrição Longa

```
QINV is a decentralized crypto index fund built natively on Base, Coinbase's Layer 2 network.

Through the QINDEX vault token, investors gain diversified exposure to a curated basket of top
digital assets without the complexity of managing multiple positions. Simply deposit into the
vault and receive QINDEX tokens representing your proportional share of the fund.

The fund is fully on-chain, non-custodial, and transparent — anyone can verify the underlying
holdings at any time through the smart contract on BaseScan.
```

---

## 🗓️ Cronograma Sugerido de Execução

### Semana 1
- [ ] Preparar todos os assets (logo, descrições, docs)
- [ ] Verificar contrato no BaseScan (se não feito)
- [ ] Desenvolver e testar adapter do DefiLlama
- [ ] Submeter PR no DefiLlama
- [ ] Submeter PR no Base Ecosystem

### Semana 2
- [ ] Preencher formulário CoinGecko
- [ ] Preencher formulário CoinMarketCap
- [ ] Submeter DappRadar
- [ ] Follow-up no DefiLlama PR se necessário

### Semana 3-4
- [ ] Preencher pre-assessment form do Safe
- [ ] Iniciar integração Zapper (se TVL justificar)
- [ ] Contato Discord Zerion (se necessário)
- [ ] Monitorar status de todas as submissões

### Semana 5+
- [ ] Follow-up em listagens pendentes
- [ ] Desenvolver Safe App (se aprovado no pre-assessment)
- [ ] Atualizar informações conforme listagens forem aprovadas
- [ ] Conectar IDs entre plataformas (ex: CoinGecko ID no DefiLlama)

---

## ⚡ Quick Wins (Pode Fazer Agora)

1. **DefiLlama** — Mais impacto por esforço. Grátis, rápido, code-based
2. **Base Ecosystem** — PR simples no GitHub, alta credibilidade
3. **CoinGecko** — Form online, mas precisa de trading ativo
4. **DappRadar** — Form simples, bom para discovery

---

## 📌 Links de Referência Rápida

| Plataforma | Link de Submissão |
|------------|------------------|
| DefiLlama | https://github.com/DefiLlama/DefiLlama-Adapters |
| CoinGecko | https://www.coingecko.com/en/coins/listing |
| CoinMarketCap | https://www.coinmarketcap.com/currencies/listing/ |
| DappRadar | https://dappradar.com/dashboard/submit-dapp |
| Base Ecosystem | https://github.com/base-org/web (PR no ecosystem.json) |
| Safe Apps | https://forms.gle/PcDcaVx715LKrrQs8 (pre-assessment obrigatório) |
| Zapper Studio | https://github.com/Zapper-fi/studio |
| Zerion DeFi SDK | https://github.com/zeriontech/defi-sdk |
| Zerion Discord | https://zerion.io/discord |
| DefiLlama Discord | https://discord.defillama.com/ |
| BaseScan | https://basescan.org/address/0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d |
