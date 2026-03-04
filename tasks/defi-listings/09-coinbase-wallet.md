# 09 — Coinbase Wallet: Discovery e Integração

> **Projeto:** QINV — Crypto Index Fund na Base Network
> **Token:** QINDEX
> **Vault (Proxy):** `0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d`
> **Chain:** Base (chainId 8453)
> **Website:** https://qinv.ai | **App:** https://app.qinv.ai

---

## 📌 Visão Geral

### O que é Coinbase Wallet Discovery

A Coinbase Wallet tem um browser/discovery integrado que sugere dApps aos usuários. Por ser a wallet da mesma empresa que opera a Base chain, projetos nativos da Base têm uma vantagem natural para aparecer nesse discovery.

### Caminhos de Visibilidade na Coinbase Wallet

| Caminho | Descrição | Esforço | Impacto |
|---------|-----------|---------|---------|
| **Base Ecosystem Listing** | Listagem em base.org/ecosystem alimenta sugestões | Baixo | Alto |
| **Coinbase Wallet SDK** | Integrar SDK para conectar seamlessly | Médio | Médio |
| **OnchainKit** | Framework da Coinbase para dApps Base | Médio | Alto |
| **Wallet Browser** | Usuários acessam app.qinv.ai pelo browser da wallet | Zero | Básico |
| **Token Recognition** | Token aparece com nome/logo na wallet | Baixo (via CoinGecko) | Alto |

### Por que importa para o QINV

- **Base-native advantage** — QINV roda na Base, chain operada pela Coinbase
- **Millions of users** — Coinbase Wallet tem milhões de usuários
- **Mobile-first** — Acesso direto do celular via wallet browser
- **Onramp integrado** — Usuários podem comprar crypto e investir no QINV no mesmo fluxo
- **OnchainKit** — QINV já usa OnchainKit, o que facilita integração
- **Brand trust** — Coinbase brand = confiança para usuários mainstream

### Impacto vs Esforço

| Aspecto | Detalhe |
|---------|---------|
| Impacto | ⭐⭐⭐⭐⭐ (máximo para projeto Base-native) |
| Dificuldade | Baixa a Média (depende do caminho) |
| Custo | Grátis |
| Tempo estimado | 1-4 semanas (combinando todos os caminhos) |

---

## ✅ Pré-requisitos Específicos

- [ ] Contrato verificado no BaseScan (ver `00-prerequisites.md`)
- [ ] App funcional na Base (app.qinv.ai)
- [ ] Token listado no CoinGecko (ver `02-coingecko.md`) — para token recognition
- [ ] Listado no Base Ecosystem (ver `05-base-ecosystem.md`) — para discovery
- [ ] Conta no GitHub
- [ ] Node.js v18+ instalado
- [ ] Familiaridade com React/Next.js (para integrações de SDK)

---

## 🔧 Caminho 1: Via Base Ecosystem Listing

### Como funciona

A listagem no Base Ecosystem (base.org/ecosystem) alimenta diretamente as sugestões da Coinbase Wallet. Quando um dApp está listado no ecossistema Base, ele tem maior probabilidade de aparecer no:

- Browser da Coinbase Wallet (seção "Explore")
- Sugestões baseadas em categoria (DeFi, Asset Management)
- Resultados de busca dentro da wallet

### Passo a Passo

1. **Completar o guia `05-base-ecosystem.md`** — listar no base.org/ecosystem
2. **Garantir que app.qinv.ai funciona bem em mobile** — Coinbase Wallet usa browser mobile
3. **Testar a dApp na Coinbase Wallet:**
   - Abrir Coinbase Wallet (app mobile)
   - Ir na aba "Browser" 
   - Digitar `app.qinv.ai`
   - Verificar que a UI funciona corretamente
   - Testar fluxo de deposit/withdraw

### Otimizações para Mobile

```css
/* Garantir que o app é responsive */
@media (max-width: 768px) {
  .container {
    padding: 16px;
    max-width: 100%;
  }
  
  .button {
    width: 100%;
    padding: 16px;
    font-size: 18px;
    /* Botões maiores para touch */
  }
  
  input {
    font-size: 16px; /* Evita zoom automático no iOS */
  }
}
```

### Meta Tags para Discovery

Adicionar meta tags ao `<head>` do app.qinv.ai para melhorar discovery:

