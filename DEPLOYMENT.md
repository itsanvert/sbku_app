# EC2 Deployment Guide - SBKU Backend

This guide covers deploying the SBKU Laravel backend to AWS EC2 using Docker.

**Last Updated:** May 24, 2026  
**Current Deployment:** https://32.236.105.9/

---

## 📋 Prerequisites

- AWS EC2 instance (Amazon Linux 2, Ubuntu 20.04+, or similar)
- Docker & Docker Compose installed
- Git access to repository
- Database credentials (PostgreSQL endpoint)
- (Optional) AWS S3 bucket for persistent file storage
- (Optional) Firebase credentials if enabling Firestore

---

## 🚀 Step 1: Initial EC2 Setup

### 1.1 SSH into your EC2 instance

```bash
ssh -i your-key.pem ec2-user@<your-ec2-public-ip>
# or for Ubuntu:
ssh -i your-key.pem ubuntu@<your-ec2-public-ip>
```

### 1.2 Install Docker & Docker Compose

**For Amazon Linux 2:**
```bash
sudo yum update -y
sudo yum install -y docker git
sudo usermod -aG docker ec2-user
sudo systemctl start docker
sudo systemctl enable docker

# Install Docker Compose
sudo curl -L https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

**For Ubuntu:**
```bash
sudo apt-get update
sudo apt-get install -y docker.io docker-compose git
sudo usermod -aG docker ubuntu
sudo systemctl start docker
sudo systemctl enable docker
```

### 1.3 Create deployment directory

```bash
mkdir -p /opt/sbku-app
cd /opt/sbku-app
```

---

## 📦 Step 2: Clone & Build

### 2.1 Clone repository

```bash
git clone <your-repo-url> .
cd backend
```

### 2.2 Create production `.env` file

```bash
cat > .env << 'EOF'
APP_NAME=SBKU
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:qA+gNzOOJyERlAI2Qx1u7AK8j/pJ0npT5KMqaOl3sCE=
APP_URL=https://32.236.105.9  # Replace with your EC2 IP/domain

# Database (PostgreSQL via Neon)
DB_CONNECTION=pgsql
DB_HOST=ep-fragrant-recipe-a7rnwwa3.ap-southeast-2.aws.neon.tech
DB_PORT=5432
DB_DATABASE=neondb
DB_USERNAME=neondb_owner
DB_PASSWORD=npg_PTQUFJLvd94h  # CHANGE THIS - use AWS Secrets Manager in production!
DB_SSLMODE=require

# Firebase (disabled by default - set to 'true' if credentials available)
USE_FIRESTORE=false

# Session & Cache
SESSION_DRIVER=file
CACHE_STORE=file

# File Storage (use S3 for persistence in production!)
FILESYSTEM_DISK=public

# Other configs
AUTH_GUARD=sanctum
LOG_LEVEL=debug
EOF
```

### 2.3 Build Docker image

```bash
docker build -t sbku-backend:latest .
```

This creates an optimized multi-stage build with:
- PHP 8.4 with Apache
- PostgreSQL support
- Optimized caching layers

---

## 🐳 Step 3: Run Container

### 3.1 Basic deployment (port 80)

```bash
docker run -d \
  --name sbku-backend \
  --restart always \
  -p 80:80 \
  -e APP_ENV=production \
  -e DB_HOST=ep-fragrant-recipe-a7rnwwa3.ap-southeast-2.aws.neon.tech \
  -e DB_PORT=5432 \
  -e DB_DATABASE=neondb \
  -e DB_USERNAME=neondb_owner \
  -e DB_PASSWORD=your-db-password \
  -e DB_SSLMODE=require \
  sbku-backend:latest
```

### 3.2 Verify container is running

```bash
# Check container status
docker ps | grep sbku-backend

# View logs
docker logs -f sbku-backend

# Test health endpoint
curl http://localhost/health
```

---

## 🔐 Step 4: Database Setup

### 4.1 Run migrations

```bash
docker exec sbku-backend php artisan migrate --force
```

### 4.2 Check migration status

```bash
docker exec sbku-backend php artisan migrate:status
```

### 4.3 Seed database (if needed)

```bash
docker exec sbku-backend php artisan db:seed --class=DatabaseSeeder
```

---

## 📱 Step 5: Update Mobile App

Update the Flutter app's API configuration:

**frontend/lib/config/api_config.dart** or **frontend/.env**:

```env
API_URL=https://32.236.105.9
API_TIMEOUT=30
```

Then rebuild and deploy the Flutter app.

---

## 🔗 Step 6: Configure Domain (Optional but Recommended)

### 6.1 Point domain to EC2

In your DNS provider (Route 53, Namecheap, etc.):
```
A record: your-domain.com → your-ec2-public-ip
```

### 6.2 Set up HTTPS with Let's Encrypt

Install Certbot in a separate container or on the host:

```bash
sudo yum install -y certbot certbot-apache
# or for Ubuntu:
sudo apt-get install -y certbot python3-certbot-apache

