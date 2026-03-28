"""
app/main.py
-----------
FastAPI application that serves a Titanic survival prediction model.

Endpoints:
    GET  /         — HTML form for entering passenger features
    POST /predict  — JSON API that returns survival prediction
    GET  /health   — Health check for container orchestration
"""

from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
from pydantic import BaseModel, Field
from typing import Literal
import joblib
import pandas as pd
import os

# ── Resolve the path to the model directory ────────────────────────
# Works whether started from project root or from inside the app/ folder
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MODEL_DIR = os.path.join(BASE_DIR, "model")

# ── Load pre-trained model and encoders at startup ─────────────────
model = joblib.load(os.path.join(MODEL_DIR, "model.joblib"))
encoders = joblib.load(os.path.join(MODEL_DIR, "encoders.joblib"))

# ── Set up Jinja2 templates directory ──────────────────────────────
TEMPLATES_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "templates")
templates = Jinja2Templates(directory=TEMPLATES_DIR)

# ── Create the FastAPI app ─────────────────────────────────────────
app = FastAPI(
    title="Titanic Survival Prediction API",
    description="Predict whether a Titanic passenger would survive based on their features.",
    version="1.0.0",
)


# ── Pydantic model for input validation ────────────────────────────
# Validates and constrains every field the model expects
class PassengerInput(BaseModel):
    Pclass: int = Field(
        ..., ge=1, le=3,
        description="Ticket class: 1 = 1st, 2 = 2nd, 3 = 3rd"
    )
    Sex: Literal["male", "female"] = Field(
        ..., description="Passenger gender"
    )
    Age: float = Field(
        ..., ge=0, le=120,
        description="Age in years (0–120)"
    )
    SibSp: int = Field(
        ..., ge=0, le=10,
        description="Number of siblings/spouses aboard"
    )
    Parch: int = Field(
        ..., ge=0, le=10,
        description="Number of parents/children aboard"
    )
    Fare: float = Field(
        ..., ge=0,
        description="Passenger fare (≥ 0)"
    )
    Embarked: Literal["C", "Q", "S"] = Field(
        ..., description="Port of embarkation: C = Cherbourg, Q = Queenstown, S = Southampton"
    )


# ── GET / — Serve the HTML prediction form ─────────────────────────
@app.get("/", response_class=HTMLResponse)
async def home(request: Request):
    """Render the main prediction form page."""
    return templates.TemplateResponse(request=request, name="index.html")


# ── POST /predict — Run the model and return prediction ─────────────
@app.post("/predict")
async def predict(passenger: PassengerInput):
    """
    Accept passenger features as JSON, encode categorical fields,
    run inference, and return the prediction with probability.
    """
    # Encode 'Sex' using the saved LabelEncoder
    sex_encoded = encoders["Sex"].transform([passenger.Sex])[0]
    # Encode 'Embarked' using the saved LabelEncoder
    embarked_encoded = encoders["Embarked"].transform([passenger.Embarked])[0]

    # Build a DataFrame matching the model's expected feature order
    input_df = pd.DataFrame({
        "Pclass": [passenger.Pclass],
        "Sex": [sex_encoded],
        "Age": [passenger.Age],
        "SibSp": [passenger.SibSp],
        "Parch": [passenger.Parch],
        "Fare": [passenger.Fare],
        "Embarked": [embarked_encoded],
    })

    # Get the predicted class (0 = did not survive, 1 = survived)
    prediction = int(model.predict(input_df)[0])
    # Get the probability of survival (class 1)
    probability = float(model.predict_proba(input_df)[0][1])

    return {
        "survived": bool(prediction),
        "prediction": prediction,
        "probability": round(probability, 4),
        "message": "Passenger would likely survive! 🎉" if prediction == 1
                   else "Passenger would likely not survive. 😔",
    }


# ── GET /health — Simple health check ──────────────────────────────
@app.get("/health")
async def health():
    """Return a simple health status (useful for Docker / cloud readiness probes)."""
    return {"status": "healthy", "model_loaded": True}
