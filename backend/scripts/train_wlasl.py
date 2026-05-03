import argparse
import sys
from pathlib import Path

import joblib
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split

sys.path.append(str(Path(__file__).resolve().parents[1]))

from app.core.config import settings
from app.ml.wlasl_loader import WLASLDataLoader


def train_dynamic_model(
    max_classes: int | None = 20,
    max_samples_per_class: int = 8,
    include_classes: list[str] | None = None,
):
    dataset_path = settings.WLASL_DATASET_PATH
    if not dataset_path.exists():
        print(f"Dataset path {dataset_path} does not exist. Skipping training.")
        return 1

    include_class_set = {item.strip().lower() for item in include_classes or [] if item.strip()}

    print("Loading WLASL sequence data...")
    loader = WLASLDataLoader(dataset_path, sequence_length=settings.WLASL_SEQUENCE_LENGTH)
    X, y, classes = loader.load_dataset(
        max_classes=max_classes,
        max_samples_per_class=max_samples_per_class,
        include_classes=include_class_set or None,
    )

    if len(X) == 0:
        print("No dynamic WLASL samples could be loaded. Please check dataset availability.")
        return 1

    model = RandomForestClassifier(
        n_estimators=200,
        random_state=42,
        n_jobs=-1,
        class_weight="balanced_subsample",
    )

    unique_classes, class_counts = np.unique(y, return_counts=True)
    can_use_stratified_split = len(X) >= len(unique_classes) * 2 and np.min(class_counts) >= 2

    print("Training WLASL random forest model...")
    if can_use_stratified_split:
        test_size = max(len(unique_classes), int(np.ceil(len(X) * 0.2)))
        X_train, X_test, y_train, y_test = train_test_split(
            X,
            y,
            test_size=test_size,
            random_state=42,
            stratify=y,
        )
        model.fit(X_train, y_train)
        accuracy = model.score(X_test, y_test)
        evaluation_split = "validation"
        print(f"Validation accuracy: {accuracy:.4f}")
    else:
        model.fit(X, y)
        accuracy = model.score(X, y)
        evaluation_split = "train_only"
        print(
            "Dataset too small for a reliable stratified validation split. "
            f"Reporting training accuracy instead: {accuracy:.4f}"
        )

    settings.WLASL_MODEL_PATH.parent.mkdir(parents=True, exist_ok=True)
    joblib.dump(
        {
            "model": model,
            "classes": classes,
            "sequence_length": settings.WLASL_SEQUENCE_LENGTH,
            "feature_shape": X.shape[1],
            "validation_accuracy": accuracy,
            "evaluation_split": evaluation_split,
        },
        settings.WLASL_MODEL_PATH,
    )
    print(f"Model saved to {settings.WLASL_MODEL_PATH}")
    return 0


def parse_args():
    parser = argparse.ArgumentParser(description="Train a baseline dynamic WLASL classifier.")
    parser.add_argument("--max-classes", type=int, default=20, help="Maximum number of WLASL classes to train.")
    parser.add_argument(
        "--max-samples-per-class",
        type=int,
        default=8,
        help="Maximum number of videos to load for each class.",
    )
    parser.add_argument(
        "--include-classes",
        type=str,
        default="",
        help="Comma-separated list of class names to train instead of the first max-classes classes.",
    )
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
    include_classes = [item for item in args.include_classes.split(",") if item.strip()]
    raise SystemExit(
        train_dynamic_model(
            max_classes=args.max_classes,
            max_samples_per_class=args.max_samples_per_class,
            include_classes=include_classes,
        )
    )
