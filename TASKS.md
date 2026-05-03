# Project Task List

## Current status

- [x] Static ASL backend review and fixes completed
- [x] Static ASL training pipeline added
- [x] Backend API tests passing
- [x] Static ASL batch evaluation report for the test set
- [x] Dynamic WLASL recognition pipeline implementation
- [x] Full mobile app static validation and debug APK build on this Flutter setup
- [ ] Full mobile app validation on a real device

## Next tasks

### 1. Add batch evaluation script for the ASL test set and export metrics
- [x] Create a script that runs all images in `datasets/ASL_Alphabet_dataset/asl_alphabet_test/asl_alphabet_test`
- [x] Record predicted label, confidence, and status for each image
- [x] Export summary metrics such as detection rate, exact-match accuracy, and per-class results
- [x] Save results to a CSV or JSON report under `backend/reports/`

### 2. Build the missing dynamic WLASL model path
- [x] Add a WLASL sequence data loader
- [x] Define a dynamic gesture training pipeline
- [x] Train and save a first dynamic model artifact
- [x] Connect dynamic inference into the backend routing/model manager
- [x] Add tests for dynamic text output behavior

### 3. Test the full working mobile app
- [x] Install and verify Flutter SDK on this machine
- [x] Run `flutter pub get`
- [x] Run `flutter analyze`
- [x] Run `flutter test`
- [x] Build Android debug APK
- [ ] Run the app on an emulator or physical device
- [ ] Validate backend connectivity from the device
- [ ] Test live camera capture -> backend recognition -> text output
- [ ] Test text-to-sign flow
- [ ] Test text-to-speech flow
- [ ] Test speech-to-text flow
- [ ] Check camera permissions, failure states, and network error handling
- [ ] Tune frame rate, payload size, and retry behavior from a real device pass
- [ ] Document final mobile test results in the README or a report file
