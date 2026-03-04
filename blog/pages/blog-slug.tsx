// ============================================
// /blog/[slug] — Single Blog Post Page
// File: app/blog/[slug]/page.tsx
// ============================================

import { Metadata } from "next";
import { notFound } from "next/navigation";
import { getSupabaseAdmin, Post } from "@/lib/supabase";
import { MDXRemote } from "next-mdx-remote/rsc";
import rehypeHighlight from "rehype-highlight";
import rehypeSlug from "rehype-slug";
import remarkGfm from "remark-gfm";

// ISR: revalidate every 60 seconds
export const revalidate = 60;

type PageProps = { params: Promise<{ slug: string }> };

async function getPost(slug: string): Promise<Post | null> {
  const supabase = getSupabaseAdmin();
  const { data, error } = await supabase
    .from("blog_posts")
    .select("*")
    .eq("slug", slug)
    .eq("status", "published")
    .single();

  if (error || !data) return null;
  return data as Post;
}

// Generate static params for all published posts
export async function generateStaticParams() {
  const supabase = getSupabaseAdmin();
  const { data } = await supabase
    .from("blog_posts")
    .select("slug")
    .eq("status", "published");

  return (data || []).map((post) => ({ slug: post.slug }));
}

// Dynamic metadata for SEO
export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const { slug } = await params;
  const post = await getPost(slug);
  if (!post) return { title: "Post Not Found" };

  return {
    title: `${post.title} | QINV Blog`,
    description: post.meta_description || post.excerpt || "",
    openGraph: {
      title: post.title,
      description: post.meta_description || post.excerpt || "",
      type: "article",
      publishedTime: post.published_at || undefined,
      authors: [post.author],
      images: post.cover_image ? [{ url: post.cover_image }] : [],
    },
    twitter: {
      card: "summary_large_image",
      title: post.title,
      description: post.meta_description || post.excerpt || "",
      images: post.cover_image ? [post.cover_image] : [],
    },
  };
}

function formatDate(dateString: string): string {
  return new Date(dateString).toLocaleDateString("en-US", {
    year: "numeric",
    month: "long",
    day: "numeric",
  });
}

// JSON-LD structured data
function ArticleJsonLd({ post }: { post: Post }) {
  const jsonLd = {
    "@context": "https://schema.org",
    "@type": "Article",
    headline: post.title,
    description: post.meta_description || post.excerpt,
    image: post.cover_image || undefined,
    author: { "@type": "Person", name: post.author },
    datePublished: post.published_at,
    dateModified: post.updated_at,
    publisher: {
      "@type": "Organization",
      name: "QINV",
    },
  };

  return (
    <script
      type="application/ld+json"
      dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
    />
  );
}

// MDX options for rendering markdown
const mdxOptions = {
  mdxOptions: {
    remarkPlugins: [remarkGfm],
    rehypePlugins: [rehypeHighlight, rehypeSlug],
  },
};

export default async function BlogPostPage({ params }: PageProps) {
  const { slug } = await params;
  const post = await getPost(slug);

  if (!post) notFound();

  return (
    <>
      <ArticleJsonLd post={post} />

      <main className="mx-auto max-w-3xl px-4 py-16">
        {/* Header */}
        <header className="mb-10">
          <div className="mb-4 flex items-center gap-3 text-sm text-muted-foreground">
            {post.published_at && (
              <time dateTime={post.published_at}>
                {formatDate(post.published_at)}
              </time>
            )}
            <span>·</span>
            <span>{post.reading_time_min} min read</span>
            <span>·</span>
            <span>{post.author}</span>
          </div>

          <h1 className="mb-4 text-4xl font-bold tracking-tight lg:text-5xl">
            {post.title}
          </h1>

          {post.excerpt && (
            <p className="text-xl text-muted-foreground">{post.excerpt}</p>
          )}

          {post.tags.length > 0 && (
            <div className="mt-4 flex flex-wrap gap-2">
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
        </header>

        {/* Cover Image */}
        {post.cover_image && (
          <div className="relative mb-10 aspect-[2/1] overflow-hidden rounded-lg">
            {/* Using img for simplicity; swap to next/image if domains are configured */}
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img
              src={post.cover_image}
              alt={post.title}
              className="h-full w-full object-cover"
            />
          </div>
        )}

        {/* Markdown Content */}
        <article className="prose prose-lg dark:prose-invert max-w-none">
          <MDXRemote source={post.content} options={mdxOptions} />
        </article>
      </main>
    </>
  );
}
