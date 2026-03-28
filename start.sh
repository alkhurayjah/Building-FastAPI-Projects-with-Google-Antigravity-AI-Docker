#!/usr/bin/env bash
# ============================================================
# start.sh — Build, run the Docker container, and open the app
# ============================================================
# Usage:  ./start.sh
# ============================================================

set -e

APP_NAME="titanic-prediction-app"
PORT=8000
URL="http://localhost:${PORT}"

echo "🐳  Building Docker image..."
docker compose up --build -d

echo "⏳  Waiting for the application to start..."
# Wait up to 60 seconds for the health endpoint
for i in $(seq 1 60); do
    if curl -sf "${URL}/health" > /dev/null 2>&1; then
        echo "✅  Application is running at ${URL}"
        break
    fi
    if [ "$i" -eq 60 ]; then
        echo "⚠️   Timed out waiting for the app. Check logs with: docker compose logs"
        exit 1
    fi
    sleep 1
done

# Open the browser automatically
echo "🌐  Opening browser..."
if command -v open &> /dev/null; then
    open "${URL}"                     # macOS
elif command -v xdg-open &> /dev/null; then
    xdg-open "${URL}"                 # Linux
elif command -v start &> /dev/null; then
    start "${URL}"                    # Windows (Git Bash / WSL)
else
    echo "👉  Please open ${URL} in your browser."
fi
