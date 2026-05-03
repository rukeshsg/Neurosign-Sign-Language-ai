import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../models/history_entry.dart';
import '../../providers/history_provider.dart';
import '../../services/accessibility_service.dart';
import '../text_to_sign/text_to_sign_screen.dart';

class SpeechToTextScreen extends ConsumerStatefulWidget {
  const SpeechToTextScreen({super.key});

  @override
  ConsumerState<SpeechToTextScreen> createState() => _SpeechToTextScreenState();
}

class _SpeechToTextScreenState extends ConsumerState<SpeechToTextScreen> {
  String _transcript = '';
  bool _isListening = false;

  Future<void> _toggleListening() async {
    final service = ref.read(accessibilityServiceProvider);
    if (_isListening) {
      await service.stopListening();
      if (mounted) setState(() => _isListening = false);
      _saveTranscript();
      return;
    }

    setState(() => _isListening = true);
    await service.startListening((text) {
      if (mounted) setState(() => _transcript = text);
    });
  }

  void _saveTranscript() {
    final text = _transcript.trim();
    if (text.isEmpty) return;
    ref.read(historyProvider.notifier).addEntry(
          HistoryEntry(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            mode: ConversationMode.speechToText,
            title: text,
            subtitle: 'Speech transcript',
            createdAt: DateTime.now(),
          ),
        );
  }

  void _sendToTextToSign() {
    final text = _transcript.trim();
    if (text.isEmpty) return;
    _saveTranscript();
    Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => TextToSignScreen(initialText: text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Speech to Text')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? NeuroColors.darkPanel
                        : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.graphic_eq_rounded,
                              color: _isListening
                                  ? NeuroColors.success
                                  : NeuroColors.graphite),
                          const SizedBox(width: 8),
                          Text(
                              _isListening
                                  ? 'Listening live'
                                  : 'Ready to listen',
                              style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Expanded(
                        child: Text(
                          _transcript.isEmpty
                              ? 'Tap the microphone and start speaking.'
                              : _transcript,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: _transcript.isEmpty
                                    ? NeuroColors.graphite
                                    : null,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _toggleListening,
                      icon: Icon(_isListening
                          ? Icons.stop_rounded
                          : Icons.mic_rounded),
                      label: Text(
                          _isListening ? 'Stop Listening' : 'Start Listening'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filledTonal(
                    onPressed: _sendToTextToSign,
                    icon: const Icon(Icons.translate_rounded),
                    tooltip: 'Send to text to sign',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