# Generate certificate
sudo certbot certonly --standalone -d your-domain.com
```

Then modify your container to mount SSL certificates:

```bash
docker run -d \
  --name sbku-backend \
  --restart always \
  -p 80:80 \
  -p 443:443 \
  -v /etc/letsencrypt:/etc/letsencrypt:ro \
  ...
```

---

## 💾 Step 7: Persistent File Storage (Important for Production)

### Problem: Ephemeral Storage
Files uploaded to `/var/www/html/storage/app/public` are lost when the container restarts.

### Solution 1: AWS S3 (Recommended)

#### 7.1 Create S3 bucket

```bash
aws s3api create-bucket \
  --bucket sbku-app-uploads-$(date +%s) \
  --region ap-southeast-2 \
  --create-bucket-configuration LocationConstraint=ap-southeast-2
```

#### 7.2 Update `.env` to use S3

```bash
FILESYSTEM_DISK=s3
AWS_ACCESS_KEY_ID=your-aws-access-key
AWS_SECRET_ACCESS_KEY=your-aws-secret-key
AWS_DEFAULT_REGION=ap-southeast-2
AWS_BUCKET=your-bucket-name
```

#### 7.3 Restart container with S3 config

```bash
docker restart sbku-backend
```

### Solution 2: EBS Volume (Alternative)

Mount an EBS volume to persist storage:

```bash
# Create and attach EBS volume via AWS Console, then mount:
sudo mount /dev/xvdf /mnt/storage
docker run -d \
  -v /mnt/storage:/var/www/html/storage/app/public \
  ...
```

---

## 📊 Step 8: Monitoring & Logs

### View container logs

```bash
docker logs sbku-backend
docker logs -f sbku-backend  # Follow in real-time
```

### Check application logs inside container

```bash
docker exec sbku-backend tail -f storage/logs/laravel.log
```

### Monitor container resource usage

```bash
docker stats sbku-backend
```

---

## 🔧 Troubleshooting

### Issue: Container won't start

```bash
# Check logs
docker logs sbku-backend

# Rebuild image if dependencies changed
docker build --no-cache -t sbku-backend:latest .

# Remove old container and restart
docker rm -f sbku-backend
docker run -d ... sbku-backend:latest
```

### Issue: Database connection fails

```bash
# Verify environment variables
docker exec sbku-backend printenv | grep DB_

# Test database connectivity
docker exec sbku-backend php artisan tinker
# In tinker: DB::connection()->getPdo();
```

### Issue: Files disappear after restart

Solution: Migrate to S3 (see Step 7, Solution 1)

### Issue: API returns 500 errors

```bash
# Check application logs
docker exec sbku-backend tail -100 storage/logs/laravel.log

# Check if migrations are applied
docker exec sbku-backend php artisan migrate:status
```

---

## 🛑 Maintenance Commands

### Update backend code

```bash
cd /opt/sbku-app/backend
git pull origin main
docker build -t sbku-backend:latest .
docker-compose up -d  # or docker restart sbku-backend
```

### Clear cache

```bash
docker exec sbku-backend php artisan cache:clear
docker exec sbku-backend php artisan route:clear
docker exec sbku-backend php artisan view:clear
```

### Database backup (PostgreSQL)

```bash
docker exec sbku-backend pg_dump -h $DB_HOST -U $DB_USERNAME $DB_DATABASE > backup-$(date +%Y%m%d).sql
```

---

## 🚨 Security Checklist

- [ ] Never commit `.env` with real credentials
- [ ] Use AWS Secrets Manager for sensitive data (future enhancement)
- [ ] Set `APP_DEBUG=false` in production
- [ ] Use HTTPS with valid SSL certificate
- [ ] Regularly update Docker images and dependencies
- [ ] Restrict security group inbound rules to only needed ports (80, 443)
- [ ] Enable EC2 instance CloudWatch monitoring
- [ ] Set up log rotation for application logs
- [ ] Backup database regularly

---

## 📚 Environment Variables Reference

| Variable | Example | Required | Notes |
|----------|---------|----------|-------|
| `APP_ENV` | `production` | ✅ | Must be `production` |
| `APP_DEBUG` | `false` | ✅ | Never `true` in production |
| `APP_KEY` | `base64:...` | ✅ | Generate with `php artisan key:generate` |
| `APP_URL` | `https://32.236.105.9` | ✅ | Must match your EC2 IP/domain |
| `DB_HOST` | `ep-fragrant-recipe...` | ✅ | PostgreSQL endpoint |
| `DB_PASSWORD` | `your-password` | ✅ | Use AWS Secrets Manager! |
| `DB_SSLMODE` | `require` | ✅ | Required for Neon |
| `FILESYSTEM_DISK` | `s3` or `public` | ❌ | Use `s3` for production |
| `USE_FIRESTORE` | `false` | ❌ | Set to `true` if using Firebase |
| `LOG_LEVEL` | `debug` | ❌ | Use `error` in production |

---

## 🔗 Useful Links

- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Laravel Deployment](https://laravel.com/docs/deployment)
- [PostgreSQL on AWS Neon](https://neon.tech/)
- [AWS S3 File Storage](https://aws.amazon.com/s3/)
- [Let's Encrypt SSL Certificates](https://letsencrypt.org/)
sudo certbot --nginx -d your-domain.com
```
