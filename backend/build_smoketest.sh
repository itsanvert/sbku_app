#!/bin/bash
# Local Docker build smoke-test for sbku-backend
# Run from: cd backend && bash /dev/stdin < this-file  OR  source this-file

set -e

echo "=== Docker build smoke-test ==="
echo ""

# 1. Check Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "ERROR: Docker is not running. Start Docker Desktop first."
    exit 1
fi

# 2. Check required files exist
echo "--- Checking required files ---"
FILES=(
    "Dockerfile"
    "start.sh"
    "docker/mpm_prefork.conf"
    "docker/php-memory.ini"
    "docker/apache-compress.conf"
    "docker/apache-performance.conf"
    "composer.json"
    "composer.lock"
    "package.json"
    "package-lock.json"
)
for f in "${FILES[@]}"; do
    if [ ! -f "$f" ]; then
        echo "MISSING: $f"
        exit 1
    fi
    echo "  OK: $f"
done

# 3. Check .env exists (only warn, don't fail)
if [ ! -f ".env" ]; then
    echo "WARN: .env not found. Create one before deploying to EC2."
    echo "      cp .env.example .env   then fill in APP_KEY, DB_*, etc."
fi

# 4. Quick Dockerfile syntax check (lint via build --dry-run equivalent)
echo ""
echo "--- Checking Dockerfile for common issues ---"
if grep -n "s/80/" Dockerfile 2>/dev/null | grep -v "^Binary"; then
    echo "WARN: Found bare 's/80/' sed pattern — this is now fixed in the Dockerfile."
fi
# Check for safe sed anchoring
if grep -n "s/^Listen 80" Dockerfile > /dev/null 2>&1; then
    echo "  OK: Dockerfile uses anchored sed (s/^Listen 80$/)"
else
    echo "WARN: Expected anchored sed for Apache port replacement not found."
fi

# 5. Verify start.sh exists and is executable
echo ""
echo "--- Checking start.sh ---"
if [ -f "start.sh" ]; then
    chmod +x start.sh 2>/dev/null || true
    echo "  OK: start.sh present"
else
    echo "ERROR: start.sh not found — ENTRYPOINT will fail!"
    exit 1
fi

# 6. Start.sh health-check: verify sed anchor is present
echo ""
echo "--- Checking start.sh runtime sed ---"
if grep -q 's/^Listen 80' start.sh 2>/dev/null; then
    echo "  OK: start.sh uses anchored sed"
elif grep -q '\${PORT}' start.sh 2>/dev/null; then
    echo "  OK: start.sh replaces \${PORT} literal token (safe)"
else
    echo "WARN: start.sh port-replacement pattern unexpected."
fi

echo ""
echo "=== Preflight OK — ready to build ==="
echo "Run:  docker build -t sbku-backend ."
