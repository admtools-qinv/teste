# 00 — Pré-requisitos Comuns a TODAS as Listagens

> **Projeto:** QINV — Crypto Index Fund na Base Network
> **Token:** QINDEX
> **Vault (Proxy):** `0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d` ⚠️ NÃO VERIFICADO
> **Implementation:** `0x53dc7d1a3796734f4ae5df06857cbb208af1b4ba`
> **Chain:** Base (chainId 8453)
> **Website:** https://qinv.ai | **App:** https://app.qinv.ai

---

## 📌 Visão Geral

Este documento lista tudo que precisa estar pronto **ANTES** de submeter qualquer listagem em qualquer plataforma. Cada guia individual (01 a 09) assume que estes pré-requisitos já foram cumpridos.

**O item mais crítico e urgente é a verificação do contrato no BaseScan.** Sem isso, praticamente nenhuma plataforma aceita a listagem.

---

## 🚨 PRIORIDADE #1: Verificação do Contrato no BaseScan

### Por que é crítico

- **CoinGecko:** Exige contrato verificado — rejeição automática sem isso
- **CoinMarketCap:** Exige contrato verificado
- **DefiLlama:** Revisores checam o código do contrato
- **DappRadar:** Exige smart contract verificável
- **Base Ecosystem:** PR sem contrato verificado será questionado
- **Zapper/Zerion:** Precisam da ABI pública para integração

**Resumo: sem contrato verificado = zero listagens possíveis.**

### Contexto Técnico do QINV

O contrato QINV usa o padrão **Proxy** (upgradeable):

| Componente | Endereço | Status |
|-----------|---------|--------|
| **Proxy** | `0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d` | ❌ NÃO VERIFICADO |
| **Implementation** | `0x53dc7d1a3796734f4ae5df06857cbb208af1b4ba` | ❌ NÃO VERIFICADO |

Para contratos proxy, é necessário verificar **AMBOS**: o proxy e a implementation. Isso permite que o BaseScan mostre a ABI completa e os usuários possam interagir via "Read/Write as Proxy".

---

### Guia Passo a Passo: Verificação do Contrato no BaseScan

#### Etapa 1: Verificar o Contrato de Implementation

A implementation contém a lógica real do contrato. Verificar esta primeiro.

**1.1. Acessar a página de verificação:**

Ir em: `https://basescan.org/address/0x53dc7d1a3796734f4ae5df06857cbb208af1b4ba#code`

Clicar em **"Verify and Publish"**.

**1.2. Escolher o método de verificação:**

Você tem 3 opções:

| Método | Quando usar |
|--------|------------|
| **Solidity (Single file)** | Contrato em um único arquivo .sol |
| **Solidity (Standard-Json)** | Compilado com Hardhat/Foundry (recomendado) |
| **Solidity (Multi-part)** | Múltiplos arquivos .sol separados |

**Recomendado:** Usar **Standard-Json Input** se o projeto usa Hardhat ou Foundry.

**1.3. Preencher os campos:**

| Campo | O que colocar |
|-------|--------------|
| **Contract Address** | `0x53dc7d1a3796734f4ae5df06857cbb208af1b4ba` |
| **Compiler Type** | Solidity (Standard-Json-Input) |
| **Compiler Version** | Exatamente a mesma versão usada no deploy (ex: v0.8.20+commit.a1b79de6) |
| **Open Source License** | MIT (ou a licença do projeto) |

**⚠️ COMO ENCONTRAR A VERSÃO DO COMPILER:**
- Checar no `hardhat.config.ts` ou `foundry.toml` do projeto
- Ou no `package.json` se usar solc diretamente
- A versão precisa ser **EXATA** — incluindo o commit hash

**1.4. Colar o Standard JSON Input:**

Se usa **Hardhat**:
```bash
# Gerar o standard JSON input
npx hardhat compile
# O arquivo fica em: artifacts/build-info/*.json
# Dentro desse JSON, o campo "input" é o Standard JSON Input
```

Se usa **Foundry**:
```bash
# Gerar o standard JSON input
forge verify-contract 0x53dc7d1a3796734f4ae5df06857cbb208af1b4ba \
  --chain base \
  --watch \
  --etherscan-api-key SEU_BASESCAN_API_KEY \
  src/NomeDoContrato.sol:NomeDoContrato
```

