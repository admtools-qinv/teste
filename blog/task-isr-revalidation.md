# Task: Add on-demand ISR revalidation to QINV blog

## Context
Blog posts are created via a Supabase Edge Function (`create-blog-post`). Currently the blog pages use time-based ISR (`revalidate = 3600`), so new posts take up to 1 hour to appear. We want instant visibility after publishing.

## What to do

### 1. Create a revalidation API route

Create `app/api/revalidate/route.ts`:

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { revalidatePath } from 'next/cache';

export async function POST(request: NextRequest) {
  const authHeader = request.headers.get('authorization');
  const token = authHeader?.replace('Bearer ', '');

  if (token !== process.env.REVALIDATION_SECRET) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  const body = await request.json();
  const { slug } = body;

  // Revalidate blog listing
  revalidatePath('/blog');

  // Revalidate specific post if slug provided
  if (slug) {
    revalidatePath(`/blog/${slug}`);
  }

  // Also revalidate sitemap
  revalidatePath('/sitemap.xml');

  return NextResponse.json({ 
    revalidated: true, 
    paths: ['/blog', slug ? `/blog/${slug}` : null].filter(Boolean),
    now: Date.now() 
  });
}
```

### 2. Add env var

Add `REVALIDATION_SECRET` to Vercel environment variables (any random string, e.g. `openssl rand -hex 24`).

### 3. Call revalidation from the Edge Function

In the `create-blog-post` Edge Function, after successfully inserting the post, add:

```typescript
// After successful insert, trigger revalidation
try {
  await fetch(`${SITE_URL}/api/revalidate`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${REVALIDATION_SECRET}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ slug: newPost.slug }),
  });
} catch (e) {
  // Non-blocking: post is saved even if revalidation fails
  console.error('Revalidation failed:', e);
}
```

Add `REVALIDATION_SECRET` and `SITE_URL=https://www.qinv.ai` to the Edge Function env vars too.

### 4. Keep time-based ISR as fallback

Don't remove the existing `revalidate` value from the pages. Just lower it as a safety net:

```typescript
// In /blog/page.tsx and /blog/[slug]/page.tsx
export const revalidate = 300; // 5 min fallback (on-demand handles the instant case)
```

## Result
- New post published → Edge Function inserts in DB → calls `/api/revalidate` → pages regenerate instantly
- If revalidation call fails, post still appears within 5 minutes (fallback)
