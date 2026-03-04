# QINV Blog Style Guide

> Extracted from analysis of all 7 existing articles on qinv.ai (Feb 2026).
> Purpose: enable automated daily blog publishing that matches existing quality and patterns.

---

## 1. Content Structure Template

Every article follows this skeleton:

```
[Opening paragraph — 2-4 sentences with a clear definition or "quick answer"]

## What is [Topic]? / Core concept section
[Definition, context, origin from traditional finance analogy]

## How does [Topic] work? / Mechanism section
### Step 1: [First stage]
### Step 2: [Second stage]
### Step 3: [Third stage]
[Optional additional steps]

## Types / Categories / Classification
[Table comparing types with columns: Type | Description | Risk/Benefit | Maturity]

## [Topic] vs. [Alternative] — Comparison section
[Large comparison table with 10-15 rows]
[Detailed breakdown per dimension with subsections]

## Advantages and risks / Pros and cons
### Advantages (or Strengths)
- Bullet list (6-8 items)
### Risks (or Weaknesses)
- Bullet list (5-7 items)
[Key insight callout paragraph]

## How to [get started / invest / use] — Step by step
### Step 1: [Action]
### Step 2: [Action]
### Step 3: [Action]
[3-5 steps, practical and actionable]

## [Ecosystem / Market context / Trends] section
[Data, statistics, institutional examples]

## Frequently asked questions
### [Question 1]?
[2-3 sentence answer restating the definition]
### [Question 2]?
### [Question 3]?
### [Question 4]?
[4-6 FAQ items]

[Disclaimer paragraph at bottom]
```

### Section count patterns:
- **Educational guides** (what-is, how-to): 7-10 H2 sections, 3-6 H3 subsections per major H2
- **Comparison articles** (vs): 8-12 H2 sections, heavy use of tables
- **Average total H2 sections**: 8-9

---

## 2. Writing Rules

### Tone & Voice
- **Educational and authoritative** — like a senior analyst explaining to an informed beginner
- **Direct, no fluff** — articles explicitly say "no fluff" in comparison pieces
- **Second person ("you")** for reader-facing advice; third person for technical explanations
- **Confident but balanced** — always present risks alongside benefits
- **Never hype** — no exclamation marks, no "amazing", no "revolutionary"

### Person & Perspective
- Default: **second person** ("When you invest...", "If you hold...")
- Technical sections: **third person** ("The protocol calculates...", "Assets are held...")
- QINV references: **third person** ("QINV operates on...", "QINV's allocation engine...")

### Do's
- Start with a **1-sentence definition** or **"Quick answer/Quick definition"** before any heading
- Use **traditional finance analogies** to explain crypto concepts (S&P 500, mutual funds, Vanguard)
- Include **specific numbers and data** (TVL figures, percentages, dates)
- Reference **credible sources** (BCG, World Economic Forum, SEC, specific protocol data)
- Use **"In one sentence:"** or **"Quick answer:"** or **"Quick definition:"** as opening hooks
- Provide **practical step-by-step instructions** for actionable topics
- Include a **disclaimer** at the end of articles with investment advice context
- Use **"Key insight:"** or **"Practical tip:"** callouts for important takeaways

### Don'ts
- Don't use first person ("I", "we") — exception: "we" only in rare editorial voice
- Don't use informal slang or memes
- Don't make unsubstantiated claims about QINV performance
- Don't bash competitors — present objective comparisons with pros/cons for both sides
- Don't use clickbait titles
- Don't use filler phrases ("In this article, we will explore...")
- Don't over-explain basics that the target audience already knows
- Don't use passive voice excessively — prefer active constructions

### Content Length
- **Target: 2,500–3,500 words** (all articles are in this range, truncated at ~10K chars ≈ 2,800–3,200 words visible)
- Educational guides trend longer (3,000+); comparison articles are similar length but more table-heavy

---

## 3. SEO Checklist

### Title Format
- **Pattern**: `[What/How] + [Primary Keyword] + [Qualifier]`
- **Examples**:
  - "What are crypto index funds and how do they work? Complete guide 2026"
  - "Asset tokenization: the future of investments"
  - "How to choose the best Web3 wallet (2025 guide)"
  - "QINV Onchain vs Glider: which one is right for you?"
  - "What is NAV (Net Asset Value) in crypto? Complete guide 2026"
  - "What is the BASE network? A complete beginner's guide"