**Método alternativo com Foundry (automático):**
```bash
forge verify-contract \
  0x53dc7d1a3796734f4ae5df06857cbb208af1b4ba \
  src/QINVVault.sol:QINVVault \
  --chain base \
  --etherscan-api-key SEU_BASESCAN_API_KEY \
  --compiler-version "0.8.20" \
  --watch
```

Se usa **Hardhat** (automático via plugin):
```bash
npx hardhat verify --network base 0x53dc7d1a3796734f4ae5df06857cbb208af1b4ba
```

**Configuração necessária no hardhat.config.ts:**
```typescript
// hardhat.config.ts
import "@nomicfoundation/hardhat-verify";

const config: HardhatUserConfig = {
  // ...
  etherscan: {
    apiKey: {
      base: "SEU_BASESCAN_API_KEY",  // Obter em https://basescan.org/myapikey
    },
    customChains: [
      {
        network: "base",
        chainId: 8453,
        urls: {
          apiURL: "https://api.basescan.org/api",
          browserURL: "https://basescan.org",
        },
      },
    ],
  },
};
```

**1.5. Constructor Arguments (se houver):**

Se o contrato de implementation foi deployado com argumentos no constructor:
- O BaseScan pode detectar automaticamente
- Se não detectar, você precisa fornecer os argumentos ABI-encoded
- Usar https://abi.hashex.org/ para encodar os argumentos

**Para contratos implementation de proxy upgradeable:** geralmente o constructor NÃO tem argumentos (usa `initialize()` em vez de constructor). Nesse caso, deixar o campo vazio.

**1.6. Clicar em "Verify and Publish"**

Se tudo estiver correto, em 10-30 segundos o contrato será verificado e você verá ✅ ao lado do endereço.

**Troubleshooting:**
- **"Bytecode does not match"**: Versão do compiler errada, ou optimizer settings diferentes
- **"Constructor arguments encoding error"**: Arguments ABI-encoded incorretos
- Verificar nas settings do Hardhat/Foundry:
  - `optimizer: { enabled: true, runs: 200 }` — precisa bater EXATAMENTE
  - `evmVersion` — precisa bater (ex: "paris", "shanghai")

---

#### Etapa 2: Verificar o Contrato Proxy

Agora que a implementation está verificada, verificar o proxy.

**2.1. Acessar a página do proxy:**

Ir em: `https://basescan.org/address/0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d#code`

**2.2. Verificar o código do proxy:**

O proxy em si é um contrato simples (geralmente ERC1967Proxy, TransparentUpgradeableProxy, ou UUPSUpgradeable). Verificar usando o mesmo processo da Etapa 1:

- Clicar em "Verify and Publish"
- Usar a mesma versão do compiler
- Colar o source code do proxy
- Se for um proxy padrão do OpenZeppelin, o BaseScan pode já reconhecer

**Dica:** Se o proxy foi deployado via OpenZeppelin Upgrades Plugin, o source code é padrão e fácil de verificar.

**Verificação via Hardhat (automática para proxies OpenZeppelin):**
```bash
# Se deployou via @openzeppelin/hardhat-upgrades, verificar assim:
npx hardhat verify --network base 0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d
```

**Verificação via Foundry:**
```bash
forge verify-contract \
  0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d \
  lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol:ERC1967Proxy \
  --chain base \
  --etherscan-api-key SEU_BASESCAN_API_KEY \
  --constructor-args $(cast abi-encode "constructor(address,bytes)" \
    0x53dc7d1a3796734f4ae5df06857cbb208af1b4ba \
    "0xINITIALIZE_CALLDATA") \
  --watch
```

**2.3. Marcar como Proxy (ESSENCIAL):**

Após verificar o código do proxy, é preciso informar ao BaseScan que este é um contrato proxy:

1. Na página do contrato proxy, ir na aba **"Contract"**
2. Clicar em **"More Options"** → **"Is this a proxy?"**
3. Ou acessar diretamente: `https://basescan.org/proxyContractChecker?a=0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d`
4. Clicar em **"Verify"**
5. O BaseScan vai detectar automaticamente o endereço da implementation
6. Confirmar que o endereço detectado é `0x53dc7d1a3796734f4ae5df06857cbb208af1b4ba`
7. Clicar em **"Save"**

