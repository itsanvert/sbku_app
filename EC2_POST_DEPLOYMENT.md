# EC2 Backend Deployment - Post-Deployment Verification

**Purpose:** Verify that all components are working correctly after deployment to EC2.

**Date:** May 24, 2026

---

## ✅ Step 1: Verify Docker Container

```bash
# Check container is running
docker ps | grep sbku-backend

# Check container logs for errors
docker logs sbku-backend

# Verify no restart loops
docker stats sbku-backend  # Should show stable memory/CPU
```

**Expected Output:**
```
CONTAINER ID   IMAGE              STATUS         PORTS
abc123         sbku-backend:latest Up 2 minutes   0.0.0.0:80->80/tcp
```

---

## ✅ Step 2: Test API Endpoints

### 2.1 Health Check Endpoint

```bash
curl -v http://32.236.105.9/health
```

**Expected Response:**
```json
{
  "status": "ok",
  "timestamp": "2026-05-24T10:00:00+00:00"
}
```

**Status Code:** 200 OK

### 2.2 Test Login Endpoint

```bash
curl -X POST http://32.236.105.9/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}'
```

**Expected Response:**
```json
{
  "success": false,
  "message": "Invalid credentials",
  "errors": null
}
```

Or if user exists:
```json
{
  "success": true,
  "user": { ... },
  "token": "token_here"
}
```

**Status Code:** 200 OK (or 401 if credentials invalid)

### 2.3 Test Storage Endpoint

```bash
curl -v http://32.236.105.9/api/storage/avatar.jpg
```

**Expected Response:** 
- 200 OK with file, OR
- 302 redirect to placeholder avatar URL

**Status Code:** 200 or 302

---

## ✅ Step 3: Verify Database Connection

```bash
# Connect to container shell
docker exec -it sbku-backend bash

# Test database connection
php artisan tinker
# Inside tinker:
DB::connection()->getPdo();  # Should not throw error
# Type: quit
```

**Expected Output:**
```
PHP Shell > DB::connection()->getPdo();
=> PDOConnection { ... }
```

**If Error:**
```
Connection refused / SQLSTATE[28P01]
```

**Fix:** Verify `DB_HOST`, `DB_PASSWORD`, and `DB_SSLMODE` in `.env`

---

## ✅ Step 4: Verify Database Migrations

```bash
# Check migration status
docker exec sbku-backend php artisan migrate:status

# If migrations pending, run them
docker exec sbku-backend php artisan migrate --force
```

**Expected Output:**
```
Batch  Migration                                              Batch Run
------  -------------------------------------------------------  -----  ----------
1      2014_10_12_000000_create_users_table                   Yes    2026-05-24
2      2014_10_12_100000_create_password_resets_table         Yes    2026-05-24
...
(all rows showing "Yes" in "Batch Run" column)
```

**If showing "Pending":**
- Run: `docker exec sbku-backend php artisan migrate --force`
- Check logs: `docker logs sbku-backend`

---

## ✅ Step 5: Verify File Storage

```bash
# Create a test file
docker exec sbku-backend php artisan tinker
# Inside tinker:
Storage::disk('public')->put('test.txt', 'Hello World');
Storage::disk('public')->exists('test.txt');  # Should return true

# Access via API
curl http://32.236.105.9/storage/test.txt
```

**Expected Response:** "Hello World"

**If getting 404 or redirect to avatar:**
- Storage symlink might not be created
- Run: `docker exec sbku-backend php artisan storage:link`
- Restart container: `docker restart sbku-backend`

---

## ✅ Step 6: Verify Environment Configuration

```bash
# Check critical environment variables
docker exec sbku-backend printenv | grep -E '^(APP_|DB_|FILESYSTEM_)' | sort
```

**Expected Output:**
```
APP_DEBUG=false
APP_ENV=production
APP_NAME=SBKU
APP_URL=https://32.236.105.9
DB_CONNECTION=pgsql
DB_DATABASE=neondb
DB_HOST=ep-fragrant-recipe-a7rnwwa3.ap-southeast-2.aws.neon.tech
DB_PASSWORD=***
DB_PORT=5432
DB_SSLMODE=require
DB_USERNAME=neondb_owner
FILESYSTEM_DISK=public
```

**Issues to Check:**
- `APP_DEBUG` must be `false`
- `APP_ENV` must be `production`
- `DB_CONNECTION` must be `pgsql` (not `sqlite`)
- `DB_SSLMODE` must be `require` (for Neon)

---

## ✅ Step 7: Monitor Container Resources

```bash
# Watch resource usage
docker stats sbku-backend

# Check system resources on EC2
free -h  # Memory
df -h    # Disk space
ps aux | grep -i php  # Running processes
```

**Expected Metrics:**
- Memory: 200-500 MB
- CPU: < 5% idle
- Disk: Sufficient free space (> 1 GB recommended)

---

## ✅ Step 8: Verify Logs are Being Collected

```bash
# View application logs
docker exec sbku-backend tail -20 storage/logs/laravel.log

# Check for errors
docker exec sbku-backend grep -i error storage/logs/laravel.log | head -10
```

**Expected:** Recent logs with timestamps, no critical errors

---

## 🔧 Common Issues & Fixes

### Issue: Container won't start

**Symptom:**
```bash
docker logs sbku-backend
# Shows: Connection refused or SQLSTATE error
```

