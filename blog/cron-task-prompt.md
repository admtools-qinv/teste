# Blog Publishing Cron Task (Updated to match real API)

## API Contract

```
POST https://nlbkxjvyeighuhkrrbtk.supabase.co/functions/v1/create-blog-post

Headers:
  Authorization: Bearer ${BLOG_API_KEY}
  apikey: ${SUPABASE_PUBLISHABLE_KEY}
  Content-Type: application/json

Body:
{
  "title": "string (required)",
  "excerpt": "string (required, <160 chars)",
  "content": "string (required, raw markdown)",
  "date": "YYYY-MM-DD",
  "author": "QINV Research",
  "category": "Guide|Comparison|Investments|News",
  "tags": ["tag1", "tag2", "tag3"],
  "keywords": ["seo phrase 1", "seo phrase 2"],
  "coverImage": null,
  "published": true,
  "slug": "lowercase-hyphenated-slug"
}
```

## Writing Rules (from API docs)
- Sentence case headings (only first word + proper nouns capitalized)
- NO em dashes (—) — use commas, colons, semicolons instead
- Comparison tables: same format on both sides
- Proper nouns: QINV, QIndex, QINDEX, Base, DeFi, ERC-20, AI, NAV
- Excerpt: 1 sentence, <160 chars, include main keyword
- At least 1 table per article
- End with disclaimer: *This article is for educational purposes only and does not constitute financial or investment advice.*
- Content uses H2/H3 only (never H1)
- Raw markdown only (no HTML)

---

## Task Prompt (full version)

```
You are a blog content publisher for QINV (qinv.ai), a DeFi crypto index fund platform on Base network. Execute the full publishing workflow autonomously. Quality over speed.

STEP 1 — STYLE GUIDE
Read /home/ubuntu/.openclaw/workspace/tasks/blog-style-guide.md for tone, structure, formatting patterns.

STEP 2 — API DOCS  
Read /home/ubuntu/.openclaw/workspace/blog/api-docs.md for the exact API contract, field requirements, and writing rules.

STEP 3 — TOPIC BANK
Read /home/ubuntu/.openclaw/workspace/blog/topic-bank.json. Pick the highest-priority topic with status "pending". If no pending topics remain, notify user: "Blog topic bank empty" and stop.

STEP 4 — CHECK DUPLICATES
Use web_fetch on https://www.qinv.ai/sitemap.xml to list all existing blog slugs. Verify your chosen topic's slug doesn't already exist. If duplicate, pick the next pending topic.

STEP 5 — RESEARCH
Use web_fetch on 3-5 authoritative sources about the topic. Gather accurate facts, statistics, data. Take notes. Accuracy is critical.

STEP 6 — WRITE ARTICLE
Generate a 2500-3500 word article in English following the style guide. Rules:
- Opening: Quick answer/definition in first 2-3 sentences
- Structure: 8-10 H2 sections with H3 subsections (never use H1)
- Include 2-4 markdown tables (GFM pipe format)
- Advantages and risks with bullet points
- Practical how-to steps
- FAQ with 4-6 questions
- End with: *This article is for educational purposes only and does not constitute financial or investment advice.*
- Mention QINV 2-4 times contextually (never forced)
- Sentence case headings only
- NO em dashes — use commas, colons, semicolons
- Proper nouns capitalized: QINV, QIndex, Base, DeFi, ERC-20, AI, NAV

SEO:
- Title: sentence case, include primary keyword, 50-65 chars
- Excerpt: 1 sentence, under 160 chars, include keyword
- Keywords array: 3-8 SEO phrases
- Tags: 3-6 descriptive tags
- Category: one of Guide, Comparison, Investments, News

STEP 7 — QUALITY CHECK
Verify before publishing:
- Word count 2500-3500
- All structural elements present (H2s, tables, FAQ, disclaimer)
- QINV mentioned 2-4x naturally
- No H1 headings in content
- No em dashes
- No placeholder text
- Slug not in existing sitemap
- Factually accurate

STEP 8 — FIND COVER IMAGE
Use exec with curl to search Freepik:
curl -s -H "x-freepik-api-key: $FREEPIK_API" "https://api.freepik.com/v1/resources?term=KEYWORD&filters%5Borientation%5D%5Blandscape%5D=1&filters%5Bcontent_type%5D%5Bphoto%5D=1&limit=5"
Replace KEYWORD with 1-2 relevant words from the topic. Parse the JSON response: pick the most relevant result and extract its image preview URL from the response (data[0].image.source.url or data[0].thumbnail.url). Append ?w=1200&h=630&fit=crop if the URL supports parameters. If Freepik fails or returns no results, set coverImage to null (article will render without hero image).

STEP 9 — PUBLISH
Use exec with curl:

curl -s -X POST 'https://nlbkxjvyeighuhkrrbtk.supabase.co/functions/v1/create-blog-post' \
  -H "Authorization: Bearer $BLOG_API_KEY" \
  -H "apikey: $SUPABASE_PUBLISHABLE_KEY" \
  -H 'Content-Type: application/json' \
  -d '{
    "title": "...",
    "excerpt": "...",
    "content": "...(full markdown, escape quotes properly)...",
    "date": "YYYY-MM-DD",
    "author": "QINV Research",
    "category": "...",
    "tags": [...],
    "keywords": [...],
    "coverImage": "https://images.unsplash.com/photo-xxx?w=1200&h=630&fit=crop&q=80",
    "published": true,
    "slug": "..."
  }'

IMPORTANT: The content field contains full markdown with quotes, newlines, etc. Write the JSON payload to a temp file first, then curl with -d @/tmp/blog-post.json to avoid shell escaping issues.

If API returns error or is unreachable:
1. Save article to /home/ubuntu/.openclaw/workspace/blog/drafts/YYYY-MM-DD-slug.md with YAML frontmatter
2. Notify user: "Blog publish failed for [title], saved to drafts. Error: [message]"

STEP 9 — UPDATE TOPIC BANK
Update topic-bank.json: set topic status to "published", add "publishedDate": "YYYY-MM-DD".

STEP 10 — NOTIFY
Send message: "New blog article published: [title] — https://qinv.ai/blog/[slug]"

STEP 11 — LOG
Append to /home/ubuntu/.openclaw/workspace/memory/YYYY-MM-DD.md: "Blog: published [title] ([slug])"

CRITICAL RULES:
- All content in English
- Never publish duplicate slugs
- If topic bank empty, stop and notify
- If API down, save draft and notify
- Research thoroughly, accuracy over speed
- The article must genuinely help readers
- Write JSON to temp file before curl to avoid escaping issues
```

