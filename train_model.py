"""
train_model.py
--------------
Trains a RandomForestClassifier on the Titanic dataset and saves
the trained model and label encoders to the 'model/' directory.

Run this script once before starting the FastAPI server:
    python train_model.py
"""

import os
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, confusion_matrix
import joblib

# ── 1. Load dataset ────────────────────────────────────────────────
data = pd.read_csv("train.csv")

# ── 2. Define feature columns and target ───────────────────────────
features = ["Pclass", "Sex", "Age", "SibSp", "Parch", "Fare", "Embarked"]
target = "Survived"

# ── 3. Handle missing values ──────────────────────────────────────
# Fill missing Age with the median value
data["Age"] = data["Age"].fillna(data["Age"].median())
# Fill missing Embarked with the most frequent value (mode)
data["Embarked"] = data["Embarked"].fillna(data["Embarked"].mode()[0])

# ── 4. Encode categorical features ────────────────────────────────
# LabelEncoder converts string labels ('male'/'female') into numbers (0/1)
le_sex = LabelEncoder()
data["Sex"] = le_sex.fit_transform(data["Sex"])

le_embarked = LabelEncoder()
data["Embarked"] = le_embarked.fit_transform(data["Embarked"])

# ── 5. Split data into training and test sets ──────────────────────
X = data[features]
y = data[target]
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# ── 6. Train a Random Forest classifier ───────────────────────────
rf_model = RandomForestClassifier(n_estimators=100, random_state=42)
rf_model.fit(X_train, y_train)

# ── 7. Evaluate model performance ─────────────────────────────────
y_pred = rf_model.predict(X_test)
accuracy = accuracy_score(y_test, y_pred)
cm = confusion_matrix(y_test, y_pred)

print(f"✅ Model trained successfully!")
print(f"   Accuracy: {accuracy:.4f}")
print(f"   Confusion Matrix:\n{cm}")

# ── 8. Save model and encoders to disk ────────────────────────────
os.makedirs("model", exist_ok=True)

# Save the trained model
joblib.dump(rf_model, "model/model.joblib")
# Save both label encoders so the API can transform user input
joblib.dump({"Sex": le_sex, "Embarked": le_embarked}, "model/encoders.joblib")

print(f"\n📦 Saved model  → model/model.joblib")
print(f"📦 Saved encoders → model/encoders.joblib")
