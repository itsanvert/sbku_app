# EC2 Deployment — sbku-backend

## Instance
- **ID**: i-06e2a06e3e5c4b50e
- **Public IP**: 32.236.105.9
- **Region**: ap-southeast-2
- **Type**: t3.micro
- **AMI**: Amazon Linux 2023 (al2023)
- **Key pair**: sbkuapp_backend_kp (local: `backend/sbkuapp_backend_kp.pem`)
- **SSH**: `ssh -i backend/sbkuapp_backend_kp.pem ec2-user@32.236.105.9`

---

## Pre-flight: Security Group

**Before SSH'ing in, confirm inbound rules allow:**

| Type        | Protocol | Port | Source        |
|-------------|----------|------|---------------|
| SSH         | TCP      | 22   | your-IP/32    |
| HTTP        | TCP      | 80   | 0.0.0.0/0     |
| HTTPS (opt) | TCP      | 443  | 0.0.0.0/0     |
| Custom app  | TCP      | 8000+| 0.0.0.0/0     |

If HTTP (80) is not open: ERR_CONNECTION_REFUSED = missing SG rule.

---

## Step 1 — SSH Into EC2

```bash
ssh -i /c/Users/Vert/Desktop/sbku_app/backend/sbkuapp_backend_kp.pem ec2-user@32.236.105.9
chmod 400 /c/Users/Vert/Desktop/sbku_app/backend/sbkuapp_backend_kp.pem   # Windows Git Bash
```

---

## Step 2 — Install Docker on Amazon Linux 2023

```bash
sudo yum update -y
sudo yum install -y docker
sudo systemctl enable --now docker
sudo usermod -aG docker ec2-user   # logout + re-login to take effect
# Note: if you're in SSH, just run docker commands with sudo for now
```

### Verify Docker is running:
```bash
sudo docker run hello-world
```

---

## Step 3 — Install Docker Compose (V2 plugin)

Amazon Linux 2023 ships with `docker compose` (V2) as a plugin via dnf:

```bash
sudo dnf install -y docker-compose-plugin
docker compose version   # should show v2.x.x
```

---

## Step 4 — Configure App Secrets

Create `backend/.env` on the EC2 instance at `/opt/sbku-backend/.env` (mount via Docker Compose):
OR — pass env vars inline. At minimum you need:

| Variable | Description |
|----------|-------------|
| APP_KEY | `php artisan key:generate --show` (generated locally) |
| APP_URL | `http://32.236.105.9` or your domain |
| DB_HOST / DB_PORT / DB_DATABASE / DB_USERNAME / DB_PASSWORD | your database (neon/rds/sqlite) |
| FIREBASE_CREDENTIALS_JSON | inline or mount `/etc/secrets/firebase-credentials.json` |
| GOOGLE_CLOUD_USE_REST | `true` (skip gRPC; already set in Dockerfile) |
| SESSION_DRIVER | `file` or `redis` |
| CACHE_DRIVER | `file` or `redis` |

---

## Step 5 — Build & Run

From the `backend/` directory on **EC2** (clone or scp the app):

```bash
cd /opt/sbku-backend

# Build (takes 10-20 min first time, then ~2 min on cache hits)
sudo docker build -t sbku-backend .

# Run
sudo docker run -d \
  --name sbku-backend \
  --restart always \
  -p 80:80 \
  -e APP_URL=http://32.236.105.9 \
  -e APP_KEY=<your-key> \
  -e DB_CONNECTION=pgsql \
  -e DB_HOST=<host> \
  -e DB_PORT=5432 \
  -e DB_DATABASE=<db> \
  -e DB_USERNAME=<user> \
  -e DB_PASSWORD=<pass> \
  -e GOOGLE_CLOUD_USE_REST=true \
  sbku-backend
```

**Verify it's running:**
```bash
sudo docker ps                      # container must be "Up"
sudo docker logs -f sbku-backend     # watch for errors during startup
sudo docker inspect --format='{{.State.Health.Status}}' sbku-backend  # should say "healthy"
curl -I http://localhost             # must return 200 from inside the instance
```

---

## Step 6 — AWS Inbound Check

From **your browser** (not SSH), visit:

```
http://32.236.105.9
```

- **200** → Live ✅
- **ERR_CONNECTION_REFUSED** → AWS Security Group inbound 80 is missing or not applied to this instance.
- **502 Bad Gateway** → Apache is up but PHP/Laravel failed. Check logs:
  ```bash
  sudo docker logs -f sbku-backend
  ```
- **Loading spinner forever** → Check Healthcheck:
  ```bash
  sudo docker inspect --format='{{.State.Health.Status}}' sbku-backend
  sudo docker inspect --format='{{.Config.Healthcheck}}' sbku-backend
  ```

---

## Quick Debug Checklist

```bash
# 1. Container lifecycle
sudo docker ps -a | grep sbku-backend
# "Exited" = crashed; "Up" = running fine

# 2. Exit code if crashed
sudo docker inspect --format='{{.State.ExitCode}}' sbku-backend

# 3. Last 100 log lines
sudo docker logs --tail 100 sbku-backend

# 4. Port binding
sudo docker port sbku-backend

# 5. Healthcheck status
sudo docker inspect --format='{{.State.Health.Status}}' sbku-backend

# 6. Security Group (from AWS Console)
#   EC2 Console → sbku-backend → Security → Inbound rules
#   Must have: Type=HTTP, Port=80, Source=0.0.0.0/0
```
