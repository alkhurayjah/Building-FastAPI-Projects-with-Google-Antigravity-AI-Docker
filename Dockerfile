# ============================================================
# Dockerfile – Titanic Survival Prediction FastAPI Application
# ============================================================
# Multi-stage build:
#   Stage 1 (builder) – install dependencies & train the model
#   Stage 2 (runtime) – slim image with only what's needed to serve
# ============================================================

# ── Stage 1: Builder ────────────────────────────────────────
FROM python:3.11-slim AS builder

WORKDIR /build

# Install Python dependencies first (cached unless requirements change)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy training data and training script
COPY train.csv .
COPY train_model.py .

# Train the model – produces model/model.joblib and model/encoders.joblib
RUN python train_model.py


# ── Stage 2: Runtime ────────────────────────────────────────
FROM python:3.11-slim

WORKDIR /app

# Install runtime dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app/ ./app/

# Copy the trained model from the builder stage
COPY --from=builder /build/model/ ./model/

# ── Metadata labels ─────────────────────────────────────────
# OCI / Docker Desktop labels so the container is recognized
# as a web service and shows an "Open in browser" button.
LABEL org.opencontainers.image.title="Titanic Survival Prediction" \
      org.opencontainers.image.description="FastAPI app that predicts Titanic passenger survival" \
      org.opencontainers.image.url="http://localhost:8000" \
      com.docker.desktop.http.port="8000" \
      com.docker.desktop.http.path="/"

# Expose the default uvicorn port
EXPOSE 8000

# Health check – Docker marks the container "healthy" once the API responds
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1

# Run the FastAPI app with uvicorn
# --host 0.0.0.0  → accept connections from any interface (required for Docker)
# --port 8000     → default port
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]