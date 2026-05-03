import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/history_entry.dart';

final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<HistoryEntry>>((ref) {
  return HistoryNotifier()..load();
});

class HistoryNotifier extends StateNotifier<List<HistoryEntry>> {
  HistoryNotifier() : super(_seedEntries);

  static const _storageKey = 'neurosign.history';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      await _persist();
      return;
    }
    state = HistoryEntry.decodeList(raw);
  }

  Future<void> add(HistoryEntry entry) async {
    state = [entry, ...state].take(50).toList();
    await _persist();
  }

  Future<void> addEntry(HistoryEntry entry) => add(entry);

  Future<void> clear() async {
    state = [];
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, HistoryEntry.encodeList(state));
  }
}

final _seedEntries = [
  HistoryEntry(
    id: 'seed-live-1',
    mode: ConversationMode.liveRecognition,
    title: 'HELLO',
    subtitle: 'Live recognition',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    confidence: 0.92,
  ),
  HistoryEntry(
    id: 'seed-text-1',
    mode: ConversationMode.textToSign,
    title: 'THANK YOU',
    subtitle: 'Text to sign',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  HistoryEntry(
    id: 'seed-speech-1',
    mode: ConversationMode.speechToText,
    title: 'How are you?',
    subtitle: 'Speech transcript',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
];
