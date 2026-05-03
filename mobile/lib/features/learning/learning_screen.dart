import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../models/history_entry.dart';
import '../../providers/history_provider.dart';

class LearningScreen extends ConsumerWidget {
  const LearningScreen({super.key});

  static const _signs = [
    ('Hello', 'Open hand near forehead, then move outward.'),
    ('Thank you', 'Flat hand from chin outward.'),
    ('Help', 'Closed hand on open palm, lift together.'),
    ('Yes', 'Closed fist nodding motion.'),
    ('No', 'Index and middle fingers close to thumb.'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Learning')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Text('Practice common signs',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
                'Short lessons, friendly prompts, and a simple progress trail for beginners.',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 18),
            LinearProgressIndicator(
              value: 0.35,
              minHeight: 10,
              borderRadius: BorderRadius.circular(20),
              color: NeuroColors.sage,
              backgroundColor: NeuroColors.mintMist,
            ),
            const SizedBox(height: 22),
            ..._signs.map(
              (item) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: NeuroColors.mintMist,
                    foregroundColor: NeuroColors.sage,
                    child: Icon(Icons.sign_language_rounded),
                  ),
                  title: Text(item.$1),
                  subtitle: Text(item.$2),
                  trailing: IconButton(
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    tooltip: 'Mark practiced',
                    onPressed: () {
                      ref.read(historyProvider.notifier).addEntry(
                            HistoryEntry(
                              id: DateTime.now()
                                  .microsecondsSinceEpoch
                                  .toString(),
                              mode: ConversationMode.learning,
                              title: item.$1,
                              subtitle: 'Practice completed',
                              createdAt: DateTime.now(),
                            ),
                          );
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${item.$1} practice saved')));
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
