import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../models/history_entry.dart';
import '../../providers/history_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _query = '';
  ConversationMode? _filter;

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(historyProvider).where((entry) {
      final matchesQuery = _query.isEmpty ||
          entry.title.toLowerCase().contains(_query.toLowerCase()) ||
          entry.subtitle.toLowerCase().contains(_query.toLowerCase());
      final matchesFilter = _filter == null || entry.mode == _filter;
      return matchesQuery && matchesFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            onPressed: () => ref.read(historyProvider.notifier).clear(),
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Clear history',
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                hintText: 'Search conversations',
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: _filter == null,
                      label: const Text('All'),
                      onSelected: (_) => setState(() => _filter = null),
                    ),
                  ),
                  ...ConversationMode.values.map(
                    (mode) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: _filter == mode,
                        label: Text(_labelFor(mode)),
                        onSelected: (_) => setState(() => _filter = mode),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (entries.isEmpty)
              const _EmptyHistory()
            else
              ...entries.map((entry) => _HistoryCard(entry: entry)),
          ],
        ),
      ),
    );
  }

  String _labelFor(ConversationMode mode) {
    return switch (mode) {
      ConversationMode.liveRecognition => 'Live',
      ConversationMode.textToSign => 'Text',
      ConversationMode.speechToText => 'Speech',
      ConversationMode.learning => 'Learning',
    };
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.entry});

  final HistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: NeuroColors.mintMist,
              foregroundColor: NeuroColors.sage,
              child: Icon(_iconFor(entry.mode)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('${entry.modeLabel} - ${entry.subtitle}',
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(_dateLabel(entry.createdAt),
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(ConversationMode mode) {
    return switch (mode) {
      ConversationMode.liveRecognition => Icons.photo_camera_rounded,
      ConversationMode.textToSign => Icons.translate_rounded,
      ConversationMode.speechToText => Icons.mic_rounded,
      ConversationMode.learning => Icons.school_rounded,
    };
  }

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Now';
    if (diff.inHours < 24) return '${diff.inHours.clamp(1, 23)}h';
    return '${date.month}/${date.day}';
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            const Icon(Icons.history_rounded,
                size: 46, color: NeuroColors.sage),
            const SizedBox(height: 10),
            Text('No matching history yet',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            const Text(
                'Live recognition, speech transcripts, text conversions, and practice sessions will be saved here.'),
          ],
        ),
      ),
    );
  }
}