- **Capitalization**: Sentence case (only first word + proper nouns capitalized)
- **Length**: 45-70 characters
- **Year tag**: Include current year for evergreen content ("2026", "2025 guide")
- **Question format**: Preferred for "what is" and "how to" articles
- **Comparison format**: "X vs Y: which one is right for you?"

### Slug Format
- Lowercase, hyphen-separated
- Contains primary keyword
- Short and descriptive (4-8 words)
- Pattern: `what-is-[topic]`, `how-to-[topic]`, `[brand]-vs-[brand]-comparison`
- Examples: `what-are-crypto-index-funds`, `asset-tokenization-future-of-investments`, `qinv-vs-glider-comparison`

### Meta Description / Opening Paragraph
- First paragraph serves as meta description (no separate meta observed)
- **Must contain primary keyword** in first sentence
- **Clear definition format**: "[Term] is [definition]" or "Quick answer: [direct answer]"
- Length: 150-200 characters for first sentence; 2-4 sentences total for opening paragraph
- Should be extractable by search engines as a featured snippet

### Heading Keyword Placement
- **H1 (title)**: Primary keyword always present
- **H2**: Primary keyword in at least 2-3 H2 headings (e.g., "What is [keyword]", "How does [keyword] work")
- **H3**: Secondary/long-tail keywords in H3 subsections
- Every H2 should contain a searchable question or phrase

### Internal Linking
- **QINV product mention**: Appears 2-4 times naturally within content
- **Link to qinv.ai**: At least once in the article body (usually in "how to get started" or comparison section)
- **Cross-link to other blog posts**: Not heavily observed but should be added
- **External links**: To authoritative sources (BaseScan, official protocol docs, regulatory bodies)

---

## 4. GEO (Generative Engine Optimization)

### First Paragraph — AI Snippet Extraction
- **Every article opens with a standalone definition** that answers the title question completely
- Format: "Quick answer:", "Quick definition:", "In one sentence:", or direct definition
- This paragraph must be **self-contained** — an AI can extract it as a complete answer
- Include the **formula or key fact** if applicable (e.g., NAV formula in first paragraph)

### FAQ Section — Structured Q&A
- **Every article should end with "Frequently asked questions" H2**
- 4-6 questions in `### Question?` format (H3)
- Each answer: 2-4 sentences, restating context for standalone extraction
- First FAQ should restate the main topic definition
- Questions should mirror common search queries (voice search friendly)

### Structured Data-Friendly Formatting
- Use **definition lists** implicitly (term in bold, explanation follows)
- Use **tables** for comparisons (easily parsed by AI)
- Use **numbered steps** for processes (Step 1, Step 2...)
- Use **"Key insight:"** prefixed paragraphs for important takeaways
- Keep paragraphs short (2-4 sentences max) for better chunking

### Content Signals for AI
- Include **"In one sentence:"** summaries for complex concepts
- Use **explicit cause-effect language** ("This means...", "What this means in practice:")
- Provide **practical examples with numbers** (not abstract theory)
- Structure comparisons as tables (AI-parseable) not prose

---

## 5. Formatting Rules

### Tables
- **Heavy use of tables** — every article has 2-5 tables
- Comparison articles: 1 large "quick comparison" table (10-15 rows) + smaller supporting tables
- Educational articles: classification tables, data tables, metric comparisons
- Table columns typically: Dimension/Feature | Option A | Option B (or: Type | Description | Risk | Maturity)
- Tables used for: comparisons, data summaries, step-by-step components, protocol features

### Lists
- **Bullet lists** for advantages, risks, strengths, weaknesses
- **Numbered lists** for steps/processes and criteria
- Items are full sentences (not fragments), starting with a bold keyword when applicable
- Typical list length: 5-8 items

### Bold Text
- Used for **key terms on first mention**
- Used for **emphasis on critical warnings or insights**
- Used in lists for **leading keywords** before the explanation
- Not overused — roughly 1-3 bold phrases per section

### Comparison Sections
- Always include a **"Quick comparison" table** early in comparison articles
- Follow with **detailed subsections** expanding each row of the table
- End comparison articles with a **"Pros and cons summary" table**
- Include **"Which investor profile does each suit?"** section
- Always present both options fairly — QINV advantages highlighted but competitor strengths acknowledged

