# Supabase — Run Migrations & Deploy Edge Functions

[Octopus Deploy Community Step Templates](https://library.octopus.com) for working with Supabase projects using the Supabase CLI.

---

## Background

[Supabase](https://supabase.com) is an open-source Firebase alternative built on PostgreSQL, offering a managed database, authentication, storage, realtime subscriptions, and **Edge Functions**: globally-distributed TypeScript/Deno serverless functions deployed to a CDN edge network.

Supabase has become the backend platform of choice for a new wave of developers building with AI-assisted tools. The auto-generated TypeScript SDK, instant REST and GraphQL APIs, and the Supabase CLI make it straightforward for an AI agent to scaffold and iterate on a backend — meaning many Octopus customers are now deploying Supabase-backed applications as part of their release pipelines, with Edge Functions increasingly where business logic lives.

This repository contains two companion step templates:

- **`Supabase - Run Migrations`** — pushes database schema changes
- **`Supabase - Deploy Edge Function`** — deploys Edge Functions

---

## Step Templates

### Supabase - Run Migrations

Located at `Library/step-templates/supabase-run-migrations.json`.

**What it does:**

1. Installs the Supabase CLI if not already present (downloads the binary directly from GitHub releases — no `npm` or `sudo` required)
2. Links the Supabase project using the provided access token via the `SUPABASE_ACCESS_TOKEN` environment variable
3. Pushes pending migrations to the remote database

**Parameters:**

| Parameter | Type | Required | Default |
|-----------|------|----------|---------|
| `SupabaseProjectRef` | String | Yes | — |
| `SupabaseDbPassword` | Sensitive | Yes | — |
| `SupabaseAccessToken` | Sensitive | Yes | — |
| `SupabaseCliVersion` | String | No | `latest` |

---

### Supabase - Deploy Edge Function

Located at `Library/step-templates/supabase-deploy-edge-function.json`.

Before this step existed, deploying Supabase Edge Functions from an Octopus deployment required a custom **Run a Script** step — manually scripting the CLI install, authentication, and deploy command for each project. This step replaces all of that: attach the package containing `supabase/functions/`, supply the project ref and access token, and the step handles the rest.

**What it does:**

1. Installs the Supabase CLI on the worker if not already present (Linux binary from GitHub releases, Homebrew on macOS), with optional version pinning
2. Authenticates via `SUPABASE_ACCESS_TOKEN` — no interactive login required, safe for CI/CD workers
3. Resolves the working directory from the extracted package (`#{Octopus.Action.Package[supabase-migrations].ExtractedPath}`) with a fallback to the current directory, matching the pattern used by the `Supabase - Run Migrations` step
4. Deploys a named function or all functions in the package
5. Optionally disables JWT verification (`--no-verify-jwt`) for public functions
6. Optionally accepts a custom import map path
7. Runs an optional post-deploy smoke test: `GET` the function URL and asserts a non-5xx response — a `401` is treated as a pass (expected when JWT verification is enabled)

**Parameters:**

| Parameter | Type | Required | Default |
|-----------|------|----------|---------|
| `SupabaseProjectRef` | String | Yes | — |
| `SupabaseAccessToken` | Sensitive | Yes | — |
| `SupabaseFunctionName` | String | No — leave empty to deploy all | — |
| `SupabaseVerifyJWT` | Checkbox | No | `true` |
| `SupabaseImportMapPath` | String | No | — |
| `SupabaseSmokeTest` | Checkbox | No | `false` |
| `SupabaseCliVersion` | String | No | `latest` |

**Package Reference Required:**
Attach a package named `supabase-migrations` to the step with **Extract package** enabled. The package must contain a `supabase/functions/` directory at its root.

**Test scenarios:**

| # | Scenario | Parameters |
|---|----------|------------|
| 1 | Deploy named function | `FunctionName: hello-world`, Deploy All: off, Verify JWT: on, Smoke Test: on → expect 401 (pass) |
| 2 | Deploy public function | `FunctionName: hello-public`, Verify JWT: **off**, Smoke Test: on → expect 200 (pass) |
| 3 | Deploy all functions | Deploy All: **on**, Function Name: empty, Smoke Test: off |
| 4 | Version pinning | `SupabaseCliVersion: 1.176.6`, `FunctionName: hello-world` |
| 5 | Smoke test fail simulation | `FunctionName: hello-world`, `SupabaseProjectRef: invalid-ref-000` → deploy fails before smoke test |

---

## Sample Project Structure

```
.github/workflows/        # GitHub Actions — packages and pushes to Octopus
build/                    # Packaging scripts
supabase/
  config.toml             # Minimal Supabase config (project_id overridden at deploy time)
  migrations/
    20240101000000_initial_schema.sql
    20240102000000_add_functions_and_indexes.sql
    20240103000000_add_tags_and_reactions.sql
  functions/
    hello-world/index.ts  # Protected function (JWT required — smoke test expects 401)
    hello-public/index.ts # Public function (no JWT — smoke test expects 200)
  seed.sql
```

---

## Deploying with Octopus

The GitHub Actions workflow (`.github/workflows/package-deployment.yml`) packages the `supabase/` directory and pushes it to the Octopus built-in feed as `supabase-migrations`, then creates a release automatically.

Both steps reference the `supabase-migrations` package, extracted to the worker alongside the script. The step templates use `Octopus.Action.Package[supabase-migrations].ExtractedPath` to locate the migrations and functions directories at runtime.

### Required Octopus variables

Set these as project variables (sensitive where indicated):

| Variable | Description | Sensitive |
|----------|-------------|-----------|
| `SupabaseProjectRef` | Your Supabase project ref (from Dashboard → Project Settings → General) | No |
| `SupabaseDbPassword` | Database password | Yes |
| `SupabaseAccessToken` | Supabase personal access token (`sbp_...`) — Dashboard → Account → Access Tokens | Yes |
| `SupabaseCliVersion` | CLI version, e.g. `latest` | No |

---

## Local development

```bash
# Install Supabase CLI
brew install supabase/tap/supabase

# Start local Supabase instance
supabase start

# Apply migrations and seed data
supabase db reset

# Serve edge functions locally
supabase functions serve
```
