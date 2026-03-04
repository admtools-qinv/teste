// ============================================
// /api/blog/posts/[slug] — GET + PUT + DELETE
// File: app/api/blog/posts/[slug]/route.ts
// ============================================

import { NextRequest, NextResponse } from "next/server";
import { getSupabaseAdmin, calculateReadingTime, PostUpdate } from "@/lib/supabase";

function unauthorized() {
  return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
}

function checkAuth(req: NextRequest): boolean {
  const token = req.headers.get("authorization")?.replace("Bearer ", "");
  return token === process.env.BLOG_API_TOKEN;
}

type RouteContext = { params: Promise<{ slug: string }> };

// GET /api/blog/posts/[slug] — Public
export async function GET(_req: NextRequest, context: RouteContext) {
  try {
    const { slug } = await context.params;
    const supabase = getSupabaseAdmin();

    const { data, error } = await supabase
      .from("blog_posts")
      .select("*")
      .eq("slug", slug)
      .eq("status", "published")
      .single();

    if (error || !data) {
      return NextResponse.json({ error: "Post not found" }, { status: 404 });
    }

    return NextResponse.json({ post: data });
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : "Internal server error";
    return NextResponse.json({ error: message }, { status: 500 });
  }
}

// PUT /api/blog/posts/[slug] — Auth required
export async function PUT(req: NextRequest, context: RouteContext) {
  if (!checkAuth(req)) return unauthorized();

  try {
    const { slug } = await context.params;
    const body = await req.json();

    // Build update object with only provided fields
    const update: PostUpdate = {};
    const allowedFields = [
      "title", "excerpt", "content", "cover_image", "tags",
      "status", "author", "meta_description", "published_at",
    ] as const;

    for (const field of allowedFields) {
      if (body[field] !== undefined) {
        (update as Record<string, unknown>)[field] = body[field];
      }
    }

    // Recalculate reading time if content changed
    if (update.content) {
      update.reading_time_min = calculateReadingTime(update.content);
    }

    // Auto-set published_at when publishing for the first time
    if (update.status === "published" && !update.published_at) {
      update.published_at = new Date().toISOString();
    }

    const supabase = getSupabaseAdmin();
    const { data, error } = await supabase
      .from("blog_posts")
      .update(update)
      .eq("slug", slug)
      .select()
      .single();

    if (error || !data) {
      return NextResponse.json({ error: "Post not found" }, { status: 404 });
    }

    // Trigger revalidation
    const baseUrl = process.env.NEXT_PUBLIC_SITE_URL || req.nextUrl.origin;
    await fetch(`${baseUrl}/api/blog/revalidate`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${process.env.BLOG_API_TOKEN}`,
      },
      body: JSON.stringify({ slug: data.slug }),
    }).catch(() => {});

    return NextResponse.json({ post: data });
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : "Internal server error";
    return NextResponse.json({ error: message }, { status: 500 });
  }
}

// DELETE /api/blog/posts/[slug] — Soft delete (archive), auth required
export async function DELETE(req: NextRequest, context: RouteContext) {
  if (!checkAuth(req)) return unauthorized();

  try {
    const { slug } = await context.params;
    const supabase = getSupabaseAdmin();

    const { data, error } = await supabase
      .from("blog_posts")
      .update({ status: "archived" as const })
      .eq("slug", slug)
      .select()
      .single();

    if (error || !data) {
      return NextResponse.json({ error: "Post not found" }, { status: 404 });
    }

    // Revalidate to remove from listings
    const baseUrl = process.env.NEXT_PUBLIC_SITE_URL || req.nextUrl.origin;
    await fetch(`${baseUrl}/api/blog/revalidate`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${process.env.BLOG_API_TOKEN}`,
      },
      body: JSON.stringify({ slug }),
    }).catch(() => {});

    return NextResponse.json({ message: "Post archived", post: data });
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : "Internal server error";
    return NextResponse.json({ error: message }, { status: 500 });
  }
}
