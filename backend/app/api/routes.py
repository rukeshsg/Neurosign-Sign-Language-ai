import base64
import binascii
import cv2
import time
import uuid
import logging
import re
import numpy as np
from fastapi import APIRouter, Body, HTTPException, Query
from pydantic import BaseModel, Field
from app.services.vision_service import VisionService
from app.services.model_service import SignLanguageModelManager

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

router = APIRouter()

# Initialize services
vision_service = VisionService()
model_manager = SignLanguageModelManager()

COMMON_SIGN_PHRASES = {
    "hello",
    "thank you",
    "please",
    "help",
    "yes",
    "no",
    "sorry",
    "good morning",
    "good night",
    "i love you",
}

class FrameRequest(BaseModel):
    image_base64: str = Field(..., min_length=8)


class TextToSignRequest(BaseModel):
    text: str = Field(..., min_length=1)


def _decode_base64_image(image_base64: str) -> np.ndarray:
    payload = image_base64.split(",", 1)[1] if "," in image_base64 else image_base64

    try:
        img_data = base64.b64decode(payload, validate=True)
    except (binascii.Error, ValueError) as exc:
        raise HTTPException(status_code=400, detail="Invalid base64 image payload.") from exc

    np_arr = np.frombuffer(img_data, np.uint8)
    img_np = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)
    if img_np is None or img_np.size == 0:
        raise HTTPException(status_code=400, detail="Invalid image format.")

    return img_np


def _normalize_text(text: str) -> list[str]:
    return re.findall(r"[a-z0-9']+", text.lower())


def _build_text_to_sign_sequence(input_text: str) -> list[dict[str, str]]:
    tokens = _normalize_text(input_text)
    sequence: list[dict[str, str]] = []
    index = 0

    while index < len(tokens):
        matched_phrase = ""
        for width in range(min(3, len(tokens) - index), 0, -1):
            phrase = " ".join(tokens[index:index + width])
            if phrase in model_manager.wlasl_vocab or phrase in COMMON_SIGN_PHRASES:
                matched_phrase = phrase
                break

        if matched_phrase:
            sequence.append({"type": "word", "value": matched_phrase})
            index += len(matched_phrase.split())
            continue

        word = tokens[index]
        for char in word:
            if char.upper() in model_manager.asl_classes:
                sequence.append({"type": "char", "value": char.upper()})
            else:
                sequence.append({"type": "unknown", "value": char})
        index += 1

    return sequence

@router.post("/recognize/frame")
async def recognize_frame(request: FrameRequest):
    """
    Process a single frame for static ASL alphabet recognition.
    """
    req_id = str(uuid.uuid4())[:8]
    start_time = time.time()
    
    try:
        img_np = _decode_base64_image(request.image_base64)

        hand_landmarks = vision_service.process_frame_for_hands(img_np)
        holistic_features = vision_service.process_frame_holistic(img_np)
        result = model_manager.process_frame(hand_landmarks, holistic_features=holistic_features)
        
        latency_ms = round((time.time() - start_time) * 1000, 2)
        logger.info(f"[{req_id}] Frame processed in {latency_ms}ms | Status: {result['status']} | Output: {result.get('text', '')}")
        
        result["latency_ms"] = latency_ms
        return result

    except HTTPException as he:
        raise he
    except Exception as e:
        logger.error(f"[{req_id}] Server error: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/text-to-sign")
async def text_to_sign(
    payload: TextToSignRequest | None = Body(default=None),
    text: str | None = Query(default=None),
):
    """
    Convert text to a sequence of sign identifiers.
    """
    req_id = str(uuid.uuid4())[:8]
    input_text = (payload.text if payload is not None else text or "").strip()
    if not input_text:
        raise HTTPException(status_code=400, detail="Text input is required.")

    logger.info(f"[{req_id}] Text-to-sign requested for: '{input_text}'")
    
    sequence = _build_text_to_sign_sequence(input_text)
    return {"sequence": sequence, "token_count": len(sequence)}


@router.get("/diagnostics")
async def diagnostics():
    """
    Report model and runtime readiness for local mobile testing.
    """
    return {
        "status": "ok",
        "asl_model_loaded": model_manager.asl_model is not None,
        "asl_model_path": str(model_manager.asl_model_path),
        "asl_model_exists": model_manager.asl_model_path.exists(),
        "wlasl_model_loaded": model_manager.wlasl_model is not None,
        "wlasl_model_path": str(model_manager.wlasl_model_path),
        "wlasl_model_exists": model_manager.wlasl_model_path.exists(),
        "wlasl_sequence_length": model_manager.wlasl_sequence_length,
        "static_classes": len(model_manager.asl_classes),
        "dynamic_vocab_size": len(model_manager.wlasl_vocab),
    }


def shutdown_services():
    vision_service.close()
