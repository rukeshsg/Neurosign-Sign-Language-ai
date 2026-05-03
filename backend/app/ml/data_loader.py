import os
import cv2
import numpy as np
from app.services.vision_service import VisionService


class DataLoader:
    def __init__(self, dataset_path: str):
        self.dataset_path = dataset_path
        self.vision_service = VisionService()
        
    def load_asl_dataset(self, max_samples_per_class=1000):
        """
        Iterates over the ASL Alphabet dataset, extracts MediaPipe landmarks,
        and returns X (features) and y (labels).
        """
        X = []
        y = []
        classes = sorted(os.listdir(self.dataset_path))
        
        for class_idx, class_name in enumerate(classes):
            class_path = os.path.join(self.dataset_path, class_name)
            if not os.path.isdir(class_path):
                continue
                
            samples = 0
            for img_name in sorted(os.listdir(class_path)):
                if samples >= max_samples_per_class:
                    break
                if not img_name.lower().endswith((".jpg", ".jpeg", ".png")):
                    continue
                    
                img_path = os.path.join(class_path, img_name)
                img = cv2.imread(img_path)
                if img is None:
                    continue
                    
                hand_landmarks = self.vision_service.process_frame_for_hands(img)
                if hand_landmarks:
                    flat_lms = self.vision_service.normalize_hand_landmarks(hand_landmarks[0])
                    if flat_lms.size == 0:
                        continue
                    X.append(flat_lms)
                    y.append(class_idx)
                    samples += 1
                    
        return np.array(X), np.array(y), classes
