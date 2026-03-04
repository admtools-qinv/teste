// ============================================
// /blog — Blog Index Page
// File: app/blog/page.tsx
// ============================================

import { Metadata } from "next";
import Image from "next/image";
import Link from "next/link";
import { getSupabaseAdmin, Post } from "@/lib/supabase";

export const metadata: Metadata = {
  title: "Blog | QINV",
  description: "Insights on quantitative investing, markets, and technology.",
  openGraph: {
    title: "Blog | QINV",
    description: "Insights on quantitative investing, markets, and technology.",
  },
};

// ISR: revalidate every 5 minutes
export const revalidate = 300;

async function getPosts(): Promise<Post[]> {
  const supabase = getSupabaseAdmin();
  const { data, error } = await supabase
    .from("blog_posts")
    .select("*")
    .eq("status", "published")
    .order("published_at", { ascending: false });

  if (error) {
    console.error("Failed to fetch posts:", error.message);
    return [];
  }

  return data as Post[];
}

function formatDate(dateString: string): string {
  return new Date(dateString).toLocaleDateString("en-US", {
    year: "numeric",
    month: "long",
    day: "numeric",
  });
}

export default async function BlogIndex() {
  const posts = await getPosts();

  return (
    <main className="mx-auto max-w-4xl px-4 py-16">
      <h1 className="mb-2 text-4xl font-bold tracking-tight">Blog</h1>
      <p className="mb-12 text-lg text-muted-foreground">
        Insights on quantitative investing, markets, and technology.
      </p>

      {posts.length === 0 ? (
        <p className="text-muted-foreground">No posts yet. Check back soon!</p>
      ) : (
        <div className="space-y-12">
          {posts.map((post) => (
            <article key={post.id} className="group">
              <Link href={`/blog/${post.slug}`} className="block">
                {post.cover_image && (
                  <div className="relative mb-4 aspect-[2/1] overflow-hidden rounded-lg">
                    <Image
                      src={post.cover_image}
                      alt={post.title}
                      fill
                      className="object-cover transition-transform group-hover:scale-105"
                      sizes="(max-width: 768px) 100vw, 800px"
                    />
                  </div>
                )}

                <div className="space-y-2">
                  <div className="flex items-center gap-3 text-sm text-muted-foreground">
                    {post.published_at && (
                      <time dateTime={post.published_at}>
                        {formatDate(post.published_at)}
                      </time>
                    )}
                    <span>·</span>
                    <span>{post.reading_time_min} min read</span>
                  </div>

                  <h2 className="text-2xl font-semibold group-hover:underline">
                    {post.title}
                  </h2>

                  {post.excerpt && (
                    <p className="text-muted-foreground">{post.excerpt}</p>
                  )}

                  {post.tags.length > 0 && (
                    <div className="flex flex-wrap gap-2 pt-1">
                      {post.tags.map((tag) => (
                        <span
                          key={tag}
                          className="rounded-full bg-secondary px-3 py-1 text-xs font-medium"
                        >
                          {tag}
                        </span>
                      ))}
                    </div>
                  )}
                </div>
              </Link>
            </article>
          ))}
        </div>
      )}
    </main>
  );
}
