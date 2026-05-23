# Backend Deployment Analysis & Issues

**Analysis Date:** May 24, 2026  
**Current Status:** Multiple critical issues detected - Ready for EC2 deployment with fixes

---

## 1. CONFIGURATION ISSUES

### Critical Issues

#### 1.1 Mismatched Database Configurations

**Severity:** 🔴 CRITICAL

- **Problem**: Two different `.env` files are pointing to different databases:
  - `.env` (Production): PostgreSQL (Neon) - `postgresql://neondb_owner:...@ep-fragrant-recipe-a7rnwwa3.ap-southeast-2.aws.neon.tech`
  - `.env.development` (Local Dev): MySQL - `127.0.0.1:3306`

- **Current Error** (laravel.log):

  ```
  SQLSTATE[HY000] [1049] Unknown database 'sbkuappdb'
  ```

  This error stems from the `.env.development` configuration trying to access local MySQL that doesn't exist.

- **Impact on EC2**: If `.env.development` is accidentally committed or used, the app will fail to connect.

**Fix Required:**

```bash
# Ensure only .env is used in production, NOT .env.development
# Add to .gitignore if not already there:
.env.development

# Production .env should use the external database
APP_ENV=production
APP_DEBUG=false
DB_CONNECTION=pgsql
DATABASE_URL="postgresql://neondb_owner:npg_PTQUFJLvd94h@ep-fragrant-recipe-a7rnwwa3.ap-southeast-2.aws.neon.tech/neondb?sslmode=require"
```

#### 1.2 Database Credentials Exposed

**Severity:** 🔴 CRITICAL

- **Problem**: Raw database credentials are visible in `.env` file:

  ```
  DB_USERNAME=neondb_owner
  DB_PASSWORD=npg_PTQUFJLvd94h
  ```

- **EC2 Impact**: Credentials are now visible in version control and logs.

**Fix Required:**

- Use EC2 Systems Manager Parameter Store or AWS Secrets Manager to store credentials
- Update `.gitignore` to ensure `.env` is never committed:
  ```
  .env
  .env.local
  .env.development
  .env.*.local
  ```

#### 1.3 Inconsistent APP_KEY Values

**Severity:** 🟡 HIGH

- `.env` has: `base64:qA+gNzOOJyERlAI2Qx1u7AK8j/pJ0npT5KMqaOl3sCE=`
- `.env.development` has: `base64:eOvGzttB2Sme3+YwJb7hse7ds1qCpwJ7HJ/KIdwHXKA=`

Different APP_KEYs will cause encryption/decryption failures in production.

**Fix Required:**
Generate a single production APP_KEY and use it consistently:

```bash
php artisan key:generate --force
```

---

## 2. FIREBASE CONNECTIVITY ISSUES

### Critical Issues

#### 2.1 Firebase Disabled but Code Still Uses It

**Severity:** 🔴 CRITICAL

- **Configuration**: `.env` shows `USE_FIRESTORE=false`
- **Problem**: Code still imports and attempts to use Firestore:
  - `app/Models/Student.php` has `SyncsToFirestore` trait
  - `app/Services/FirestoreService.php` has initialization logic
  - `app/Livewire/Users/UserIndex.php` calls `FirestoreService`
  - `app/Livewire/Subjects/SubjectIndex.php` calls `FirestoreService`

- **Runtime Risk**: If Firebase credentials aren't configured, these services will fail silently or throw errors when `FirestoreService::isActive()` checks happen.

**Current Implementation:**

```php
// FirestoreService.php
public static function isActive(): bool
{
    return env('USE_FIRESTORE', false) === 'true';  // Currently returns false
}

// But code still references it:
if (\App\Services\FirestoreService::isActive()) {
    $this->firestore->delete('users', (string)$this->deleteUserId);
}
```

#### 2.2 Missing Firebase Credentials File

**Severity:** 🟡 HIGH

- **Problem**: `.env` has commented out Firebase paths:

  ```php
  # FIREBASE_CREDENTIALS=storage/app/sbkuapp-vert25-bd306018b6de.json
  # FIREBASE_PROJECT_ID=sbkuapp-vert25F
  ```

- **Missing File**: `storage/app/sbkuapp-vert25-bd306018b6de.json` is not present in the repo

- **EC2 Impact**: If `USE_FIRESTORE=true` is set in production, the app will fail with missing credentials.

