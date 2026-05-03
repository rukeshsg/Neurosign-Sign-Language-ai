<<<<<<< HEAD
# NeuroSign

NeuroSign is a mobile-first sign-language communication product with a Flutter client and a FastAPI backend. It supports live sign recognition, sign-to-text, sign-to-speech, text-to-sign, speech-to-text, conversation history, beginner learning, and local ML training/evaluation workflows.

See [docs/NEUROSIGN_PRODUCT_UPGRADE.md](docs/NEUROSIGN_PRODUCT_UPGRADE.md) for the product roadmap, brand system, current features, and mobile testing notes.

## Project structure

```text
sign language project/
|- backend/                  FastAPI API, model code, training script, tests
|  |- app/
|  |  |- api/                HTTP routes
|  |  |- core/               Configuration and path resolution
|  |  |- ml/                 Dataset loading helpers
|  |  `- services/           MediaPipe and model inference services
|  |- models/                Trained static classifier artifacts
|  |- scripts/               Model training entry point
|  `- tests/                 API tests
|- datasets/
|  |- ASL_Alphabet_dataset/  Static alphabet dataset
|  `- WLASL_dataset/         Word-level sign video vocabulary
|- docs/                     PRD, UX, and tech stack notes
`- mobile/                   Flutter application
```

## Features

- Static ASL alphabet recognition from camera images
- Text output with duplicate suppression and confidence smoothing
- Text-to-speech from the Flutter client
- Text-to-sign phrase lookup with finger-spelling fallback
- Speech-to-text input on the mobile side
- Conversation history, learning/practice, settings, light mode, and dark mode
- Training script for a compact sklearn landmark classifier
- Batch ASL evaluation report generation
- Baseline dynamic WLASL training and inference path

## Tech stack

- Backend: FastAPI, MediaPipe, OpenCV, scikit-learn, Pydantic
- Mobile: Flutter, Riverpod, Dio, camera, flutter_tts, speech_to_text
- Data: ASL Alphabet dataset and WLASL dataset included in `datasets/`

## Setup

### 1. Backend environment

```powershell
cd backend
py -3.11 -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

### 2. Train the static ASL model

```powershell
python scripts\train_asl.py --max-samples-per-class 80
```

This saves `backend/models/asl_static.joblib`.

### 3. Run backend API

```powershell
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Health checks:

- `GET /health`
- `GET /api/v1/diagnostics`
- `POST /api/v1/recognize/frame`
- `POST /api/v1/text-to-sign`

### 4. Run tests

```powershell
python -m pytest tests -q
```

### 5. Generate an ASL evaluation report

```powershell
python scripts\evaluate_asl.py --output-dir reports
```

This writes:

- `backend/reports/asl_evaluation_summary.json`
- `backend/reports/asl_evaluation_rows.csv`

### 6. Train a baseline dynamic WLASL model

```powershell
python scripts\train_wlasl.py --max-classes 20 --max-samples-per-class 8
```

For a focused word subset:

```powershell
python scripts\train_wlasl.py --include-classes "hello,help,please,thanks,yes,no"
```

### 7. Mobile app

Install Flutter separately, then:

```powershell
cd ..\mobile
flutter pub get
flutter analyze
flutter test
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

For a physical Android device, run the backend with `--host 0.0.0.0` and replace `10.0.2.2` with your PC IP.

To build a debug APK:

```powershell
flutter build apk --debug --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

## API usage

### Recognize a frame

```json
POST /api/v1/recognize/frame
{
  "image_base64": "<base64 jpeg>"
}
```

Response example:

```json
{
  "text": "A",
  "confidence": 0.94,
  "status": "new_prediction",
  "latency_ms": 58.21
}
```

### Convert text to sign tokens

```json
POST /api/v1/text-to-sign
{
  "text": "hello world"
}
```

## Known limitations

- Dynamic WLASL performance depends heavily on how many classes and videos you choose to train; the baseline pipeline is intentionally lightweight.
- Mobile launcher and splash image generation still need real PNG assets in `mobile/assets/`.
- The committed `backend/venv` is machine-specific and should not be reused.
=======
# Neurosign-Sign-Language-ai
AI-powered Sign Language to Text &amp; Speech Communication System using Computer Vision and Deep Learning
>>>>>>> 8801176541974f7d6c82447686b16baf65196a5c
