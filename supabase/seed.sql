-- Seed data for testing
-- Note: In a real Supabase project, this would be run with supabase db reset or similar

-- Insert sample users
INSERT INTO users (id, email, name) VALUES
    ('550e8400-e29b-41d4-a716-446655440000', 'alice@example.com', 'Alice Johnson'),
    ('550e8400-e29b-41d4-a716-446655440001', 'bob@example.com', 'Bob Smith'),
    ('550e8400-e29b-41d4-a716-446655440002', 'charlie@example.com', 'Charlie Brown');

-- Insert sample posts
INSERT INTO posts (id, title, content, author_id) VALUES
    ('660e8400-e29b-41d4-a716-446655440000', 'Welcome to Supabase', 'This is a sample post about Supabase migrations.', '550e8400-e29b-41d4-a716-446655440000'),
    ('660e8400-e29b-41d4-a716-446655440001', 'Database Best Practices', 'Some tips for database design and migrations.', '550e8400-e29b-41d4-a716-446655440001'),
    ('660e8400-e29b-41d4-a716-446655440002', 'Octopus Deploy Integration', 'How to use Octopus Deploy with Supabase.', '550e8400-e29b-41d4-a716-446655440002');

-- Insert sample comments
INSERT INTO comments (post_id, author_id, content) VALUES
    ('660e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440001', 'Great post!'),
    ('660e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440000', 'Very helpful tips.'),
    ('660e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001', 'Looking forward to trying this.');