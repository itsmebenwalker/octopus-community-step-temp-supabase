# Supabase - Run Migrations

An [Octopus Deploy Community Step Template](https://library.octopus.com) that runs database migrations against a Supabase project using the Supabase CLI.

## Step Template

The step template is located at `Library/step-templates/supabase-run-migrations.json`.

### What it does

1. Installs the Supabase CLI if not already present (downloads the binary directly from GitHub releases — no `npm` or `sudo` required)
2. Links the Supabase project using the provided access token via the `SUPABASE_ACCESS_TOKEN` environment variable
3. Pushes pending migrations to the remote database

### Parameters

| Parameter | Description | Required | Default |
|-----------|-------------|----------|---------|
| `SupabaseProjectRef` | The unique identifier of your Supabase project | Yes | — |
| `SupabaseDbPassword` | Password for the PostgreSQL database user | Yes | — |
| `SupabaseAccessToken` | Supabase access token for CLI authentication | Yes | — |
| `SupabaseCliVersion` | Version of the Supabase CLI to install | No | `latest` |

## Sample Project Structure

This repository also contains a sample project used to test the step template end-to-end with Octopus Deploy.

```
.github/workflows/        # GitHub Actions — packages and pushes to Octopus
build/                    # Packaging scripts
supabase/
  config.toml             # Supabase project configuration
  migrations/
    20240101000000_initial_schema.sql          # users, posts, comments tables + RLS
    20240102000000_add_functions_and_indexes.sql  # functions, triggers, indexes
    20240103000000_add_tags_and_reactions.sql   # tags, post_tags, reactions tables
  seed.sql                # Sample data for local testing
```

## Deploying migrations with Octopus

The GitHub Actions workflow (`.github/workflows/package-deployment.yml`) packages the `supabase/` directory and pushes it to the Octopus built-in feed as `supabase-migrations`, then creates a release automatically.

The deployment process references the `supabase-migrations` package, which is extracted to the worker alongside the script. The step template uses `Octopus.Action.Package[supabase-migrations].ExtractedPath` to locate the migrations directory at runtime.

### Required Octopus variables

Set these as project variables (sensitive where indicated):

| Variable | Description | Sensitive |
|----------|-------------|-----------|
| `SupabaseProjectRef` | Your Supabase project ref (from the dashboard URL) | No |
| `SupabaseDbPassword` | Database password | Yes |
| `SupabaseAccessToken` | Supabase access token (`sbp_...`) | Yes |
| `SupabaseCliVersion` | CLI version, e.g. `latest` | No |

## Local development

```bash
# Install Supabase CLI
brew install supabase/tap/supabase

# Start local Supabase instance
supabase start

# Apply migrations and seed data
supabase db reset
```