**Fix:**
```bash
# 1. Check .env file
docker exec sbku-backend cat .env | grep DB_

# 2. Verify database is accessible
docker exec sbku-backend php -r "
try {
    \$pdo = new PDO('pgsql:host=ep-fragrant-recipe-a7rnwwa3.ap-southeast-2.aws.neon.tech;port=5432;dbname=neondb;sslmode=require', 
                     'neondb_owner', 'password');
    echo 'Database connected!';
} catch (Exception \$e) {
    echo 'Error: ' . \$e->getMessage();
}
"

# 3. If still failing, rebuild image
docker build --no-cache -t sbku-backend:latest .
```

---

### Issue: API returns 500 errors

**Symptom:**
```bash
curl http://32.236.105.9/health
# Returns: 500 Internal Server Error
```

**Fix:**
```bash
# 1. Check application logs
docker exec sbku-backend tail -50 storage/logs/laravel.log

# 2. Check if APP_KEY is set
docker exec sbku-backend php artisan key:generate

# 3. Restart container
docker restart sbku-backend

# 4. If still failing, check syntax
docker exec sbku-backend php artisan tinker
# Inside: DB::raw('SELECT 1');
```

---

### Issue: Files disappear after container restart

**Symptom:**
```bash
# Upload a file, it works
curl http://32.236.105.9/api/storage/my-file.jpg  # Returns file

# Restart container
docker restart sbku-backend

# File is gone
curl http://32.236.105.9/api/storage/my-file.jpg  # 404 or avatar redirect
```

**Fix (Migrate to S3):**
```bash
# 1. Create S3 bucket
aws s3api create-bucket \
  --bucket sbku-uploads-production \
  --region ap-southeast-2

# 2. Update .env
docker exec sbku-backend bash -c 'cat >> .env << EOF
FILESYSTEM_DISK=s3
AWS_ACCESS_KEY_ID=your-key
AWS_SECRET_ACCESS_KEY=your-secret
AWS_BUCKET=sbku-uploads-production
EOF'

# 3. Restart with updated config
docker restart sbku-backend
```

---

### Issue: Database migrations failed

**Symptom:**
```bash
docker exec sbku-backend php artisan migrate:status
# Shows many "Pending" migrations
```

**Fix:**
```bash
# 1. Run migrations with force flag
docker exec sbku-backend php artisan migrate --force

# 2. If specific migration fails, check syntax
docker exec sbku-backend php artisan tinker
# Inside: include('database/migrations/2026_05_24_xxx.php');

# 3. Review error in logs
docker logs sbku-backend
docker exec sbku-backend tail storage/logs/laravel.log
```

---

### Issue: High memory or CPU usage

**Symptom:**
```bash
docker stats sbku-backend
# Shows: MEM 80%, CPU 60%+
```

**Fix:**
```bash
# 1. Check running processes
docker exec sbku-backend ps aux

# 2. Review error logs for loops
docker exec sbku-backend grep -i "loop\|recursion" storage/logs/laravel.log

# 3. Reduce PHP-FPM worker processes
# Edit Dockerfile and reduce:
# RUN sed -i 's/MaxRequestWorkers 256/MaxRequestWorkers 50/' ...

# 4. Rebuild and restart
docker build -t sbku-backend:latest .
docker restart sbku-backend
```

---

## 📊 Performance Baseline

After successful deployment, you should see:

```
✅ Container Status: Running
✅ Health Check: 200 OK
✅ Database Connection: Active
✅ Migrations: All applied
✅ Memory Usage: 200-500 MB
✅ CPU Usage: < 5% idle
✅ Disk Space: > 1 GB free
✅ API Response Time: < 500ms
✅ Logs: No critical errors
✅ File Storage: Working (files persist or stored in S3)
```

---

## 🚀 Ready for Production?

Once all checks pass, verify:

- [ ] Backend container is running and stable
- [ ] All API endpoints responding with correct status codes
- [ ] Database connected and migrations applied
- [ ] File storage configured (either S3 or ephemeral with understanding)
- [ ] Logs are clean (no critical errors)
- [ ] Performance is acceptable (response times < 500ms)
- [ ] Security configured (APP_DEBUG=false, HTTPS if using domain)
- [ ] Mobile app configured with correct API_URL

---

## 📞 Next Steps

1. **Update Mobile App**
   - Update `API_URL` to `https://32.236.105.9`
   - Rebuild Flutter app
   - Test authentication and API calls

2. **Set up Monitoring** (Optional but Recommended)
   ```bash
   # Enable CloudWatch monitoring
   aws ec2 monitor-instances --instance-ids i-xxxxx
   ```

3. **Configure Backups**
   - Set up automated database backups
   - Enable EBS snapshots

4. **Security Hardening**
   - Restrict security group to only needed ports
   - Enable EC2 instance termination protection
   - Set up log aggregation to CloudWatch

5. **Auto-scaling** (if needed)
   - Create AMI from this instance
   - Set up Auto Scaling Group for high availability

---

## 🔗 Reference Links

- [Docker Logs Documentation](https://docs.docker.com/engine/reference/commandline/logs/)
- [Laravel Artisan Commands](https://laravel.com/docs/artisan)
- [PostgreSQL Connection Troubleshooting](https://www.postgresql.org/docs/current/libpq-envars.html)
- [AWS EC2 CloudWatch Monitoring](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html)
