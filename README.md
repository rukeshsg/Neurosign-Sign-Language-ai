# NeuroSign - AI Powered Sign Language Recognition

> Breaking communication barriers with AI-powered Sign Language Recognition, Speech Assistance, and Real-time Translation.

![Python](https://img.shields.io/badge/Python-3.11-blue)
![FastAPI](https://img.shields.io/badge/FastAPI-Backend-green)
![Flutter](https://img.shields.io/badge/Flutter-Mobile-blue)
![MediaPipe](https://img.shields.io/badge/MediaPipe-Hand%20Tracking-orange)
![Scikit-Learn](https://img.shields.io/badge/Scikit--Learn-ML-yellow)
![License](https://img.shields.io/badge/License-MIT-success)

---

## Overview

NeuroSign is an AI-powered Sign Language Communication System designed to help bridge the communication gap between deaf or speech-impaired individuals and others.

The application combines Computer Vision, Machine Learning, Natural Language Processing, and Mobile Development to recognize hand gestures in real time, convert them into text and speech, and provide an interactive learning experience.

The project consists of a FastAPI backend, a Flutter mobile application, and custom machine learning models trained on sign language datasets.

---

## Features

- Real-time Sign Language Recognition
- Sign to Text Conversion
- Sign to Speech Conversion
- Text to Sign Translation
- Speech to Text Support
- Beginner Learning & Practice Module
- Conversation History
- Confidence Score Prediction
- AI-powered Gesture Recognition
- FastAPI REST APIs
- Cross-platform Flutter Mobile App

---

## Tech Stack

### Backend
- Python
- FastAPI
- OpenCV
- MediaPipe
- Scikit-Learn
- Pydantic

### Mobile
- Flutter
- Riverpod
- Dio
- Camera
- Flutter TTS
- Speech to Text

### Machine Learning
- MediaPipe Hand Landmarks
- Landmark Feature Extraction
- Random Forest Classifier
- Static ASL Recognition
- Dynamic Sign Recognition (WLASL)

---

## Project Structure

```text
NeuroSign/
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

---

## How It Works

1. Capture hand gestures using the mobile camera.
2. MediaPipe detects hand landmarks.
3. Extract landmark features.
4. AI model predicts the sign.
5. Convert prediction into text.
6. Optionally convert text into speech.
7. Display the result in real time.

---

## Installation

### Clone Repository

```bash
git clone https://github.com/rukeshsg/Neurosign-Sign-Language-ai.git

cd Neurosign-Sign-Language-ai
```

### Backend

```bash
cd backend

python -m venv .venv

pip install -r requirements.txt

uvicorn app.main:app --reload
```

### Mobile

```bash
cd mobile

flutter pub get

flutter run
```

---

## API Endpoints

| Method | Endpoint | Description |
|---------|----------|-------------|
| GET | /health | Health Check |
| POST | /recognize/frame | Recognize Sign |
| POST | /text-to-sign | Convert Text to Sign |

---

## Datasets

- ASL Alphabet Dataset
- WLASL Dataset

---

## Future Improvements

- Sentence Recognition
- Transformer-based Sign Recognition
- Multi-language Support
- Indian Sign Language (ISL)
- Cloud Model Deployment
- User Authentication
- Personalized Learning Progress

