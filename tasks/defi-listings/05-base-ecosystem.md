# 05 — Base Ecosystem: Listagem no base.org/ecosystem

> **Projeto:** QINV — Crypto Index Fund na Base Network
> **Token:** QINDEX
> **Vault (Proxy):** `0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d`
> **Chain:** Base (chainId 8453)
> **Website:** https://qinv.ai | **App:** https://app.qinv.ai

---

## 📌 Visão Geral

### O que é o Base Ecosystem Directory

O Base Ecosystem Directory (https://base.org/ecosystem) é a vitrine oficial de projetos construídos na rede Base. É mantido pela própria equipe do Base (Coinbase) e funciona como um catálogo curado de dApps, ferramentas e protocolos que operam na chain.

### Por que importa para o QINV

- **Selo oficial** — Estar listado no base.org é validação direta pela equipe da Coinbase
- **Discovery orgânico** — Usuários buscando dApps no Base encontram projetos aqui primeiro
- **Porta de entrada para Coinbase Wallet** — O diretório alimenta sugestões no wallet/browser da Coinbase
- **SEO poderoso** — base.org tem autoridade de domínio altíssima
- **Credibilidade cascata** — Facilita listagens em outras plataformas ("listed on Base Ecosystem")
- **Gratuito** — Processo 100% via Pull Request no GitHub

### Impacto vs Esforço

| Aspecto | Detalhe |
|---------|---------|
| Impacto | ⭐⭐⭐⭐⭐ (máximo para projetos Base-native) |
| Dificuldade | Baixa (JSON + PR no GitHub) |
| Custo | Grátis |
| Tempo estimado | 3-14 dias (depende do review cycle) |

---

## ✅ Pré-requisitos Específicos

- [ ] Contrato verificado no BaseScan (ver `00-prerequisites.md`)
- [ ] Projeto funcional e acessível (app.qinv.ai funcionando)
- [ ] Conta no GitHub
- [ ] Git instalado localmente
- [ ] Logo do projeto em formato adequado (PNG ou SVG, quadrado, fundo transparente)
- [ ] Descrição curta e longa do projeto em inglês
- [ ] Pelo menos 1 smart contract deployado e funcional na Base

---

## 🔧 Passo a Passo Completo

### Passo 1: Identificar o Repositório Correto

O diretório do ecossistema Base é mantido no GitHub:

**Repositório:** https://github.com/base-org/web

> ⚠️ **IMPORTANTE:** O repositório e processo podem mudar. Sempre verifique o README mais recente antes de submeter.

A listagem do ecossistema fica tipicamente em:
- `apps/web/src/data/ecosystem.json` ou
- Um diretório dedicado como `apps/web/src/data/ecosystem/`

### Passo 2: Fork e Clone

```bash
# Fork via GitHub UI: https://github.com/base-org/web → Fork

# Clonar o fork
git clone https://github.com/SEU-USER/web.git
cd web

# Criar branch
git checkout -b add-qinv-ecosystem

# Instalar dependências (monorepo)
yarn install
```

### Passo 3: Entender a Estrutura de Dados

Cada projeto no ecossistema é representado por um objeto JSON. O formato típico:

```json
{
  "name": "QINV",
  "url": "https://app.qinv.ai",
  "description": "AI-powered crypto index fund. Invest in a diversified portfolio of top crypto assets through a single vault token (QINDEX) on Base.",
  "shortDescription": "AI-powered crypto index fund on Base",
  "tags": ["defi", "asset-management"],
  "imageUrl": "/images/ecosystem/qinv.png",
  "category": "DeFi",
  "subcategory": "Asset Management"
}
```

> ⚠️ **Campos podem variar.** Verifique entradas existentes no arquivo para confirmar o schema exato.

### Passo 4: Preparar o Logo

Requisitos típicos para o logo:
- **Formato:** PNG ou SVG
- **Tamanho:** 256x256px mínimo, quadrado
- **Fundo:** Transparente preferido
- **Localização:** Copiar para o diretório de imagens do ecossistema (ex: `apps/web/public/images/ecosystem/qinv.png`)

```bash
# Copiar logo para o diretório correto
cp /caminho/do/logo/qinv.png apps/web/public/images/ecosystem/qinv.png
```

### Passo 5: Adicionar a Entrada do QINV

Editar o arquivo de dados do ecossistema. Exemplo baseado no formato mais comum:

```json
{
  "name": "QINV",
  "url": "https://app.qinv.ai",
  "description": "QINV is an AI-powered crypto index fund built on Base. Users deposit assets into a managed vault and receive QINDEX tokens representing their share of a diversified crypto portfolio. The protocol uses quantitative strategies to optimize allocation across top assets, offering passive DeFi exposure through a single token.",
  "tags": ["defi", "asset-management", "index-fund", "vault"],
  "imageUrl": "/images/ecosystem/qinv.png"
}
```

### Passo 6: Validar Localmente

```bash
# Verificar que o JSON é válido
cat apps/web/src/data/ecosystem.json | python3 -m json.tool > /dev/null && echo "✅ JSON válido"

# Se o projeto usa Next.js, rodar o build
yarn build

# Verificar se a página carrega
yarn dev
# Acessar http://localhost:3000/ecosystem e buscar "QINV"
```

### Passo 7: Commit e Pull Request

```bash
git add .
git commit -m "feat(ecosystem): add QINV - AI-powered crypto index fund"
git push origin add-qinv-ecosystem
```

#### Template do Pull Request

```markdown
## Add QINV to Base Ecosystem

### Project Information
- **Name:** QINV
- **Website:** https://qinv.ai
- **App:** https://app.qinv.ai
- **Category:** DeFi / Asset Management
- **Contract:** 0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d (Base)

### Description
QINV is an AI-powered crypto index fund on Base. Users deposit into a vault 
and receive QINDEX tokens representing diversified crypto exposure. The protocol
uses quantitative strategies for portfolio optimization.

### Checklist
- [x] Project is live and functional on Base mainnet
- [x] Smart contract deployed on Base
- [x] Logo added in correct format
- [x] JSON entry follows existing schema
- [x] Build passes locally
- [x] Description is accurate and concise

### Links
- GitHub: [link do repo se público]
- Docs: https://qinv.ai (se houver docs)
- Contract: https://basescan.org/address/0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d
```

---

## 📋 Valores Sugeridos para o QINV

| Campo | Valor Sugerido |
|-------|---------------|
| **name** | `QINV` |
| **url** | `https://app.qinv.ai` |
| **description** (longa) | `QINV is an AI-powered crypto index fund built on Base. Users deposit assets into a managed vault and receive QINDEX tokens representing their share of a diversified crypto portfolio. The protocol uses quantitative strategies to optimize allocation across top assets, offering passive DeFi exposure through a single token.` |
| **shortDescription** | `AI-powered crypto index fund on Base` |
| **tags** | `["defi", "asset-management", "index-fund", "vault"]` |
| **category** | `DeFi` |
| **subcategory** | `Asset Management` |

---

## 🔍 Categorias Disponíveis no Base Ecosystem

As categorias mais comuns no diretório:

| Categoria | Subcategorias |
|-----------|--------------|
| **DeFi** | DEX, Lending, Asset Management, Yield, Derivatives |
| **NFT** | Marketplace, Collections, Tools |
| **Social** | Social, Messaging, Identity |
| **Gaming** | Games, Metaverse |
| **Infrastructure** | Bridge, Oracle, RPC, Wallet |
| **Developer Tools** | SDK, API, Analytics |

**QINV se encaixa em:** DeFi → Asset Management

---

## ❌ Motivos Comuns de Rejeição

| Motivo | Como evitar |
|--------|------------|
| **Projeto não funcional** | Garantir que app.qinv.ai está acessível e funcional |
| **Contrato não verificado** | Verificar no BaseScan ANTES de submeter |
| **Descrição genérica** | Ser específico sobre o que o projeto faz |
| **Logo baixa qualidade** | PNG/SVG de alta resolução, fundo transparente |
| **JSON malformado** | Validar com `python3 -m json.tool` ou `jq` |
| **Schema incorreto** | Copiar formato exato das entradas existentes |
| **Projeto duplicado** | Verificar se QINV já não está listado |
| **Sem contrato na Base** | Deve ter pelo menos 1 contrato deployado na Base mainnet |
| **Link quebrado** | Testar todos os URLs antes de submeter |
| **PR sem descrição** | Usar o template completo com todas as informações |

---

## 🔄 Processo de Review

### Timeline Típico

1. **Dia 0:** Submissão do PR
2. **Dia 1-3:** Bot de CI valida o formato e build
3. **Dia 3-7:** Review manual pela equipe Base
4. **Dia 7-14:** Merge ou feedback com pedidos de mudança

### O que os Reviewers Checam

- ✅ Projeto realmente roda na Base mainnet
- ✅ Smart contract deployado e (idealmente) verificado
- ✅ Website funcional e profissional
- ✅ Descrição precisa (não é marketing fluff)
- ✅ Logo adequado
- ✅ Não é scam/rug/fork sem atribuição
- ✅ JSON válido, sem quebrar o build

### Como Responder a Feedback

Se receberem comentários no PR:
1. Responder educadamente e rapidamente (< 24h)
2. Fazer as mudanças solicitadas
3. Pedir re-review com `@` mention no reviewer

---

## 📡 Pós-Listagem: Manutenção

### Monitoramento Contínuo

- [ ] Verificar periodicamente se a listagem está visível em base.org/ecosystem
- [ ] Manter o website (app.qinv.ai) sempre acessível
- [ ] Atualizar descrição se o produto mudar significativamente

### Atualizações Futuras

Para atualizar dados (nova descrição, novo logo, etc.):

1. Criar novo PR no mesmo repositório
2. Referenciar o PR original
3. Explicar o motivo da atualização

### Remoção

Se o projeto for descontinuado ou mudar de chain, submeter PR para remover a entrada.

---

## 🔗 Links Úteis

| Recurso | URL |
|---------|-----|
| Base Ecosystem Page | https://base.org/ecosystem |
| Base GitHub (web repo) | https://github.com/base-org/web |
| Base Discord | https://discord.gg/buildonbase |
| Base Docs | https://docs.base.org |
| BaseScan | https://basescan.org |

---

## ⚠️ Blockers Atuais para o QINV

1. **Contrato NÃO verificado no BaseScan** — Resolver ANTES de submeter (ver `00-prerequisites.md`)
2. **TVL muito baixo (~$22)** — Não é blocker técnico, mas pode gerar perguntas dos reviewers
3. **Conferir se o repo base-org/web aceita PRs externos** — Verificar CONTRIBUTING.md

---

*Última atualização: Fevereiro 2025*
*Próximo guia: [06-zapper.md](./06-zapper.md) — Zapper Protocol Integration*
