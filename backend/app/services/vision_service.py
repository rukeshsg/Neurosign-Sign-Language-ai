import cv2
import mediapipe as mp
import numpy as np


class VisionService:
    HOLISTIC_FEATURE_LENGTH = (33 * 4) + (21 * 3) + (21 * 3)

    def __init__(self):
        self.mp_hands = mp.solutions.hands
        self.hands = self.mp_hands.Hands(
            static_image_mode=True,
            max_num_hands=2,
            min_detection_confidence=0.5,
            min_tracking_confidence=0.5
        )
        self.mp_holistic = mp.solutions.holistic
        self.holistic = self.mp_holistic.Holistic(
            min_detection_confidence=0.5,
            min_tracking_confidence=0.5
        )

    def process_frame_for_hands(self, image_np: np.ndarray):
        """
        Process the frame to extract hand landmarks.
        Returns a list of landmarks for up to 2 hands.
        """
        image_rgb = cv2.cvtColor(image_np, cv2.COLOR_BGR2RGB)
        results = self.hands.process(image_rgb)
        
        hand_landmarks = []
        if results.multi_hand_landmarks:
            for hand_lms in results.multi_hand_landmarks:
                landmarks = [[lm.x, lm.y, lm.z] for lm in hand_lms.landmark]
                hand_landmarks.append(landmarks)
                
        return hand_landmarks

    @staticmethod
    def normalize_hand_landmarks(landmarks):
        """
        Normalize hand landmarks relative to the wrist and scale them so the model
        is less sensitive to translation and hand size.
        """
        points = np.asarray(landmarks, dtype=np.float32)
        if points.size == 0:
            return np.empty(0, dtype=np.float32)

        wrist = points[0]
        relative = points - wrist
        scale = np.max(np.linalg.norm(relative[:, :2], axis=1))
        if scale > 0:
            relative = relative / scale

        return relative.flatten()

    def process_frame_holistic(self, image_np: np.ndarray):
        """
        Extract holistic features (pose + hands + face).
        Useful for WLASL dynamic gestures.
        """
        image_rgb = cv2.cvtColor(image_np, cv2.COLOR_BGR2RGB)
        results = self.holistic.process(image_rgb)
        
        # Flattened landmarks for easier ML processing
        # Pose: 33 landmarks, Face: 468, Hands: 21 each
        
        def extract_pose(landmark_list):
            if landmark_list:
                return np.array([[lm.x, lm.y, lm.z, lm.visibility] for lm in landmark_list.landmark]).flatten()
            return None

        def extract_hand(landmark_list):
            if landmark_list:
                return np.array([[lm.x, lm.y, lm.z] for lm in landmark_list.landmark]).flatten()
            return None

        pose = extract_pose(results.pose_landmarks)
        lh = extract_hand(results.left_hand_landmarks)
        rh = extract_hand(results.right_hand_landmarks)
        
        # For simplicity, if not found, use zeros
        pose = pose if pose is not None else np.zeros(33 * 4)
        lh = lh if lh is not None else np.zeros(21 * 3)
        rh = rh if rh is not None else np.zeros(21 * 3)
        
        # Concatenate features
        return np.concatenate([pose, lh, rh])

    def close(self):
        self.hands.close()
        self.holistic.close()