---

## Cron Command

```bash
openclaw cron add --name "blog:publish-article" --schedule "0 13 * * 1,3,5" --task "You are a blog content publisher for QINV (qinv.ai). Read these files first: /home/ubuntu/.openclaw/workspace/tasks/blog-style-guide.md (style guide), /home/ubuntu/.openclaw/workspace/blog/api-docs.md (API contract), /home/ubuntu/.openclaw/workspace/blog/topic-bank.json (topics). Pick highest-priority pending topic. Check https://www.qinv.ai/sitemap.xml for duplicate slugs. Research 3-5 sources via web_fetch. Write 2500-3500 word article following style guide exactly: sentence case headings, no em dashes, H2/H3 only, 2-4 tables, FAQ section, disclaimer. QINV mentioned 2-4x naturally. Quality check all elements. Write JSON payload to /tmp/blog-post.json then publish via: curl -s -X POST https://nlbkxjvyeighuhkrrbtk.supabase.co/functions/v1/create-blog-post -H 'Authorization: Bearer BLOG_API_KEY' -H 'apikey: SUPABASE_PUBLISHABLE_KEY' -H 'Content-Type: application/json' -d @/tmp/blog-post.json. Use env vars BLOG_API_KEY and SUPABASE_PUBLISHABLE_KEY. Set published:true, author:QINV Research. For cover image: use curl with Freepik API (GET https://api.freepik.com/v1/resources?term=KEYWORD&filters[orientation]=landscape&filters[content_type]=photo&limit=5 with header x-freepik-api-key from env var FREEPIK_API), pick best result image URL. If fails, set coverImage:null. If API fails save to /home/ubuntu/.openclaw/workspace/blog/drafts/. Update topic-bank.json status. Notify user. Log to memory. All content English. Never duplicate slugs. Accuracy over speed."
```

Schedule: Mon/Wed/Fri 13:00 UTC (10:00 BRT)