**Fix Required:**

```bash
# Either:
1. Keep USE_FIRESTORE=false and remove all Firestore code references
2. Or: Provide Firebase credentials file and configure:
   FIREBASE_CREDENTIALS=/var/www/html/storage/app/firebase-credentials.json
   GOOGLE_APPLICATION_CREDENTIALS=/var/www/html/storage/app/firebase-credentials.json
   USE_FIRESTORE=true
```

---

## 3. DATABASE MIGRATION STATUS

### Issues Found

#### 3.1 Large Number of Migrations (43+ files)

**Severity:** 🟡 MEDIUM

Migrations list:

```
2026_05_23_021804_add_indexes_to_support_list_pages.php (Latest)
2026_05_23_235800_add_room_id_to_syllabuses_table.php
2026_05_22_000001_add_performance_indexes.php
...and 40+ more
```

**EC2 Concern**: No indication of migration status on current database.

**Fix Required Before Deployment:**

```bash
# 1. Check current migration status
php artisan migrate:status

# 2. Run all pending migrations
php artisan migrate --force

# 3. Verify database matches schema
php artisan migrate:fresh --seed  # ONLY if starting fresh
```

#### 3.2 Database Driver Mismatch Risk

**Severity:** 🟡 MEDIUM

- Migrations were likely created for MySQL (`.env.development`)
- Production is PostgreSQL (Neon)
- Some migrations may have MySQL-specific syntax

**Recommendation:**
Review migrations for platform-specific code:

- Check for `AUTOINCREMENT` (use `SERIAL` in PostgreSQL)
- Check for `COLLATE utf8mb4_unicode_ci` clauses
- Check for backtick quotes (PostgreSQL uses double quotes)

---

## 4. API ENDPOINT ISSUES

### Configuration Issues

#### 4.1 API URL Points to Localhost/Tunnel

**Severity:** 🟡 MEDIUM

- `.env` has: `APP_URL=https://ministers-carter-presidential-objective.trycloudflare.com`
- This is a Cloudflare tunnel (temporary testing URL)

**EC2 Fix Required:**

```bash
APP_URL=https://your-ec2-domain.com  # Update to actual EC2 domain
APP_ENV=production
APP_DEBUG=false
```

#### 4.2 Health Check Endpoint Exists

**Severity:** ✅ GOOD

- API has a `/health` endpoint (line in `api.php`)
- Good for EC2 load balancer health checks

#### 4.3 Storage Endpoint Issue

**Severity:** 🟡 MEDIUM

- Public storage route has fallback to external avatar service:
  ```php
  return redirect('https://ui-avatars.com/api/?name=' . urlencode($fallbackLetter) . '&background=random&color=fff&size=128');
  ```
- Problem: If storage is ephemeral on EC2, all images will be lost on restart
- CORS headers are manually set (good for Flutter Web)

**EC2 Fix Required:**

- Use S3 for persistent storage instead of local storage
- Update `config/filesystems.php`:
  ```php
  'default' => env('FILESYSTEM_DISK', 's3'),
  's3' => [
      'driver' => 's3',
      'key' => env('AWS_ACCESS_KEY_ID'),
      'secret' => env('AWS_SECRET_ACCESS_KEY'),
      'region' => env('AWS_DEFAULT_REGION'),
      'bucket' => env('AWS_BUCKET'),
  ]
  ```

---

## 5. DOCKER-SPECIFIC ISSUES

### Critical Issues

#### 5.1 PORT Environment Variable Conflict

**Severity:** 🟡 MEDIUM

- Dockerfile sets:
  ```dockerfile
  ENV PORT=80
  EXPOSE 8080  # Conflicting!
  ```
- Port configuration is dynamic:
  ```bash
  RUN sed -i 's/80/${PORT}/g' /etc/apache2/sites-available/000-default.conf
  ```

**EC2 Fix Required:**

```dockerfile
ENV PORT=8080  # Match EXPOSE
# Or ensure PORT and EXPOSE match

# In start.sh, ensure this works:
sed -i "s/Listen 80/Listen ${PORT:-8080}/g" /etc/apache2/ports.conf
```

#### 5.2 Missing Runtime Database URL Handling

**Severity:** 🔴 CRITICAL

