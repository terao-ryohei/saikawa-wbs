#!/bin/bash
set -e

echo "============================================"
echo "Dev Container Post-Create Setup"
echo "============================================"

echo ""
echo "Checking installed software versions..."
echo ""

echo "--- OS Version ---"
cat /etc/os-release | grep -E "^(NAME|VERSION)="

echo ""
echo "--- Ruby Version ---"
ruby --version

echo ""
echo "--- Bundler Version ---"
bundler --version

echo ""
echo "--- Git Version ---"
git --version

echo ""
echo "--- PostgreSQL Client Version ---"
psql --version

echo ""
echo "--- Redis CLI Version ---"
redis-cli --version

echo ""
echo "--- Node.js Version ---"
node --version

echo ""
echo "--- Yarn Version ---"
yarn --version

echo ""
echo "============================================"
echo "Checking service connections..."
echo "============================================"

echo ""
echo "--- PostgreSQL Server Version ---"
PAGER=cat PGPASSWORD=postgres psql -h db -U postgres -c "SELECT version();" 2>/dev/null || echo "PostgreSQL not yet available"

echo ""
echo "--- Redis Server Version ---"
redis-cli -h redis INFO server 2>/dev/null | grep redis_version || echo "Redis not yet available"

echo ""
echo "============================================"
echo "Setting up GDK..."
echo "============================================"

# GDK clone (initial setup only)
if [ ! -d "/workspace/gdk" ]; then
  echo "Cloning GDK repository..."
  git clone https://gitlab.com/gitlab-org/gitlab-development-kit.git /workspace/gdk
else
  echo "GDK directory already exists (skipping clone)"
fi

# Add GDK bin to PATH (gdk command is at /workspace/gdk/bin/gdk)
export PATH="/workspace/gdk/bin:$PATH"

# Navigate to GDK directory
cd /workspace/gdk

# Apply gdk.yml.template (initial setup only)
if [ ! -f "/workspace/gdk/gdk.yml" ]; then
  echo "Applying gdk.yml.template..."
  cp /workspace/.devcontainer/gdk.yml.template /workspace/gdk/gdk.yml
  echo "gdk.yml created from template"
else
  echo "gdk.yml already exists (skipping template)"
fi

# Bundle install for GDK itself (resolves zeitwerk dependency before gdk install)
echo ""
echo "Running bundle install for GDK..."
bundle install
echo "GDK bundle install completed"

# GDK install (initial setup)
echo ""
echo "============================================"
echo "Running GDK install..."
echo "WARNING: Initial GDK install takes 15-30 minutes"
echo "(GitLab source clone + bundle install + yarn install)"
echo "============================================"
gdk install
echo "GDK install completed"

echo ""
echo "============================================"
echo "Configuring GDK to use Vite instead of Webpack..."
echo "============================================"

# Stop webpack and rails-web if they are running
echo "Stopping webpack and rails-web..."
gdk stop webpack rails-web 2>/dev/null || echo "Services not running (this is expected)"

# Configure GDK to use Vite instead of Webpack
echo "Disabling webpack..."
gdk config set webpack.enabled false

echo "Enabling vite..."
gdk config set vite.enabled true

# Reconfigure GDK with new settings
echo "Reconfiguring GDK..."
gdk reconfigure

# Restart vite and rails-web
echo "Restarting vite and rails-web..."
gdk restart vite rails-web 2>/dev/null || echo "Services will be started when GDK is started"

echo ""
echo "============================================"
echo "Dev Container setup complete!"
echo "============================================"
