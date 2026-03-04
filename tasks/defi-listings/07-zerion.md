# 07 — Zerion: Portfolio Tracker & DeFi Wallet Integration

> **Projeto:** QINV — Crypto Index Fund na Base Network
> **Token:** QINDEX
> **Vault (Proxy):** `0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d`
> **Implementation:** `0x53dc7d1a3796734f4ae5df06857cbb208af1b4ba`
> **Chain:** Base (chainId 8453)
> **Website:** https://qinv.ai | **App:** https://app.qinv.ai

---

## 📌 Visão Geral

### O que é o Zerion

Zerion (https://zerion.io) é uma wallet DeFi e portfolio tracker que permite aos usuários visualizar, gerenciar e negociar ativos em múltiplas chains. É um dos principais concorrentes do Zapper, com foco em UX mobile-first e integração nativa de wallet.

### Como Funciona a Listagem

Zerion utiliza dois mecanismos principais para listar tokens e protocolos:

1. **Token List** — Para reconhecimento básico do token (nome, logo, preço). Zerion consome listas do CoinGecko, token lists padrão (Uniswap-style) e sua própria curadoria interna.
2. **DeFi SDK / Protocol Integration** — Para exibir posições de protocolo (vaults, pools, staking). Zerion mantém o **DeFi SDK**, um sistema open source para decodificar posições DeFi.

**Repositório DeFi SDK:** https://github.com/zeriontech/defi-sdk
**Token Request:** https://github.com/zeriontech/token-directory (legado) → agora via API/curadoria

### Por que importa para o QINV

- **Wallet nativa** — Usuários da Zerion Wallet veem QINDEX diretamente no app
- **Portfolio tracking** — Posição no vault aparece com valor correto em USD
- **Swap integration** — Se listado, pode aparecer em rotas de swap dentro do app
- **Mobile first** — Grande base de usuários mobile (iOS/Android)
- **Composição do index** — Pode exibir underlying assets do vault
- **Credibilidade DeFi** — "Available on Zerion" é reconhecido no ecossistema

### Impacto vs Esforço

| Aspecto | Detalhe |
|---------|---------|
| Impacto | ⭐⭐⭐⭐ (alto) |
| Dificuldade | Média-Alta |
| Custo | Grátis |
| Tempo estimado | 7-21 dias (depende de review e backlog) |

---

## ✅ Pré-requisitos Específicos

- [ ] Contrato verificado no BaseScan (ver `00-prerequisites.md`) — **OBRIGATÓRIO**
- [ ] ABI do vault disponível publicamente
- [ ] Token com pelo menos alguma liquidez on-chain (mesmo que mínima)
- [ ] Logo do QINDEX em PNG 256x256 (fundo transparente)
- [ ] Logo do QINDEX em SVG (preferível)
- [ ] CoinGecko listing concluída (ver `02-coingecko.md`) — ajuda muito na detecção automática
- [ ] Conta no GitHub
- [ ] Informações do token: nome, símbolo, decimals, descrição
- [ ] Links: website, docs, Twitter/X, Discord/Telegram

---

## 🔧 Passo a Passo Completo

### Caminho 1: Listagem Básica do Token (Reconhecimento + Logo)

#### Passo 1: Verificar se QINDEX já aparece no Zerion

```
URL: https://app.zerion.io/tokens/qindex-0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d?chain=base
```

Se não aparecer ou aparecer sem logo/nome correto, seguir para o Passo 2.

#### Passo 2: Submeter via Token Directory (GitHub)

O método mais direto é contribuir para a lista de tokens do Zerion:

```bash
# 1. Fork do repositório
# URL: https://github.com/zeriontech/token-directory → Fork

# 2. Clone local
git clone https://github.com/SEU_USUARIO/token-directory.git
cd token-directory

# 3. Criar branch
git checkout -b add-qindex-base
```

#### Passo 3: Adicionar Token à Lista

Verificar a estrutura do repositório (pode variar). Tipicamente:

```bash
# Navegar para a pasta da chain Base
# A estrutura pode ser:
# tokens/base/ ou chains/8453/ — verificar o README do repo
```

Criar/editar o arquivo de listagem:

```json
{
  "address": "0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d",
  "chainId": 8453,
  "name": "QINV Index",
  "symbol": "QINDEX",
  "decimals": 18,
  "logoURI": "https://raw.githubusercontent.com/SEU_USUARIO/token-directory/main/logos/base/0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d.png",
  "tags": ["defi", "index", "vault"],
  "extensions": {
    "website": "https://qinv.ai",
    "description": "QINV is a decentralized crypto index fund on Base network, providing diversified exposure to crypto assets through a single ERC-4626 vault token."
  }
}
```

#### Passo 4: Adicionar Logo

```bash
# Copiar o logo para a pasta correta
# Exemplo (verificar estrutura do repo):
mkdir -p logos/base/
cp /path/to/qindex-logo.png logos/base/0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d.png

# Requisitos do logo:
# - PNG, 256x256 pixels
# - Fundo transparente (preferido)
# - Tamanho máximo: 100KB
# - Sem texto excessivo, legível em tamanhos pequenos
```

#### Passo 5: Commit e Pull Request

```bash
git add .
git commit -m "feat: add QINDEX token on Base network

- Token: QINDEX (QINV Index Fund)
- Chain: Base (8453)
- Address: 0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d
- Category: DeFi Index Fund / Asset Management
- Website: https://qinv.ai"

git push origin add-qindex-base
```

**Criar PR no GitHub:**
- Título: `Add QINDEX token on Base network`
- Descrição:

```markdown
## Token Information
- **Name:** QINV Index
- **Symbol:** QINDEX
- **Chain:** Base (8453)
- **Address:** `0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d`
- **Decimals:** 18
- **Category:** DeFi Index Fund / Asset Management

## About QINV
QINV is a decentralized crypto index fund on Base network. It uses an ERC-4626 vault
to provide diversified exposure to crypto assets through a single token (QINDEX).

## Links
- Website: https://qinv.ai
- App: https://app.qinv.ai
- BaseScan: https://basescan.org/address/0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d

## Verification
- [ ] Contract verified on BaseScan
- [ ] Logo meets requirements (256x256 PNG)
- [ ] Token actively traded on Base
```

---

### Caminho 2: Submissão via Formulário de Contato Zerion

Se o repositório token-directory estiver descontinuado ou não aceitar PRs:

#### Passo 1: Contato via Suporte

```
URL: https://zerion.io/support
Email: support@zerion.io
```

**Template de email/formulário:**

```
Subject: Token Listing Request — QINDEX on Base Network

Hi Zerion team,

I'd like to request the addition of QINDEX token to Zerion's token list.

Token Details:
- Name: QINV Index
- Symbol: QINDEX
- Chain: Base (Chain ID: 8453)
- Contract Address: 0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d
- Decimals: 18
- Token Standard: ERC-20 (ERC-4626 Vault)

About the Project:
QINV is a decentralized crypto index fund on Base network. The QINDEX token 
represents shares in a diversified vault that holds multiple crypto assets, 
similar to a traditional index fund but fully on-chain.

Links:
- Website: https://qinv.ai
- App: https://app.qinv.ai
- BaseScan: https://basescan.org/address/0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d

The contract is verified on BaseScan and follows the ERC-4626 standard.

We can provide logo files in any format required (PNG, SVG).

Thank you for considering our request.

Best regards,
[Nome]
QINV Team
```

---

### Caminho 3: Integração de Protocolo (DeFi SDK)

Este é o caminho avançado para que o Zerion reconheça QINV como um **protocolo DeFi** (não apenas um token), exibindo posições no vault com underlying assets.

#### Passo 1: Fork e Setup do DeFi SDK

```bash
# Fork: https://github.com/zeriontech/defi-sdk → Fork

git clone https://github.com/SEU_USUARIO/defi-sdk.git
cd defi-sdk
npm install
```

#### Passo 2: Entender a Estrutura

O DeFi SDK usa "adapters" para cada protocolo. Cada adapter define:

- **Asset adapter** — Como ler os ativos do protocolo
- **Debt adapter** — Como ler dívidas (não aplicável para QINV)
- **Metadata** — Informações do protocolo

```
src/
  adapters/
    qinv/
      index.ts          # Entry point
      qinvAdapter.ts    # Lógica de leitura de posições
      metadata.ts       # Informações do protocolo
```

#### Passo 3: Criar o Adapter

```typescript
// src/adapters/qinv/metadata.ts
export const QINV_METADATA = {
  name: 'QINV',
  description: 'Decentralized Crypto Index Fund',
  url: 'https://qinv.ai',
  iconURL: 'https://qinv.ai/logo.png',
  category: 'Asset Management',
  chains: ['base'],
};

// src/adapters/qinv/qinvAdapter.ts
import { ethers } from 'ethers';

// ABI mínima necessária
const VAULT_ABI = [
  'function balanceOf(address owner) view returns (uint256)',
  'function totalAssets() view returns (uint256)',
  'function totalSupply() view returns (uint256)',
  'function asset() view returns (address)',
  'function convertToAssets(uint256 shares) view returns (uint256)',
  'function decimals() view returns (uint8)',
  'function symbol() view returns (string)',
  'function name() view returns (string)',
];

const VAULT_ADDRESS = '0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d';

export class QinvAdapter {
  /**
   * Retorna as posições do usuário no vault QINV
   */
  async getPositions(userAddress: string, provider: ethers.Provider) {
    const vault = new ethers.Contract(VAULT_ADDRESS, VAULT_ABI, provider);
    
    const [shares, totalAssets, totalSupply, underlyingAsset] = await Promise.all([
      vault.balanceOf(userAddress),
      vault.totalAssets(),
      vault.totalSupply(),
      vault.asset(),
    ]);

    if (shares === 0n) return [];

    // Calcular valor em underlying asset
    const userAssets = await vault.convertToAssets(shares);

    return [
      {
        type: 'deposit',
        asset: {
          address: VAULT_ADDRESS,
          symbol: 'QINDEX',
          decimals: 18,
        },
        balance: shares.toString(),
        underlyingAssets: [
          {
            address: underlyingAsset,
            balance: userAssets.toString(),
          },
        ],
      },
    ];
  }
}
```

#### Passo 4: Registrar o Adapter

```typescript
// src/adapters/qinv/index.ts
import { QinvAdapter } from './qinvAdapter';
import { QINV_METADATA } from './metadata';

export default {
  metadata: QINV_METADATA,
  adapter: new QinvAdapter(),
};
```

#### Passo 5: Testes

```typescript
// src/adapters/qinv/__tests__/qinvAdapter.test.ts
import { QinvAdapter } from '../qinvAdapter';
import { ethers } from 'ethers';

describe('QinvAdapter', () => {
  const adapter = new QinvAdapter();
  const provider = new ethers.JsonRpcProvider('https://mainnet.base.org');

  it('should return empty for address with no position', async () => {
    const positions = await adapter.getPositions(
      '0x0000000000000000000000000000000000000001',
      provider
    );
    expect(positions).toEqual([]);
  });

  it('should return position for holder', async () => {
    // Substituir por um endereço holder real quando disponível
    const holder = '0x...'; // TODO: endereço com posição real
    const positions = await adapter.getPositions(holder, provider);
    expect(positions.length).toBeGreaterThan(0);
    expect(positions[0].asset.symbol).toBe('QINDEX');
  });
});
```

#### Passo 6: Submeter PR

```bash
git add .
git commit -m "feat: add QINV protocol adapter

- Protocol: QINV (Decentralized Crypto Index Fund)
- Chain: Base
- Vault: 0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d
- Standard: ERC-4626
- Reads user vault positions and underlying assets"

git push origin add-qinv-adapter
```

**PR Description:**

```markdown
## Protocol: QINV

### Description
QINV is a decentralized crypto index fund on Base. Users deposit assets 
into an ERC-4626 vault and receive QINDEX shares representing their 
proportional ownership of the diversified portfolio.

### What this adapter does
- Reads user's QINDEX share balance
- Converts shares to underlying asset value via `convertToAssets()`
- Returns position with underlying asset breakdown

### Contract Information
- Vault (Proxy): `0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d`
- Chain: Base (8453)
- Standard: ERC-4626

### Testing
- Tested against Base mainnet RPC
- Verified with known holder addresses

### Links
- Website: https://qinv.ai
- App: https://app.qinv.ai
```

---

## 📋 Campos e Valores Sugeridos (Resumo)

| Campo | Valor |
|-------|-------|
| Token Name | QINV Index |
| Symbol | QINDEX |
| Chain | Base |
| Chain ID | 8453 |
| Contract Address | 0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d |
| Decimals | 18 |
| Token Standard | ERC-20 / ERC-4626 |
| Category | DeFi / Index Fund / Asset Management |
| Description | Decentralized crypto index fund on Base network providing diversified exposure through a single vault token |
| Website | https://qinv.ai |
| App URL | https://app.qinv.ai |
| Logo Format | PNG 256x256, fundo transparente |

---

## ❌ Motivos Comuns de Rejeição

| Motivo | Como Resolver |
|--------|--------------|
| **Contrato não verificado** | Verificar proxy + implementation no BaseScan (ver `00-prerequisites.md`) |
| **Token sem liquidez** | Garantir ao menos um pool com liquidez mínima (Uniswap V3, Aerodrome, etc.) |
| **Logo fora do padrão** | 256x256 PNG, fundo transparente, < 100KB |
| **Adapter com bugs** | Rodar testes locais extensivos antes do PR |
| **Protocolo muito novo/pequeno** | TVL e número de holders importam — focar em crescimento orgânico |
| **PR incompleto** | Incluir testes, documentação e metadata completa |
| **Duplicata** | Verificar se alguém já submeteu antes |
| **ABI indisponível** | Contrato não verificado = sem ABI pública = rejeição |

---

## 🔄 Manutenção Pós-Listagem

### Monitoramento Regular

- [ ] Verificar se o token aparece corretamente no app Zerion (web + mobile)
- [ ] Confirmar que o preço está sendo trackado corretamente
- [ ] Verificar se posições de vault são exibidas (se adapter foi aceito)
- [ ] Monitorar issues no repositório do DeFi SDK

### Atualizações Necessárias

| Evento | Ação Necessária |
|--------|-----------------|
| Upgrade do contrato (nova implementation) | Atualizar adapter se ABI mudar |
| Mudança de chain/endereço | Novo PR atualizando o adapter |
| Zerion depreca DeFi SDK | Migrar para novo sistema (ficar atento a announcements) |
| Nova versão do vault | Atualizar ABI e lógica do adapter |
| Logo update | Submeter novo PR com logo atualizado |

### Métricas para Acompanhar

- Número de usuários trackando QINDEX via Zerion
- Feedback de usuários sobre exibição correta de posições
- Status do PR (se pendente)
- Releases do DeFi SDK que possam quebrar o adapter

---

## 🔗 Links Úteis

| Recurso | URL |
|---------|-----|
| Zerion App | https://app.zerion.io |
| Zerion API Docs | https://developers.zerion.io |
| DeFi SDK GitHub | https://github.com/zeriontech/defi-sdk |
| Token Directory | https://github.com/zeriontech/token-directory |
| Zerion Support | https://zerion.io/support |
| Zerion Discord | https://discord.gg/zerion |
| Zerion Twitter | https://twitter.com/zerabordar |
| BaseScan QINDEX | https://basescan.org/address/0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d |

---

## 📅 Timeline Estimada

| Fase | Duração | Notas |
|------|---------|-------|
| Preparação (logo, ABI, verificação) | 1-3 dias | Depende de `00-prerequisites.md` |
| Token listing (Caminho 1 ou 2) | 3-14 dias | Depende do backlog de review |
| Protocol adapter (Caminho 3) | 5-14 dias | Desenvolvimento + review |
| Verificação pós-listagem | 1-2 dias | Testar em web e mobile |
| **Total estimado** | **7-21 dias** | |

---

## 💡 Dicas Estratégicas

1. **Comece pelo token listing** (Caminho 1 ou 2) — é mais rápido e já dá visibilidade básica
2. **CoinGecko primeiro** — Zerion consome dados do CoinGecko; se QINDEX estiver lá, pode aparecer automaticamente
3. **Protocol adapter depois** — só faz sentido quando TVL justificar o esforço de desenvolvimento
4. **Engage com a comunidade Zerion** — Discord é ativo e o time responde
5. **Mobile testing** — Zerion é mobile-first; testar no app iOS/Android após listagem
6. **Mantenha o adapter atualizado** — Adapters abandonados são eventualmente removidos
