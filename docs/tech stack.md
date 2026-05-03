# Tech Stack Document
## Sign Language to Text & Speech Mobile App

**Version:** 1.0  
**Status:** Draft  
**Project Type:** Final Year Project  
**Platform:** Mobile-first with AI backend support

---

## 1. Purpose of This Document

This document defines the recommended technology stack for a mobile application that converts sign language to text and speech, supports text/speech to sign, and includes advanced features such as real-time recognition, learning mode, analytics, custom gestures, and professional UI/UX.

The stack is selected for three goals:
1. Strong mobile experience.
2. Reliable AI and computer vision performance.
3. A realistic implementation path for a final-year project.

---

## 2. Recommended Architecture at a Glance

### Recommended Approach
Use a **hybrid mobile + backend architecture**:
- The **mobile app** handles camera access, UI, speech playback, speech input, and user interaction.
- The **Python backend** handles hand tracking, gesture inference, sentence processing, and heavier AI tasks.
- The **database / sync layer** stores user preferences, history, and optional analytics.

### High-Level Flow
```text
Flutter Mobile App
  → Camera Frame / Image Upload
  → FastAPI Backend
  → MediaPipe + TensorFlow / TensorFlow Lite
  → Text / Sentence Output
  → Speech + UI Feedback
```

This architecture is the best fit for a mobile project because it keeps the app responsive while avoiding the performance and debugging difficulties of running every AI task directly on the phone.

---

## 3. Final Recommended Stack

## 3.1 Mobile Frontend
### Primary Choice: Flutter + Dart
Flutter is the main frontend framework for this project.

#### Why Flutter fits this project
- One codebase for Android and iOS.
- Strong support for beautiful UI and smooth animations.
- Good camera, audio, and networking integration.
- Excellent for building a polished product-style interface.
- Built around widgets, which makes it easy to create reusable UI components.
- Designed for cross-platform apps from a single codebase.

#### Why it is better here than native Android only
- Faster development.
- Easier to maintain.
- Better for presenting a polished, consistent UI.
- Good choice when the goal is a strong demo and final-year submission.

#### Flutter UI approach
Use:
- Material 3 components
- Custom cards and panels
- Dark mode first design
- Smooth transitions and microinteractions
- Responsive layouts for different screen sizes

---

## 3.2 Camera and Video Input
### Primary Choice: `camera` package
The Flutter `camera` plugin is the main camera solution.

#### Why use it
- Supports camera preview.
- Can capture images and video.
- Can stream image buffers to Dart, which is useful for recognition pipelines.

#### Use cases in this project
- Live sign recognition from the camera.
- Frame capture for sending to the backend.
- Video upload or video processing mode.

### Optional enhancement
If you want a more customizable camera UI later, you can use a more advanced camera wrapper, but the base `camera` package is the safest starting point.

---

## 3.3 State Management
### Recommended Choice: Riverpod
Use Riverpod to manage app state.

#### Why Riverpod
- Better structure for large Flutter apps.
- Works well with asynchronous data.
- Keeps camera state, recognition state, settings, and history organized.
- Scales well as the project grows.

#### What it manages
- Camera status
- Recognition status
- Selected language
- Theme mode
- Speech playback state
- User history
- API loading/error states

### Alternative
Provider is simpler, but Riverpod is a stronger choice for a large final-year project with multiple screens and async features.

---

## 3.4 API Communication
### Recommended Choice: Dio
Use Dio for network requests between Flutter and FastAPI.

#### Why Dio
- Handles HTTP requests cleanly.
- Supports interceptors, timeouts, request cancellation, file upload, and response handling.
- Better suited than a basic HTTP client when the app grows.

#### Where Dio is used
- Uploading gesture frames to the backend.
- Sending text for prediction or translation.
- Requesting processed recognition results.
- Downloading model or configuration updates if needed.

---

## 3.5 Speech Output
### Recommended Choice: flutter_tts
Use `flutter_tts` for text-to-speech playback inside the mobile app.

#### Why flutter_tts
- Easy integration with Flutter.
- Supports multiple mobile platforms.
- Good for speaking recognized text instantly.
- Gives the app a practical accessibility feature without extra backend load.

#### Use cases
- Speak recognized sign text.
- Read typed text aloud.
- Play learning feedback or accessibility prompts.

---

## 3.6 Speech Input
### Recommended Choice: speech_to_text
Use `speech_to_text` for voice input.

#### Why speech_to_text
- Exposes device speech recognition in Flutter.
- Suitable for short commands and phrases.
- Useful for the reverse communication mode.

