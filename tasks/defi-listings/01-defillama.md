# 01 — DefiLlama: Adapter + PR Guide

> **Projeto:** QINV — Crypto Index Fund na Base Network
> **Token:** QINDEX
> **Vault (Proxy):** `0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d`
> **Chain:** Base (chainId 8453)
> **Website:** https://qinv.ai | **App:** https://app.qinv.ai

---

## 📌 Visão Geral

### O que é DefiLlama

DefiLlama é **O padrão da indústria** para tracking de TVL (Total Value Locked) em protocolos DeFi. É o site mais usado por investidores, analistas e mídia cripto para avaliar o tamanho e relevância de projetos DeFi.

### Por que importa para o QINV

- **Credibilidade instantânea** — Estar no DefiLlama = "é um protocolo real"
- **Dados cascateam** — CoinGecko e CoinMarketCap puxam dados de TVL do DefiLlama
- **SEO e Discovery** — Páginas do DefiLlama rankeiam alto no Google
- **Gratuito** — Processo 100% open source via Pull Request no GitHub
- **Rápido** — 2-7 dias do PR ao listing no site
- **Prioridade #1** — Fazer ANTES de qualquer outra listagem

### Impacto vs Esforço

| Aspecto | Detalhe |
|---------|---------|
| Impacto | ⭐⭐⭐⭐⭐ (máximo) |
| Dificuldade | Média (requer código JavaScript) |
| Custo | Grátis |
| Tempo estimado | 2-7 dias |

---

## ✅ Pré-requisitos Específicos

- [ ] Contrato verificado no BaseScan (ver `00-prerequisites.md`)
- [ ] Conhecimento básico de JavaScript/Node.js
- [ ] Conta no GitHub
- [ ] Git instalado localmente
- [ ] Node.js instalado (v16+)
- [ ] Conhecimento da ABI do vault (quais funções expõe)
- [ ] Saber quais tokens o vault contém (underlying assets)
- [ ] Logo do projeto (SVG ou PNG de alta resolução)

---

## 🔧 Passo a Passo Completo

### Passo 1: Fork do Repositório

1. Acessar: **https://github.com/DefiLlama/DefiLlama-Adapters**
2. Clicar em **"Fork"** no canto superior direito
3. Manter as configurações padrão e confirmar o fork

### Passo 2: Clonar e Configurar

```bash
# Clonar o seu fork
git clone https://github.com/SEU-USER/DefiLlama-Adapters.git
cd DefiLlama-Adapters

# Instalar dependências
npm install

# Criar branch para o adapter
git checkout -b add-qinv-adapter
```

### Passo 3: Criar o Adapter

Criar o arquivo: `projects/qinv/index.js`

```bash
mkdir -p projects/qinv
```

#### Opção A: Vault ERC-4626 (totalAssets + asset)

Se o vault segue o padrão ERC-4626:

```javascript
const QINV_VAULT = '0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d';

async function tvl(api) {
  // Ler o total de assets sob gestão
  const totalAssets = await api.call({
    abi: 'uint256:totalAssets',
    target: QINV_VAULT,
  });

  // Ler qual é o token base do vault
  const asset = await api.call({
    abi: 'address:asset',
    target: QINV_VAULT,
  });

  api.add(asset, totalAssets);
}

module.exports = {
  methodology:
    'TVL is calculated by reading totalAssets() from the QINV ERC-4626 vault contract on Base.',
  base: {
    tvl,
  },
};
```

#### Opção B: Multi-Asset Vault (Index Fund com múltiplos tokens)

Se o vault detém múltiplos tokens (mais provável para um index fund):

```javascript
const { sumTokens2 } = require('../helper/unwrapLPs');

const QINV_VAULT = '0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d';

async function tvl(api) {
  // Listar TODOS os tokens que o vault detém na Base
  const tokens = [
    '0x4200000000000000000000000000000000000006', // WETH
    '0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913', // USDC
    '0x50c5725949A6F0c72E6C4a641F24049A917DB0Cb', // DAI
    '0x2Ae3F1Ec7F1F5012CFEab0185bfc7aa3cf0DEc22', // cbETH
    // Adicionar TODOS os tokens que o vault pode conter
  ];

  return sumTokens2({
    api,
    owner: QINV_VAULT,
    tokens,
  });
}

module.exports = {
  methodology:
    'TVL is calculated by summing all underlying token balances held in the QINV vault contract on Base.',
  base: {
    tvl,
  },
};
```

#### Opção C: Vault com função customizada

Se o vault tem uma função tipo `getHoldings()` ou `getUnderlyingBalances()`:

```javascript
const QINV_VAULT = '0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d';

async function tvl(api) {
  // Exemplo: se o vault expõe getHoldings() retornando (address[], uint256[])
  const holdings = await api.call({
    abi: 'function getHoldings() view returns (address[] tokens, uint256[] amounts)',
    target: QINV_VAULT,
  });

  holdings.tokens.forEach((token, i) => {
    api.add(token, holdings.amounts[i]);
  });
}

module.exports = {
  methodology:
    'TVL is calculated by reading the underlying holdings from the QINV vault contract on Base.',
  base: {
    tvl,
  },
};
```

