from pathlib import Path
import numpy as np
try:
    import tensorflow as tf
except ImportError:
    tf = None
try:
    import joblib
except ImportError:
    joblib = None
from typing import Dict, List, Tuple
from collections import deque
import logging
from app.core.config import settings
from app.services.vision_service import VisionService

logger = logging.getLogger(__name__)


class SignLanguageModelManager:
    def __init__(self):
        self.asl_model_path = Path(settings.ASL_MODEL_PATH)
        self.wlasl_model_path = Path(settings.WLASL_MODEL_PATH)
        self.wlasl_sequence_length = settings.WLASL_SEQUENCE_LENGTH
        
        self.asl_model = None
        self.wlasl_model = None
        self.asl_classes = list("ABCDEFGHIJKLMNOPQRSTUVWXYZ") + ["del", "space", "nothing"]
        
        self.wlasl_vocab = self._load_wlasl_vocab()
        
        self.history_queue = deque(maxlen=settings.SMOOTHING_WINDOW_SIZE)
        self.dynamic_feature_queue = deque(maxlen=self.wlasl_sequence_length)
        self.last_prediction = None
        self.last_prediction_type = None
        self.last_confidence = 0.0

        self._load_models()

    def _load_models(self):
        """Load persisted models if they exist, otherwise use deterministic fallback inference."""
        if self.asl_model_path.exists():
            if self.asl_model_path.suffix == ".joblib" and joblib is not None:
                payload = joblib.load(self.asl_model_path)
                self.asl_model = payload["model"]
                self.asl_classes = payload.get("classes", self.asl_classes)
                logger.info("Loaded ASL sklearn model from %s", self.asl_model_path)
            elif self.asl_model_path.suffix == ".h5" and tf is not None:
                self.asl_model = tf.keras.models.load_model(self.asl_model_path)
                logger.info("Loaded legacy ASL TensorFlow model from %s", self.asl_model_path)
            else:
                logger.warning("Unsupported ASL model format or missing dependency for %s", self.asl_model_path)
        else:
            logger.warning("ASL model not found at %s. Using deterministic fallback inference.", self.asl_model_path)

        if self.wlasl_model_path.exists():
            if self.wlasl_model_path.suffix == ".joblib" and joblib is not None:
                payload = joblib.load(self.wlasl_model_path)
                self.wlasl_model = payload["model"]
                self.wlasl_vocab = set(payload.get("classes", self.wlasl_vocab))
                self.wlasl_sequence_length = payload.get("sequence_length", self.wlasl_sequence_length)
                self.dynamic_feature_queue = deque(maxlen=self.wlasl_sequence_length)
                logger.info("Loaded WLASL sklearn model from %s", self.wlasl_model_path)
            elif self.wlasl_model_path.suffix == ".h5" and tf is not None:
                self.wlasl_model = tf.keras.models.load_model(self.wlasl_model_path)
                logger.info("Loaded legacy WLASL TensorFlow model from %s", self.wlasl_model_path)
            else:
                logger.warning("Unsupported WLASL model format or missing dependency for %s", self.wlasl_model_path)
        else:
            logger.warning("WLASL dynamic model unavailable. Dynamic gesture recognition remains in placeholder mode.")

    def _load_wlasl_vocab(self) -> set[str]:
        dataset_path = Path(settings.WLASL_DATASET_PATH)
        if not dataset_path.exists():
            logger.warning("WLASL dataset path not found at %s", dataset_path)
            return {"hello", "thank you", "please", "yes", "no", "help", "sorry"}

        return {
            item.name.lower()
            for item in dataset_path.iterdir()
            if item.is_dir() and not item.name.startswith(".")
        }

    def _simulate_asl_inference(self, landmarks) -> Tuple[str, float]:
        """Use a deterministic fallback so the API still behaves predictably without a trained model."""
        if len(landmarks) > 0:
            value = int(abs(float(landmarks[0])) * 1000) % len(self.asl_classes)
            return self.asl_classes[value], 0.55
        return "A", 0.55

    def predict_wlasl(self, sequence_features: np.ndarray) -> Tuple[str, float]:
        if self.wlasl_model is None or sequence_features.size == 0:
            return "", 0.0

        if tf is not None and hasattr(self.wlasl_model, "predict") and self.wlasl_model_path.suffix == ".h5":
            pred = self.wlasl_model.predict(sequence_features.reshape(1, -1), verbose=0)[0]
            class_idx = int(np.argmax(pred))
            classes = sorted(self.wlasl_vocab)
            return classes[class_idx], float(pred[class_idx])

        probabilities = self.wlasl_model.predict_proba(sequence_features.reshape(1, -1))[0]
        class_idx = int(np.argmax(probabilities))
        predicted_label = self.wlasl_model.classes_[class_idx]
        return str(predicted_label), float(probabilities[class_idx])

    def _finalize_prediction(self, token: str, confidence: float, prediction_type: str) -> Dict:
        rounded_confidence = round(confidence, 2)
        if confidence <= 0:
            return {"text": "", "confidence": 0.0, "status": "low_confidence"}

        if token != self.last_prediction or prediction_type != self.last_prediction_type:
            self.last_prediction = token
            self.last_prediction_type = prediction_type
            self.last_confidence = confidence
            return {
                "text": token,
                "confidence": rounded_confidence,
                "status": "new_prediction",
                "prediction_type": prediction_type,
            }

        return {
            "text": token,
            "confidence": rounded_confidence,
            "status": "duplicate",
            "prediction_type": prediction_type,
        }

    def predict_asl(self, hand_landmarks: List[List[float]]) -> Tuple[str, float]:
        """
        Predict static character (ASL Alphabet).
        Requires flattened relative landmarks.
        """
        flat_lms = VisionService.normalize_hand_landmarks(hand_landmarks)
        if flat_lms.size == 0:
            return "", 0.0
        
        if self.asl_model is None:
            return self._simulate_asl_inference(flat_lms)

        if tf is not None and hasattr(self.asl_model, "predict") and self.asl_model_path.suffix == ".h5":
            pred = self.asl_model.predict(flat_lms.reshape(1, -1), verbose=0)[0]
            class_idx = int(np.argmax(pred))
            return self.asl_classes[class_idx], float(pred[class_idx])

        probabilities = self.asl_model.predict_proba(flat_lms.reshape(1, -1))[0]
        class_idx = int(np.argmax(probabilities))
        predicted_label = self.asl_model.classes_[class_idx]
        if isinstance(predicted_label, (int, np.integer)):
            predicted_label = self.asl_classes[int(predicted_label)]
        return str(predicted_label), float(probabilities[class_idx])

    def process_frame(
        self,
        hand_landmarks: List[List[float]],
        holistic_features: np.ndarray | None = None,
        mode: str = "auto",
    ) -> Dict:
        """
        The Priority Decision Layer.
        """
        if holistic_features is not None and holistic_features.size > 0 and np.any(holistic_features):
            self.dynamic_feature_queue.append(np.asarray(holistic_features, dtype=np.float32))
        elif not hand_landmarks:
            self.dynamic_feature_queue.clear()

        dynamic_prediction = None
        dynamic_confidence = 0.0
        if mode != "static" and self.wlasl_model is not None and len(self.dynamic_feature_queue) == self.wlasl_sequence_length:
            dynamic_sequence = np.concatenate(list(self.dynamic_feature_queue))
            dynamic_prediction, dynamic_confidence = self.predict_wlasl(dynamic_sequence)

        if not hand_landmarks and dynamic_confidence >= settings.DYNAMIC_CONFIDENCE_THRESHOLD and dynamic_prediction:
            return self._finalize_prediction(dynamic_prediction, dynamic_confidence, "dynamic")

        if not hand_landmarks:
            self.history_queue.clear()
            self.last_prediction = None
            self.last_prediction_type = None
            return {"text": "", "confidence": 0.0, "status": "no_hand"}

        pred_char, conf = self.predict_asl(hand_landmarks[0])
        if not pred_char:
            if dynamic_confidence >= settings.DYNAMIC_CONFIDENCE_THRESHOLD and dynamic_prediction:
                return self._finalize_prediction(dynamic_prediction, dynamic_confidence, "dynamic")
            return {"text": "", "confidence": 0.0, "status": "low_confidence"}

        self.history_queue.append((pred_char, conf))
        
        votes = {}
        for char, c in self.history_queue:
            votes[char] = votes.get(char, 0) + c
        
        best_char = max(votes, key=votes.get)
        avg_conf = votes[best_char] / sum([1 for x, _ in self.history_queue if x == best_char])

        if (
            mode != "static"
            and dynamic_confidence >= settings.DYNAMIC_CONFIDENCE_THRESHOLD
            and dynamic_confidence > avg_conf
            and dynamic_prediction
        ):
            return self._finalize_prediction(dynamic_prediction, dynamic_confidence, "dynamic")

        if avg_conf > settings.CONFIDENCE_THRESHOLD:
            return self._finalize_prediction(best_char, avg_conf, "static")
        
        return {"text": "", "confidence": round(avg_conf, 2), "status": "low_confidence"}