```html
<head>
  <!-- Basic -->
  <title>QINV - AI-Powered Crypto Index Fund on Base</title>
  <meta name="description" content="Invest in a diversified crypto portfolio. Deposit assets and receive QINDEX tokens on Base network." />
  
  <!-- Open Graph -->
  <meta property="og:title" content="QINV - Crypto Index Fund" />
  <meta property="og:description" content="AI-powered crypto index fund on Base. Diversified crypto exposure via a single token." />
  <meta property="og:image" content="https://qinv.ai/og-image.png" />
  <meta property="og:url" content="https://app.qinv.ai" />
  
  <!-- DApp Meta -->
  <meta name="dapp:chain" content="base" />
  <meta name="dapp:category" content="defi" />
</head>
```

---

## 🔧 Caminho 2: Coinbase Wallet SDK

### O que é

O Coinbase Wallet SDK permite integrar a conexão com Coinbase Wallet de forma nativa, oferecendo a melhor UX possível para usuários dessa wallet.

### Instalação

```bash
npm install @coinbase/wallet-sdk
```

### Integração Básica

```typescript
import CoinbaseWalletSDK from '@coinbase/wallet-sdk';

// Inicializar o SDK
const coinbaseWallet = new CoinbaseWalletSDK({
  appName: 'QINV - Crypto Index Fund',
  appLogoUrl: 'https://qinv.ai/logo.png',
  appChainIds: [8453], // Base
});

// Criar provider
const provider = coinbaseWallet.makeWeb3Provider();

// Conectar wallet
async function connectWallet() {
  try {
    const accounts = await provider.request({
      method: 'eth_requestAccounts',
    });
    
    console.log('Connected:', accounts[0]);
    
    // Verificar/trocar para Base
    try {
      await provider.request({
        method: 'wallet_switchEthereumChain',
        params: [{ chainId: '0x2105' }], // 8453 em hex
      });
    } catch (switchError: any) {
      // Se Base não está adicionada, adicionar
      if (switchError.code === 4902) {
        await provider.request({
          method: 'wallet_addEthereumChain',
          params: [{
            chainId: '0x2105',
            chainName: 'Base',
            nativeCurrency: { name: 'Ether', symbol: 'ETH', decimals: 18 },
            rpcUrls: ['https://mainnet.base.org'],
            blockExplorerUrls: ['https://basescan.org'],
          }],
        });
      }
    }
    
    return accounts[0];
  } catch (error) {
    console.error('Connection failed:', error);
    throw error;
  }
}
```

### Integração com wagmi/viem (Recomendado)

Se o app já usa wagmi (como muitos projetos Base):

```typescript
import { createConfig, http } from 'wagmi';
import { base } from 'wagmi/chains';
import { coinbaseWallet } from 'wagmi/connectors';

const config = createConfig({
  chains: [base],
  connectors: [
    coinbaseWallet({
      appName: 'QINV - Crypto Index Fund',
      appLogoUrl: 'https://qinv.ai/logo.png',
      preference: 'smartWalletOnly', // ou 'all' para suportar ambos
    }),
  ],
  transports: {
    [base.id]: http(),
  },
});
```

### Smart Wallet Support

A Coinbase Wallet agora suporta Smart Wallets (account abstraction). Para melhor compatibilidade:

```typescript
import { coinbaseWallet } from 'wagmi/connectors';

// Suportar tanto Smart Wallet quanto EOA
const connector = coinbaseWallet({
  appName: 'QINV',
  preference: 'all', // 'smartWalletOnly' | 'eoaOnly' | 'all'
});
```

---

## 🔧 Caminho 3: OnchainKit (Já usado pelo QINV)

### O que é OnchainKit

OnchainKit é o framework oficial da Coinbase para construir dApps na Base. Fornece componentes React prontos para:

- Conexão de wallet
- Identity (ENS, basename)
- Transações
- Swap
- Buy crypto (onramp)
- NFT minting

**Repositório:** https://github.com/coinbase/onchainkit
**Docs:** https://onchainkit.xyz

### Vantagem: QINV já usa OnchainKit

Se o QINV já integra o OnchainKit, isso significa:

1. ✅ Conexão com Coinbase Wallet já funciona
2. ✅ Componentes otimizados para Base já estão em uso
3. ✅ Pode aproveitar mais features para melhorar UX

### Componentes Úteis para o QINV

#### Identity Component (mostrar nome do usuário)

```tsx
import { Identity, Name, Avatar } from '@coinbase/onchainkit/identity';

function UserProfile({ address }: { address: `0x${string}` }) {
  return (
    <Identity address={address} chain={base}>
      <Avatar />
      <Name />
    </Identity>
  );
}
```