### Callout Patterns
- **"Key insight:"** — for important analytical takeaways
- **"Practical tip:"** — for actionable investor advice
- **"Important notice:"** — for regulatory/legal disclaimers
- **"Disclaimer:"** — end-of-article legal notice
- **"What this means in practice:"** — bridging technical to practical

### Images
- No inline images observed in extracted content (likely hero images in CMS only)
- Articles rely entirely on **text, tables, and structured formatting**

---

## 6. Topics Already Covered

| # | Topic | Slug | Type |
|---|-------|------|------|
| 1 | Crypto index funds (what they are, how they work) | `what-are-crypto-index-funds` | Educational guide |
| 2 | Asset tokenization (RWA, future of investments) | `asset-tokenization-future-of-investments` | Educational guide |
| 3 | Web3 wallet comparison (MetaMask, Coinbase, Trust, OKX) | `how-to-choose-best-web3-wallet` | How-to / Comparison |
| 4 | QINV vs Glider (portfolio automation comparison) | `qinv-vs-glider-comparison` | Competitor comparison |
| 5 | QINV vs SSI Protocol / SoSoValue (index fund comparison) | `qinv-vs-ssi-protocol-comparison` | Competitor comparison |
| 6 | Base network (what it is, beginner's guide) | `what-is-base-network-beginners-guide` | Educational guide |
| 7 | NAV — Net Asset Value in crypto | `what-is-nav-net-asset-value-crypto` | Educational guide |

### Key themes already covered:
- Crypto index funds (concept + mechanics)
- Asset tokenization / RWA
- Web3 wallets
- Base network / Layer 2
- NAV valuation
- QINV vs 2 direct competitors (Glider, SSI/SoSoValue)

---

## 7. Topic Ideas (20 Future Articles)

Ordered by estimated SEO potential (search volume × relevance to QINV):

| # | Topic | Slug Suggestion | Type | SEO Rationale |
|---|-------|-----------------|------|---------------|
| 1 | What is DeFi? Complete beginner's guide 2026 | `what-is-defi-beginners-guide` | Educational | Massive search volume, funnel top |
| 2 | Dollar-cost averaging (DCA) in crypto: strategy guide | `dollar-cost-averaging-dca-crypto-guide` | Educational | High intent, directly tied to QINV use case |
| 3 | What are smart contracts and how do they work? | `what-are-smart-contracts-how-they-work` | Educational | High volume, supports QINV vault narrative |
| 4 | Crypto portfolio diversification: strategies for 2026 | `crypto-portfolio-diversification-strategies` | Educational | Direct QINV value prop |
| 5 | What is an ERC-20 token? Complete guide | `what-is-erc20-token-guide` | Educational | Supports QIndex token understanding |
| 6 | QINV vs Index Coop (DPI): on-chain index comparison | `qinv-vs-index-coop-dpi-comparison` | Comparison | Competitor capture, DeFi audience |
| 7 | What is portfolio rebalancing and why it matters in crypto | `what-is-portfolio-rebalancing-crypto` | Educational | Core QINV feature explanation |
| 8 | Crypto stablecoins explained: USDC, USDT, DAI | `stablecoins-explained-usdc-usdt-dai` | Educational | High volume, on-ramp topic |
| 9 | What is yield farming? DeFi returns explained | `what-is-yield-farming-defi-returns` | Educational | DeFi funnel, composability angle |
| 10 | Optimistic rollups vs ZK rollups: L2 comparison | `optimistic-rollups-vs-zk-rollups-comparison` | Educational | Supports Base network understanding |
| 11 | How to bridge assets to Base network | `how-to-bridge-assets-base-network` | How-to | Practical, drives Base adoption |
| 12 | What is a crypto ETF? Bitcoin & Ethereum ETFs explained | `what-is-crypto-etf-bitcoin-ethereum` | Educational | High search volume, NAV article synergy |
| 13 | QINV vs Enzyme Finance comparison | `qinv-vs-enzyme-finance-comparison` | Comparison | Competitor capture |
| 14 | Best DeFi protocols on Base network 2026 | `best-defi-protocols-base-network` | Listicle | Base ecosystem, QINV inclusion |
| 15 | What is on-chain transparency and why it matters | `what-is-on-chain-transparency` | Educational | Core QINV differentiator |
| 16 | Crypto market cap vs TVL: what investors should know | `crypto-market-cap-vs-tvl-explained` | Educational | Metric education, DeFi audience |
| 17 | How AI is transforming crypto portfolio management | `ai-crypto-portfolio-management` | Educational | QINV AI narrative |
| 18 | What is impermanent loss? LP risks explained | `what-is-impermanent-loss-explained` | Educational | DeFi education, composability angle |
| 19 | Passive income in crypto: 5 strategies for 2026 | `passive-income-crypto-strategies` | Listicle | High intent, QINV as option |
| 20 | What is account abstraction (ERC-4337)? | `what-is-account-abstraction-erc-4337` | Educational | Technical audience, wallet UX topic |

---

## 8. CTA Patterns

### How QINV is Referenced in Articles

**Pattern 1: Product mention within educational context** (most common)
> "Platforms like QINV offer AI-managed indexed crypto portfolios through a dedicated app, with automatic rebalancing and on-chain transparency."
- Appears in "how to get started" sections
- Framed as one option among several (not hard-sell)

**Pattern 2: Technical architecture reference**
> "QINV operates on the Base network using a vault-centric on-chain architecture: when you mint QIndex (QINDEX), your capital enters a shared smart contract vault..."
- Used when explaining on-chain concepts
- QINV as a concrete example of the concept being taught

**Pattern 3: Comparison table inclusion**
> QINV appears as a row in protocol comparison tables alongside established names (Yearn, DPI, Balancer)
- Normalizes QINV alongside recognized protocols
- Non-aggressive positioning

**Pattern 4: Step-by-step recommendation**
> "Step 5: try managed DeFi portfolios — platforms like QINV Onchain (qinv.ai) offer automated crypto portfolios built directly on BASE"
- Appears as the final step in how-to guides
- Natural progression from manual to automated

**Pattern 5: Dedicated comparison articles**
> Full "QINV vs [Competitor]" articles with balanced pros/cons
- Always acknowledges competitor strengths
- Highlights QINV differentiators: on-chain custody, AI allocation, Base network
- Ends with "which profile suits each" rather than declaring a winner

### CTA Rules for New Articles
1. **Mention QINV 2-4 times** per article (never forced)
2. **Always contextual** — QINV appears as an example or option, not an ad
3. **Include (qinv.ai)** parenthetically at least once for discoverability
4. **Position in "how to get started" or "practical example" sections** — highest reader intent
5. **Never use "Sign up now" or aggressive sales language**
6. **Highlight differentiators naturally**: on-chain transparency, AI-driven rebalancing, Base network, non-custodial vault
7. **In comparison articles**: always end with a "choose X if... choose Y if..." balanced framework

---

## Appendix: Article-by-Article Analysis Summary

| Article | Word Count (est.) | Tables | H2s | H3s | FAQ | Opening Hook | QINV Mentions |
|---------|-------------------|--------|-----|-----|-----|--------------|---------------|
| Crypto Index Funds | ~3,200 | 3 | 9 | 7 | No (truncated) | Direct definition | 3-4 |
| Asset Tokenization | ~3,000 | 3 | 8 | 8 | Yes | "Quick definition:" | 2-3 |
| Web3 Wallet Guide | ~3,000 | 1 large | 9 | 8 | No (truncated) | "Quick answer:" | 1 (Step 5) |
| QINV vs Glider | ~3,200 | 3 | 8 | 4 | No (truncated) | Context paragraph | Throughout |
| QINV vs SSI Protocol | ~3,200 | 3 | 8 | 4 | No (truncated) | Context paragraph | Throughout |
| Base Network Guide | ~3,000 | 2 | 9 | 5 | Yes (truncated) | "In one sentence:" | 1 (Step 5) |
| NAV in Crypto | ~3,000 | 4 | 8 | 8 | Yes | "Quick answer:" | 1-2 |

### Consistent Patterns Across All Articles:
- **Opening hook**: Always a standalone definition/answer before any heading
- **Tables**: 2-4 per article minimum
- **Balanced structure**: concept → mechanism → types → comparison → risks → how-to → FAQ
- **Disclaimer**: Present in educational articles with investment context
- **No images in body**: Text-only with heavy table formatting
- **Sentence case headings**: Consistent across all articles
- **Professional, authoritative tone**: Zero slang, zero hype
