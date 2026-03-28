"""
test_request.py
---------------
Sends a sample POST request to the /predict endpoint to verify
that the FastAPI server is running and the model responds correctly.

Usage:
    1. Start the server:  uvicorn app.main:app --port 8000
    2. Run this script:   python test_request.py
"""

import requests
import json

# ── Base URL of the running FastAPI server ─────────────────────────
BASE_URL = "http://localhost:8000"

# ── Sample passenger data for prediction ───────────────────────────
# This represents a 25-year-old male in 3rd class, no family, fare $7.25,
# embarked from Southampton – historically low survival probability.
sample_passenger = {
    "Pclass": 3,
    "Sex": "male",
    "Age": 25,
    "SibSp": 0,
    "Parch": 0,
    "Fare": 7.25,
    "Embarked": "S",
}

print("=" * 50)
print("🧪 Testing Titanic Survival Prediction API")
print("=" * 50)

# ── Test 1: Health check ───────────────────────────────────────────
print("\n1️⃣  GET /health")
try:
    resp = requests.get(f"{BASE_URL}/health")
    print(f"   Status: {resp.status_code}")
    print(f"   Body:   {resp.json()}")
except requests.ConnectionError:
    print("   ❌ Could not connect. Is the server running on port 8000?")
    exit(1)

# ── Test 2: Prediction endpoint ───────────────────────────────────
print("\n2️⃣  POST /predict")
print(f"   Payload: {json.dumps(sample_passenger, indent=2)}")
resp = requests.post(f"{BASE_URL}/predict", json=sample_passenger)
print(f"   Status:  {resp.status_code}")
result = resp.json()
print(f"   Result:  {json.dumps(result, indent=2)}")

# ── Test 3: Try another passenger (1st-class female → high survival) ──
print("\n3️⃣  POST /predict (1st-class female)")
high_survival = {
    "Pclass": 1,
    "Sex": "female",
    "Age": 30,
    "SibSp": 1,
    "Parch": 0,
    "Fare": 100.0,
    "Embarked": "C",
}
print(f"   Payload: {json.dumps(high_survival, indent=2)}")
resp = requests.post(f"{BASE_URL}/predict", json=high_survival)
print(f"   Status:  {resp.status_code}")
result = resp.json()
print(f"   Result:  {json.dumps(result, indent=2)}")

print("\n" + "=" * 50)
print("✅ All tests completed!")
print("=" * 50)