#### Transaction Component (simplificar deposit)

```tsx
import { 
  Transaction, 
  TransactionButton,
  TransactionStatus,
  TransactionStatusLabel,
  TransactionStatusAction,
} from '@coinbase/onchainkit/transaction';
import { base } from 'wagmi/chains';
import { encodeFunctionData, parseUnits } from 'viem';

const VAULT_ABI = [
  {
    name: 'deposit',
    type: 'function',
    inputs: [
      { name: 'assets', type: 'uint256' },
      { name: 'receiver', type: 'address' },
    ],
    outputs: [{ name: 'shares', type: 'uint256' }],
    stateMutability: 'nonpayable',
  },
] as const;

function DepositButton({ 
  amount, 
  receiver 
}: { 
  amount: string; 
  receiver: `0x${string}` 
}) {
  const calls = [
    // Approve (se necessário)
    {
      to: UNDERLYING_ASSET_ADDRESS as `0x${string}`,
      data: encodeFunctionData({
        abi: ERC20_ABI,
        functionName: 'approve',
        args: [QINV_VAULT as `0x${string}`, parseUnits(amount, 6)],
      }),
    },
    // Deposit
    {
      to: QINV_VAULT as `0x${string}`,
      data: encodeFunctionData({
        abi: VAULT_ABI,
        functionName: 'deposit',
        args: [parseUnits(amount, 6), receiver],
      }),
    },
  ];

  return (
    <Transaction
      chainId={base.id}
      calls={calls}
    >
      <TransactionButton text="Invest in QINV" />
      <TransactionStatus>
        <TransactionStatusLabel />
        <TransactionStatusAction />
      </TransactionStatus>
    </Transaction>
  );
}
```

#### Buy Crypto Onramp (fiat → crypto → QINV)

```tsx
import { Buy } from '@coinbase/onchainkit/buy';

// Permite que usuários comprem crypto diretamente via Coinbase Pay
// e depois depositem no vault
function BuyAndInvest() {
  return (
    <div>
      <h3>Don't have crypto yet?</h3>
      <Buy />
      <p>After buying, you can deposit into the QINV vault above.</p>
    </div>
  );
}
```

#### Wallet Component

```tsx
import { 
  ConnectWallet, 
  Wallet, 
  WalletDropdown, 
  WalletDropdownDisconnect 
} from '@coinbase/onchainkit/wallet';

function WalletConnect() {
  return (
    <Wallet>
      <ConnectWallet>
        <span>Connect to Invest</span>
      </ConnectWallet>
      <WalletDropdown>
        <WalletDropdownDisconnect />
      </WalletDropdown>
    </Wallet>
  );
}
```

### Configuração do OnchainKit

```tsx
// providers.tsx
import { OnchainKitProvider } from '@coinbase/onchainkit';
import { base } from 'wagmi/chains';

function Providers({ children }: { children: React.ReactNode }) {
  return (
    <OnchainKitProvider
      apiKey={process.env.NEXT_PUBLIC_ONCHAINKIT_API_KEY}
      chain={base}
      config={{
        appearance: {
          name: 'QINV',
          logo: 'https://qinv.ai/logo.png',
          mode: 'auto', // light/dark/auto
          theme: 'default',
        },
      }}
    >
      {children}
    </OnchainKitProvider>
  );
}
```

---

## 🔧 Caminho 4: Token Recognition na Coinbase Wallet

### Como funciona

Para que o QINDEX apareça com nome, símbolo e logo corretos na Coinbase Wallet (em vez de "Unknown Token"):

1. **CoinGecko listing** — Coinbase Wallet puxa dados de tokens do CoinGecko
2. **Base token list** — Tokens na lista oficial da Base aparecem automaticamente
3. **Uniswap token list** — Lista de tokens do Uniswap (se QINDEX tiver pool)

### Opção A: Via CoinGecko (principal)

Seguir `02-coingecko.md`. Após listagem:
- Coinbase Wallet detecta automaticamente (24-72h)
- Nome, símbolo, logo e preço aparecem

### Opção B: Token List da Base

Se existir uma token list oficial da Base, submeter QINDEX:

```json
{
  "name": "QINDEX",
  "address": "0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d",
  "symbol": "QINDEX",
  "decimals": 18,
  "chainId": 8453,
  "logoURI": "https://qinv.ai/tokens/qindex.png"
}
```

Verificar: https://github.com/ethereum-optimism/ethereum-optimism.github.io (Base usa infra similar ao Optimism para token lists)

