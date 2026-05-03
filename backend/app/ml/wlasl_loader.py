from pathlib import Path

import cv2
import numpy as np

from app.core.config import settings
from app.services.vision_service import VisionService


class WLASLDataLoader:
    def __init__(
        self,
        dataset_path: str | Path,
        sequence_length: int | None = None,
        vision_service: VisionService | None = None,
    ):
        self.dataset_path = Path(dataset_path)
        self.sequence_length = sequence_length or settings.WLASL_SEQUENCE_LENGTH
        self.vision_service = vision_service or VisionService()

    def _sample_indices(self, frame_count: int) -> np.ndarray:
        if frame_count <= 0:
            return np.array([], dtype=int)
        return np.linspace(0, max(frame_count - 1, 0), num=self.sequence_length, dtype=int)

    def _extract_video_features(self, video_path: Path) -> np.ndarray | None:
        capture = cv2.VideoCapture(str(video_path))
        if not capture.isOpened():
            return None

        try:
            frame_count = int(capture.get(cv2.CAP_PROP_FRAME_COUNT))
            sample_indices = self._sample_indices(frame_count)
            if sample_indices.size == 0:
                return None

            features = []
            valid_frames = 0
            for frame_index in sample_indices:
                capture.set(cv2.CAP_PROP_POS_FRAMES, int(frame_index))
                success, frame = capture.read()
                if not success or frame is None:
                    features.append(np.zeros(VisionService.HOLISTIC_FEATURE_LENGTH, dtype=np.float32))
                    continue

                holistic = self.vision_service.process_frame_holistic(frame).astype(np.float32)
                if np.any(holistic):
                    valid_frames += 1
                features.append(holistic)

            if valid_frames == 0:
                return None

            return np.concatenate(features, dtype=np.float32)
        finally:
            capture.release()

    def load_dataset(
        self,
        max_classes: int | None = None,
        max_samples_per_class: int = 10,
        include_classes: set[str] | None = None,
    ):
        X: list[np.ndarray] = []
        y: list[int] = []
        classes = [
            item.name
            for item in sorted(self.dataset_path.iterdir(), key=lambda path: path.name.lower())
            if item.is_dir()
        ]

        if include_classes:
            classes = [class_name for class_name in classes if class_name.lower() in include_classes]
        if max_classes is not None:
            classes = classes[:max_classes]

        for class_idx, class_name in enumerate(classes):
            class_path = self.dataset_path / class_name
            samples = 0

            for video_path in sorted(class_path.glob("*.mp4")):
                if samples >= max_samples_per_class:
                    break

                features = self._extract_video_features(video_path)
                if features is None:
                    continue

                X.append(features)
                y.append(class_idx)
                samples += 1

        return np.array(X), np.array(y), classes
