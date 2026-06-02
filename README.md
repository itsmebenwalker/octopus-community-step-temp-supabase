# Supabase — Run Migrations & Deploy Edge Functions

[Octopus Deploy Community Step Templates](https://library.octopus.com) for working with Supabase projects using the Supabase CLI.

---

## Step Templates

### Supabase - Run Migrations

Located at `Library/step-templates/supabase-run-migrations.json`.

**What it does:**

1. Installs the Supabase CLI if not already present (downloads the binary directly from GitHub releases — no `npm` or `sudo` required)
2. Links the Supabase project using the provided access token via the `SUPABASE_ACCESS_TOKEN` environment variable
3. Pushes pending migrations to the remote database

**Parameters:**

| Parameter | Description | Required | Default |
|-----------|-------------|----------|---------|
| `SupabaseProjectRef` | The unique identifier of your Supabase project | Yes | — |
| `SupabaseDbPassword` | Password for the PostgreSQL database user | Yes | — |
| `SupabaseAccessToken` | Supabase access token for CLI authentication | Yes | — |
| `SupabaseCliVersion` | Version of the Supabase CLI to install | No | `latest` |

---

### Supabase - Deploy Edge Function

Deploys one or all edge functions to a Supabase project.

**What it does:**

1. Installs the Supabase CLI if not already present
2. Authenticates using the provided access token
3. Deploys the specified function (or all functions with `--all`) using `supabase functions deploy`
4. Optionally runs a smoke test — an HTTP GET to the deployed function URL — and validates the response code

**Parameters:**

| Parameter | Description | Required | Default |
|-----------|-------------|----------|---------|
| `SupabaseProjectRef` | The unique identifier of your Supabase project | Yes | — |
| `SupabaseAccessToken` | Supabase access token (`sbp_...`) for CLI authentication | Yes | — |
| `FunctionName` | Name of the function to deploy (e.g. `hello-world`). Leave empty when Deploy All is on | No | — |
| `DeployAll` | Deploy all functions in `supabase/functions/` with `--all` | No | `false` |
| `VerifyJwt` | Enforce JWT verification on the function. Set to `false` to pass `--no-verify-jwt` | No | `true` |
| `SmokeTest` | Perform an HTTP GET after deploy and assert the expected status code | No | `false` |
| `SmokeTestExpectedStatus` | HTTP status code considered a pass (e.g. `200` or `401`) | No | `200` |
| `SupabaseCliVersion` | Version of the Supabase CLI to install | No | `latest` |

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

The deployment process references the `supabase-migrations` package, extracted to the worker alongside the script. The step template uses `Octopus.Action.Package[supabase-migrations].ExtractedPath` to locate the migrations and functions directories at runtime.

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
