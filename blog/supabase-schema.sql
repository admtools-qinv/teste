-- ============================================
-- Blog Posts Schema for Supabase
-- ============================================

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create enum for post status
CREATE TYPE post_status AS ENUM ('draft', 'published', 'archived');

-- Create blog_posts table
CREATE TABLE blog_posts (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title           TEXT NOT NULL,
  slug            TEXT NOT NULL UNIQUE,
  excerpt         TEXT,
  content         TEXT NOT NULL,          -- Markdown content
  cover_image     TEXT,                   -- URL to cover image
  tags            TEXT[] DEFAULT '{}',
  status          post_status DEFAULT 'draft',
  author          TEXT NOT NULL,
  reading_time_min INTEGER DEFAULT 1,
  meta_description TEXT,
  published_at    TIMESTAMPTZ,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_blog_posts_slug ON blog_posts (slug);
CREATE INDEX idx_blog_posts_status ON blog_posts (status);
CREATE INDEX idx_blog_posts_published_at ON blog_posts (published_at DESC);
CREATE INDEX idx_blog_posts_tags ON blog_posts USING GIN (tags);

-- Auto-update updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER blog_posts_updated_at
  BEFORE UPDATE ON blog_posts
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

-- View for published posts ordered by date
CREATE VIEW published_posts AS
  SELECT *
  FROM blog_posts
  WHERE status = 'published'
    AND published_at IS NOT NULL
  ORDER BY published_at DESC;

-- ============================================
-- Row Level Security
-- ============================================

ALTER TABLE blog_posts ENABLE ROW LEVEL SECURITY;

-- Public read access for published posts
CREATE POLICY "Public can read published posts"
  ON blog_posts FOR SELECT
  USING (status = 'published');

-- Service role has full access (used by API routes via service key)
CREATE POLICY "Service role full access"
  ON blog_posts FOR ALL
  USING (auth.role() = 'service_role')
  WITH CHECK (auth.role() = 'service_role');