#### Use cases
- Convert spoken input into text.
- Feed the text into the sign display mode.
- Allow hands-free interaction in the app.

---

## 3.7 Local Storage and Preferences
### Recommended Choice: shared_preferences + path_provider
Use both depending on the data type.

#### shared_preferences
Use for:
- Theme mode
- Language choice
- Voice settings
- Confidence threshold
- Last selected screen or mode

#### path_provider
Use for:
- Saving local files
- Storing exported sessions
- Keeping offline logs or sample data files

#### Why this combination
- `shared_preferences` is simple for settings.
- `path_provider` helps the app find filesystem locations when saving files locally.
- Together they cover lightweight persistent storage without adding complexity.

---

## 3.8 Authentication and Cloud Sync
### Recommended Choice: Firebase
Use Firebase only where cloud support adds real value.

#### Suggested Firebase services
- Firebase Authentication: user login and profile access
- Cloud Firestore: session history, saved gestures, and user data
- Cloud Storage: optional media or uploaded samples
- Firebase Analytics: usage and session insights

#### Why Firebase fits this project
- It gives hosted backend services with less setup.
- It works well with Flutter.
- It is useful for sync, profiles, and optional analytics.
- It keeps the project professional without requiring a complex custom database server for everything.

#### Best practice
Do not make Firebase mandatory for basic recognition. The app should still work in a local or limited mode when possible.

---

## 3.9 Backend API
### Primary Choice: FastAPI
Use FastAPI as the Python backend service.

#### Why FastAPI
- Modern and fast API framework.
- Built for type-hinted Python code.
- Good support for async endpoints.
- Very clean for AI service design.
- Easy to build image upload endpoints, prediction endpoints, and history APIs.

#### Why it is ideal for this project
- Python is still the best environment for model inference and computer vision.
- FastAPI gives a clean bridge between Flutter and the AI layer.
- It keeps the project modular and easier to debug.

#### Typical backend endpoints
- `/recognize` → gesture recognition
- `/translate` → text processing or language conversion
- `/custom-gesture` → user training samples
- `/history` → session sync and logs
- `/health` → service status

---

## 3.10 Computer Vision
### Primary Choice: MediaPipe + OpenCV
Use MediaPipe for hand and body landmarks, and OpenCV for frame operations.

#### Why MediaPipe
- MediaPipe Hand Landmarker detects hand landmarks.
- It supports real-time hand tracking.
- It works with image input and continuous streams.
- It can detect multiple hands and returns landmark information.
- The Holistic Landmarker can combine pose, face, and hand landmarks when you want more advanced gesture support.

#### Why OpenCV
- Great for preprocessing frames.
- Useful for resizing, cropping, filtering, and image enhancement.
- Helps make the pipeline more stable before inference.

#### Use cases
- Live hand landmark extraction.
- Gesture frame preprocessing.
- Motion smoothing and frame cleanup.
- Optional full-body or face-assisted gesture expansion later.

---

## 3.11 Machine Learning
### Primary Choice: TensorFlow
Use TensorFlow for training and inference of gesture models.

#### Why TensorFlow
- Strong support for mobile, desktop, web, and cloud deployment.
- Good ecosystem for model training and export.
- Works well with CNN-based static gesture recognition.
- Can also support sequence-based models for dynamic gestures.

#### Model strategy
- **CNN** for static gestures like alphabets and numbers.
- **LSTM / sequence model** for moving signs or word sequences.
- **Context model** for sentence correction and prediction.

#### Why TensorFlow is a good fit for a mobile project
- The model can be trained in Python and then deployed in a mobile-friendly form.
- TensorFlow supports mobile deployment through TensorFlow Lite.

---

## 3.12 Mobile Deployment of AI
### Optional / Advanced Choice: TensorFlow Lite
Use TensorFlow Lite if you want part of the recognition to run on-device.

#### Why TensorFlow Lite
- Smaller and more mobile-friendly than full TensorFlow.
- Better for lightweight inference on phones.
- Useful for offline or low-latency mode.

#### Best use in this project
- Simple gestures can run on-device.
- Complex gesture or sentence logic can stay on the backend.

#### Why not rely only on on-device ML
- Mobile-only ML can become hard to debug.
- Model conversion and optimization add risk.
- Performance may vary by device.
- A hybrid system is usually safer for a final-year project.

---

## 4. Suggested Stack by Module

### 4.1 User Interface Module
- Flutter
- Dart
- Material 3
- Riverpod
- Animation widgets

