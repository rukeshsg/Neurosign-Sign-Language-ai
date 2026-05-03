import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

final accessibilityServiceProvider = Provider<AccessibilityService>((ref) {
  return AccessibilityService();
});

class AccessibilityService {
  final FlutterTts _flutterTts = FlutterTts();
  final SpeechToText _speechToText = SpeechToText();
  bool _isSttInitialized = false;
  late final Future<void> _setupFuture;

  AccessibilityService() {
    _setupFuture = _initialize();
  }

  Future<void> _initialize() async {
    await _initTts();
    await _initStt();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _initStt() async {
    _isSttInitialized = await _speechToText.initialize();
  }

  Future<void> speak(String text) async {
    await _setupFuture;
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  Future<void> stopSpeaking() async {
    await _setupFuture;
    await _flutterTts.stop();
  }

  Future<void> startListening(ValueChanged<String> onResult) async {
    await _setupFuture;
    if (_isSttInitialized) {
      await _speechToText.listen(onResult: (result) {
        onResult(result.recognizedWords);
      });
    }
  }

  Future<void> stopListening() async {
    await _setupFuture;
    if (_speechToText.isListening) {
      await _speechToText.stop();
    }
  }
}