**Resultado esperado:** Após essa etapa, a página do proxy mostrará:
- ✅ Contrato verificado
- Abas **"Read as Proxy"** e **"Write as Proxy"** disponíveis
- A ABI combinada (proxy + implementation) acessível

---

#### Etapa 3: Verificação Final

Confirmar que tudo está OK:

- [ ] `https://basescan.org/address/0x53dc7d1a3796734f4ae5df06857cbb208af1b4ba#code` → mostra ✅ e source code
- [ ] `https://basescan.org/address/0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d#code` → mostra ✅ e source code
- [ ] Aba "Read as Proxy" funciona no contrato proxy
- [ ] Aba "Write as Proxy" funciona no contrato proxy
- [ ] Funções como `totalAssets()`, `name()`, `symbol()`, `decimals()` retornam valores corretos

---

### Obter API Key do BaseScan

Necessário para verificação via CLI (Hardhat/Foundry):

1. Acessar https://basescan.org/register (criar conta se não tiver)
2. Ir em https://basescan.org/myapikey
3. Clicar em "Add" para criar uma nova API key
4. Copiar a key gerada
5. Adicionar no `.env`:
   ```
   BASESCAN_API_KEY=sua_api_key_aqui
   ```

---

## ✅ Checklist de Assets (Preparar Antes de Qualquer Listagem)

### Logos

- [ ] **Logo SVG** — Quadrado, mínimo 128×128px, bordas arredondadas ficam bem
- [ ] **Logo PNG 256×256px** — Alguns sites pedem PNG
- [ ] **Logo PNG 64×64px** — Para thumbnails
- [ ] **Logo WebP 200×200px** — Necessário para Base Ecosystem

### Textos

- [ ] **Descrição curta** (máx 200 chars):
  > "QINV is a crypto index fund on Base offering diversified exposure to top digital assets through the QINDEX vault token. One token, full market coverage."

- [ ] **Descrição longa** (2-3 parágrafos):
  > QINV is a decentralized crypto index fund built natively on Base, Coinbase's Layer 2 network.
  >
  > Through the QINDEX vault token, investors gain diversified exposure to a curated basket of top digital assets without the complexity of managing multiple positions. Simply deposit into the vault and receive QINDEX tokens representing your proportional share of the fund.
  >
  > The fund is fully on-chain, non-custodial, and transparent — anyone can verify the underlying holdings at any time through the smart contract on BaseScan.

### Links e Presença Online

- [ ] **Website:** https://qinv.ai (HTTPS obrigatório)
- [ ] **App:** https://app.qinv.ai
- [ ] **Twitter/X** — Ativo com posts recentes
- [ ] **Discord ou Telegram** da comunidade
- [ ] **Docs/Gitbook** com documentação técnica
- [ ] **GitHub público** com código do contrato
- [ ] **Email oficial** com domínio próprio (ex: team@qinv.ai — NÃO usar Gmail)

### Técnico

- [ ] **Contrato verificado no BaseScan** — Ver seção acima ⚠️
- [ ] **Audit report** (se tiver — acelera MUITO aprovações)
- [ ] **ABI pública** (disponível automaticamente após verificação)
- [ ] **Decimais do token** — Verificar no contrato (provavelmente 18)
- [ ] **Total supply** acessível on-chain
- [ ] **Token sendo negociado em pelo menos 1 DEX** (para CoinGecko/CMC)

---

## 📧 Template de Email para Contatos Diretos

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
- Website: https://qinv.ai
- App: https://app.qinv.ai
- Docs: [URL]
- Twitter: [URL]
- GitHub: [URL]

Best regards,
[NOME]
```

---

## 🔗 Links de Referência

| Recurso | URL |
|---------|-----|
| BaseScan - Proxy | https://basescan.org/address/0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d |
| BaseScan - Implementation | https://basescan.org/address/0x53dc7d1a3796734f4ae5df06857cbb208af1b4ba |
| BaseScan - API Key | https://basescan.org/myapikey |
| BaseScan - Proxy Checker | https://basescan.org/proxyContractChecker?a=0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d |
| Hardhat Verify Plugin | https://hardhat.org/hardhat-runner/plugins/nomicfoundation-hardhat-verify |
| Foundry Verify Docs | https://book.getfoundry.sh/reference/forge/forge-verify-contract |
| ABI Encoder (HashEx) | https://abi.hashex.org/ |
| Website QINV | https://qinv.ai |
| App QINV | https://app.qinv.ai |