### 4.2 Camera Module
- camera
- image buffer streaming

### 4.3 Gesture Recognition Module
- MediaPipe Hand Landmarker
- MediaPipe Holistic Landmarker
- OpenCV
- TensorFlow

### 4.4 API Module
- FastAPI
- async endpoints
- request validation
- file upload handling

### 4.5 Speech Module
- flutter_tts
- speech_to_text

### 4.6 Storage Module
- shared_preferences
- path_provider
- Firebase Firestore
- Firebase Authentication
- Firebase Storage

### 4.7 Networking Module
- Dio

---

## 5. Recommended Stack Variants

## Variant A: Best Overall Recommendation
### Flutter + FastAPI + MediaPipe + TensorFlow + Firebase

#### Why this is the best choice
- Strong mobile UI.
- Strong AI backend.
- Easy to explain in viva.
- Good balance of difficulty and quality.
- Best chance of finishing with a polished result.

#### Ideal for
- Final-year project.
- Professional-looking demo.
- Advanced UI/UX.
- Real-time recognition with future scalability.

---

## Variant B: Mostly On-Device Mobile AI
### Flutter + TensorFlow Lite + MediaPipe + Local Storage

#### Why choose it
- More offline capability.
- Lower dependency on backend.
- Good for simple demos.

#### Why it is not the first choice
- Harder to tune.
- More device-specific issues.
- Less flexible for heavy models or sentence processing.

---

## Variant C: Heavy Cloud-Driven Model
### Flutter + FastAPI + Cloud AI + Firebase

#### Why choose it
- Good for scale.
- Easy to update models centrally.

#### Why it is not the first choice
- Strong dependency on network.
- More infrastructure complexity.
- Less ideal for offline scenarios.

---

## 6. Why This Stack Fits Your Project Need

This project needs more than just a basic sign detection demo. It needs:
- A premium mobile interface
- Real-time camera interaction
- AI-assisted recognition
- Speech output
- Reverse sign display
- Learning and analytics features

The recommended stack supports all of those requirements while keeping the build realistic for a student project.

### Key reasons this stack is strong
- **Flutter** gives a professional mobile UI.
- **FastAPI** gives a clean AI backend.
- **MediaPipe** gives real-time hand tracking.
- **TensorFlow** gives custom model training.
- **Firebase** gives optional sync and storage.
- **flutter_tts** and **speech_to_text** cover accessibility features.

---

## 7. Feature-to-Tech Mapping

| Feature | Recommended Tech |
|---|---|
| Camera preview | Flutter camera package |
| Hand tracking | MediaPipe Hand Landmarker |
| Full-body gesture support | MediaPipe Holistic Landmarker |
| Gesture classification | TensorFlow model |
| Frame preprocessing | OpenCV |
| API communication | Dio + FastAPI |
| Text-to-speech | flutter_tts |
| Speech-to-text | speech_to_text |
| Settings storage | shared_preferences |
| File storage | path_provider |
| History sync | Firebase Firestore |
| Login / profiles | Firebase Authentication |
| Optional media storage | Firebase Storage |
| App state management | Riverpod |

---

## 8. Recommended Development Stack for the Final Build

### Must-Have
- Flutter
- FastAPI
- MediaPipe
- TensorFlow
- OpenCV
- Riverpod
- camera
- Dio
- flutter_tts
- speech_to_text
- shared_preferences

### Should-Have
- Firebase Authentication
- Firestore
- path_provider
- TensorFlow Lite for select lightweight inference

### Nice-to-Have
- Firebase Storage
- Analytics dashboard sync
- Offline caching
- Custom gesture training flow

---

## 9. What Not to Overcomplicate

To keep the project realistic:
- Do not try to do all AI directly on mobile from day one.
- Do not build every feature as cloud-only.
- Do not use too many storage systems.
- Do not use a framework that makes the UI look generic.

The safest approach is:
- Flutter for the app.
- FastAPI for recognition.
- MediaPipe + TensorFlow for vision and ML.
- Firebase only where it adds real value.

---

## 10. Final Recommendation

### Best Stack for This Project
**Flutter + FastAPI + MediaPipe + TensorFlow + OpenCV + Firebase + Riverpod**

### Why this is the best fit
- Professional mobile experience.
- Advanced AI capability.
- Strong real-time features.
- Good balance between performance and complexity.
- Excellent for a final-year project presentation.

### Final opinion
This stack gives you the best chance of building something that looks modern, works reliably, and is impressive in both demo and viva.
