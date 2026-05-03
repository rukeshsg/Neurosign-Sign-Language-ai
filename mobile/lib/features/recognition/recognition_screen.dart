import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../models/history_entry.dart';
import '../../providers/history_provider.dart';
import '../../providers/recognition_provider.dart';
import '../../services/accessibility_service.dart';

class RecognitionScreen extends ConsumerStatefulWidget {
  const RecognitionScreen({super.key});

  @override
  ConsumerState<RecognitionScreen> createState() => _RecognitionScreenState();
}

class _RecognitionScreenState extends ConsumerState<RecognitionScreen> {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isCapturingFrame = false;
  bool _muted = false;
  int _cameraIndex = 0;
  Timer? _captureTimer;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera([int index = 0]) async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        ref.read(recognitionProvider.notifier).setError();
        return;
      }

      await _cameraController?.dispose();
      _cameraIndex = index.clamp(0, _cameras.length - 1);
      _cameraController = CameraController(
        _cameras[_cameraIndex],
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup:
            Platform.isIOS ? ImageFormatGroup.bgra8888 : ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() => _isCameraInitialized = true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isCameraInitialized = false);
      ref.read(recognitionProvider.notifier).setError();
    }
  }

  Future<void> _flipCamera() async {
    if (_cameras.length < 2) return;
    await _stopStreaming(saveHistory: false);
    setState(() => _isCameraInitialized = false);
    await _initCamera((_cameraIndex + 1) % _cameras.length);
  }

  Future<void> _captureAndSendFrame() async {
    if (!_isCameraInitialized ||
        _cameraController == null ||
        _isCapturingFrame ||
        !mounted ||
        !ref.read(recognitionProvider).isDetecting) {
      return;
    }

    _isCapturingFrame = true;
    try {
      final picture = await _cameraController!.takePicture();
      final bytes = await picture.readAsBytes();
      await ref
          .read(recognitionProvider.notifier)
          .processFrame(base64Encode(bytes));

      final file = File(picture.path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      if (mounted) ref.read(recognitionProvider.notifier).setError();
      await _stopStreaming(saveHistory: false);
    } finally {
      _isCapturingFrame = false;
    }
  }

  Future<void> _startStreaming() async {
    if (!_isCameraInitialized || _captureTimer != null) return;
    ref.read(recognitionProvider.notifier).startDetection();
    _captureTimer = Timer.periodic(
        const Duration(milliseconds: 520), (_) => _captureAndSendFrame());
    await _captureAndSendFrame();
  }

  Future<void> _stopStreaming({bool saveHistory = true}) async {
    _captureTimer?.cancel();
    _captureTimer = null;
    ref.read(recognitionProvider.notifier).stopDetection();
    if (saveHistory) _saveHistory();
  }

  void _saveHistory() {
    final state = ref.read(recognitionProvider);
    final text = state.currentText.trim();
    if (text.isEmpty) return;
    ref.read(historyProvider.notifier).addEntry(
          HistoryEntry(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            mode: ConversationMode.liveRecognition,
            title: text,
            subtitle:
                'Confidence ${(state.confidence * 100).toStringAsFixed(0)}%',
            createdAt: DateTime.now(),
            confidence: state.confidence,
          ),
        );
  }

  @override
  void dispose() {
    _captureTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recognitionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Recognition'),
        actions: [
          IconButton(
            icon: const Icon(Icons.backspace_outlined),
            tooltip: 'Delete last word',
            onPressed: () =>
                ref.read(recognitionProvider.notifier).deleteLastWord(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Clear text',
            onPressed: () => ref.read(recognitionProvider.notifier).clearText(),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Center(
                child: _StatusChip(
                    status: state.status, isDetecting: state.isDetecting)),
            const SizedBox(height: 16),
            _CameraFrame(
              isInitialized: _isCameraInitialized,
              isDetecting: state.isDetecting,
              controller: _cameraController,
            ),
            const SizedBox(height: 18),
            _RecognizedTextPanel(
              text: state.currentText,
              confidence: state.confidence,
              muted: _muted,
              onSpeak: () {
                if (!_muted) {
                  ref
                      .read(accessibilityServiceProvider)
                      .speak(state.currentText);
                }
              },
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed:
                  state.isDetecting ? () => _stopStreaming() : _startStreaming,
              icon: Icon(state.isDetecting
                  ? Icons.stop_rounded
                  : Icons.play_arrow_rounded),
              label: Text(
                  state.isDetecting ? 'Stop Detection' : 'Start Detection'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    state.isDetecting ? NeuroColors.danger : NeuroColors.sage,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ToolButton(
                    icon: Icons.light_mode_outlined,
                    label: 'Light',
                    onTap: () {}),
                _ToolButton(
                    icon: Icons.cameraswitch_rounded,
                    label: 'Flip',
                    onTap: _flipCamera),
                _ToolButton(
                  icon: _muted
                      ? Icons.volume_off_rounded
                      : Icons.volume_up_rounded,
                  label: _muted ? 'Muted' : 'Speech',
                  onTap: () => setState(() => _muted = !_muted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CameraFrame extends StatelessWidget {
  const _CameraFrame({
    required this.isInitialized,
    required this.isDetecting,
    required this.controller,
  });

  final bool isInitialized;
  final bool isDetecting;
  final CameraController? controller;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? NeuroColors.darkPanel
              : NeuroColors.mintMist,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
              color: isDetecting ? NeuroColors.sage : Colors.transparent,
              width: 2),
        ),
        clipBehavior: Clip.antiAlias,
        child: isInitialized && controller != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  CameraPreview(controller!),
                  CustomPaint(
                      painter: _DetectionCornerPainter(isActive: isDetecting)),
                ],
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _RecognizedTextPanel extends StatelessWidget {
  const _RecognizedTextPanel({
    required this.text,
    required this.confidence,
    required this.muted,
    required this.onSpeak,
  });

  final String text;
  final double confidence;
  final bool muted;
  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recognized Text',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: Text(
                      text.trim().isEmpty
                          ? 'Waiting for gestures...'
                          : text.trim(),
                      key: ValueKey(text),
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: text.trim().isEmpty
                                    ? NeuroColors.graphite
                                    : NeuroColors.sage,
                              ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Confidence ${(confidence * 100).toStringAsFixed(0)}%'),
                ],
              ),
            ),
            IconButton.filledTonal(
              onPressed: text.trim().isEmpty ? null : onSpeak,
              icon: Icon(
                  muted ? Icons.volume_off_rounded : Icons.volume_up_rounded),
              tooltip: 'Speak recognized text',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.isDetecting});

  final String status;
  final bool isDetecting;

  @override
  Widget build(BuildContext context) {
    final hasError = status == 'error';
    return Chip(
      avatar: Icon(
        hasError ? Icons.error_outline_rounded : Icons.circle,
        size: 14,
        color: hasError ? NeuroColors.danger : NeuroColors.success,
      ),
      label: Text(hasError
          ? 'Camera/API issue'
          : (isDetecting ? 'Detecting...' : 'Ready')),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton(
      {required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
            onPressed: onTap, icon: Icon(icon), tooltip: label),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _DetectionCornerPainter extends CustomPainter {
  const _DetectionCornerPainter({required this.isActive});

  final bool isActive;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          isActive ? NeuroColors.sage : Colors.white.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    const inset = 24.0;
    const length = 42.0;

    for (final corner in [
      const Offset(inset, inset),
      Offset(size.width - inset, inset),
      Offset(inset, size.height - inset),
      Offset(size.width - inset, size.height - inset),
    ]) {
      final horizontalDirection = corner.dx < size.width / 2 ? 1.0 : -1.0;
      final verticalDirection = corner.dy < size.height / 2 ? 1.0 : -1.0;
      canvas.drawLine(
          corner, corner + Offset(length * horizontalDirection, 0), paint);
      canvas.drawLine(
          corner, corner + Offset(0, length * verticalDirection), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DetectionCornerPainter oldDelegate) =>
      isActive != oldDelegate.isActive;
}
