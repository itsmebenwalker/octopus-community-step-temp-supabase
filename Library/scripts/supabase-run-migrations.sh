# Supabase - Run Migrations
# This script runs database migrations against a Supabase project

set -e

# Parameter validation
if [ -z "$SUPABASE_PROJECT_REF" ]; then
    echo "ERROR: Supabase Project Ref is required. Please provide a value for 'Project Ref'."
    exit 1
fi

if [ -z "$SUPABASE_DB_PASSWORD" ]; then
    echo "ERROR: Database Password is required. Please provide a value for 'Database Password'."
    exit 1
fi

if [ -z "$SUPABASE_ACCESS_TOKEN" ]; then
    echo "ERROR: Access Token is required. Please provide a value for 'Access Token'."
    exit 1
fi

echo "=========================================="
echo "Supabase - Run Migrations"
echo "=========================================="
echo "Project Ref: $SUPABASE_PROJECT_REF"
echo "CLI Version: $SUPABASE_CLI_VERSION"
echo "=========================================="

# Check if Supabase CLI is installed
install_supabase_cli() {
    local version="$1"
    
    echo "Installing Supabase CLI..."
    
    # Detect OS
    if [ "$(uname)" = "Darwin" ]; then
        # macOS
        if [ "$version" = "latest" ]; then
            brew install supabase/tap/supabase
        else
            brew install supabase/tap/supabase@"$version"
        fi
    elif [ "$(uname)" = "Linux" ]; then
        # Linux - install via npm
        if [ "$version" = "latest" ]; then
            npm install -g supabase
        else
            npm install -g supabase@"$version"
        fi
    else
        echo "ERROR: Unsupported operating system: $(uname)"
        exit 1
    fi
}

# Check for CLI
if ! command -v supabase &> /dev/null; then
    echo "Supabase CLI not found. Installing..."
    install_supabase_cli "$SUPABASE_CLI_VERSION"
else
    echo "Supabase CLI found: $(which supabase)"
    CURRENT_VERSION=$(supabase --version 2>/dev/null | awk '{print $2}')
    echo "Current version: $CURRENT_VERSION"
    
    # Optionally update if not latest
    if [ "$SUPABASE_CLI_VERSION" != "latest" ] && [ "$SUPABASE_CLI_VERSION" != "$CURRENT_VERSION" ]; then
        echo "Updating CLI to version $SUPABASE_CLI_VERSION..."
        install_supabase_cli "$SUPABASE_CLI_VERSION"
    fi
fi

# Verify CLI installation
if ! command -v supabase &> /dev/null; then
    echo "ERROR: Failed to install Supabase CLI"
    exit 1
fi

echo ""
echo "=========================================="
echo "Authenticating with Supabase..."
echo "=========================================="

# Set access token for CLI
echo "$SUPABASE_ACCESS_TOKEN" | supabase login --token stdin

# Run migrations
echo ""
echo "=========================================="
echo "Running database migrations..."
echo "=========================================="

# Push migrations to the remote database
# The CLI will use the access token for authentication
export PGPASSWORD="$SUPABASE_DB_PASSWORD"

supabase db push \
    --project-ref "$SUPABASE_PROJECT_REF" \
    --db-password "$SUPABASE_DB_PASSWORD" \
    --linked

echo ""
echo "=========================================="
echo "Migration completed successfully!"
echo "=========================================="