- `start.sh` has sophisticated PostgreSQL parsing for Neon
- But if `DATABASE_URL` env var doesn't match expected format, it fails silently

**Issues in start.sh:**

```bash
# This assumes DATABASE_URL has a specific format
WITHOUT_PROTO="${NEON_URL#*://}"
CREDS_AND_HOST="${WITHOUT_PROTO%%\?*}"
# If URL format is unexpected, parsing fails

# Variables become empty, and database connection fails
```

**EC2 Recommendation:**

- For EC2, use simpler environment variables instead of parsing URLs:
  ```bash
  export DB_CONNECTION=pgsql
  export DB_HOST=your-rds-endpoint.amazonaws.com
  export DB_PORT=5432
  export DB_DATABASE=sbkuappdb
  export DB_USERNAME=admin
  export DB_PASSWORD=your-password
  export DB_SSLMODE=require
  ```

#### 5.3 File Permissions on Storage

**Severity:** 🟡 MEDIUM

- Dockerfile copies files at build time
- `storage/` and `bootstrap/cache/` need write permissions at runtime
- Not explicitly handled in Dockerfile

**Fix Required:**

```dockerfile
# Add to Dockerfile after COPY . .
RUN chmod -R 755 storage bootstrap/cache && \
    chown -R www-data:www-data storage bootstrap/cache
```

#### 5.4 start.sh Robustness

**Severity:** 🟡 MEDIUM

- `start.sh` has complex shell parsing that could fail
- No error handling for missing environment variables
- Should validate all required vars before starting Apache

**Recommended Addition:**

```bash
#!/bin/bash
set -e  # Exit on any error

# Validate required variables
for var in DB_CONNECTION DB_HOST DB_DATABASE DB_USERNAME; do
    if [ -z "${!var}" ]; then
        echo "ERROR: Missing required environment variable: $var"
        exit 1
    fi
done

echo "Database configuration validated"
# ... rest of script
```

#### 5.5 Cache Directory Issues

**Severity:** 🟡 MEDIUM

- Dockerfile tries to cache views at build time:
  ```dockerfile
  RUN php artisan view:cache 2>/dev/null || true
  ```
- But this runs with development APP_KEY, not production key
- Cache becomes invalid when APP_KEY changes

**Fix Required:**

```dockerfile
# Don't cache views at build time
# Let start.sh handle it with correct APP_KEY:

# In start.sh:
php artisan view:cache --force
php artisan config:cache
```

---

## 6. SUMMARY TABLE: EC2 DEPLOYMENT CHECKLIST

| Issue                | Current                         | Required                         | Priority    |
| -------------------- | ------------------------------- | -------------------------------- | ----------- |
| Database Config      | PostgreSQL (good)               | Use RDS endpoint                 | 🔴 CRITICAL |
| Credentials Exposure | In .env                         | Use AWS Secrets Manager          | 🔴 CRITICAL |
| Firebase Setup       | Disabled but code references it | Clean up or configure            | 🔴 CRITICAL |
| APP_URL              | Tunnel URL                      | EC2 domain/IP                    | 🔴 CRITICAL |
| Storage              | Local ephemeral                 | S3 bucket                        | 🟡 HIGH     |
| Database Migrations  | Not verified                    | Run `migrate:status` & `migrate` | 🟡 HIGH     |
| PORT Configuration   | Mismatched 80/8080              | Align PORT and EXPOSE            | 🟡 HIGH     |
| start.sh Parsing     | Complex/fragile                 | Use simple env vars              | 🟡 MEDIUM   |
| File Permissions     | Not explicit                    | Add chown/chmod                  | 🟡 MEDIUM   |
| Docker Build         | Multi-stage (good)              | Validate at runtime              | ✅ GOOD     |

---

## 7. DEPLOYMENT STEPS FOR EC2

### Phase 1: Preparation (Before Deployment)

```bash
# 1. Generate new APP_KEY for production
php artisan key:generate --force

# 2. Verify .env.development is in .gitignore
echo ".env.development" >> backend/.gitignore

# 3. Check migration status locally
php artisan migrate:status

# 4. Run migrations locally to identify issues
php artisan migrate --force

# 5. Verify all tests pass
php artisan test
```

### Phase 2: EC2 Environment Variables

