import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../history/history_screen.dart';
import '../home/home_screen.dart';
import '../learning/learning_screen.dart';
import '../recognition/recognition_screen.dart';
import '../settings/settings_screen.dart';
import '../speech/speech_to_text_screen.dart';
import '../text_to_sign/text_to_sign_screen.dart';

class NeuroSignShell extends ConsumerStatefulWidget {
  const NeuroSignShell({super.key});

  @override
  ConsumerState<NeuroSignShell> createState() => _NeuroSignShellState();
}

class _NeuroSignShellState extends ConsumerState<NeuroSignShell> {
  int _selectedIndex = 0;

  void _openTab(int index) {
    setState(() => _selectedIndex = index);
  }

  void _push(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        onOpenRecognition: () => _openTab(2),
        onOpenTextToSign: () => _openTab(1),
        onOpenSpeechToText: () => _push(const SpeechToTextScreen()),
        onOpenHistory: () => _openTab(3),
        onOpenLearning: () => _push(const LearningScreen()),
        onOpenSettings: () => _openTab(4),
      ),
      const TextToSignScreen(),
      const RecognitionScreen(),
      const HistoryScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _openTab,
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.translate_outlined),
              selectedIcon: Icon(Icons.translate_rounded),
              label: 'Text'),
          NavigationDestination(
              icon: Icon(Icons.photo_camera_outlined),
              selectedIcon: Icon(Icons.photo_camera_rounded),
              label: 'Live'),
          NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history_rounded),
              label: 'History'),
          NavigationDestination(
              icon: Icon(Icons.tune_outlined),
              selectedIcon: Icon(Icons.tune_rounded),
              label: 'Settings'),
        ],
      ),
    );
  }
}
