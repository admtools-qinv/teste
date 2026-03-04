# Frontend & Web Security Audit — qinv.ai

**Audit Date:** 2026-02-24  
**Scope:** https://www.qinv.ai (Next.js landing page) and https://app.qinv.ai (Vite SPA — trading app)  
**Auditor:** Automated external security assessment  
**Classification:** External black-box audit (no source code access)

---

## Executive Summary

QINV operates two frontend properties: a **Next.js marketing site** on `www.qinv.ai` and a **Vite/React trading application** on `app.qinv.ai`. Both are hosted on Vercel. The overall posture is **reasonable for an early-stage DeFi project** but has several medium-severity gaps that should be addressed, particularly around HTTP security headers and overly permissive CORS. No critical vulnerabilities (leaked private keys, exposed databases, open admin panels) were found.

**Risk Rating: MEDIUM** — No immediate exploitable critical vulnerabilities, but hardening is needed.

---

## Findings

### 1. Missing HTTP Security Headers on www.qinv.ai

| Header | Status |
|--------|--------|
| `Content-Security-Policy` | ❌ **MISSING** |
| `X-Frame-Options` | ❌ **MISSING** |
| `X-Content-Type-Options` | ❌ **MISSING** |
| `Strict-Transport-Security` | ✅ Present (`max-age=63072000`) |
| `Referrer-Policy` | ❌ **MISSING** |
| `Permissions-Policy` | ❌ **MISSING** |

**Severity:** Medium  
**Impact:** Without CSP, the landing page is more vulnerable to XSS injection. Missing `X-Frame-Options` allows clickjacking attacks where the site could be embedded in malicious iframes. Missing `X-Content-Type-Options` could allow MIME sniffing attacks.  
**Recommendation:**  
Add these headers via `next.config.js` or `vercel.json`:
```
Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'
X-Frame-Options: DENY
X-Content-Type-Options: nosniff
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: camera=(), microphone=(), geolocation=()
```

---

### 2. Weak CSP on app.qinv.ai (via meta tag)

The app has a CSP defined via `<meta http-equiv="Content-Security-Policy">`:

```
script-src 'self' 'unsafe-inline' 'unsafe-eval' 'wasm-unsafe-eval' https: blob:;
```

**Severity:** Medium  
**Impact:** `'unsafe-inline'` and `'unsafe-eval'` significantly weaken XSS protection. Any XSS vulnerability becomes trivially exploitable because inline scripts and eval() are allowed. The `https:` source in script-src allows loading scripts from ANY HTTPS domain.  
**Recommendation:**  
- Remove `'unsafe-eval'` if possible (some Web3 libraries may require it — if so, document the exception)
- Replace `'unsafe-inline'` with nonce-based or hash-based CSP
- Replace `https:` with specific allowed domains
- Move CSP to an HTTP header (meta tags can be bypassed in some edge cases)

---

### 3. Wildcard CORS on Both Domains

Both `www.qinv.ai` and `app.qinv.ai` return:
```
access-control-allow-origin: *
```

**Severity:** Medium  
**Impact:** Any website can make cross-origin requests to these domains. For the marketing site this is low risk, but for `app.qinv.ai` (which has API endpoints), this could enable:
- Cross-site data theft if authenticated API endpoints don't separately validate Origin
- CSRF-like attacks against API endpoints
- Data exfiltration from authenticated sessions  
**Recommendation:**  
- On `app.qinv.ai`: Restrict CORS to specific origins (`https://app.qinv.ai`, `https://www.qinv.ai`)
- On `www.qinv.ai`: Acceptable for a static marketing site, but still better to restrict

---

### 4. Missing X-Frame-Options on app.qinv.ai

**Severity:** Medium  
**Impact:** The trading application can be embedded in iframes on attacker-controlled pages. This enables clickjacking attacks where users could be tricked into performing wallet transactions they didn't intend. For a DeFi app handling real money, this is particularly dangerous.  
**Recommendation:**  
Add `X-Frame-Options: DENY` or `Content-Security-Policy: frame-ancestors 'self' https://keys.coinbase.com` (to still allow wallet popups)

---

### 5. Cross-Origin-Opener-Policy set to `unsafe-none`

```
cross-origin-opener-policy: unsafe-none
```

**Severity:** Low  
**Impact:** This is intentionally set for wallet compatibility (documented in HTML comments). While it's necessary for Coinbase Smart Wallet and MetaMask Mobile, it means the app cannot use cross-origin isolation features that prevent Spectre-type attacks.  
**Recommendation:**  
- This is an **accepted risk** for wallet functionality. No change needed.
- Document this in a security decisions log for compliance.

---

### 6. Supabase Anon Key Exposed in JavaScript Bundle

