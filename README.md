# 🚢 Titanic Survival Prediction – FastAPI + Docker

A machine learning web application that predicts Titanic passenger survival using a **RandomForestClassifier**. Built with **FastAPI** and packaged in **Docker** for cross-platform deployment.

---

## 📁 Project Structure

```
├── app/
│   ├── __init__.py          # Python package marker
│   ├── main.py              # FastAPI application (endpoints + model inference)
│   └── templates/
│       └── index.html       # Web UI (prediction form)
├── model/                   # Generated after training
│   ├── model.joblib         # Trained RandomForest model
│   └── encoders.joblib      # Saved LabelEncoders (Sex, Embarked)
├── train.csv                # Titanic training dataset
├── train_model.py           # Script to train and save the model
├── test_request.py          # Example script to test the API
├── requirements.txt         # Python dependencies
├── Dockerfile               # Multi-stage Docker build
├── docker-compose.yml       # One-command Docker Compose setup
├── start.sh                 # Build, run, and auto-open browser script
├── .dockerignore            # Files excluded from Docker context
└── README.md                # This file
```

---

## 🚀 Quick Start (Local)

### 1. Install dependencies

```bash
pip install -r requirements.txt
```

### 2. Train the model

```bash
python train_model.py
```

This creates `model/model.joblib` and `model/encoders.joblib`.

### 3. Start the server

```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

### 4. Open the web UI

Navigate to **http://localhost:8000** in your browser.

### 5. Test the API (optional)

```bash
pip install requests     # if not already installed
python test_request.py
```

---

## 🐳 Docker

The Dockerfile uses a **multi-stage build**: it trains the model in the first stage and creates a slim runtime image in the second. The container includes a **health check** and **Docker Desktop labels** so it shows an "Open in browser" button automatically.

### Option A — Start script (recommended)

Builds the image, starts the container, and **opens your browser automatically**:

```bash
./start.sh
```

### Option B — Docker Compose

```bash
docker compose up --build
```

Then open **http://localhost:8000**, or click **"Open in browser"** in Docker Desktop.

### Option C — Docker CLI

```bash
docker build -t titanic-fastapi .
docker run -d -p 8000:8000 --name titanic-app titanic-fastapi
```

Open **http://localhost:8000** to use the app.

### Stop the container

```bash
docker compose down        # if started with Compose / start.sh
# or
docker stop titanic-app    # if started with docker run
```

---

## 🔌 API Reference

### `GET /` — Web UI
Returns the HTML prediction form.

### `POST /predict` — Prediction Endpoint
**Request body (JSON):**
```json
{
  "Pclass": 3,
  "Sex": "male",
  "Age": 25,
  "SibSp": 0,
  "Parch": 0,
  "Fare": 7.25,
  "Embarked": "S"
}
```

**Response:**
```json
{
  "survived": false,
  "prediction": 0,
  "probability": 0.1234,
  "message": "Passenger would likely not survive. 😔"
}
```

### `GET /health` — Health Check
```json
{ "status": "healthy", "model_loaded": true }
```

### `GET /docs` — Interactive API Docs
FastAPI auto-generates Swagger UI at `/docs`.

---

## ☁️ Cloud Deployment

The Docker image runs on any platform that supports containers:
- **AWS**: ECS, App Runner, EC2
- **Google Cloud**: Cloud Run, GKE
- **Azure**: Container Apps, ACI
- **Others**: Railway, Render, Fly.io

Example (Google Cloud Run):
```bash
gcloud run deploy titanic-app \
  --source . \
  --port 8000 \
  --allow-unauthenticated
```

---

## 📝 License

This project is for educational purposes.