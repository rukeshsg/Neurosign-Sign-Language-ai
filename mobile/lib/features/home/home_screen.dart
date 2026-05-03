import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../models/history_entry.dart';
import '../../providers/history_provider.dart';
import '../../widgets/neurosign_logo.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({
    super.key,
    required this.onOpenRecognition,
    required this.onOpenTextToSign,
    required this.onOpenSpeechToText,
    required this.onOpenHistory,
    required this.onOpenLearning,
    required this.onOpenSettings,
  });

  final VoidCallback onOpenRecognition;
  final VoidCallback onOpenTextToSign;
  final VoidCallback onOpenSpeechToText;
  final VoidCallback onOpenHistory;
  final VoidCallback onOpenLearning;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider).take(3).toList();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          children: [
            Row(
              children: [
                const NeuroSignLogo(size: 52, showWordmark: false),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome back',
                          style: Theme.of(context).textTheme.bodyMedium),
                      Text('NeuroSigner',
                          style: Theme.of(context).textTheme.titleLarge),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: onOpenSettings,
                  icon: const Icon(Icons.notifications_none_rounded),
                  tooltip: 'Notifications',
                ),
              ],
            ),
            const SizedBox(height: 26),
            Text('Explore', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.98,
              children: [
                _FeatureCard(
                  title: 'Live Recognition',
                  subtitle: 'Real-time sign to text',
                  icon: Icons.photo_camera_rounded,
                  tint: NeuroColors.mintMist,
                  onTap: onOpenRecognition,
                ),
                _FeatureCard(
                  title: 'Text to Sign',
                  subtitle: 'Convert words to signs',
                  icon: Icons.translate_rounded,
                  tint: NeuroColors.butter,
                  onTap: onOpenTextToSign,
                ),
                _FeatureCard(
                  title: 'Speech to Text',
                  subtitle: 'Speak and reuse text',
                  icon: Icons.mic_rounded,
                  tint: const Color(0xFFE4F3EC),
                  onTap: onOpenSpeechToText,
                ),
                _FeatureCard(
                  title: 'Learning',
                  subtitle: 'Practice common signs',
                  icon: Icons.school_rounded,
                  tint: NeuroColors.blush,
                  onTap: onOpenLearning,
                ),
                _FeatureCard(
                  title: 'History',
                  subtitle: 'Replay conversations',
                  icon: Icons.history_rounded,
                  tint: NeuroColors.sky,
                  onTap: onOpenHistory,
                ),
                _FeatureCard(
                  title: 'Settings',
                  subtitle: 'Theme, API, access',
                  icon: Icons.tune_rounded,
                  tint: const Color(0xFFE7F2FF),
                  onTap: onOpenSettings,
                ),
              ],
            ),
            const SizedBox(height: 26),
            Row(
              children: [
                Expanded(
                    child: Text('Recent Activity',
                        style: Theme.of(context).textTheme.titleLarge)),
                TextButton(
                    onPressed: onOpenHistory, child: const Text('See all')),
              ],
            ),
            const SizedBox(height: 8),
            if (history.isEmpty)
              const _EmptyRecentActivity()
            else
              ...history
                  .map((entry) => _RecentActivityTile(entry: entry))
                  .toList(),
            const SizedBox(height: 14),
            _QuickPhraseBar(onPhraseTap: onOpenTextToSign),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tint,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? NeuroColors.darkPanel : tint,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: isDark
                    ? NeuroColors.darkPanelSoft
                    : Colors.white.withValues(alpha: 0.74),
                foregroundColor: NeuroColors.sage,
                child: Icon(icon),
              ),
              const Spacer(),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentActivityTile extends StatelessWidget {
  const _RecentActivityTile({required this.entry});

  final HistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: NeuroColors.mintMist,
          foregroundColor: NeuroColors.sage,
          child: Icon(_modeIcon(entry.mode)),
        ),
        title: Text(entry.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(entry.modeLabel),
        trailing: Text(_timeLabel(entry.createdAt),
            style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }

  IconData _modeIcon(ConversationMode mode) {
    return switch (mode) {
      ConversationMode.liveRecognition => Icons.photo_camera_rounded,
      ConversationMode.textToSign => Icons.translate_rounded,
      ConversationMode.speechToText => Icons.mic_rounded,
      ConversationMode.learning => Icons.school_rounded,
    };
  }

  String _timeLabel(DateTime date) {
    final now = DateTime.now();
    if (now.difference(date).inDays == 0) return 'Today';
    if (now.difference(date).inDays == 1) return 'Yesterday';
    return '${date.month}/${date.day}';
  }
}

class _EmptyRecentActivity extends StatelessWidget {
  const _EmptyRecentActivity();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const Icon(Icons.history_rounded, color: NeuroColors.sage),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Your recognized signs, speech notes, and converted text will appear here.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickPhraseBar extends StatelessWidget {
  const _QuickPhraseBar({required this.onPhraseTap});

  final VoidCallback onPhraseTap;

  @override
  Widget build(BuildContext context) {
    const phrases = ['hello', 'thank you', 'help', 'yes', 'no'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: phrases
          .map(
            (phrase) => ActionChip(
              avatar: const Icon(Icons.bolt_rounded, size: 18),
              label: Text(phrase),
              onPressed: onPhraseTap,
            ),
          )
          .toList(),
    );
  }
}
