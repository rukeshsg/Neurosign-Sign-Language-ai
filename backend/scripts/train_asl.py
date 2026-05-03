import argparse
import sys
from pathlib import Path

import joblib
from sklearn.model_selection import train_test_split
from sklearn.neural_network import MLPClassifier
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler

sys.path.append(str(Path(__file__).resolve().parents[1]))
from app.ml.data_loader import DataLoader
from app.core.config import settings


def train_static_model(max_samples_per_class: int = 100):
    dataset_path = settings.ASL_DATASET_PATH
    if not dataset_path.exists():
        print(f"Dataset path {dataset_path} does not exist. Skipping training.")
        return 1

    print("Loading data...")
    loader = DataLoader(str(dataset_path))
    X, y, classes = loader.load_asl_dataset(max_samples_per_class=max_samples_per_class)
    
    if len(X) == 0:
        print("No valid data loaded. Please check dataset.")
        return 1

    X_train, X_test, y_train, y_test = train_test_split(
        X,
        y,
        test_size=0.2,
        random_state=42,
        stratify=y,
    )

    model = Pipeline(
        [
            ("scaler", StandardScaler()),
            (
                "classifier",
                MLPClassifier(
                    hidden_layer_sizes=(128, 64),
                    learning_rate_init=0.001,
                    max_iter=80,
                    early_stopping=True,
                    random_state=42,
                    verbose=True,
                ),
            ),
        ]
    )

    print("Training sklearn MLP model...")
    model.fit(X_train, y_train)
    accuracy = model.score(X_test, y_test)
    print(f"Validation accuracy: {accuracy:.4f}")

    print("Saving model...")
    settings.ASL_MODEL_PATH.parent.mkdir(parents=True, exist_ok=True)
    joblib.dump(
        {
            "model": model,
            "classes": classes,
            "feature_shape": X.shape[1],
            "validation_accuracy": accuracy,
        },
        settings.ASL_MODEL_PATH,
    )
    print(f"Model saved to {settings.ASL_MODEL_PATH}")
    return 0


def parse_args():
    parser = argparse.ArgumentParser(description="Train the static ASL classifier.")
    parser.add_argument(
        "--max-samples-per-class",
        type=int,
        default=100,
        help="Maximum number of training images to load from each class.",
    )
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
    raise SystemExit(train_static_model(max_samples_per_class=args.max_samples_per_class))