```bash
# Set these in EC2 (Systems Manager Parameter Store or RDS Secrets Manager)
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:GENERATED_KEY_HERE
APP_URL=https://your-ec2-domain.com
DB_CONNECTION=pgsql
DB_HOST=your-rds-endpoint.amazonaws.com
DB_PORT=5432
DB_DATABASE=sbkuappdb
DB_USERNAME=admin
DB_PASSWORD=YOUR_STRONG_PASSWORD
DB_SSLMODE=require
FILESYSTEM_DISK=s3
AWS_ACCESS_KEY_ID=your-ec2-instance-role-id
AWS_SECRET_ACCESS_KEY=your-ec2-instance-role-secret
AWS_DEFAULT_REGION=ap-southeast-2
AWS_BUCKET=your-app-bucket
USE_FIRESTORE=false  # Keep disabled unless Firebase is fully configured
```

### Phase 3: Docker Deployment

```bash
# Build image with production tags
docker build -t sbku-app:latest -t sbku-app:$(date +%Y%m%d) .

# Push to ECR (if using AWS ECR)
aws ecr get-login-password --region ap-southeast-2 | docker login --username AWS --password-stdin YOUR_ECR_REGISTRY
docker tag sbku-app:latest YOUR_ECR_REGISTRY/sbku-app:latest
docker push YOUR_ECR_REGISTRY/sbku-app:latest

# Run on EC2
docker run -d \
  --name sbku-app \
  --restart always \
  -p 8080:8080 \
  -e APP_ENV=production \
  -e APP_DEBUG=false \
  -e APP_KEY=$PRODUCTION_KEY \
  -e DB_HOST=$RDS_ENDPOINT \
  -e DB_PASSWORD=$DB_PASSWORD \
  sbku-app:latest
```

### Phase 4: Post-Deployment Verification

```bash
# 1. Check container logs
docker logs sbku-app

# 2. Test health endpoint
curl https://your-ec2-domain.com/api/health

# 3. Verify migrations ran
docker exec sbku-app php artisan migrate:status

# 4. Check Laravel logs
docker exec sbku-app tail -f storage/logs/laravel.log
```

---

## 8. RECOMMENDATIONS

### Immediate Actions (Before EC2 Deployment)

1. ✅ Fix DATABASE configuration mismatch
2. ✅ Remove or secure all credentials
3. ✅ Decide: Keep Firestore disabled or fully configure it
4. ✅ Update APP_URL to EC2 domain
5. ✅ Configure S3 for persistent storage
6. ✅ Update Dockerfile PORT settings
7. ✅ Add error handling to start.sh

### Architecture Improvements

1. Use AWS RDS PostgreSQL (managed database)
2. Use AWS S3 for file storage (persistent)
3. Use AWS Systems Manager Parameter Store for secrets
4. Use ALB (Application Load Balancer) for health checks
5. Enable CloudWatch monitoring and logs
6. Set up auto-scaling for multiple EC2 instances

### Security Hardening

1. ✅ Never commit `.env` files
2. ✅ Use IAM roles for EC2 instance credentials
3. ✅ Enable SSL/TLS certificate (AWS Certificate Manager)
4. ✅ Restrict database access to VPC security group
5. ✅ Enable CloudTrail for audit logging
6. ✅ Use strong database passwords (20+ characters)

---

## 9. RISK ASSESSMENT

| Component             | Risk Level  | Impact                       | Mitigation                           |
| --------------------- | ----------- | ---------------------------- | ------------------------------------ |
| Database Connectivity | 🔴 CRITICAL | App completely down          | Verify credentials before deployment |
| Ephemeral Storage     | 🔴 CRITICAL | User uploads lost on restart | Migrate to S3 immediately            |
| Firebase Integration  | 🟡 MEDIUM   | Feature failures if enabled  | Remove code or fully configure       |
| Configuration Errors  | 🟡 MEDIUM   | Runtime failures             | Validate all env vars at startup     |
| Docker Build Issues   | 🟡 MEDIUM   | Deployment fails             | Test build in staging first          |
| File Permissions      | 🟢 LOW      | Permission denied errors     | Add chown/chmod commands             |

---

## Contact & Support

For questions on implementing these fixes, review:

- [Laravel Config Documentation](https://laravel.com/docs/11.x/configuration)
- [AWS Secrets Manager Integration](https://docs.aws.amazon.com/secretsmanager/latest/userguide/secret-lambda-functions.html)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