The app.qinv.ai JS bundle contains:
- **Supabase URL:** `https://nlbkxjvyeighuhkrrbtk.supabase.co`
- **Supabase Anon JWT:** Decoded claims: `{"iss":"supabase","ref":"nlbkxjvyeighuhkrrbtk","role":"anon","iat":1758041035,"exp":2073617035}`
- **Reown (WalletConnect) Project ID:** `ca5d3233652482df225f14e36364cdc6`

**Severity:** Low (by design)  
**Impact:** The Supabase anon key is **designed** to be public in client-side apps. The key only provides anonymous-role access. The Supabase REST API properly returns `401` without an API key. The Reown project ID is also intended to be public.  
**Recommendation:**  
- ✅ Ensure Row-Level Security (RLS) is enabled on ALL Supabase tables
- ✅ Ensure no sensitive data is accessible with the anon role
- ✅ Verify that Supabase service_role key is NOT exposed (confirmed: it is not)
- Consider adding rate limiting to Supabase edge functions

---

### 7. Supabase Webhook URL Exposed in farcaster.json

File: `https://qinv.ai/.well-known/farcaster.json`
```json
"webhookUrl": "https://nlbkxjvyeighuhkrrbtk.supabase.co/functions/v1/farcaster-webhook"
```

**Severity:** Low  
**Impact:** The Farcaster webhook endpoint is publicly known. It properly returns `405 Method Not Allowed` for non-POST requests. An attacker could attempt to send crafted webhook payloads.  
**Recommendation:**  
- Ensure webhook validates Farcaster signatures/authenticity
- Add rate limiting to the edge function
- Validate all incoming payload schemas

---

### 8. `X-Powered-By: Express` Header on app.qinv.ai API

```
x-powered-by: Express
```

**Severity:** Low  
**Impact:** Reveals the server framework, making it marginally easier for attackers to target Express-specific vulnerabilities.  
**Recommendation:**  
Disable with `app.disable('x-powered-by')` or add `helmet()` middleware.

---

### 9. Next.js Build Manifest and Internal Route Exposure

The build manifest at `/_next/static/{buildId}/_buildManifest.js` is accessible and reveals:
- A URL rewrite: `/.well-known/:path*` → `/api/well-known/:path*`
- SSG routes: `/blog/[slug]`
- Build filter configuration

**Severity:** Info  
**Impact:** Minor information disclosure. Reveals internal routing structure. The rewrite from `.well-known` to API routes is worth noting for security review.  
**Recommendation:**  
- This is standard Next.js behavior and difficult to prevent without custom configuration
- Ensure `/api/well-known/*` endpoints are properly secured

---

### 10. SPA Catch-All Routing on app.qinv.ai Returns 200 for Everything

Requests to `/.env`, `/.git/config`, `/admin`, `/debug`, `/_debug`, `/graphql` all return HTTP 200 with the SPA index.html shell.

**Severity:** Low  
**Impact:** This is standard SPA behavior (client-side routing). It does NOT expose actual `.env` files or git repos — the response body is always the same HTML shell. However, automated scanners may flag these as false positives, and it could confuse security auditors.  
**Recommendation:**  
- Add explicit 404 responses for known sensitive paths in `vercel.json`:
  ```json
  { "src": "/(\\..*)$", "status": 404 }
  ```
- This improves security posture signaling and prevents false positives in automated scans

---

### 11. API Endpoints Properly Protected

| Endpoint | Status | Assessment |
|----------|--------|------------|
| `/api/health` | 200 (public) | ✅ Expected — health check |
| `/api/users` | 403 | ✅ Properly protected |
| `/api/admin` | 403 | ✅ Properly protected |
| `/api/config` | 403 | ✅ Properly protected |
| `/api/graphql` | 403 | ✅ Properly protected |

**Severity:** Info (Positive Finding)  
**Impact:** API endpoints correctly enforce authentication/authorization.  
**Recommendation:** No changes needed. Good implementation.

---

### 12. Missing security.txt

No `/.well-known/security.txt` file on either domain.

**Severity:** Info  
**Impact:** Security researchers have no standardized way to report vulnerabilities.  
**Recommendation:**  
Create `/.well-known/security.txt` with:
```
Contact: security@qinv.ai
Preferred-Languages: en
Expires: 2027-02-24T00:00:00.000Z
```

---

### 13. No Cookie Security Issues (No Cookies Set)

Neither `www.qinv.ai` nor `app.qinv.ai` set any cookies on initial page load. The Supabase infrastructure sets its own cookies (`__cf_bm`) with proper flags: `HttpOnly; Secure; SameSite=None`.

**Severity:** Info (Positive Finding)  
**Impact:** No cookie-based attack vectors on the primary domains. Authentication appears to be token-based (wallet signatures), which is appropriate for a Web3 app.  
**Recommendation:** No changes needed.

---

### 14. SSL/TLS Configuration

