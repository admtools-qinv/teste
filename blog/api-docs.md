# QINV Blog API — OpenClaw Integration Guide

## Overview

The QINV blog is powered by a Supabase database + Next.js with ISR (Incremental Static Regeneration). New articles are created via a secure Edge Function API. Once a post is published, it appears on [qinv.ai/blog](https://qinv.ai/blog) within 1 hour automatically — no deploy or manual intervention required.

```
OpenClaw Agent                         Landing Page (qinv.ai)
     │                                        │
     │  POST /create-blog-post                │  Reads from Supabase
     │  Authorization: Bearer <BLOG_API_KEY>  │  ISR revalidate = 1h
     ▼                                        ▼
┌──────────────────────────────────────────────────┐
│              Supabase (blog_posts)                │
│  published = true  →  visible on site            │
│  published = false →  draft, not visible         │
└──────────────────────────────────────────────────┘
```

---

## Authentication

All requests require a Bearer token in the `Authorization` header.

```
Authorization: Bearer <BLOG_API_KEY>
```

The `BLOG_API_KEY` is a dedicated secret configured as an environment variable in Supabase Edge Functions. It is separate from the service role key and only grants access to the blog creation endpoint.

Additionally, the Supabase API Gateway requires the `apikey` header:

```
apikey: <SUPABASE_PUBLISHABLE_KEY>
```

Both headers are required on every request. Values are provided via environment variables — never hardcode them.

---

## Endpoint

### `POST` Create Blog Post

```
POST https://nlbkxjvyeighuhkrrbtk.supabase.co/functions/v1/create-blog-post
```

**Headers:**

```
Authorization: Bearer ${BLOG_API_KEY}
apikey: ${SUPABASE_PUBLISHABLE_KEY}
Content-Type: application/json
```

**Request Body:**

```json
{
  "title": "What are crypto index funds?",
  "excerpt": "Short description under 160 characters for SEO and list page.",
  "content": "Raw markdown content of the article...",
  "date": "2026-02-23",
  "author": "QINV Team",
  "category": "Guide",
  "tags": ["crypto index fund", "DeFi", "passive investing"],
  "keywords": ["crypto index fund", "how do crypto index funds work"],
  "coverImage": "/images/blog/my-article.png",
  "published": false,
  "slug": "what-are-crypto-index-funds"
}
```

**Field Reference:**

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `title` | string | **Yes** | — | Article title. Use sentence case (only first word and proper nouns capitalized). |
| `excerpt` | string | **Yes** | — | SEO description shown on list page. Keep under 160 characters. |
| `content` | string | **Yes** | — | Full article body in **raw Markdown**. Supports GFM tables, blockquotes, code blocks. Do NOT send HTML. |
| `date` | string | No | Today | Publication date in `YYYY-MM-DD` format. |
| `author` | string | No | `"QINV Team"` | Author name. |
| `category` | string | No | `null` | Single category: `"Guide"`, `"Comparison"`, `"Investments"`, `"News"`, etc. |
| `tags` | string[] | No | `[]` | 3–6 descriptive tags for the article topic. |
| `keywords` | string[] | No | `[]` | 3–8 SEO keyword phrases users would search for. |
| `coverImage` | string | No | `null` | Cover image URL. Preferred: Unsplash URLs with `?w=1200&h=630&fit=crop&q=80` for 16:9 ratio. Also supports Supabase Storage URLs (optimized by Next.js) or any https:// URL (served as-is). Send `null` for no hero image. |
| `published` | boolean | No | `false` | Set to `true` to make the article visible on the site. |
| `slug` | string | No | Auto-generated | URL identifier. Auto-generated from title if omitted (lowercase, no accents, hyphens, max 80 chars). Must be unique. |
| `language` | string | No | `"en"` | Language of the article. Use `"pt-BR"` for the Brazilian blog (qinv.com.br). Default `"en"` goes to qinv.ai. |

**Auto-calculated fields (do not send):**
- `reading_time` — calculated from word count (content words / 200, rounded up)
- `created_at` — set to current timestamp

---

## Responses

### 201 Created (success)

```json
{
  "success": true,
  "data": {
    "id": 8,
    "slug": "what-are-crypto-index-funds",
    "title": "What are crypto index funds?",
    "published": false,
    "date": "2026-02-23",
    "reading_time": 12
  }
}
```

### 400 Bad Request (missing fields)

```json
{
  "success": false,
  "error": "Missing required fields",
  "message": "title, excerpt, and content are required"
}
```

### 401 Unauthorized (invalid or missing API key)

```json
{
  "success": false,
  "error": "Unauthorized"
}
```

### 409 Conflict (duplicate slug)

```json
{
  "success": false,
  "error": "Slug already exists",
  "message": "A blog post with slug 'what-are-crypto-index-funds' already exists",
  "code": "DUPLICATE_SLUG"
}
```

### 429 Too Many Requests (rate limited)

```json
{
  "success": false,
  "error": "Rate limit exceeded",
  "retryAfter": 45
}
```

Rate limit: **20 requests per minute** per IP.

### 500 Internal Server Error

```json
{
  "success": false,
  "error": "Error description"
}
```

---

## Recommended Workflow

### 1. Create as draft first

Send the article with `"published": false`. This saves it in the database but does NOT show it on the site. Validate the response to confirm the slug and reading time.

### 2. Review (optional)

The QINV team can review the draft directly in Supabase dashboard.

### 3. Publish

To publish a draft, update the `published` field to `true` via Supabase SQL:

```sql
UPDATE blog_posts SET published = true WHERE slug = 'my-article-slug';
```

Or send a new request with `"published": true` (requires a unique slug — cannot reuse an existing one).

### 4. Article goes live

Within **1 hour** of `published = true`, the article appears on:
- Blog list: `https://qinv.ai/blog`
- Article page: `https://qinv.ai/blog/<slug>`
- Sitemap: `https://qinv.ai/sitemap.xml`

---

## Content Guidelines

### Markdown format

The `content` field must be **raw Markdown** (not HTML). Supported features:

- `## Heading 2` and `### Heading 3` (never use `# H1` — the title is H1)
- GFM pipe tables (`| Column | Column |`)
- Blockquotes (`> text`)
- Fenced code blocks (triple backticks)
- Bold (`**text**`), italic (`*text*`), inline code (`` `code` ``)
- Ordered and unordered lists
- Horizontal rules (`---`) as section separators
- Links (`[text](url)`)

### Writing style rules

1. **Sentence case** for all headings and titles. Only capitalize first word and proper nouns.
   - Correct: `"What are crypto index funds and how do they work?"`
   - Wrong: `"What Are Crypto Index Funds And How Do They Work?"`

2. **Avoid em dashes** (`—`). Use commas, colons, or semicolons instead.
   - Correct: `"Both platforms work as index funds: you buy a token that..."`
   - Wrong: `"Both platforms work as index funds — you buy a token that..."`

3. **Comparison tables**: when comparing numbers, use the same format on both sides.
   - Correct: `| Fee | 5% per year (~0.0137%/day) | 3.65% per year (~0.01%/day) |`
   - Wrong: `| Fee | 5% per year | ~3.65% per year (0.01%/day) |`

4. **Proper nouns** stay capitalized: QINV, QIndex, QINDEX, Base, DeFi, ERC-20, AI, NAV.

5. **Excerpt** should be 1 sentence, under 160 characters, and include the main keyword.

6. Every article should contain at least one table or structured comparison.

7. End articles with a disclaimer: `*This article is for educational purposes only and does not constitute financial or investment advice.*`

### SEO checklist

- `title` includes target keyword
- `excerpt` under 160 chars with keyword
- `keywords` array has 3–8 search phrases
- `tags` array has 3–6 topic tags
- `category` matches existing categories (`Guide`, `Comparison`, `Investments`, `News`)
- Content uses H2/H3 headings (not H1)

---

## Example: Full Request

```bash
curl -X POST \
  'https://nlbkxjvyeighuhkrrbtk.supabase.co/functions/v1/create-blog-post' \
  -H "Authorization: Bearer ${BLOG_API_KEY}" \
  -H "apikey: ${SUPABASE_PUBLISHABLE_KEY}" \
  -H 'Content-Type: application/json' \
  -d '{
    "title": "How to diversify your crypto portfolio in 2026",
    "excerpt": "Learn 5 strategies to diversify your crypto portfolio and reduce risk using index funds, stablecoins, and DeFi protocols.",
    "content": "Diversification is the most important...\n\n## Why diversify?\n\nCrypto markets are volatile...\n\n| Strategy | Risk | Return potential |\n|---|---|---|\n| **Index funds** | Medium | Medium |\n| **Stablecoins** | Low | Low |\n\n---\n\n*This article is for educational purposes only and does not constitute financial or investment advice.*",
    "category": "Guide",
    "tags": ["diversification", "crypto portfolio", "risk management"],
    "keywords": ["crypto portfolio diversification", "how to diversify crypto"],
    "published": false
  }'
```

---

## Environment Variables (OpenClaw)

The agent needs these two env vars configured:

| Variable | Description |
|----------|-------------|
| `BLOG_API_KEY` | Dedicated API key for blog post creation |
| `SUPABASE_PUBLISHABLE_KEY` | Supabase API Gateway key |

Both are provided by the QINV team. Never commit them to version control.
