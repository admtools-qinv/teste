# DeFi Listings & Integrações — QINV

## Status Tracker

| # | Plataforma | Prioridade | Esforço | Dependência | Status |
|---|-----------|------------|---------|-------------|--------|
| 00 | **Verificação BaseScan** | 🔴 P0 | Baixo | Código fonte do contrato | ⬜ Pendente |
| 01 | **DefiLlama** | 🟠 P1 | Médio | Contrato verificado | ⬜ Pendente |
| 05 | **Base Ecosystem** | 🟠 P1 | Baixo | Website funcional | ⬜ Pendente |
| 02 | **CoinGecko** | 🟡 P2 | Baixo | Contrato verificado, liquidez | ⬜ Pendente |
| 03 | **CoinMarketCap** | 🟡 P2 | Baixo | Contrato verificado, liquidez | ⬜ Pendente |
| 04 | **DappRadar** | 🟡 P3 | Baixo | Contrato verificado | ⬜ Pendente |
| 06 | **Zapper** | 🟡 P3 | Alto | DefiLlama listado | ⬜ Pendente |
| 07 | **Zerion** | 🟡 P3 | Médio | CoinGecko listado | ⬜ Pendente |
| 09 | **Coinbase Wallet** | 🔵 P4 | Médio | Base Ecosystem listado | ⬜ Pendente |
| 08 | **Safe App** | 🔵 P4 | Alto | Audit, contrato verificado | ⬜ Pendente |

## Ordem de Execução

```
Semana 1:  [00] Verificar contrato no BaseScan ← BLOCKER pra tudo
           [05] Aplicar pro Base Ecosystem (não precisa de verificação)

Semana 2:  [01] PR no DefiLlama (adapter JS)
           [04] Submit no DappRadar

Semana 3:  [02] Aplicar no CoinGecko (precisa de liquidez no token)
           [03] Aplicar no CoinMarketCap

Semana 4+: [06] Zapper integration (depois de DefiLlama)
           [07] Zerion integration (depois de CoinGecko)
           [09] Coinbase Wallet (depois de Base Ecosystem)
           [08] Safe App (precisa de audit formal)
```

## Pré-requisitos Globais

- ❌ **Contrato verificado no BaseScan** — ver `00-prerequisites.md`
- ❌ **Audit de smart contract** — necessário pra Safe App e acelera outros listings
- ⚠️ **TVL** — atualmente ~$22, muitas plataformas pedem mínimo $10k-$50k
- ⚠️ **Liquidez do token** — CoinGecko/CMC pedem pool com volume de trading
- ✅ **Website funcional** — qinv.ai
- ⚠️ **Documentação técnica** — criar docs.qinv.ai ou whitepaper

## Arquivos

| Arquivo | Conteúdo |
|---------|----------|
| `00-prerequisites.md` | Pré-requisitos + verificação do contrato no BaseScan |
| `01-defillama.md` | DefiLlama adapter + PR no GitHub |
| `02-coingecko.md` | Listing do token QINDEX no CoinGecko |
| `03-coinmarketcap.md` | Listing do token QINDEX no CoinMarketCap |
| `04-dappradar.md` | Listing do dApp no DappRadar |
| `05-base-ecosystem.md` | Listing no Base ecosystem |
| `06-zapper.md` | Integração no Zapper (portfolio tracker) |
| `07-zerion.md` | Integração no Zerion (portfolio tracker) |
| `08-safe-app.md` | Desenvolvimento de Safe App (Gnosis) |
| `09-coinbase-wallet.md` | Discovery no Coinbase Wallet |
