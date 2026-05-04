-- Create tags table
CREATE TABLE tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create post_tags join table
CREATE TABLE post_tags (
    post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
    tag_id  UUID REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY (post_id, tag_id)
);

-- Create reactions table
CREATE TABLE reactions (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id    UUID REFERENCES posts(id) ON DELETE CASCADE,
    author_id  UUID REFERENCES users(id) ON DELETE CASCADE,
    emoji      TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE (post_id, author_id, emoji)
);

-- Enable RLS
ALTER TABLE tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE reactions ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Anyone can view tags" ON tags
    FOR SELECT USING (true);

CREATE POLICY "Anyone can view post tags" ON post_tags
    FOR SELECT USING (true);

CREATE POLICY "Authenticated users can tag posts" ON post_tags
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Anyone can view reactions" ON reactions
    FOR SELECT USING (true);

CREATE POLICY "Authenticated users can react" ON reactions
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Users can remove their own reactions" ON reactions
    FOR DELETE USING (auth.uid() = author_id);

-- Indexes
CREATE INDEX idx_post_tags_post_id ON post_tags(post_id);
CREATE INDEX idx_post_tags_tag_id ON post_tags(tag_id);
CREATE INDEX idx_reactions_post_id ON reactions(post_id);