**⚠️ IMPORTANTE:** Adaptar o código para a ABI real do contrato vault. Verificar no BaseScan (após verificação) quais funções o vault expõe.

### Passo 4: Testar Localmente

```bash
# Testar o adapter
node test.js projects/qinv/index.js
```

Se precisar de RPC customizada, criar arquivo `.env`:
```
BASE_RPC="https://mainnet.base.org"
```

**Saída esperada (exemplo):**
```
base --- tvl ---
{
  "0x4200000000000000000000000000000000000006": "1500000000000000000",
  "0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913": "5000000000"
}
```

O teste deve:
- ✅ Completar sem erros
- ✅ Retornar valores numéricos > 0
- ✅ Não usar `fetch()` ou chamadas a APIs externas

### Passo 5: Commit e Push

```bash
git add projects/qinv/index.js
git commit -m "Add QINV adapter - crypto index fund on Base"
git push origin add-qinv-adapter
```

### Passo 6: Criar o Pull Request

1. Ir em: `https://github.com/DefiLlama/DefiLlama-Adapters/compare`
2. Selecionar seu fork e branch `add-qinv-adapter`
3. Clicar em "Create Pull Request"
4. **OBRIGATÓRIO:** Marcar ✅ **"Allow edits by maintainers"**

### Passo 7: Preencher o Template do PR

```markdown
##### Name (to be shown on DefiLlama):
QINV

##### Twitter Link:
https://twitter.com/QINV_HANDLE

##### List of audit links if any:
[Link do audit se existir, ou "No audit yet"]

##### Website Link:
https://qinv.ai

##### Logo (High resolution, will be shown with rounded borders):
[URL direta para a logo SVG/PNG - hospedar no GitHub ou site]

##### Current TVL:
$22 (early stage)

##### Treasury Addresses (if the protocol has treasury):
N/A

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
[Especificar: Chainlink, Pyth, ou "None"]

##### Forked from:
[Se fork: qual protocolo. Se original: "No"]

##### Methodology:
TVL is calculated by reading the underlying token balances held in the QINV vault contract on Base.
```

---

## ⚠️ Motivos Comuns de Rejeição

| Motivo | Como evitar |
|--------|------------|
| TVL calculado via fetch/API | **NUNCA** usar `fetch()` no adapter. TVL deve ser lido on-chain |
| `package-lock.json` editado | Não fazer commit deste arquivo |
| npm packages adicionados | Não adicionar dependências. Usar apenas o SDK do DefiLlama |
| "Allow edits by maintainers" desmarcado | Manter sempre marcado — eles editam adapters com frequência |
| TVL muito baixo | Não há mínimo oficial, mas <$10k pode ser deprioritizado |
| Logo faltando ou baixa qualidade | Fornecer SVG ou PNG de alta resolução no PR |
| Código duplicado/desnecessário | Manter o adapter enxuto e limpo |
| Testes falhando | Rodar `node test.js` localmente antes de submeter |

---

## 📬 Pós-Listagem

### Quando aparece no site
- TVL aparece no site **~24h após o merge** do PR
- Pode demorar até 48h em alguns casos

### Se demorar mais de 48h
- Pedir ajuda no Discord: https://discord.defillama.com/
- Mencionar o PR number e pedir status update

### Atualizações futuras
- Para editar info do protocolo (nome, descrição, links): editar em https://github.com/DefiLlama/defillama-server/blob/master/defi/src/protocols/data2.ts
- Para atualizar o adapter (novo token no vault, por exemplo): submeter novo PR editando `projects/qinv/index.js`

### Monitoramento contínuo
- DefiLlama **desativa adapters que dão erro**
- Monitorar se o TVL está sendo reportado corretamente
- Se adicionar novos tokens ao vault, atualizar o adapter

### Conectar com outras plataformas
- Após listagem no DefiLlama, usar o DefiLlama protocol ID nas submissões para:
  - CoinGecko (campo "DefiLlama ID")
  - CoinMarketCap (referência de TVL)
  - Outras plataformas que verificam TVL

---

## 📅 Timeline Detalhada

| Etapa | Tempo estimado |
|-------|---------------|
| Desenvolver adapter | 1-2 horas (se ABI clara) a 1-2 dias |
| Testar localmente | 30 min |
| Submeter PR | 15 min |
| Review pelos maintainers | 1-3 dias úteis |
| Merge | 2-5 dias total |
| Aparecer no UI | +24h após merge |
| **Total** | **~2-7 dias** |

---

## 🔗 Links e Referências

| Recurso | URL |
|---------|-----|
| Repositório de Adapters | https://github.com/DefiLlama/DefiLlama-Adapters |
| Documentação dos Adapters | https://github.com/DefiLlama/DefiLlama-Adapters/blob/main/README.md |
| Discord DefiLlama | https://discord.defillama.com/ |
| DefiLlama Server (editar info) | https://github.com/DefiLlama/defillama-server |
| Site DefiLlama | https://defillama.com/ |
| BaseScan - QINV Proxy | https://basescan.org/address/0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d |
| BaseScan - QINV Implementation | https://basescan.org/address/0x53dc7d1a3796734f4ae5df06857cbb208af1b4ba |
