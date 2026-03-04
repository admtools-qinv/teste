# Plano: Automação de Blog QINV.ai

## Visão Geral
Cron job diário que gera e publica artigos no blog da QINV automaticamente, mantendo qualidade profissional consistente com os 7 artigos existentes.

---

## Arquitetura

```
┌─────────────────┐     ┌──────────────────┐     ┌──────────────┐
│  OpenClaw Cron   │────▶│  Supabase API    │────▶│  Vercel ISR  │
│  (diário 10h BRT)│     │  (Postgres)      │     │  (regenera)  │
└─────────────────┘     └──────────────────┘     └──────────────┘
        │
        ├── 1. Lê posts existentes (GET /api/blog/posts)
        ├── 2. Escolhe tópico (do banco de 20+ temas)
        ├── 3. Gera artigo (seguindo style guide)
        ├── 4. Busca imagem landscape (Unsplash)
        ├── 5. Publica (POST /api/blog/posts)
        └── 6. Notifica Aragorn no Telegram
```

## Componentes

### 1. Topic Bank (nosso lado)
- Arquivo `blog/topic-bank.md` com temas priorizados por SEO
- Cada tema: título, slug, keywords, tipo, prioridade
- Cron marca temas usados e gera novos quando acabar
- Evita repetição: consulta GET /api/blog/posts antes

### 2. Article Generator (cron task)
- Usa style guide como referência
- Estrutura fixa: opening hook → concept → mechanism → comparison → pros/cons → how-to → FAQ
- 2500-3500 palavras, em inglês
- QINV mencionado 2-4x contextualmente
- Disclaimer no final
- Tabelas, listas, SEO headings

### 3. Image Sourcing
- Unsplash API (gratuita, 50 req/hora)
- Busca por keyword do artigo
- Filtro: orientation=landscape
- Fallback: Pexels API (também gratuita)
- Credita fotógrafo conforme licença

### 4. Publishing API (lado do Aragorn)
- POST /api/blog/posts → cria post no Supabase
- GET /api/blog/posts → lista existentes
- Auth via Bearer token
- Vercel ISR revalida automaticamente

### 5. Quality Checks (antes de publicar)
- Word count: 2500-3500
- Estrutura: tem opening hook? tem FAQ? tem tabelas?
- SEO: keyword no título, slug, primeiro parágrafo, 2+ H2s
- QINV mentions: 2-4x (não mais, não menos)
- Sem repetição de tema
- Imagem landscape encontrada

---

## Cron Job Design

```
Nome: blog:daily-article
Schedule: "0 13 * * 1-5" (10h BRT seg-sex, pula finais de semana)
```

### Task prompt (resumido):
1. Ler style guide de /workspace/tasks/blog-style-guide.md
2. GET posts existentes da API
3. Escolher próximo tópico do topic bank
4. Gerar artigo completo em markdown
5. Buscar imagem no Unsplash
6. POST para API com: title, slug, content, excerpt, coverImage, tags
7. Notificar Aragorn: "📝 Artigo publicado: [título] — [url]"
8. Atualizar topic bank (marcar como usado)
9. Log em memory/YYYY-MM-DD.md

---

## Imagens — Estratégia

### Fonte primária: Unsplash
- API: https://api.unsplash.com/search/photos
- Parâmetros: query=[keyword], orientation=landscape, per_page=5
- Selecionar a mais relevante
- URL: foto.urls.regular (1080px)
- Crédito: foto.user.name (incluir no post ou metadata)
- Rate limit: 50 req/hora (suficiente)

### Fonte secundária: Pexels
- API: https://api.pexels.com/v1/search
- Mesmos parâmetros
- Fallback se Unsplash não retornar resultado bom

### Regras de imagem:
- SEMPRE landscape (horizontal)
- Relevante ao tema (crypto, finance, technology, charts)
- Alta qualidade (min 1200px largura)
- Sem texto sobreposto
- Sem marcas d'água

---

## O que falta do Aragorn

1. **Criar tabela `posts` no Supabase** (SQL pronto abaixo)
2. **Criar API routes no Next.js** (código pronto abaixo)
3. **Me passar**: SUPABASE_URL, SUPABASE_ANON_KEY, BLOG_API_TOKEN
4. **Unsplash API key** (grátis em unsplash.com/developers) — ou eu uso web_fetch direto

---

## Review do Plano

### ✅ Pontos fortes:
- Style guide extraído dos artigos reais (não inventado)
- Quality checks antes de publicar
- Topic bank evita repetição
- Notificação no Telegram mantém Aragorn no loop
- Seg-sex evita flood de conteúdo

### ⚠️ Riscos e mitigações:
- **Qualidade inconsistente**: Mitigado pelo style guide rigoroso + quality checks
- **Tema irrelevante**: Mitigado pelo topic bank curado + consulta de existentes
- **Imagem ruim**: Fallback Pexels + validação de dimensões
- **API fora**: Retry com backoff, notifica se falhar
- **Conteúdo incorreto**: Risco real — artigos sobre crypto precisam de dados corretos
  → Mitigação: usar web_fetch pra pesquisar fatos antes de escrever

### 🔄 Ajuste após review:
- Adicionar step de PESQUISA antes de escrever (web_fetch em 3-5 fontes relevantes)
- Adicionar opção de "draft mode" — publicar como draft e Aragorn aprova
- Considerar publicação 3x/semana em vez de diária (qualidade > quantidade)

---

## Recomendação Final

**Começar com 3x/semana** (seg, qua, sex) em vez de diário:
- Mais tempo pra pesquisar e gerar conteúdo de qualidade
- Não satura o blog com conteúdo
- Padrão da indústria pra blogs B2B

Aragorn pode ajustar pra diário depois se a qualidade se mantiver.
