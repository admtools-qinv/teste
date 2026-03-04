import { createClient } from "@supabase/supabase-js";

// ============================================
// Post type definition
// ============================================

export type PostStatus = "draft" | "published" | "archived";

export interface Post {
  id: string;
  title: string;
  slug: string;
  excerpt: string | null;
  content: string;
  cover_image: string | null;
  tags: string[];
  status: PostStatus;
  author: string;
  reading_time_min: number;
  meta_description: string | null;
  published_at: string | null;
  created_at: string;
  updated_at: string;
}

export type PostInsert = Omit<Post, "id" | "created_at" | "updated_at">;
export type PostUpdate = Partial<Omit<Post, "id" | "created_at" | "updated_at">>;

// ============================================
// Server-side Supabase client (service role)
// ============================================

export function getSupabaseAdmin() {
  const url = process.env.SUPABASE_URL;
  const key = process.env.SUPABASE_SERVICE_ROLE_KEY;

  if (!url || !key) {
    throw new Error("Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY");
  }

  return createClient(url, key, {
    auth: { persistSession: false },
  });
}

// ============================================
// Helpers
// ============================================

/** Calculate reading time from markdown content (~200 wpm) */
export function calculateReadingTime(content: string): number {
  const words = content.trim().split(/\s+/).length;
  return Math.max(1, Math.round(words / 200));
}

/** Validate required fields for creating a post */
export function validatePostInput(
  body: Record<string, unknown>
): { valid: true; data: PostInsert } | { valid: false; error: string } {
  const { title, slug, content, author } = body;

  if (!title || typeof title !== "string") return { valid: false, error: "title is required" };
  if (!slug || typeof slug !== "string") return { valid: false, error: "slug is required" };
  if (!content || typeof content !== "string") return { valid: false, error: "content is required" };
  if (!author || typeof author !== "string") return { valid: false, error: "author is required" };

  // Validate slug format
  if (!/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(slug as string)) {
    return { valid: false, error: "slug must be lowercase alphanumeric with hyphens" };
  }

  const reading_time_min = calculateReadingTime(content as string);
  const status = (body.status as PostStatus) || "draft";
  const published_at =
    status === "published" ? (body.published_at as string) || new Date().toISOString() : (body.published_at as string) || null;

  return {
    valid: true,
    data: {
      title: title as string,
      slug: slug as string,
      excerpt: (body.excerpt as string) || null,
      content: content as string,
      cover_image: (body.cover_image as string) || null,
      tags: Array.isArray(body.tags) ? body.tags : [],
      status,
      author: author as string,
      reading_time_min,
      meta_description: (body.meta_description as string) || null,
      published_at,
    },
  };
}
