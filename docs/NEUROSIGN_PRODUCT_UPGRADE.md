# NeuroSign Product Upgrade

## Brand Identity

NeuroSign is a premium sign-language communication assistant for live recognition, speech, text conversion, learning, and conversation support.

Brand mood:

- Calm, intelligent, accessible, and trustworthy.
- Mint and sage green as the primary identity.
- Soft white cards in light mode and deep charcoal panels in dark mode.
- Rounded surfaces, gentle depth, clear typography, and generous spacing.

Core palette:

- Mint background: `#D1EADE`
- Primary sage: `#44976E`
- Deep sage: `#1F6D49`
- Charcoal text: `#17212A`
- Dark base: `#0F1714`
- Dark panel: `#182B24`
- Pastel support colors: blush, butter, sky, and soft mint.

Logo concept:

- A hand base represents sign language.
- A neural brain/circuit motif represents intelligence.
- A signal wave represents speech, communication, and live recognition.
- The Flutter app currently renders the logo as a scalable custom painter for onboarding, header, and compact mark use.

## Current Features

- NeuroSign onboarding with brand mark and CTA.
- Home dashboard with feature cards.
- Live Recognition screen with camera preview, recognition status, recognized text, speech playback, mute, clear, delete, and camera flip controls.
- Text to Sign screen with typed input, speech dictation, quick phrase chips, tokenized output, and finger-spelling fallback.
- Speech to Text screen with live transcript and send-to-text-to-sign flow.
- History screen with search and mode filters.
- Learning screen with beginner signs and practice progress.
- Settings screen with theme mode, large text, API base URL, permissions guidance, and model info.
- Light and dark theme support.
- Local persistent settings and history.
- FastAPI health, diagnostics, frame recognition, and text-to-sign endpoints.
- ASL static model loading and WLASL dynamic model path support.
- ASL batch evaluation report support.

## Next-Level Feature Ideas

- Real animated sign avatar for text-to-sign output.
- Practice feedback using user camera pose comparison.
- Account sync and cloud history.
- Emergency phrase mode with one-tap cards.
- Offline ASL static inference on-device.
- Personalized smoothing thresholds per user.
- Class-wise learning recommendations from failed predictions.
- In-app model diagnostics and backend connectivity test.
- Multi-language speech/text support.
- Teacher/admin dashboard for learning progress.

## ML Pipeline Notes

- Treat the current WLASL model as a baseline proof of pipeline only.
- Expand training to the full dataset before claiming production accuracy.
- Add train/validation/test splits with signer/video leakage checks.
- Save only the best validation model.
- Export accuracy, precision, recall, F1, confusion matrix, per-class metrics, and failure examples.
- Track baseline vs improved architecture results honestly.

## Local Mobile Testing

Emulator API URL:

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

Physical Android phone API URL:

```powershell
flutter run --dart-define=API_BASE_URL=http://YOUR_PC_IP:8000/api/v1
```

Use `0.0.0.0` for the backend host when testing from a physical phone:

```powershell
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## Verification

- Backend tests: `7 passed`
- Flutter analyzer: no issues found
- Flutter widget test: passed
- Android debug APK: built successfully at `mobile/build/app/outputs/flutter-apk/app-debug.apk`
