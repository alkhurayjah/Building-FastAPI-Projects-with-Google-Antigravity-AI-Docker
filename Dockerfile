# ╔══════════════════════════════════════════════════════════════╗
# ║  Dockerfile — Titanic Survival Prediction (FastAPI)        ║
# ║                                                            ║
# ║  Multi-stage build for a production-ready container:       ║
# ║    Stage 1 (builder)  → install deps & train the ML model  ║
# ║    Stage 2 (runtime)  → slim image, only serving needs     ║
# ║                                                            ║
# ║  Usage:                                                    ║
# ║    ./start.sh              (recommended — one click)       ║
# ║    docker compose up -d    (manual)                        ║
# ╚══════════════════════════════════════════════════════════════╝

# ───────────── Stage 1: Builder ─────────────────────────────────
FROM python:3.11-slim AS builder

WORKDIR /build

# 1. Install Python dependencies (cached unless requirements.txt changes)
COPY requirements.txt .
RUN pip install --no-cache-dir --quiet -r requirements.txt

# 2. Copy training assets and train the model
COPY train.csv .
COPY train_model.py .
RUN python train_model.py


# ───────────── Stage 2: Runtime ─────────────────────────────────
FROM python:3.11-slim AS runtime

# Security: run as non-root user
RUN groupadd --gid 1000 appuser \
 && useradd  --uid 1000 --gid appuser --shell /bin/bash --create-home appuser

WORKDIR /app

# 1. Install only runtime Python packages
COPY requirements.txt .
RUN pip install --no-cache-dir --quiet -r requirements.txt \
 && rm -rf /root/.cache

# 2. Copy application source code
COPY app/ ./app/

# 3. Copy the trained model artifacts from the builder stage
COPY --from=builder /build/model/ ./model/

# 4. Set ownership to the non-root user
RUN chown -R appuser:appuser /app

USER appuser

# ── Container metadata ──────────────────────────────────────────
LABEL org.opencontainers.image.title="Titanic Survival Prediction" \
      org.opencontainers.image.description="FastAPI ML app — predicts Titanic passenger survival" \
      org.opencontainers.image.url="http://localhost:8000" \
      com.docker.desktop.http.port="8000" \
      com.docker.desktop.http.path="/"

EXPOSE 8000

# ── Health check ────────────────────────────────────────────────
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1

# ── Entrypoint ──────────────────────────────────────────────────
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
