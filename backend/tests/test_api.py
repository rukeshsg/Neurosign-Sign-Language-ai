import unittest
import base64
import sys
from pathlib import Path

import numpy as np
import cv2
from fastapi.testclient import TestClient

BACKEND_ROOT = Path(__file__).resolve().parents[1]
if str(BACKEND_ROOT) not in sys.path:
    sys.path.insert(0, str(BACKEND_ROOT))

from app.main import app

client = TestClient(app)

class TestSignLanguageAPI(unittest.TestCase):
    
    def setUp(self):
        # Create a dummy image (black square)
        img = np.zeros((100, 100, 3), dtype=np.uint8)
        _, buffer = cv2.imencode('.jpg', img)
        self.dummy_base64 = base64.b64encode(buffer).decode('utf-8')
        
    def test_health_check(self):
        response = client.get("/health")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json(), {"status": "healthy"})

    def test_recognize_frame_no_hand(self):
        # Sending a black image should result in 'no_hand' status
        response = client.post("/api/v1/recognize/frame", json={"image_base64": self.dummy_base64})
        self.assertEqual(response.status_code, 200)
        
        data = response.json()
        self.assertIn("status", data)
        self.assertEqual(data["status"], "no_hand")
        self.assertIn("latency_ms", data)
        
    def test_recognize_frame_invalid_base64(self):
        response = client.post("/api/v1/recognize/frame", json={"image_base64": "invalid_base64++"})
        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.json()["detail"], "Invalid base64 image payload.")
        
    def test_text_to_sign(self):
        response = client.post("/api/v1/text-to-sign", json={"text": "hello world"})
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertIn("sequence", data)
        self.assertEqual(data["sequence"][0], {"type": "word", "value": "hello"})
        self.assertEqual(data["sequence"][1], {"type": "char", "value": "W"})
        self.assertEqual(data["token_count"], len(data["sequence"]))

    def test_text_to_sign_requires_text(self):
        response = client.post("/api/v1/text-to-sign", json={"text": ""})
        self.assertEqual(response.status_code, 422)

    def test_text_to_sign_query_param(self):
        response = client.post("/api/v1/text-to-sign?text=help")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()["sequence"], [{"type": "word", "value": "help"}])

    def test_diagnostics(self):
        response = client.get("/api/v1/diagnostics")
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(data["status"], "ok")
        self.assertIn("asl_model_loaded", data)
        self.assertIn("wlasl_model_loaded", data)

if __name__ == '__main__':
    unittest.main()
