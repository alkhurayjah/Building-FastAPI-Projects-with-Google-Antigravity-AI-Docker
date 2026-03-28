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
├── Dockerfile               # Multi-stage Docker build (builder → runtime)
├── docker-compose.yml       # Docker Compose orchestration
├── start.sh                 # 🚀 One-click launcher (build + run + open browser)
├── .dockerignore            # Files excluded from Docker build context
└── README.md                # This file
```

---

## 🚀 Quick Start (Local — without Docker)

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

## 🐳 Docker (Recommended)

The project uses a **multi-stage Docker build** that trains the model in the first stage and creates a slim, secure runtime image (with a non-root user) in the second.

### ⚡ One-Click Start (recommended)

Just run:

```bash
./start.sh
```

This single command will:
1. ✅ Verify Docker is installed and running
2. 🛑 Stop any previous container
3. 🔨 Build the Docker image (with model training)
4. 🚀 Start the container
5. ⏳ Wait for the health check to pass
6. 🌐 Open your browser automatically

### Manual: Docker Compose

```bash
docker compose up --build -d     # Build & start in background
docker compose logs -f           # View live logs
docker compose down              # Stop the container
```

### Manual: Docker CLI

```bash
docker build -t titanic-fastapi .
docker run -d -p 8000:8000 --name titanic-app titanic-fastapi
```

Then open **http://localhost:8000** to use the app.

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