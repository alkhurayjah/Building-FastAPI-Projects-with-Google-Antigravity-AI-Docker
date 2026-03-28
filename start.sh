#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║  start.sh — One-Click Docker Launcher                      ║
# ║                                                            ║
# ║  This script does everything:                              ║
# ║    1. Checks that Docker is running                        ║
# ║    2. Stops any previous container                         ║
# ║    3. Builds the Docker image                              ║
# ║    4. Starts the container                                 ║
# ║    5. Waits for the health check to pass                   ║
# ║    6. Opens the app in your browser                        ║
# ║                                                            ║
# ║  Usage:  ./start.sh                                        ║
# ╚══════════════════════════════════════════════════════════════╝

set -euo pipefail

# ── Configuration ───────────────────────────────────────────────
APP_NAME="titanic-prediction-app"
PORT=8000
URL="http://localhost:${PORT}"
MAX_WAIT=90   # seconds to wait for the app to become healthy

# ── Colors for pretty output ───────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ── Helper functions ───────────────────────────────────────────
info()    { echo -e "${BLUE}ℹ ${NC} $*"; }
success() { echo -e "${GREEN}✅${NC} $*"; }
warn()    { echo -e "${YELLOW}⚠️ ${NC} $*"; }
error()   { echo -e "${RED}❌${NC} $*"; exit 1; }

# ── Step 1: Check Docker is available and running ──────────────
echo ""
echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}║   🚢  Titanic Prediction — Docker Launcher  ║${NC}"
echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════╝${NC}"
echo ""

if ! command -v docker &> /dev/null; then
    error "Docker is not installed. Please install Docker Desktop first: https://docker.com/get-started"
fi

if ! docker info &> /dev/null; then
    error "Docker daemon is not running. Please start Docker Desktop and try again."
fi
success "Docker is running"

# ── Step 2: Stop any previous container ────────────────────────
if docker ps -q -f "name=${APP_NAME}" | grep -q .; then
    info "Stopping previous container..."
    docker compose down --remove-orphans 2>/dev/null || true
    success "Previous container stopped"
fi

# ── Step 3: Build and start ────────────────────────────────────
info "Building Docker image & starting container..."
echo ""
docker compose up --build -d

echo ""
success "Container started"

# ── Step 4: Wait for health check ──────────────────────────────
info "Waiting for the application to become healthy..."
for i in $(seq 1 ${MAX_WAIT}); do
    if curl -sf "${URL}/health" > /dev/null 2>&1; then
        echo ""
        success "Application is ${GREEN}${BOLD}running${NC} at ${BOLD}${URL}${NC}"
        break
    fi
    if [ "$i" -eq "${MAX_WAIT}" ]; then
        echo ""
        warn "Timed out after ${MAX_WAIT}s. The app may still be starting."
        info "Check logs with: ${BOLD}docker compose logs -f${NC}"
        exit 1
    fi
    # Show a simple progress indicator
    printf "."
    sleep 1
done

# ── Step 5: Open the browser ──────────────────────────────────
echo ""
info "Opening browser..."
if command -v open &> /dev/null; then
    open "${URL}"                       # macOS
elif command -v xdg-open &> /dev/null; then
    xdg-open "${URL}"                   # Linux
elif command -v start &> /dev/null; then
    start "${URL}"                      # Windows (Git Bash / WSL)
else
    info "Please open ${BOLD}${URL}${NC} in your browser."
fi

echo ""
echo -e "${BOLD}${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}  🎉  All done! The app is live at ${URL}${NC}"
echo -e "${BOLD}${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${CYAN}Useful commands:${NC}"
echo -e "    View logs   →  ${BOLD}docker compose logs -f${NC}"
echo -e "    Stop app    →  ${BOLD}docker compose down${NC}"
echo -e "    Restart     →  ${BOLD}docker compose restart${NC}"
echo -e "    API docs    →  ${BOLD}${URL}/docs${NC}"
echo ""
