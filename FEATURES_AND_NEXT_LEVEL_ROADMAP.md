# Sign Language Assistant: Features and Next-Level Roadmap

## Overview

Sign Language Assistant is a mobile-first communication and accessibility system that helps convert sign language into text and speech, while also supporting reverse communication from text to sign. The system combines a Flutter mobile app, a FastAPI backend, computer vision, and machine learning models to create an interactive sign language assistance platform.

## What the system currently does

### 1. Sign-to-text recognition
- Captures camera frames from the mobile app
- Sends frames to the backend API
- Detects hands and extracts landmarks using MediaPipe
- Runs static ASL recognition for alphabet-style hand signs
- Applies smoothing and duplicate suppression before returning output
- Displays the recognized result as text in the mobile app

### 2. Text-to-speech support
- Reads recognized text aloud using the mobile app
- Helps non-signers understand the generated output quickly
- Improves accessibility and real-time communication

### 3. Text-to-sign conversion
- Accepts typed or spoken text from the user
- Splits text into words
- Checks whether the word exists in the WLASL vocabulary
- Returns either a word-level sign token or character-by-character fallback tokens
- Displays the token sequence in the mobile app

### 4. Speech-to-text input
- Lets the user speak into the mobile app
- Converts spoken words into text
- Passes the text into the text-to-sign flow

### 5. Static ASL model training
- Loads the ASL alphabet dataset
- Extracts normalized hand landmarks from images
- Trains a lightweight landmark-based classifier
- Saves the trained model for backend inference

### 6. Static ASL evaluation
- Runs the trained static ASL model against the test set
- Exports detailed row-by-row results
- Exports summary metrics such as:
  - exact-match accuracy
  - detection rate
  - per-class results

### 7. Baseline dynamic WLASL pipeline
- Loads WLASL videos
- Extracts sampled holistic features from sequences
- Trains a baseline dynamic classifier
- Saves the model for dynamic inference experiments

### 8. API layer
- Provides a health check endpoint
- Provides frame recognition endpoint
- Provides text-to-sign endpoint
- Exposes interactive API docs through Swagger UI

## Current project features

### Backend features
- FastAPI-based API service
- MediaPipe hand and holistic landmark extraction
- Static ASL inference pipeline
- Baseline dynamic WLASL inference path
- Model loading through environment-based config
- Training scripts for static and dynamic models
- Evaluation script for ASL test-set reporting
- Automated API tests

### Mobile app features
- Home screen with feature entry points
- Live recognition screen
- Text-to-sign screen
- Speech-to-text input
- Text-to-speech output
- API base URL override through `--dart-define`

### Data and ML features
- ASL alphabet dataset support
- WLASL vocabulary support
- Landmark normalization
- Prediction smoothing
- Duplicate suppression
- Report generation for model evaluation

## System flow

### Flow 1: Sign to text
1. User opens Live Recognition in the mobile app
2. Camera captures frames
3. Frame is sent to backend API
4. Backend extracts landmarks
5. Model predicts sign
6. Backend returns text result
7. Mobile app displays recognized text
8. User can optionally speak the result aloud

### Flow 2: Text to sign
1. User types text or uses speech input
2. Mobile app sends text to backend
3. Backend converts words into sign tokens
4. Mobile app displays the token sequence

### Flow 3: Model development
1. Dataset is loaded
2. Features are extracted
3. Model is trained
4. Model is evaluated
5. Model artifact is saved for runtime use

## Present limitations

- Static recognition still misses some ASL test-set samples
- Dynamic WLASL model is a baseline, not a production-quality recognizer
- Live mobile testing still depends on completing Flutter setup and runtime validation
- Text-to-sign currently uses token output, not sign animation or avatar rendering
- Learning mode and settings mode are only partially represented in the UI structure
- Mobile visual assets are placeholders

## New features that can take this project to the next level

### 1. Real sentence formation
- Join letter predictions into full words
- Add auto-spacing and punctuation
- Add simple grammar correction
- Add word suggestions for incomplete sign sequences

### 2. Better dynamic sign recognition
- Replace the baseline dynamic classifier with a stronger sequence model
- Use temporal transformers, LSTM, or TCN-based models
- Support continuous gesture streams instead of isolated sequences

### 3. Learning mode
- Show reference gestures
- Compare user gesture against target gesture
- Provide feedback such as hand angle, finger position, and timing
- Add practice sessions and quizzes

### 4. Sign animation and avatar output
- Replace text tokens with visual sign cards, GIFs, or animated 3D/avatar playback
- Make text-to-sign mode much more useful for real communication and learning

### 5. Conversation mode
- Create a two-way interface:
  - signer -> text/speech
  - speaker -> text/sign
- Add a conversation history panel
- Add turn-by-turn communication mode

### 6. Offline and edge inference
- Move lightweight inference to the mobile device using TensorFlow Lite
- Reduce latency
- Improve usability without constant backend dependency

### 7. Personalization
- Custom gesture training for a specific user
- Save preferences, history, and frequently used phrases
- Add profile-based adaptive recognition tuning

### 8. Multi-language output
- Translate recognized text into regional or international languages
- Support multilingual speech output

### 9. Analytics dashboard
- Recognition accuracy trends
- Most recognized signs
- Response time tracking
- User learning progress

### 10. Accessibility and usability upgrades
- Better large-text support
- Better microphone/camera permission handling
- High-contrast mode
- Low-network warning and retry states
- Clear offline/error feedback

### 11. Deployment-ready architecture
- Cloud-hosted backend
- Secure API configuration
- Remote mobile testing
- Shared access for demos, teachers, and evaluators

### 12. Real-world demo features
- Saved phrases
- Emergency quick-speak actions
- Education mode for classrooms
- Interpreter-assist mode for events or service counters

## Recommended next implementation order

### Phase 1: Product stability
- Finish full mobile runtime testing
- Fix any remaining Flutter runtime issues
- Improve static ASL accuracy
- Clean up mobile assets and app polish

### Phase 2: Stronger functionality
- Improve text-to-sign visual output
- Add sentence formation logic
- Improve dynamic WLASL recognition
- Add conversation mode

### Phase 3: Advanced value
- Add learning mode
- Add analytics and history
- Add multilingual output
- Add personalization and custom gestures

### Phase 4: Demo and deployment readiness
- Prepare hosted backend option
- Add production environment config
- Add final polished app branding and assets
- Validate app on emulator and physical device

## Why this project has strong potential

This project already has the foundation of a serious accessibility product:
- live computer vision
- model training pipeline
- API-based architecture
- mobile app interface
- speech input and output
- static and dynamic recognition direction

With improved mobile validation, better dynamic modeling, sign visualization, and conversation-friendly UX, this can grow from a good academic project into a strong real-world assistive communication system.
