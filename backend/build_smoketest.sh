#!/bin/bash
# Local Docker build smoke-test for sbku-backend
# Run from: cd backend && bash build_smoketest.sh

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
    "docker/nginx.conf"
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
    echo "WARN: .env not found. Create one before deploying:"
    echo "      cp .env.example .env   then fill in APP_KEY, DB_*, etc."
    echo "      NOTE: In ECS, secrets come from task definition / SSM."
fi

# 4. Quick Dockerfile syntax check
echo ""
echo "--- Checking Dockerfile for common issues ---"
if grep -n "npg_" Dockerfile 2>/dev/null; then
    echo "ERROR: Hardcoded database credentials found in Dockerfile!"
    exit 1
fi
if grep -n "password" Dockerfile 2>/dev/null | grep -iv "^[^:]*:[^:]*#\|composer\|password_reset\|Password\|PASSWORD"; then
    echo "WARN: Possible hardcoded password in Dockerfile — verify."
fi

# 5. Verify start.sh exists and is executable
echo ""
echo "--- Checking start.sh ---"
if [ -f "start.sh" ]; then
    chmod +x start.sh 2>/dev/null || true
    echo "  OK: start.sh present"
    if grep -q "cleanup()" start.sh 2>/dev/null; then
        echo "  OK: start.sh has graceful shutdown trap"
    else
        echo "  WARN: start.sh missing graceful shutdown trap"
    fi
else
    echo "ERROR: start.sh not found — ENTRYPOINT will fail!"
    exit 1
fi

# 6. Check nginx config for HTTP/2 support
echo ""
echo "--- Checking nginx.conf ---"
if grep -q "reuseport" docker/nginx.conf 2>/dev/null; then
    echo "  OK: nginx.conf has modern socket options"
else
    echo "  WARN: nginx.conf missing reuseport directive"
fi

echo ""
echo "=== Preflight OK — ready to build ==="
echo "Run:  docker build -t sbku-backend ."
echo ""
echo "To deploy to ECS:"
echo "  1. Push image to ECR"
echo "  2. Update ecs-task-definition.json with your ACCOUNT_ID"
echo "  3. aws ecs update-service --cluster sbku-backend --service sbku-backend --force-new-deployment"
