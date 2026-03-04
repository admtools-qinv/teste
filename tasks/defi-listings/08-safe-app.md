# 08 — Gnosis Safe App: Desenvolvimento de Safe{Wallet} App para QINV

> **Projeto:** QINV — Crypto Index Fund na Base Network
> **Token:** QINDEX
> **Vault (Proxy):** `0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d`
> **Implementation:** `0x53dc7d1a3796734f4ae5df06857cbb208af1b4ba`
> **Chain:** Base (chainId 8453)
> **Website:** https://qinv.ai | **App:** https://app.qinv.ai

---

## 📌 Visão Geral

### O que é o Safe{Wallet} (ex-Gnosis Safe)

Safe{Wallet} (https://safe.global) é a carteira multisig mais usada no ecossistema Ethereum e EVM-compatible chains. Gerencia bilhões de dólares em ativos cripto e é usada por DAOs, tesourarias de protocolos e investidores institucionais.

### O que são Safe Apps

Safe Apps são aplicações web que rodam **dentro** da interface do Safe{Wallet}. Funcionam como mini-dApps embeddadas que podem interagir diretamente com o cofre multisig do usuário, sem necessidade de conectar wallet externamente.

**Diretório de Safe Apps:** https://app.safe.global/apps
**Documentação:** https://docs.safe.global/safe-apps

### Por que importa para o QINV

- **Acesso institucional** — DAOs e treasuries podem investir no QINV index diretamente via Safe
- **Multisig nativo** — Operações de deposit/withdraw com aprovação multi-party
- **Confiança** — Estar no diretório Safe Apps é selo de qualidade para investidores sérios
- **Base network** — Safe já suporta Base, facilitando a integração
- **TVL potencial** — Treasuries de DAOs movimentam volumes significativos
- **Visibilidade** — Milhares de Safes ativos na Base network

### Impacto vs Esforço

| Aspecto | Detalhe |
|---------|---------|
| Impacto | ⭐⭐⭐⭐⭐ (muito alto para público institucional) |
| Dificuldade | Alta (desenvolvimento web + integração SDK) |
| Custo | Grátis (hosting pode ter custo mínimo) |
| Tempo estimado | 14-30 dias (desenvolvimento + review) |

---

## ✅ Pré-requisitos Específicos

- [ ] Contrato verificado no BaseScan (ver `00-prerequisites.md`) — **OBRIGATÓRIO**
- [ ] ABI do vault disponível publicamente
- [ ] Conhecimento de React/TypeScript
- [ ] Conhecimento básico de ethers.js ou viem/wagmi
- [ ] Conta no GitHub
- [ ] Domínio para hospedar o app (ex: safe.qinv.ai)
- [ ] SSL (HTTPS obrigatório)
- [ ] Logo do QINV em SVG e PNG (256x256)
- [ ] `manifest.json` do Safe App (ver abaixo)
- [ ] Familiaridade com ERC-4626 (deposit, withdraw, redeem)

---

## 🔧 Passo a Passo Completo

### Fase 1: Setup do Projeto

#### Passo 1: Criar Projeto usando Safe Apps SDK

O Safe fornece um template starter kit:

```bash
# Opção 1: Usar o template oficial (recomendado)
npx create-react-app qinv-safe-app --template @safe-global/cra-template-safe-app

# Opção 2: Adicionar SDK a um projeto existente
mkdir qinv-safe-app && cd qinv-safe-app
npm init -y
npm install react react-dom typescript @types/react @types/react-dom
npm install @safe-global/safe-apps-sdk @safe-global/safe-apps-react-sdk
npm install @safe-global/safe-apps-provider
npm install ethers@^6
```

#### Passo 2: Estrutura do Projeto

```
qinv-safe-app/
├── public/
│   ├── manifest.json          # ← Obrigatório para Safe Apps
│   ├── logo.svg               # ← Logo do app
│   └── index.html
├── src/
│   ├── App.tsx                # ← Entry point
│   ├── components/
│   │   ├── VaultInfo.tsx      # ← Info do vault (TVL, share price)
│   │   ├── DepositForm.tsx    # ← Formulário de deposit
│   │   ├── WithdrawForm.tsx   # ← Formulário de withdraw
│   │   └── PositionDisplay.tsx # ← Posição do Safe no vault
│   ├── hooks/
│   │   ├── useVault.ts        # ← Hook para interações com vault
│   │   └── useSafeAppsSDK.ts  # ← Hook wrapper do SDK
│   ├── constants/
│   │   ├── abi.ts             # ← ABI do vault
│   │   └── addresses.ts       # ← Endereços dos contratos
│   └── utils/
│       └── formatting.ts      # ← Utils de formatação
├── package.json
└── tsconfig.json
```

#### Passo 3: Configurar o manifest.json

```json
{
  "name": "QINV Index Fund",
  "description": "Invest in a diversified crypto index fund. Deposit assets into the QINV vault and receive QINDEX shares representing your proportional ownership of the portfolio.",
  "iconPath": "logo.svg",
  "providedBy": {
    "name": "QINV",
    "url": "https://qinv.ai"
  },
  "networks": {
    "8453": "base"
  }
}
```

> ⚠️ **O `manifest.json` DEVE estar em `public/` e acessível em `https://SEU_DOMINIO/manifest.json`**

---

### Fase 2: Desenvolvimento do App

#### Passo 4: Constantes e ABI

```typescript
// src/constants/addresses.ts
export const VAULT_ADDRESS = '0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d';
export const BASE_CHAIN_ID = 8453;

// src/constants/abi.ts
export const VAULT_ABI = [
  // Leitura
  'function name() view returns (string)',
  'function symbol() view returns (string)',
  'function decimals() view returns (uint8)',
  'function totalAssets() view returns (uint256)',
  'function totalSupply() view returns (uint256)',
  'function asset() view returns (address)',
  'function balanceOf(address owner) view returns (uint256)',
  'function convertToAssets(uint256 shares) view returns (uint256)',
  'function convertToShares(uint256 assets) view returns (uint256)',
  'function maxDeposit(address receiver) view returns (uint256)',
  'function maxWithdraw(address owner) view returns (uint256)',
  'function previewDeposit(uint256 assets) view returns (uint256)',
  'function previewWithdraw(uint256 assets) view returns (uint256)',
  'function previewRedeem(uint256 shares) view returns (uint256)',
  // Escrita
  'function deposit(uint256 assets, address receiver) returns (uint256 shares)',
  'function withdraw(uint256 assets, address receiver, address owner) returns (uint256 shares)',
  'function redeem(uint256 shares, address receiver, address owner) returns (uint256 assets)',
  'function approve(address spender, uint256 amount) returns (bool)',
] as const;

export const ERC20_ABI = [
  'function balanceOf(address owner) view returns (uint256)',
  'function decimals() view returns (uint8)',
  'function symbol() view returns (string)',
  'function name() view returns (string)',
  'function allowance(address owner, address spender) view returns (uint256)',
  'function approve(address spender, uint256 amount) returns (bool)',
] as const;
```

#### Passo 5: Hook Principal do Vault

```typescript
// src/hooks/useVault.ts
import { useState, useEffect, useCallback } from 'react';
import { ethers } from 'ethers';
import { useSafeAppsSDK } from '@safe-global/safe-apps-react-sdk';
import { VAULT_ADDRESS } from '../constants/addresses';
import { VAULT_ABI, ERC20_ABI } from '../constants/abi';

interface VaultState {
  totalAssets: bigint;
  totalSupply: bigint;
  userShares: bigint;
  userAssetsValue: bigint;
  underlyingAsset: string;
  underlyingBalance: bigint;
  underlyingAllowance: bigint;
  underlyingSymbol: string;
  underlyingDecimals: number;
  vaultDecimals: number;
  sharePrice: number; // assets por share
  loading: boolean;
  error: string | null;
}

export function useVault() {
  const { sdk, safe } = useSafeAppsSDK();
  const [state, setState] = useState<VaultState>({
    totalAssets: 0n,
    totalSupply: 0n,
    userShares: 0n,
    userAssetsValue: 0n,
    underlyingAsset: '',
    underlyingBalance: 0n,
    underlyingAllowance: 0n,
    underlyingSymbol: '',
    underlyingDecimals: 18,
    vaultDecimals: 18,
    sharePrice: 0,
    loading: true,
    error: null,
  });

  const provider = useMemo(() => {
    return new ethers.BrowserProvider(new SafeAppProvider(safe, sdk));
  }, [sdk, safe]);

  const fetchVaultData = useCallback(async () => {
    try {
      const vault = new ethers.Contract(VAULT_ADDRESS, VAULT_ABI, provider);
      
      const [
        totalAssets,
        totalSupply,
        userShares,
        underlyingAsset,
        vaultDecimals,
      ] = await Promise.all([
        vault.totalAssets(),
        vault.totalSupply(),
        vault.balanceOf(safe.safeAddress),
        vault.asset(),
        vault.decimals(),
      ]);

      // Buscar dados do underlying asset
      const underlying = new ethers.Contract(underlyingAsset, ERC20_ABI, provider);
      const [underlyingBalance, underlyingAllowance, underlyingSymbol, underlyingDecimals] = 
        await Promise.all([
          underlying.balanceOf(safe.safeAddress),
          underlying.allowance(safe.safeAddress, VAULT_ADDRESS),
          underlying.symbol(),
          underlying.decimals(),
        ]);

      // Calcular valor em assets
      const userAssetsValue = userShares > 0n 
        ? await vault.convertToAssets(userShares)
        : 0n;

      // Share price
      const sharePrice = totalSupply > 0n
        ? Number(totalAssets) / Number(totalSupply)
        : 1;

      setState({
        totalAssets,
        totalSupply,
        userShares,
        userAssetsValue,
        underlyingAsset,
        underlyingBalance,
        underlyingAllowance,
        underlyingSymbol,
        underlyingDecimals,
        vaultDecimals,
        sharePrice,
        loading: false,
        error: null,
      });
    } catch (err) {
      setState(prev => ({
        ...prev,
        loading: false,
        error: `Erro ao carregar dados do vault: ${err}`,
      }));
    }
  }, [provider, safe.safeAddress]);

  useEffect(() => {
    fetchVaultData();
    const interval = setInterval(fetchVaultData, 15000); // refresh a cada 15s
    return () => clearInterval(interval);
  }, [fetchVaultData]);

  return { ...state, refresh: fetchVaultData, provider };
}
```

#### Passo 6: Componente de Deposit

```typescript
// src/components/DepositForm.tsx
import React, { useState } from 'react';
import { ethers } from 'ethers';
import { useSafeAppsSDK } from '@safe-global/safe-apps-react-sdk';
import { BaseTransaction } from '@safe-global/safe-apps-sdk';
import { VAULT_ADDRESS } from '../constants/addresses';
import { VAULT_ABI, ERC20_ABI } from '../constants/abi';

interface DepositFormProps {
  underlyingAsset: string;
  underlyingBalance: bigint;
  underlyingAllowance: bigint;
  underlyingSymbol: string;
  underlyingDecimals: number;
  onSuccess: () => void;
}

export function DepositForm({
  underlyingAsset,
  underlyingBalance,
  underlyingAllowance,
  underlyingSymbol,
  underlyingDecimals,
  onSuccess,
}: DepositFormProps) {
  const { sdk, safe } = useSafeAppsSDK();
  const [amount, setAmount] = useState('');
  const [loading, setLoading] = useState(false);

  const handleDeposit = async () => {
    if (!amount || parseFloat(amount) <= 0) return;
    setLoading(true);

    try {
      const depositAmount = ethers.parseUnits(amount, underlyingDecimals);
      const txs: BaseTransaction[] = [];

      // Se allowance insuficiente, adicionar tx de approve
      if (underlyingAllowance < depositAmount) {
        const iface = new ethers.Interface(ERC20_ABI);
        txs.push({
          to: underlyingAsset,
          value: '0',
          data: iface.encodeFunctionData('approve', [
            VAULT_ADDRESS,
            depositAmount,
          ]),
        });
      }

      // Transaction de deposit
      const vaultIface = new ethers.Interface(VAULT_ABI);
      txs.push({
        to: VAULT_ADDRESS,
        value: '0',
        data: vaultIface.encodeFunctionData('deposit', [
          depositAmount,
          safe.safeAddress,
        ]),
      });

      // Submeter batch de transactions
      // O Safe SDK permite enviar múltiplas txs como batch (approve + deposit)
      await sdk.txs.send({ txs });

      setAmount('');
      onSuccess();
    } catch (err) {
      console.error('Deposit error:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleMax = () => {
    setAmount(ethers.formatUnits(underlyingBalance, underlyingDecimals));
  };

  return (
    <div className="deposit-form">
      <h3>Depositar no QINV Vault</h3>
      
      <div className="balance-info">
        <span>Saldo disponível: </span>
        <strong>
          {ethers.formatUnits(underlyingBalance, underlyingDecimals)} {underlyingSymbol}
        </strong>
      </div>

      <div className="input-group">
        <input
          type="number"
          placeholder="0.00"
          value={amount}
          onChange={(e) => setAmount(e.target.value)}
          min="0"
          step="any"
        />
        <button onClick={handleMax} className="max-btn">MAX</button>
      </div>

      <button
        onClick={handleDeposit}
        disabled={loading || !amount || parseFloat(amount) <= 0}
        className="deposit-btn"
      >
        {loading ? 'Processando...' : 'Depositar'}
      </button>

      <p className="info-text">
        Você receberá QINDEX shares proporcionais ao seu depósito.
        {underlyingAllowance < ethers.parseUnits(amount || '0', underlyingDecimals) && (
          <span className="approval-note">
            ⚠️ Uma transação de aprovação será incluída automaticamente.
          </span>
        )}
      </p>
    </div>
  );
}
```

#### Passo 7: Componente de Withdraw/Redeem

```typescript
// src/components/WithdrawForm.tsx
import React, { useState } from 'react';
import { ethers } from 'ethers';
import { useSafeAppsSDK } from '@safe-global/safe-apps-react-sdk';
import { BaseTransaction } from '@safe-global/safe-apps-sdk';
import { VAULT_ADDRESS } from '../constants/addresses';
import { VAULT_ABI } from '../constants/abi';

interface WithdrawFormProps {
  userShares: bigint;
  userAssetsValue: bigint;
  vaultDecimals: number;
  underlyingDecimals: number;
  underlyingSymbol: string;
  onSuccess: () => void;
}

export function WithdrawForm({
  userShares,
  userAssetsValue,
  vaultDecimals,
  underlyingDecimals,
  underlyingSymbol,
  onSuccess,
}: WithdrawFormProps) {
  const { sdk, safe } = useSafeAppsSDK();
  const [shares, setShares] = useState('');
  const [loading, setLoading] = useState(false);

  const handleRedeem = async () => {
    if (!shares || parseFloat(shares) <= 0) return;
    setLoading(true);

    try {
      const redeemShares = ethers.parseUnits(shares, vaultDecimals);
      const vaultIface = new ethers.Interface(VAULT_ABI);

      const txs: BaseTransaction[] = [
        {
          to: VAULT_ADDRESS,
          value: '0',
          data: vaultIface.encodeFunctionData('redeem', [
            redeemShares,
            safe.safeAddress,
            safe.safeAddress,
          ]),
        },
      ];

      await sdk.txs.send({ txs });
      setShares('');
      onSuccess();
    } catch (err) {
      console.error('Redeem error:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleMax = () => {
    setShares(ethers.formatUnits(userShares, vaultDecimals));
  };

  return (
    <div className="withdraw-form">
      <h3>Resgatar do QINV Vault</h3>

      <div className="position-info">
        <div>
          <span>Suas shares: </span>
          <strong>{ethers.formatUnits(userShares, vaultDecimals)} QINDEX</strong>
        </div>
        <div>
          <span>Valor estimado: </span>
          <strong>
            {ethers.formatUnits(userAssetsValue, underlyingDecimals)} {underlyingSymbol}
          </strong>
        </div>
      </div>

      <div className="input-group">
        <input
          type="number"
          placeholder="0.00"
          value={shares}
          onChange={(e) => setShares(e.target.value)}
          min="0"
          step="any"
        />
        <button onClick={handleMax} className="max-btn">MAX</button>
      </div>

      <button
        onClick={handleRedeem}
        disabled={loading || !shares || parseFloat(shares) <= 0}
        className="redeem-btn"
      >
        {loading ? 'Processando...' : 'Resgatar'}
      </button>

      <p className="info-text">
        Você receberá {underlyingSymbol} proporcional às shares resgatadas.
      </p>
    </div>
  );
}
```

#### Passo 8: App Principal

```typescript
// src/App.tsx
import React, { useState } from 'react';
import { SafeProvider } from '@safe-global/safe-apps-react-sdk';
import { useVault } from './hooks/useVault';
import { DepositForm } from './components/DepositForm';
import { WithdrawForm } from './components/WithdrawForm';
import { ethers } from 'ethers';

function SafeApp() {
  const vault = useVault();
  const [activeTab, setActiveTab] = useState<'deposit' | 'withdraw'>('deposit');

  if (vault.loading) {
    return <div className="loading">Carregando dados do vault...</div>;
  }

  if (vault.error) {
    return <div className="error">{vault.error}</div>;
  }

  return (
    <div className="qinv-safe-app">
      <header>
        <img src="/logo.svg" alt="QINV" className="logo" />
        <h1>QINV Index Fund</h1>
        <p>Invista em um index fund cripto diversificado</p>
      </header>

      {/* Vault Stats */}
      <section className="vault-stats">
        <div className="stat">
          <label>Total Value Locked</label>
          <value>
            {ethers.formatUnits(vault.totalAssets, vault.underlyingDecimals)}{' '}
            {vault.underlyingSymbol}
          </value>
        </div>
        <div className="stat">
          <label>Total Shares</label>
          <value>{ethers.formatUnits(vault.totalSupply, vault.vaultDecimals)} QINDEX</value>
        </div>
        <div className="stat">
          <label>Share Price</label>
          <value>{vault.sharePrice.toFixed(6)} {vault.underlyingSymbol}/QINDEX</value>
        </div>
      </section>

      {/* User Position */}
      {vault.userShares > 0n && (
        <section className="user-position">
          <h3>Sua Posição</h3>
          <div className="position-details">
            <span>
              {ethers.formatUnits(vault.userShares, vault.vaultDecimals)} QINDEX
            </span>
            <span className="separator">≈</span>
            <span>
              {ethers.formatUnits(vault.userAssetsValue, vault.underlyingDecimals)}{' '}
              {vault.underlyingSymbol}
            </span>
          </div>
        </section>
      )}

      {/* Tabs */}
      <div className="tabs">
        <button
          className={activeTab === 'deposit' ? 'active' : ''}
          onClick={() => setActiveTab('deposit')}
        >
          Depositar
        </button>
        <button
          className={activeTab === 'withdraw' ? 'active' : ''}
          onClick={() => setActiveTab('withdraw')}
        >
          Resgatar
        </button>
      </div>

      {/* Forms */}
      {activeTab === 'deposit' ? (
        <DepositForm
          underlyingAsset={vault.underlyingAsset}
          underlyingBalance={vault.underlyingBalance}
          underlyingAllowance={vault.underlyingAllowance}
          underlyingSymbol={vault.underlyingSymbol}
          underlyingDecimals={vault.underlyingDecimals}
          onSuccess={vault.refresh}
        />
      ) : (
        <WithdrawForm
          userShares={vault.userShares}
          userAssetsValue={vault.userAssetsValue}
          vaultDecimals={vault.vaultDecimals}
          underlyingDecimals={vault.underlyingDecimals}
          underlyingSymbol={vault.underlyingSymbol}
          onSuccess={vault.refresh}
        />
      )}

      <footer>
        <a href="https://qinv.ai" target="_blank" rel="noopener noreferrer">
          qinv.ai
        </a>
        <span>•</span>
        <a href="https://app.qinv.ai" target="_blank" rel="noopener noreferrer">
          App
        </a>
        <span>•</span>
        <a
          href="https://basescan.org/address/0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d"
          target="_blank"
          rel="noopener noreferrer"
        >
          BaseScan
        </a>
      </footer>
    </div>
  );
}

function App() {
  return (
    <SafeProvider>
      <SafeApp />
    </SafeProvider>
  );
}

export default App;
```

---

### Fase 3: Testes e Deploy

#### Passo 9: Testar Localmente com Safe

```bash
# Iniciar o servidor de desenvolvimento
npm start
# O app roda em http://localhost:3000

# Testar no Safe{Wallet}:
# 1. Ir para https://app.safe.global
# 2. Conectar a um Safe na Base network
# 3. Ir em Apps → "Add custom app"
# 4. Colar URL: http://localhost:3000
# 5. O Safe carrega o manifest.json e exibe o app
```

> ⚠️ **Para testes locais**, o Safe permite adicionar apps de localhost. Em produção, precisa de HTTPS.

#### Passo 10: Checklist de Testes

```markdown
## Testes Obrigatórios

### Leitura
- [ ] Vault stats carregam corretamente (TVL, supply, share price)
- [ ] Posição do usuário exibe corretamente
- [ ] Saldo do underlying asset exibe corretamente
- [ ] App funciona quando Safe não tem posição no vault

### Deposit
- [ ] Approve funciona quando allowance é zero
- [ ] Deposit com valor válido cria transação correta
- [ ] Batch approve+deposit funciona como transação única
- [ ] Botão MAX preenche saldo total
- [ ] Input não aceita valores negativos
- [ ] Erro tratado quando saldo insuficiente

### Withdraw/Redeem
- [ ] Redeem cria transação correta
- [ ] Botão MAX preenche shares totais
- [ ] Erro tratado quando shares insuficientes

### Edge Cases
- [ ] Safe sem saldo de underlying
- [ ] Safe sem posição no vault
- [ ] Vault com totalSupply = 0
- [ ] Rede errada (não é Base)
- [ ] Conexão lenta / RPC timeout
```

#### Passo 11: Deploy

```bash
# Build de produção
npm run build

# Opções de hosting:

# 1. Vercel (recomendado — grátis, HTTPS automático)
npm install -g vercel
vercel --prod
# URL: https://qinv-safe-app.vercel.app

# 2. Netlify
npm install -g netlify-cli
netlify deploy --prod --dir=build
# URL: https://qinv-safe-app.netlify.app

# 3. GitHub Pages
npm install gh-pages --save-dev
# Adicionar ao package.json:
# "homepage": "https://qinv.github.io/safe-app",
# "scripts": { "deploy": "gh-pages -d build" }
npm run deploy

# 4. Custom domain
# Apontar safe.qinv.ai para o hosting escolhido
# Configurar HTTPS via Let's Encrypt ou Cloudflare
```

---

### Fase 4: Submissão ao Diretório Safe Apps

#### Passo 12: Submeter ao Registro Oficial

O registro de Safe Apps é mantido no GitHub:

```
URL: https://github.com/safe-global/safe-apps-list
```

```bash
# Fork do repositório
# URL: https://github.com/safe-global/safe-apps-list → Fork

git clone https://github.com/SEU_USUARIO/safe-apps-list.git
cd safe-apps-list
git checkout -b add-qinv-app
```

#### Passo 13: Adicionar ao Registro

Seguir a estrutura do repositório (verificar README para formato atual):

```json
{
  "app": {
    "url": "https://safe.qinv.ai",
    "name": "QINV Index Fund",
    "iconUrl": "https://safe.qinv.ai/logo.svg",
    "description": "Invest in a diversified crypto index fund on Base. Deposit assets into the QINV ERC-4626 vault and receive QINDEX shares.",
    "chains": [8453],
    "provider": {
      "url": "https://qinv.ai",
      "name": "QINV"
    },
    "accessControl": {
      "type": "NO_RESTRICTIONS"
    },
    "tags": ["defi", "investments", "asset-management"]
  }
}
```

#### Passo 14: Pull Request

```bash
git add .
git commit -m "feat: add QINV Index Fund Safe App

- App URL: https://safe.qinv.ai
- Chain: Base (8453)
- Features: ERC-4626 vault deposit/withdraw
- Category: DeFi / Asset Management"

git push origin add-qinv-app
```

**PR Description:**

```markdown
## Safe App: QINV Index Fund

### Description
QINV is a decentralized crypto index fund on Base network. This Safe App allows 
multisig wallets to deposit assets into the QINV ERC-4626 vault and manage their 
positions directly from the Safe{Wallet} interface.

### Features
- View vault statistics (TVL, share price, total supply)
- View Safe's current position in the vault
- Deposit underlying assets (with automatic approve batching)
- Redeem QINDEX shares for underlying assets
- Real-time data refresh

### Technical Details
- **Vault Standard:** ERC-4626
- **Chain:** Base (8453)
- **Contract:** `0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d`
- **SDK:** @safe-global/safe-apps-sdk

### Links
- App URL: https://safe.qinv.ai
- Website: https://qinv.ai
- BaseScan: https://basescan.org/address/0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d

### Screenshots
[Incluir screenshots do app funcionando dentro do Safe]

### Testing
- Tested on Base mainnet with Safe wallet
- All deposit/withdraw flows verified
- Edge cases handled (no balance, no position, wrong network)
```

---

## 📋 Campos e Valores Sugeridos (Resumo)

| Campo | Valor |
|-------|-------|
| App Name | QINV Index Fund |
| App URL | https://safe.qinv.ai |
| Description | Invest in a diversified crypto index fund on Base. Deposit assets and receive QINDEX shares. |
| Icon URL | https://safe.qinv.ai/logo.svg |
| Chains | [8453] (Base) |
| Provider Name | QINV |
| Provider URL | https://qinv.ai |
| Tags | defi, investments, asset-management |
| Access Control | NO_RESTRICTIONS |

---

## ❌ Motivos Comuns de Rejeição

| Motivo | Como Resolver |
|--------|--------------|
| **manifest.json inacessível** | Verificar que `https://dominio/manifest.json` retorna JSON válido |
| **HTTPS ausente** | Deploy com HTTPS obrigatório (Vercel/Netlify fazem automaticamente) |
| **Contrato não verificado** | Verificar no BaseScan (ver `00-prerequisites.md`) |
| **App não funciona no Safe iframe** | Testar extensivamente dentro do Safe, não apenas standalone |
| **CORS issues** | Configurar headers CORS no hosting |
| **Sem tratamento de erros** | App deve funcionar graciosamente em todos os edge cases |
| **UI/UX ruim** | Design profissional, responsivo, acessível |
| **Sem testes** | Demonstrar que o app foi testado com Safe real |
| **Descrição vaga** | Ser específico sobre o que o app faz |
| **App muito simples** | Deve agregar valor real vs. usar o app web normal |

---

## 🔄 Manutenção Pós-Listagem

### Monitoramento

- [ ] Verificar semanalmente se o app funciona no Safe{Wallet}
- [ ] Monitorar erros via console/Sentry
- [ ] Acompanhar issues no repositório safe-apps-list
- [ ] Testar após updates do Safe{Wallet}

### Atualizações Necessárias

| Evento | Ação |
|--------|------|
| Upgrade do vault (nova implementation) | Atualizar ABI se interface mudar |
| Safe Apps SDK update | Atualizar dependências e testar |
| Nova chain suportada pelo QINV | Adicionar chain ao manifest.json |
| Novas features no vault | Adicionar UI correspondente |
| Safe depreca versão do SDK | Migrar para nova versão |
| Domínio expira | Renovar domínio e SSL |

### Melhorias Futuras

- [ ] Histórico de transações do Safe no vault
- [ ] Gráfico de performance do index
- [ ] Composição dos ativos do vault (pie chart)
- [ ] Estimativa de gas antes de submeter
- [ ] Suporte a múltiplas chains (quando QINV expandir)
- [ ] Notificações de rebalanceamento
- [ ] Comparação de performance vs. benchmarks

---

## 🔗 Links Úteis

| Recurso | URL |
|---------|-----|
| Safe{Wallet} | https://app.safe.global |
| Safe Apps SDK Docs | https://docs.safe.global/safe-apps |
| Safe Apps SDK GitHub | https://github.com/safe-global/safe-apps-sdk |
| Safe Apps List (registro) | https://github.com/safe-global/safe-apps-list |
| Safe CRA Template | https://github.com/safe-global/safe-apps-sdk/tree/main/packages/cra-template-safe-app |
| Safe Developer Hub | https://docs.safe.global |
| ERC-4626 Spec | https://eips.ethereum.org/EIPS/eip-4626 |
| BaseScan QINDEX | https://basescan.org/address/0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d |

---

## 📅 Timeline Estimada

| Fase | Duração | Notas |
|------|---------|-------|
| Setup e planejamento | 1-2 dias | Template, arquitetura, manifest |
| Desenvolvimento core | 5-10 dias | Components, hooks, styling |
| Testes dentro do Safe | 2-3 dias | Testar em Safe real na Base |
| Deploy e HTTPS | 1 dia | Vercel/Netlify |
| PR e review | 5-14 dias | Backlog do time Safe |
| **Total estimado** | **14-30 dias** | |

---

## 💡 Dicas Estratégicas

1. **Use o template oficial** — `cra-template-safe-app` já vem configurado corretamente
2. **Batch transactions** — A killer feature do Safe é batching; sempre combine approve+deposit em uma tx
3. **Mobile responsive** — Safe{Wallet} é usado em mobile; teste responsividade
4. **Error boundaries** — Um crash no app dentro do iframe é péssima UX; use React Error Boundaries
5. **Não reinvente** — Use o SDK oficial; não tente conectar wallet manualmente
6. **Screenshots no PR** — Facilitam o review e aumentam chance de aprovação
7. **App standalone** — O app pode funcionar também fora do Safe (como dApp normal) para demonstração
8. **Institucional focus** — O público do Safe é institucional; UI deve ser profissional e séria
