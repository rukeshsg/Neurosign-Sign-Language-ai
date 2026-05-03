import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../models/history_entry.dart';
import '../../models/sign_token.dart';
import '../../providers/history_provider.dart';
import '../../services/accessibility_service.dart';
import '../../services/api_service.dart';

class TextToSignScreen extends ConsumerStatefulWidget {
  const TextToSignScreen({super.key, this.initialText});

  final String? initialText;

  @override
  ConsumerState<TextToSignScreen> createState() => _TextToSignScreenState();
}

class _TextToSignScreenState extends ConsumerState<TextToSignScreen> {
  late final TextEditingController _textController;
  List<SignToken> _signSequence = [];
  bool _isLoading = false;
  bool _isListening = false;
  int _currentSignIndex = 0;
  String? _error;

  static const _suggestions = [
    'hello',
    'thank you',
    'help',
    'yes',
    'no',
    'good morning'
  ];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText ?? '');
  }

  Future<void> _convertTextToSign() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _signSequence = [];
      _currentSignIndex = 0;
    });

    try {
      final sequence = await ref.read(apiServiceProvider).textToSign(text);
      if (!mounted) return;

      setState(() {
        _signSequence = sequence;
        _isLoading = false;
      });

      ref.read(historyProvider.notifier).addEntry(
            HistoryEntry(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              mode: ConversationMode.textToSign,
              title: text,
              subtitle: '${sequence.length} sign tokens',
              createdAt: DateTime.now(),
            ),
          );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error =
            'Could not reach the NeuroSign backend. Check the API URL and network.';
      });
    }
  }

  Future<void> _toggleListening() async {
    final stt = ref.read(accessibilityServiceProvider);
    if (_isListening) {
      await stt.stopListening();
      if (mounted) setState(() => _isListening = false);
      return;
    }

    setState(() => _isListening = true);
    await stt.startListening((text) {
      _textController.text = text;
      _textController.selection = TextSelection.collapsed(offset: text.length);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current =
        _signSequence.isEmpty ? null : _signSequence[_currentSignIndex];

    return Scaffold(
      appBar: AppBar(title: const Text('Text to Sign')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Text('Convert language into a clear sign sequence.',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            TextField(
              controller: _textController,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Type a phrase like "thank you" or "I need help"',
                suffixIcon: IconButton(
                  icon: Icon(
                      _isListening ? Icons.mic_off_rounded : Icons.mic_rounded),
                  tooltip: _isListening ? 'Stop listening' : 'Dictate text',
                  onPressed: _toggleListening,
                ),
              ),
              onSubmitted: (_) => _convertTextToSign(),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _suggestions
                  .map(
                    (text) => ActionChip(
                      label: Text(text),
                      onPressed: () {
                        _textController.text = text;
                        _convertTextToSign();
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _convertTextToSign,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.auto_awesome_rounded),
                label: Text(_isLoading ? 'Converting...' : 'Convert to Signs'),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 14),
              _StatusCard(
                  message: _error!,
                  icon: Icons.wifi_off_rounded,
                  isError: true),
            ],
            const SizedBox(height: 24),
            _SignDisplay(current: current),
            const SizedBox(height: 18),
            if (_signSequence.isNotEmpty)
              SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _signSequence.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final token = _signSequence[index];
                    final isCurrent = index == _currentSignIndex;
                    return ChoiceChip(
                      selected: isCurrent,
                      label: Text(token.value.toUpperCase()),
                      avatar: Icon(
                          token.isWord
                              ? Icons.sign_language_rounded
                              : Icons.abc_rounded,
                          size: 18),
                      onSelected: (_) =>
                          setState(() => _currentSignIndex = index),
                    );
                  },
                ),
              )
            else
              const _StatusCard(
                message:
                    'Converted signs will appear as word and alphabet tokens here.',
                icon: Icons.sign_language_rounded,
              ),
          ],
        ),
      ),
    );
  }
}

class _SignDisplay extends StatelessWidget {
  const _SignDisplay({required this.current});

  final SignToken? current;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? NeuroColors.darkPanel : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: NeuroColors.sage.withValues(alpha: isDark ? 0.10 : 0.08),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.sign_language_rounded,
              size: 92, color: NeuroColors.sage.withValues(alpha: 0.72)),
          const SizedBox(height: 18),
          Text(
            current?.value.toUpperCase() ?? 'READY',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .displayLarge
                ?.copyWith(color: NeuroColors.sage),
          ),
          const SizedBox(height: 8),
          Text(
            current == null
                ? 'Waiting for a phrase'
                : (current!.isWord ? 'Word sign' : 'Finger-spelling fallback'),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.message,
    required this.icon,
    this.isError = false,
  });

  final String message;
  final IconData icon;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isError ? NeuroColors.danger.withValues(alpha: 0.10) : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: isError ? NeuroColors.danger : NeuroColors.sage),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}
