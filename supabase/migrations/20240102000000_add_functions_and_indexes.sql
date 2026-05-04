-- Create a function to get user posts count
CREATE OR REPLACE FUNCTION get_user_posts_count(user_uuid UUID)
RETURNS INTEGER AS $$
BEGIN
    RETURN (SELECT COUNT(*) FROM posts WHERE author_id = user_uuid);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create a function to get post comments count
CREATE OR REPLACE FUNCTION get_post_comments_count(post_uuid UUID)
RETURNS INTEGER AS $$
BEGIN
    RETURN (SELECT COUNT(*) FROM comments WHERE post_id = post_uuid);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create a trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply the trigger to users table
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Apply the trigger to posts table
CREATE TRIGGER update_posts_updated_at
    BEFORE UPDATE ON posts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Create an index on posts author_id for better performance
CREATE INDEX idx_posts_author_id ON posts(author_id);

-- Create an index on comments post_id
CREATE INDEX idx_comments_post_id ON comments(post_id);

-- Create an index on comments author_id
CREATE INDEX idx_comments_author_id ON comments(author_id);