- **Certificate:** Let's Encrypt (R13), valid Jan 8 – Apr 8, 2026
- **HSTS:** ✅ `max-age=63072000` (2 years) on both domains
- **HTTP→HTTPS Redirect:** ✅ Both `http://www.qinv.ai` and `http://qinv.ai` redirect via 308 to HTTPS
- **SAN:** `www.qinv.ai` only (cert does not cover `qinv.ai` bare domain — handled by Vercel redirect)

**Severity:** Info (Positive Finding)  
**Impact:** TLS is properly configured. HSTS is strong.  
**Recommendation:**  
- Consider adding `includeSubDomains` and `preload` to the HSTS header
- Submit to HSTS preload list (https://hstspreload.org)

---

### 15. Open Redirect Testing — Not Vulnerable

Tested parameters: `?redirect=`, `?next=`, `?url=` on both domains.  
**Result:** No redirect Location headers returned. The sites do not reflect these parameters.

**Severity:** Info (Positive Finding)

---

### 16. HTML Comment Information Disclosure on app.qinv.ai

The app.qinv.ai HTML contains detailed comments explaining:
- Why COOP is set to `unsafe-none`
- That CSP frame-src includes `keys.coinbase.com` for Smart Wallet
- Links to external documentation

**Severity:** Info  
**Impact:** Reveals architectural decisions and wallet integration details to anyone inspecting the source. Not directly exploitable but provides reconnaissance information.  
**Recommendation:**  
Strip HTML comments in production builds. For Vite, use `vite-plugin-html` with `removeComments: true`.

---

### 17. Sensitive Path Exposure on www.qinv.ai

The following paths are accessible (all return 404, properly handled):
- `/.env` → 404 ✅
- `/.git/config` → 404 ✅  
- `/package.json` → 404 ✅

**Severity:** Info (Positive Finding)  
**Impact:** No sensitive files are exposed on the marketing site.

---

## Summary Table

| # | Finding | Severity | Status |
|---|---------|----------|--------|
| 1 | Missing security headers on www.qinv.ai | **Medium** | Needs fix |
| 2 | Weak CSP (unsafe-inline/eval) on app.qinv.ai | **Medium** | Needs fix |
| 3 | Wildcard CORS (`*`) on both domains | **Medium** | Needs fix |
| 4 | Missing X-Frame-Options on app.qinv.ai | **Medium** | Needs fix |
| 5 | COOP set to unsafe-none | Low | Accepted risk |
| 6 | Supabase anon key in JS bundle | Low | By design |
| 7 | Supabase webhook URL in farcaster.json | Low | Monitor |
| 8 | X-Powered-By: Express header | Low | Easy fix |
| 9 | Next.js build manifest exposed | Info | Standard behavior |
| 10 | SPA catch-all returns 200 for sensitive paths | Low | Should fix |
| 11 | API endpoints properly protected | Info | ✅ Good |
| 12 | Missing security.txt | Info | Should add |
| 13 | No cookie issues | Info | ✅ Good |
| 14 | Strong SSL/TLS + HSTS | Info | ✅ Good |
| 15 | No open redirects | Info | ✅ Good |
| 16 | HTML comments disclose architecture | Info | Nice to fix |
| 17 | No sensitive files exposed on www | Info | ✅ Good |

---

## Priority Actions

### Immediate (This Week)
1. **Add security headers** to `www.qinv.ai` via `vercel.json` or `next.config.js` (CSP, X-Frame-Options, X-Content-Type-Options, Referrer-Policy)
2. **Restrict CORS** on `app.qinv.ai` to specific allowed origins
3. **Add `X-Frame-Options: DENY`** to `app.qinv.ai` via `vercel.json`
4. **Remove `X-Powered-By`** header from Express

### Short-term (This Month)  
5. Strengthen CSP on `app.qinv.ai` — minimize `unsafe-inline`/`unsafe-eval`
6. Add `security.txt` file
7. Add explicit 404 rules for dotfiles on `app.qinv.ai`
8. Strip HTML comments from production builds
9. Add HSTS `includeSubDomains; preload` and submit to preload list

### Ongoing
10. Audit Supabase RLS policies to ensure anon key cannot access sensitive data
11. Add rate limiting to Supabase edge functions
12. Monitor for new security header recommendations
13. Regular dependency audits (especially Web3 libraries)

---

## Methodology

This audit was performed externally using:
- `curl` for HTTP header analysis and endpoint probing
- Manual source code review of served HTML/JS
- SSL certificate inspection via `openssl`
- Common path enumeration (`.env`, `.git`, `package.json`, admin panels)
- Open redirect parameter testing
- CORS origin validation testing
- JavaScript bundle analysis for exposed secrets

**Limitations:** This is an external black-box audit. Internal API logic, smart contract security, Supabase RLS policies, and server-side code were not assessed. A full penetration test and smart contract audit are recommended for a DeFi platform handling real funds.
