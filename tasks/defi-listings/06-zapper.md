# 06 — Zapper: Protocol Integration via Zapper Studio

> **Projeto:** QINV — Crypto Index Fund na Base Network
> **Token:** QINDEX
> **Vault (Proxy):** `0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d`
> **Chain:** Base (chainId 8453)
> **Website:** https://qinv.ai | **App:** https://app.qinv.ai

---

## 📌 Visão Geral

### O que é o Zapper

Zapper (https://zapper.xyz) é uma das maiores plataformas de portfolio tracking e DeFi dashboard. Permite que usuários visualizem todas as suas posições DeFi, tokens e NFTs em um único lugar, com suporte a múltiplas chains.

### Como Funciona a Integração

Zapper usa o **Zapper Studio** — um framework open source em TypeScript para integrar protocolos. Cada protocolo é representado por um "app module" que define como ler saldos, posições e tokens do contrato.

**Repositório:** https://github.com/Zapper-fi/studio

### Por que importa para o QINV

- **Portfolio visibility** — Usuários de QINDEX veem o valor real da posição, não apenas o token
- **Underlying assets** — Zapper pode mostrar os ativos dentro do vault (composição do index)
- **Dashboard DeFi** — QINV aparece como protocolo reconhecido no dashboard
- **Data feed** — Outros agregadores consomem dados do Zapper
- **Credibilidade** — "Tracked by Zapper" é selo de legitimidade

### Impacto vs Esforço

| Aspecto | Detalhe |
|---------|---------|
| Impacto | ⭐⭐⭐⭐ (alto) |
| Dificuldade | Alta (requer TypeScript + conhecimento da ABI) |
| Custo | Grátis |
| Tempo estimado | 5-14 dias (PR review pode demorar) |

---

## ✅ Pré-requisitos Específicos

- [ ] Contrato verificado no BaseScan (ver `00-prerequisites.md`) — **OBRIGATÓRIO para ter ABI**
- [ ] ABI do vault disponível publicamente
- [ ] Node.js v18+ instalado
- [ ] TypeScript básico
- [ ] Conta no GitHub
- [ ] Git instalado
- [ ] Conhecimento das funções do vault (totalAssets, asset, balanceOf, etc.)
- [ ] Logo do projeto (SVG preferido, ou PNG 256x256)

---

## 🔧 Passo a Passo Completo

### Passo 1: Fork e Setup do Zapper Studio

```bash
# Fork via GitHub UI: https://github.com/Zapper-fi/studio → Fork

# Clonar o fork
git clone https://github.com/SEU-USER/studio.git
cd studio

# Instalar dependências
pnpm install

# Criar branch
git checkout -b feat/add-qinv
```

### Passo 2: Gerar o Scaffold do App

O Zapper Studio tem um gerador CLI para criar a estrutura inicial:

```bash
# Gerar scaffold para novo app
pnpm studio create-app qinv
```

Isso cria a estrutura em `src/apps/qinv/`:

```
src/apps/qinv/
├── qinv.module.ts          # Módulo principal do app
├── qinv.definition.ts      # Metadata do protocolo
├── contracts/
│   └── index.ts             # ABIs e contract factories
├── assets/
│   └── qinv-logo.png        # Logo do protocolo
└── base/                    # Chain-specific (Base)
    ├── qinv.vault.token-fetcher.ts  # Token fetcher para o vault
    └── qinv.balance-fetcher.ts       # Balance fetcher
```

### Passo 3: Definir o App (qinv.definition.ts)

```typescript
import { Register } from '~app-toolkit/decorators';
import { appDefinition, AppDefinition } from '~app/app.definition';
import { AppAction, AppTag, GroupType } from '~app/app.interface';

export const QINV_DEFINITION = appDefinition({
  id: 'qinv',
  name: 'QINV',
  description: 'AI-powered crypto index fund. Deposit assets and receive QINDEX tokens representing diversified crypto exposure.',
  url: 'https://qinv.ai',

  groups: {
    vault: {
      id: 'vault',
      type: GroupType.TOKEN,
      label: 'Vault',
    },
  },

  tags: [AppTag.ASSET_MANAGEMENT, AppTag.FUND_MANAGER],

  keywords: ['index', 'fund', 'vault', 'asset-management', 'base'],

  links: {
    website: 'https://qinv.ai',
    github: '', // Adicionar se público
    discord: '', // Adicionar se existir
    twitter: '', // Adicionar se existir
  },

  supportedNetworks: {
    base: [AppAction.VIEW],
  },
});

@Register.AppDefinition(QINV_DEFINITION.id)
export class QinvAppDefinition extends AppDefinition {
  constructor() {
    super(QINV_DEFINITION);
  }
}
```

### Passo 4: Definir os Contratos (contracts/index.ts)

```typescript
import { Injectable, Inject } from '@nestjs/common';
import { IAppToolkit, APP_TOOLKIT } from '~app-toolkit/app-toolkit.interface';
import { ContractFactory } from '~contract/contracts';

// ABI mínima do vault QINV
const QINV_VAULT_ABI = [
  {
    inputs: [],
    name: 'totalAssets',
    outputs: [{ name: '', type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'totalSupply',
    outputs: [{ name: '', type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [{ name: 'account', type: 'address' }],
    name: 'balanceOf',
    outputs: [{ name: '', type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'asset',
    outputs: [{ name: '', type: 'address' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'decimals',
    outputs: [{ name: '', type: 'uint8' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'name',
    outputs: [{ name: '', type: 'string' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'symbol',
    outputs: [{ name: '', type: 'string' }],
    stateMutability: 'view',
    type: 'function',
  },
] as const;

@Injectable()
export class QinvContractFactory extends ContractFactory {
  constructor(@Inject(APP_TOOLKIT) protected readonly appToolkit: IAppToolkit) {
    super();
  }

  qinvVault({ address, network }: { address: string; network: string }) {
    return this.appToolkit.globalContracts.createContract({
      address,
      network,
      abi: QINV_VAULT_ABI,
    });
  }
}
```

### Passo 5: Criar o Token Fetcher (base/qinv.vault.token-fetcher.ts)

O Token Fetcher define como o Zapper descobre e precifica os tokens do protocolo:

```typescript
import { Inject } from '@nestjs/common';
import { Register } from '~app-toolkit/decorators';
import { APP_TOOLKIT, IAppToolkit } from '~app-toolkit/app-toolkit.interface';
import { PositionFetcher } from '~position/position-fetcher.interface';
import { AppTokenPosition } from '~position/position.interface';
import { Network } from '~types/network.interface';

import { QINV_DEFINITION } from '../qinv.definition';
import { QinvContractFactory } from '../contracts';

const QINV_VAULT_ADDRESS = '0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d';

const appId = QINV_DEFINITION.id;
const groupId = QINV_DEFINITION.groups.vault.id;
const network = Network.BASE_MAINNET;

@Register.TokenPositionFetcher({ appId, groupId, network })
export class QinvVaultTokenFetcher implements PositionFetcher<AppTokenPosition> {
  constructor(
    @Inject(APP_TOOLKIT) private readonly appToolkit: IAppToolkit,
    @Inject(QinvContractFactory)
    private readonly contractFactory: QinvContractFactory,
  ) {}

  async getPositions(): Promise<AppTokenPosition[]> {
    const multicall = this.appToolkit.getMulticall(network);
    const baseTokens = await this.appToolkit.getBaseTokenPrices(network);

    // Criar instância do contrato
    const vault = this.contractFactory.qinvVault({
      address: QINV_VAULT_ADDRESS,
      network,
    });

    const vaultContract = multicall.wrap(vault);

    // Buscar dados do vault
    const [symbol, decimals, totalSupply, totalAssets, underlyingAssetAddress] =
      await Promise.all([
        vaultContract.symbol(),
        vaultContract.decimals(),
        vaultContract.totalSupply(),
        vaultContract.totalAssets(),
        vaultContract.asset(),
      ]);

    // Encontrar o token base (underlying asset)
    const underlyingToken = baseTokens.find(
      (t) => t.address.toLowerCase() === underlyingAssetAddress.toLowerCase(),
    );
    if (!underlyingToken) return [];

    // Calcular price per share
    const supply = Number(totalSupply) / 10 ** decimals;
    const assets = Number(totalAssets) / 10 ** underlyingToken.decimals;
    const pricePerShare = supply > 0 ? assets / supply : 0;
    const price = pricePerShare * underlyingToken.price;
    const liquidity = assets * underlyingToken.price;

    // Construir o AppToken
    const vaultToken: AppTokenPosition = {
      type: 'app-token' as const,
      appId,
      groupId,
      address: QINV_VAULT_ADDRESS,
      network,
      symbol,
      decimals,
      supply,
      price,
      pricePerShare: [pricePerShare],
      tokens: [underlyingToken],
      dataProps: {
        liquidity,
        reserve: assets,
      },
      displayProps: {
        label: `QINV Vault (${symbol})`,
        secondaryLabel: `${(pricePerShare).toFixed(4)} ${underlyingToken.symbol} / share`,
        images: [
          // Logo do QINV — será substituído pelo logo real
          'https://qinv.ai/logo.png',
        ],
      },
    };

    return [vaultToken];
  }
}
```

### Passo 6: Criar o Module (qinv.module.ts)

```typescript
import { Register } from '~app-toolkit/decorators';
import { AbstractApp } from '~app/app.abstract';

import { QinvAppDefinition, QINV_DEFINITION } from './qinv.definition';
import { QinvContractFactory } from './contracts';
import { QinvVaultTokenFetcher } from './base/qinv.vault.token-fetcher';

@Register.AppModule({
  appId: QINV_DEFINITION.id,
  providers: [
    QinvAppDefinition,
    QinvContractFactory,
    QinvVaultTokenFetcher,
  ],
})
export class QinvAppModule extends AbstractApp() {}
```

### Passo 7: Adicionar o Logo

```bash
# Copiar logo para o diretório de assets
cp /caminho/do/logo/qinv.png src/apps/qinv/assets/qinv-logo.png

# Formato: PNG 256x256 ou SVG
# Fundo: Transparente
```

### Passo 8: Testar Localmente

```bash
# Rodar o studio em modo desenvolvimento
pnpm studio start

# Em outro terminal, testar o token fetcher
curl http://localhost:5001/apps/qinv/tokens?network=base

# Testar balance de uma carteira específica
curl "http://localhost:5001/apps/qinv/balances?network=base&addresses[]=0xSEU_ENDERECO"
```

**Resultado esperado do `/tokens`:**
```json
[
  {
    "type": "app-token",
    "appId": "qinv",
    "address": "0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d",
    "network": "base",
    "symbol": "QINDEX",
    "price": 1.05,
    "supply": 100,
    "pricePerShare": [1.05]
  }
]
```

### Passo 9: Submeter o Pull Request

```bash
git add .
git commit -m "feat(qinv): add QINV index fund vault integration on Base"
git push origin feat/add-qinv
```

#### Template do Pull Request

```markdown
## Add QINV Protocol Integration

### Protocol Information
- **Name:** QINV
- **Category:** Asset Management / Index Fund
- **Chain:** Base
- **Website:** https://qinv.ai
- **App:** https://app.qinv.ai
- **Contract (Vault):** 0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d

### What this PR adds
- App definition and module for QINV protocol
- Vault token fetcher for QINDEX token on Base
- Price per share calculation based on totalAssets/totalSupply
- Contract factory with vault ABI

### Token types
- **Vault Token (QINDEX):** Represents share of the index fund vault

### Testing
- [x] Token fetcher returns correct data
- [x] Price per share calculation verified
- [x] Logo added
- [x] Builds without errors

### Screenshots
[Adicionar screenshots do token aparecendo no Zapper local]
```

---

## 📋 Detalhes Técnicos: App Token vs Contract Position

### Quando usar AppToken (nosso caso)

**AppToken** = token ERC-20 que representa uma posição DeFi
- ✅ QINDEX é um ERC-20 que representa share do vault
- ✅ Tem `totalSupply`, `balanceOf`
- ✅ Tem preço derivado de underlying assets

### Quando usar ContractPosition

**ContractPosition** = posição que NÃO é representada por um token
- Staking sem receipt token
- Farming positions
- Locked positions

**QINV usa AppToken** porque QINDEX é um ERC-20 transferível.

---

## ❌ Motivos Comuns de Rejeição

| Motivo | Como evitar |
|--------|------------|
| **ABI incorreta** | Verificar contrato no BaseScan, copiar ABI exata |
| **Token fetcher não retorna dados** | Testar localmente com `pnpm studio start` |
| **Preço calculado errado** | Verificar decimals e pricePerShare math |
| **Sem testes** | Garantir que o build passa e o endpoint retorna dados |
| **Contrato não verificado** | Verificar no BaseScan ANTES |
| **Logo não incluído** | Adicionar PNG/SVG em `src/apps/qinv/assets/` |
| **TypeScript errors** | Rodar `pnpm lint` e `pnpm build` antes de submeter |
| **Network incorreta** | Usar `Network.BASE_MAINNET` para Base |
| **Código duplicado** | Reusar helpers do app-toolkit quando possível |
| **PR muito grande** | Manter escopo mínimo: apenas o que é necessário |

---

## 🔄 Pós-Listagem: Manutenção

### Monitoramento

- [ ] Verificar se o QINDEX aparece corretamente no Zapper (https://zapper.xyz)
- [ ] Conferir se o preço e saldo estão corretos
- [ ] Monitorar issues no GitHub relacionadas ao adapter

### Atualizações Futuras

Se o vault for atualizado (nova implementation):
1. Verificar se a ABI mudou
2. Atualizar o `QinvContractFactory` se necessário
3. Submeter novo PR com as mudanças

Se novos vaults forem adicionados:
1. Adicionar novos endereços ao token fetcher
2. Considerar criar group IDs separados por vault type

### Breaking Changes no Zapper Studio

O Zapper Studio pode mudar APIs. Ficar atento a:
- Migration guides no repo
- Major version bumps
- Deprecation notices

---

## 🔗 Links Úteis

| Recurso | URL |
|---------|-----|
| Zapper | https://zapper.xyz |
| Zapper Studio GitHub | https://github.com/Zapper-fi/studio |
| Zapper Studio Docs | https://studio.zapper.fi/docs |
| Exemplos de Vaults | Buscar `vault.token-fetcher.ts` no repo |
| Discord Zapper | https://discord.gg/zapper |

---

## ⚠️ Blockers Atuais para o QINV

1. **Contrato NÃO verificado no BaseScan** — Sem ABI pública, impossível criar contract factory
2. **ABI desconhecida** — Precisamos saber as funções exatas do vault (totalAssets? asset? convertToAssets?)
3. **TVL baixo (~$22)** — Não é blocker técnico, mas Zapper pode priorizar protocolos maiores no review

---

> ⚠️ **NOTA:** O Zapper Studio pode ter mudado sua arquitetura desde a última verificação. O código acima é baseado na estrutura conhecida. Sempre consulte o README e exemplos recentes do repositório antes de implementar.

---

*Última atualização: Fevereiro 2025*
*Próximo guia: [07-zerion.md](./07-zerion.md) — Zerion Integration*
