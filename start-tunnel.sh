#!/bin/bash

# ==============================================================================
# 🚀 SBKU APP - AUTOMATED CLOUDFLARE TUNNEL & DOCKER RESTART MANAGER
# ==============================================================================
# This script runs on the EC2 host. It:
# 1. Stops any existing cloudflared tunnel processes.
# 2. Starts a new background Cloudflare quick tunnel.
# 3. Polls and extracts the newly generated URL.
# 4. Automatically updates the backend env file at /opt/sbku-app.env.
# 5. Restarts the sbku-app Docker container with the new URL.
# ==============================================================================

LOG_FILE="$HOME/tunnel.log"
ENV_FILE="/opt/sbku-app.env"
CONTAINER_NAME="sbku-app"
IMAGE_NAME="sbku-app:latest"

echo "==============================================="
echo "⚙️  Starting SBKU Automation Pipeline..."
echo "==============================================="

# 1. Stop old tunnels
echo "🛑 Stopping any active cloudflared tunnels..."
pkill -f "cloudflared tunnel" 2>/dev/null || true
sleep 1

# 2. Start new tunnel in background
echo "⚡ Launching new background Cloudflare tunnel..."
rm -f "$LOG_FILE"
nohup cloudflared tunnel --url http://localhost:80 > "$LOG_FILE" 2>&1 &

# 3. Wait and extract URL
echo "⏳ Waiting for Cloudflare to assign a Tunnel URL..."
TUNNEL_URL=""
for i in {1..15}; do
    sleep 1
    if [ -f "$LOG_FILE" ]; then
        TUNNEL_URL=$(grep -oE "https://[a-zA-Z0-9-]+\.trycloudflare\.com" "$LOG_FILE" | head -n 1)
        if [ -n "$TUNNEL_URL" ]; then
            break
        fi
    fi
    echo -n "."
done
echo ""

if [ -z "$TUNNEL_URL" ]; then
    echo "❌ ERROR: Tunnel URL generation timed out!"
    echo "---- [ Full Log Output ] ----"
    cat "$LOG_FILE"
    exit 1
fi

echo "🎉 SUCCESS! Quick tunnel is running!"
echo "📱 Public URL: $TUNNEL_URL"
echo "-----------------------------------------------"

# 4. Update the environment variables file
echo "💾 Writing updated environments to $ENV_FILE..."
sudo tee "$ENV_FILE" > /dev/null << EOF
NEON_DATABASE_URL="postgresql://neondb_owner:npg_PTQUFJLvd94h@ep-fragrant-recipe-a7rnwwa3.ap-southeast-2.aws.neon.tech/neondb?sslmode=require"
APP_KEY=base64:qA+gNzOOJyERlAI2Qx1u7AK8j/pJ0npT5KMqaOl3sCE=
APP_ENV=production
APP_DEBUG=false
APP_URL=$TUNNEL_URL
ASSET_URL=$TUNNEL_URL
EOF
sudo chmod 600 "$ENV_FILE"
echo "✅ Environment file updated successfully!"

# 5. Restart the backend container
echo "🐳 Restarting '$CONTAINER_NAME' Docker container..."
sudo docker stop "$CONTAINER_NAME" 2>/dev/null || true
sudo docker rm "$CONTAINER_NAME" 2>/dev/null || true
sudo docker run -d \
  --name "$CONTAINER_NAME" \
  -p 8080:80 \
  --memory="768m" \
  --memory-reservation="512m" \
  --env-file "$ENV_FILE" \
  "$IMAGE_NAME"

echo "-----------------------------------------------"
echo "🚀 PIPELINE COMPLETE! Everything is running!"
echo ""
echo "👉 NEXT STEPS FOR MOBILE APP:"
echo "1. Update your local Flutter app's frontend/.env file:"
echo "   API_URL=$TUNNEL_URL"
echo ""
echo "2. Re-run your mobile app. It will connect immediately!"
echo "==============================================="
