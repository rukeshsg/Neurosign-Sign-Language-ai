import argparse
import csv
import json
import sys
from pathlib import Path

import cv2

sys.path.append(str(Path(__file__).resolve().parents[1]))

from app.core.config import settings
from app.services.model_service import SignLanguageModelManager
from app.services.vision_service import VisionService


def evaluate_asl(output_dir: Path):
    test_dir = settings.ASL_TEST_DATASET_PATH
    output_dir.mkdir(parents=True, exist_ok=True)

    vision_service = VisionService()
    model_manager = SignLanguageModelManager()
    rows = []

    try:
        for image_path in sorted(test_dir.glob("*_test.jpg")):
            expected_label = image_path.stem.replace("_test", "")
            image = cv2.imread(str(image_path))
            if image is None:
                continue

            model_manager.history_queue.clear()
            model_manager.dynamic_feature_queue.clear()
            model_manager.last_prediction = None
            model_manager.last_prediction_type = None

            hand_landmarks = vision_service.process_frame_for_hands(image)
            holistic_features = vision_service.process_frame_holistic(image)
            result = model_manager.process_frame(hand_landmarks, holistic_features=holistic_features)

            predicted_text = result.get("text", "")
            status = result.get("status", "unknown")
            confidence = float(result.get("confidence", 0.0))

            rows.append(
                {
                    "file_name": image_path.name,
                    "expected_label": expected_label,
                    "predicted_text": predicted_text,
                    "status": status,
                    "confidence": confidence,
                    "exact_match": predicted_text.lower() == expected_label.lower(),
                    "hand_detected": bool(hand_landmarks),
                }
            )
    finally:
        vision_service.close()

    total = len(rows)
    exact_matches = sum(1 for row in rows if row["exact_match"])
    detected_frames = sum(1 for row in rows if row["status"] != "no_hand")

    per_class = {}
    for row in rows:
        entry = per_class.setdefault(
            row["expected_label"],
            {"total": 0, "exact_matches": 0, "detected_frames": 0},
        )
        entry["total"] += 1
        entry["exact_matches"] += int(row["exact_match"])
        entry["detected_frames"] += int(row["status"] != "no_hand")

    summary = {
        "total_samples": total,
        "exact_match_accuracy": round(exact_matches / total, 4) if total else 0.0,
        "detection_rate": round(detected_frames / total, 4) if total else 0.0,
        "per_class": per_class,
        "rows": rows,
    }

    json_path = output_dir / "asl_evaluation_summary.json"
    csv_path = output_dir / "asl_evaluation_rows.csv"

    with json_path.open("w", encoding="utf-8") as json_file:
        json.dump(summary, json_file, indent=2)

    with csv_path.open("w", newline="", encoding="utf-8") as csv_file:
        writer = csv.DictWriter(csv_file, fieldnames=rows[0].keys() if rows else [])
        if rows:
            writer.writeheader()
            writer.writerows(rows)

    print(f"Saved JSON summary to {json_path}")
    print(f"Saved CSV rows to {csv_path}")
    print(json.dumps({k: v for k, v in summary.items() if k != 'rows'}, indent=2))
    return 0


def parse_args():
    parser = argparse.ArgumentParser(description="Evaluate the trained ASL model against the test set.")
    parser.add_argument(
        "--output-dir",
        default=str(Path("reports")),
        help="Directory where evaluation outputs should be written.",
    )
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
    raise SystemExit(evaluate_asl(Path(args.output_dir)))
