-- Seed data for testing
-- Note: In a real Supabase project, this would be run with supabase db reset or similar

-- Insert sample users
INSERT INTO users (id, email, name) VALUES
    ('550e8400-e29b-41d4-a716-446655440000', 'alice@example.com', 'Alice Johnson'),
    ('550e8400-e29b-41d4-a716-446655440001', 'bob@example.com', 'Bob Smith'),
    ('550e8400-e29b-41d4-a716-446655440002', 'charlie@example.com', 'Charlie Brown'),
    ('550e8400-e29b-41d4-a716-446655440003', 'diana@example.com', 'Diana Prince'),
    ('550e8400-e29b-41d4-a716-446655440004', 'evan@example.com', 'Evan Torres'),
    ('550e8400-e29b-41d4-a716-446655440005', 'fiona@example.com', 'Fiona Gallagher');

-- Insert sample posts
INSERT INTO posts (id, title, content, author_id) VALUES
    ('660e8400-e29b-41d4-a716-446655440000', 'Welcome to Supabase', 'This is a sample post about Supabase migrations.', '550e8400-e29b-41d4-a716-446655440000'),
    ('660e8400-e29b-41d4-a716-446655440001', 'Database Best Practices', 'Some tips for database design and migrations.', '550e8400-e29b-41d4-a716-446655440001'),
    ('660e8400-e29b-41d4-a716-446655440002', 'Octopus Deploy Integration', 'How to use Octopus Deploy with Supabase.', '550e8400-e29b-41d4-a716-446655440002'),
    ('660e8400-e29b-41d4-a716-446655440003', 'Getting Started with Row Level Security', 'An introduction to RLS policies in Supabase.', '550e8400-e29b-41d4-a716-446655440003'),
    ('660e8400-e29b-41d4-a716-446655440004', 'Realtime Subscriptions Explained', 'How to use Supabase Realtime to listen for database changes.', '550e8400-e29b-41d4-a716-446655440004'),
    ('660e8400-e29b-41d4-a716-446655440005', 'CI/CD for Database Migrations', 'Automating schema changes with Octopus Deploy pipelines.', '550e8400-e29b-41d4-a716-446655440005');

-- Insert sample comments
INSERT INTO comments (post_id, author_id, content) VALUES
    ('660e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440001', 'Great post!'),
    ('660e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440000', 'Very helpful tips.'),
    ('660e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001', 'Looking forward to trying this.'),
    ('660e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440002', 'RLS policies finally make sense to me now.'),
    ('660e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440004', 'Would love to see a follow-up on multi-tenant setups.'),
    ('660e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440003', 'Realtime is a game changer for dashboards.'),
    ('660e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440005', 'Does this work with Edge Functions too?'),
    ('660e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440000', 'We use this exact setup in production, works great.'),
    ('660e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440002', 'How do you handle rollbacks?');