### Opção C: Importação Manual pelo Usuário

Mesmo sem listagem, usuários podem adicionar manualmente:
1. Coinbase Wallet → Tokens → Import Token
2. Colar endereço: `0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d`
3. Chain: Base
4. Token aparece com saldo

---

## 📋 Valores Sugeridos para Submissões

| Campo | Valor |
|-------|-------|
| **App Name** | `QINV - Crypto Index Fund` |
| **Short Description** | `AI-powered crypto index fund on Base` |
| **Long Description** | `Invest in a diversified crypto portfolio through a single vault token. QINV uses quantitative strategies to manage allocation across top crypto assets on Base network.` |
| **Category** | `DeFi` / `Asset Management` |
| **Chain** | `Base (8453)` |
| **App URL** | `https://app.qinv.ai` |
| **Website** | `https://qinv.ai` |
| **Contract** | `0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d` |
| **Token** | `QINDEX` |

---

## ❌ Motivos Comuns de Rejeição / Problemas

| Problema | Solução |
|----------|---------|
| **App não funciona em mobile** | Testar extensivamente no browser da Coinbase Wallet |
| **Token aparece como "Unknown"** | Listar no CoinGecko primeiro |
| **Wallet não conecta** | Verificar Coinbase Wallet SDK integration |
| **Chain errada** | Implementar auto-switch para Base |
| **UI quebrada no iframe** | Testar em diferentes viewports |
| **Sem Base Ecosystem listing** | Submeter PR no base.org/ecosystem primeiro |
| **Contrato não verificado** | Verificar no BaseScan |
| **OnchainKit desatualizado** | Manter `@coinbase/onchainkit` na versão mais recente |

---

## 🔄 Pós-Integração: Manutenção

### Monitoramento

- [ ] Testar app mensalmente na Coinbase Wallet (mobile + extension)
- [ ] Verificar que token recognition funciona (nome + logo aparecem)
- [ ] Acompanhar atualizações do OnchainKit
- [ ] Monitorar atualizações do Coinbase Wallet SDK

### Atualizações Recomendadas

- **OnchainKit:** Atualizar frequentemente (breaking changes são documentados)
- **Coinbase Wallet SDK:** Manter na última versão estável
- **wagmi/viem:** Acompanhar major releases

### Métricas para Acompanhar

- Número de conexões via Coinbase Wallet (analytics)
- Transações originadas da Coinbase Wallet
- Feedback de usuários mobile

---

## 🎯 Estratégia Integrada: Sequência Recomendada

```
1. Verificar contrato no BaseScan (00-prerequisites.md)
   ↓
2. Listar no CoinGecko (02-coingecko.md)
   → Token aparece na Coinbase Wallet automaticamente
   ↓
3. Listar no Base Ecosystem (05-base-ecosystem.md)
   → App aparece no discovery da Coinbase Wallet
   ↓
4. Garantir OnchainKit atualizado e funcionando
   → Melhor UX para usuários Coinbase Wallet
   ↓
5. Coinbase Wallet SDK integration (se não existir)
   → Conexão seamless
   ↓
6. Otimizar para mobile
   → Maioria dos usuários Coinbase Wallet é mobile
```

---

## 🔗 Links Úteis

| Recurso | URL |
|---------|-----|
| Coinbase Wallet | https://www.coinbase.com/wallet |
| Coinbase Wallet SDK | https://github.com/coinbase/coinbase-wallet-sdk |
| OnchainKit | https://onchainkit.xyz |
| OnchainKit GitHub | https://github.com/coinbase/onchainkit |
| Base Ecosystem | https://base.org/ecosystem |
| Base Docs | https://docs.base.org |
| Coinbase Developer Platform | https://www.coinbase.com/developer-platform |
| wagmi Docs | https://wagmi.sh |

---

## ⚠️ Blockers Atuais para o QINV

1. **Contrato NÃO verificado no BaseScan** — Afeta token recognition e credibilidade
2. **CoinGecko listing pendente** — Necessário para token aparecer automaticamente na wallet
3. **Base Ecosystem listing pendente** — Principal canal de discovery
4. **TVL muito baixo (~$22)** — Pode afetar priorização em curadoria manual
5. **Mobile testing** — Precisa validar que app.qinv.ai funciona bem no browser mobile da Coinbase Wallet

---

*Última atualização: Fevereiro 2025*
*Voltar para: [README.md](./README.md) — Índice de todos os guias*
