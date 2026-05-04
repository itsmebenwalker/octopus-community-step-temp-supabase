# octopus-community-step-temp-supabase

This is a sample Supabase project for testing the Octopus Deploy Community Step Template for database migrations.

## Project Structure

- `.github`: Github Actions for package deployments into Octopus Deploy
- `supabase/config.toml`: Supabase project configuration
- `supabase/migrations/`: Database migration files
  - `20240101000000_initial_schema.sql`: Creates users, posts, and comments tables with RLS policies
  - `20240102000000_add_functions_and_indexes.sql`: Adds functions, triggers, and indexes
- `supabase/seed.sql`: Sample data for testing

## Usage

1. Install Supabase CLI
2. Run `supabase start` to start the local Supabase instance
3. Run `supabase db reset` to apply migrations and seed data
4. Use this project to test the Octopus Deploy Community Step Template for Supabase migrations

## Packaging for Octopus

To create a package for Octopus Deploy, you can zip the `supabase/migrations/` directory or include the entire `supabase/` folder depending on your deployment strategy.
