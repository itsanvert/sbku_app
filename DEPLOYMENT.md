# Deployment Guide for EC2

This project is deployed on AWS EC2 using Docker (Apache + PHP 8.4).

## Prerequisites
1. An AWS EC2 instance running Amazon Linux 2 / Ubuntu.
2. Docker and Docker Compose installed on the instance.
3. Your code pushed to a GitHub repository.

## Step 1: Prepare Firebase Credentials
1. In your Firebase Console, go to **Project Settings > Service Accounts**.
2. Click **Generate New Private Key** and download the JSON file.
3. Upload the file to your EC2 instance (e.g., to `/home/ec2-user/firebase-credentials.json`).

## Step 2: Deploy to EC2

1. SSH into your EC2 instance:
   ```bash
   ssh -i your-key.pem ec2-user@<your-ec2-public-dns>
   ```

2. Clone the repository:
   ```bash
   git clone <your-repo-url> /home/ec2/app
   cd /home/ec2/app/backend
   ```

3. Build and run with Docker:
   ```bash
   docker build -t sbkuapp .
   docker run -d \
     -p 80:8080 \
     -e APP_ENV=production \
     -e APP_KEY=base64:your-generated-key \
     -e DB_CONNECTION=sqlite \
     -e USE_FIRESTORE=true \
     -e FIREBASE_PROJECT_ID=sbkuapp-vert25 \
     -v /home/ec2/firebase-credentials.json:/etc/secrets/firebase-credentials.json \
     sbkuapp
   ```

## Step 3: Initial Data Migration (One-time)
Run the Firestore data migration:
```bash
docker exec <container-id> php artisan firestore:migrate
```

## Step 4: Update Mobile App
1. Update `API_URL` in `frontend/.env` to your EC2 public DNS:
   ```env
   API_URL=http://ec2-32-236-105-9.ap-southeast-2.compute.amazonaws.com
   ```
2. Rebuild your Flutter app.

## Environment Variables
Key environment variables for production:
| Variable | Value | Description |
|---|---|---|
| `APP_ENV` | `production` | Laravel environment |
| `APP_DEBUG` | `false` | Disable debug mode |
| `USE_FIRESTORE` | `true` | Enable Firestore as primary data source |
| `DB_CONNECTION` | `sqlite` | Fallback database |
| `SESSION_DRIVER` | `file` | File-based sessions |
| `CACHE_STORE` | `file` | File-based cache |
| `FIREBASE_PROJECT_ID` | `sbkuapp-vert25` | Firebase project |
| `GOOGLE_CLOUD_USE_REST` | `true` | Use REST for Firestore |

## Nginx Setup (Recommended)
For production, add nginx as a reverse proxy in front of Apache for better static file serving and HTTP/2 support:
```nginx
server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name your-domain.com;

    root /var/www/html/public;

    location /build/ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## SSL with Let's Encrypt
```bash
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```
