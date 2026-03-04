// ============================================
// /api/blog/revalidate — POST
// File: app/api/blog/revalidate/route.ts
// ============================================

import { NextRequest, NextResponse } from "next/server";
import { revalidatePath } from "next/cache";

export async function POST(req: NextRequest) {
  const token = req.headers.get("authorization")?.replace("Bearer ", "");
  if (token !== process.env.BLOG_API_TOKEN) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  try {
    const body = await req.json().catch(() => ({}));
    const slug = body?.slug as string | undefined;

    // Revalidate blog index
    revalidatePath("/blog");

    // Revalidate specific post if slug provided
    if (slug) {
      revalidatePath(`/blog/${slug}`);
    }

    return NextResponse.json({
      revalidated: true,
      paths: ["/blog", slug ? `/blog/${slug}` : null].filter(Boolean),
    });
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : "Revalidation failed";
    return NextResponse.json({ error: message }, { status: 500 });
  }
}
