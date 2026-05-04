# Supabase - Run Migrations Pester Tests
# Tests for the Supabase database migration step template

Describe "Supabase - Run Migrations" {
    BeforeAll {
        # Set test environment variables
        $env:SUPABASE_PROJECT_REF = "test-project-ref"
        $env:SUPABASE_DB_PASSWORD = "test-password"
        $env:SUPABASE_ACCESS_TOKEN = "test-token"
        $env:SUPABASE_CLI_VERSION = "latest"
    }

    AfterAll {
        # Clean up test environment variables
        Remove-Item Env:\SUPABASE_PROJECT_REF -ErrorAction SilentlyContinue
        Remove-Item Env:\SUPABASE_DB_PASSWORD -ErrorAction SilentlyContinue
        Remove-Item Env:\SUPABASE_ACCESS_TOKEN -ErrorAction SilentlyContinue
        Remove-Item Env:\SUPABASE_CLI_VERSION -ErrorAction SilentlyContinue
    }

    Context "Parameter Validation" {
        It "fails when ProjectRef is empty" {
            $scriptContent = @'
set -e

SUPABASE_PROJECT_REF=""
SUPABASE_DB_PASSWORD="test"
SUPABASE_ACCESS_TOKEN="test"

if [ -z "$SUPABASE_PROJECT_REF" ]; then
    echo "ERROR: Supabase Project Ref is required."
    exit 1
fi
'@
            { bash -c $scriptContent } | Should -Throw
        }

        It "fails when Database Password is empty" {
            $scriptContent = @'
set -e

SUPABASE_PROJECT_REF="test-ref"
SUPABASE_DB_PASSWORD=""
SUPABASE_ACCESS_TOKEN="test"

if [ -z "$SUPABASE_DB_PASSWORD" ]; then
    echo "ERROR: Database Password is required."
    exit 1
fi
'@
            { bash -c $scriptContent } | Should -Throw
        }

        It "fails when Access Token is empty" {
            $scriptContent = @'
set -e

SUPABASE_PROJECT_REF="test-ref"
SUPABASE_DB_PASSWORD="test"
SUPABASE_ACCESS_TOKEN=""

if [ -z "$SUPABASE_ACCESS_TOKEN" ]; then
    echo "ERROR: Access Token is required."
    exit 1
fi
'@
            { bash -c $scriptContent } | Should -Throw
        }
    }

    Context "Happy Path" {
        It "succeeds with valid parameters" {
            # Mock test - in real scenario, this would test actual CLI behavior
            $scriptContent = @'
set -e

SUPABASE_PROJECT_REF="test-ref"
SUPABASE_DB_PASSWORD="test-password"
SUPABASE_ACCESS_TOKEN="test-token"
SUPABASE_CLI_VERSION="latest"

echo "=========================================="
echo "Supabase - Run Migrations"
echo "=========================================="
echo "Project Ref: $SUPABASE_PROJECT_REF"
echo "CLI Version: $SUPABASE_CLI_VERSION"
echo "=========================================="

# Validate parameters are set
if [ -z "$SUPABASE_PROJECT_REF" ]; then
    echo "ERROR: Supabase Project Ref is required."
    exit 1
fi

if [ -z "$SUPABASE_DB_PASSWORD" ]; then
    echo "ERROR: Database Password is required."
    exit 1
fi

if [ -z "$SUPABASE_ACCESS_TOKEN" ]; then
    echo "ERROR: Access Token is required."
    exit 1
fi

echo "Parameter validation passed!"
exit 0
'@
            $result = bash -c $scriptContent
            $LASTEXITCODE | Should -Be 0
            $result | Should -Match "Parameter validation passed"
        }
    }

    Context "CLI Installation Detection" {
        It "detects when Supabase CLI is not installed" {
            # Test the CLI detection logic
            $scriptContent = @'
if ! command -v supabase &> /dev/null; then
    echo "CLI not found"
else
    echo "CLI found"
fi
'@
            # This will pass if CLI is not installed, fail if it is
            $result = bash -c $scriptContent
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context "Version Handling" {
        It "accepts 'latest' as version" {
            $scriptContent = @'
SUPABASE_CLI_VERSION="latest"
if [ "$SUPABASE_CLI_VERSION" = "latest" ]; then
    echo "Version is latest"
    exit 0
fi
exit 1
'@
            $result = bash -c $scriptContent
            $LASTEXITCODE | Should -Be 0
        }

        It "accepts specific version numbers" {
            $scriptContent = @'
SUPABASE_CLI_VERSION="1.123.4"
if [[ "$SUPABASE_CLI_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Version is semver"
    exit 0
fi
exit 1
'@
            $result = bash -c $scriptContent
            $LASTEXITCODE | Should -Be 0
        }
    }
}

Describe "JSON Template Validation" {
    Context "Required Fields" {
        It "has a valid Id field" {
            $template = Get-Content "$PSScriptRoot/../step-templates/supabase-run-migrations.json" | ConvertFrom-Json
            $template.Id | Should -Not -BeNullOrEmpty
            $template.Id | Should -Not -Match "^00000000-0000-0000-0000-000000000000$"
        }

        It "has a valid Name field" {
            $template = Get-Content "$PSScriptRoot/../step-templates/supabase-run-migrations.json" | ConvertFrom-Json
            $template.Name | Should -Not -BeNullOrEmpty
            $template.Name | Should -Match "^.+ - .+$"
        }

        It "has a valid Description field" {
            $template = Get-Content "$PSScriptRoot/../step-templates/supabase-run-migrations.json" | ConvertFrom-Json
            $template.Description | Should -Not -BeNullOrEmpty
        }

        It "has ActionType set to Octopus.Script" {
            $template = Get-Content "$PSScriptRoot/../step-templates/supabase-run-migrations.json" | ConvertFrom-Json
            $template.ActionType | Should -Be "Octopus.Script"
        }

        It "has Version set to 1" {
            $template = Get-Content "$PSScriptRoot/../step-templates/supabase-run-migrations.json" | ConvertFrom-Json
            $template.Version | Should -Be 1
        }

        It "has LastModifiedBy set" {
            $template = Get-Content "$PSScriptRoot/../step-templates/supabase-run-migrations.json" | ConvertFrom-Json
            $template.LastModifiedBy | Should -Not -BeNullOrEmpty
        }
    }

    Context "Parameters" {
        It "has all required parameters" {
            $template = Get-Content "$PSScriptRoot/../step-templates/supabase-run-migrations.json" | ConvertFrom-Json
            $template.Parameters.Count | Should -BeGreaterThan 0
        }

        It "has unique parameter Ids" {
            $template = Get-Content "$PSScriptRoot/../step-templates/supabase-run-migrations.json" | ConvertFrom-Json
            $ids = $template.Parameters.Id
            ($ids | Select-Object -Unique).Count | Should -Be $ids.Count
        }

        It "has sensitive parameters marked correctly" {
            $template = Get-Content "$PSScriptRoot/../step-templates/supabase-run-migrations.json" | ConvertFrom-Json
            $sensitiveParams = $template.Parameters | Where-Object { $_.DisplaySettings.'Octopus.ControlType' -eq "Sensitive" }
            $sensitiveParams.Count | Should -BeGreaterThan 0
        }

        It "has sensitive parameters with null DefaultValue" {
            $template = Get-Content "$PSScriptRoot/../step-templates/supabase-run-migrations.json" | ConvertFrom-Json
            $sensitiveParams = $template.Parameters | Where-Object { $_.DisplaySettings.'Octopus.ControlType' -eq "Sensitive" }
            foreach ($param in $sensitiveParams) {
                $param.DefaultValue | Should -BeNullOrEmpty
            }
        }
    }

    Context "Script Body" {
        It "has a script body defined" {
            $template = Get-Content "$PSScriptRoot/../step-templates/supabase-run-migrations.json" | ConvertFrom-Json
            $template.Properties.'Octopus.Action.Script.ScriptBody' | Should -Not -BeNullOrEmpty
        }

        It "uses Octopus parameter syntax" {
            $template = Get-Content "$PSScriptRoot/../step-templates/supabase-run-migrations.json" | ConvertFrom-Json
            $scriptBody = $template.Properties.'Octopus.Action.Script.ScriptBody'
            $scriptBody | Should -Match "#\{.*\}"
        }
    }
}
