// ============================================
// /api/blog/posts — GET (list) + POST (create)
// File: app/api/blog/posts/route.ts
// ============================================

import { NextRequest, NextResponse } from "next/server";
import { getSupabaseAdmin, validatePostInput, calculateReadingTime } from "@/lib/supabase";

function unauthorized() {
  return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
}

function checkAuth(req: NextRequest): boolean {
  const token = req.headers.get("authorization")?.replace("Bearer ", "");
  return token === process.env.BLOG_API_TOKEN;
}

// GET /api/blog/posts?status=published&limit=10&offset=0
export async function GET(req: NextRequest) {
  try {
    const { searchParams } = req.nextUrl;
    const status = searchParams.get("status") || "published";
    const limit = Math.min(Number(searchParams.get("limit")) || 20, 100);
    const offset = Number(searchParams.get("offset")) || 0;

    const supabase = getSupabaseAdmin();

    const { data, error, count } = await supabase
      .from("blog_posts")
      .select("*", { count: "exact" })
      .eq("status", status)
      .order("published_at", { ascending: false })
      .range(offset, offset + limit - 1);

    if (error) throw error;

    return NextResponse.json({ posts: data, total: count, limit, offset });
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : "Internal server error";
    return NextResponse.json({ error: message }, { status: 500 });
  }
}

// POST /api/blog/posts — Auth required
export async function POST(req: NextRequest) {
  if (!checkAuth(req)) return unauthorized();

  try {
    const body = await req.json();
    const validation = validatePostInput(body);

    if (!validation.valid) {
      return NextResponse.json({ error: validation.error }, { status: 400 });
    }

    const supabase = getSupabaseAdmin();
    const { data, error } = await supabase
      .from("blog_posts")
      .insert(validation.data)
      .select()
      .single();

    if (error) {
      if (error.code === "23505") {
        return NextResponse.json({ error: "Slug already exists" }, { status: 409 });
      }
      throw error;
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
    }).catch(() => {}); // Non-blocking

    return NextResponse.json({ post: data }, { status: 201 });
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : "Internal server error";
    return NextResponse.json({ error: message }, { status: 500 });
  }
}
