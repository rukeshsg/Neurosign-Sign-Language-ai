import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../providers/app_settings_provider.dart';
import '../../widgets/neurosign_logo.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _apiController;

  @override
  void initState() {
    super.initState();
    _apiController =
        TextEditingController(text: ref.read(appSettingsProvider).apiBaseUrl);
  }

  @override
  void dispose() {
    _apiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            const Center(child: NeuroSignLogo(size: 82)),
            const SizedBox(height: 24),
            _Section(
              title: 'Appearance',
              children: [
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.phone_android_rounded),
                        label: Text('System')),
                    ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_rounded),
                        label: Text('Light')),
                    ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_rounded),
                        label: Text('Dark')),
                  ],
                  selected: {settings.themeMode},
                  onSelectionChanged: (value) => ref
                      .read(appSettingsProvider.notifier)
                      .setThemeMode(value.first),
                ),
                SwitchListTile(
                  value: settings.largeText,
                  onChanged: (value) => ref
                      .read(appSettingsProvider.notifier)
                      .setLargeText(value),
                  title: const Text('Larger text'),
                  subtitle: const Text('Increase app text for readability.'),
                ),
              ],
            ),
            _Section(
              title: 'Backend',
              children: [
                TextField(
                  controller: _apiController,
                  decoration: const InputDecoration(
                    labelText: 'API base URL',
                    helperText:
                        'Emulator: http://10.0.2.2:8000/api/v1. Phone: use your PC IP.',
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () => ref
                      .read(appSettingsProvider.notifier)
                      .setApiBaseUrl(_apiController.text.trim()),
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('Save API URL'),
                ),
              ],
            ),
            const _Section(
              title: 'Permissions',
              children: [
                _InfoTile(
                    icon: Icons.photo_camera_rounded,
                    title: 'Camera',
                    subtitle: 'Required for live sign recognition.'),
                _InfoTile(
                    icon: Icons.mic_rounded,
                    title: 'Microphone',
                    subtitle: 'Required for speech-to-text.'),
                _InfoTile(
                    icon: Icons.volume_up_rounded,
                    title: 'Speaker',
                    subtitle: 'Used for text-to-speech playback.'),
              ],
            ),
            const _Section(
              title: 'Model Info',
              children: [
                _InfoTile(
                    icon: Icons.psychology_rounded,
                    title: 'ASL Static',
                    subtitle:
                        'Sklearn model loaded from backend/models/asl_static.joblib.'),
                _InfoTile(
                    icon: Icons.timeline_rounded,
                    title: 'WLASL Dynamic',
                    subtitle:
                        'Baseline dynamic model available; requires full dataset training for production quality.'),
                _InfoTile(
                    icon: Icons.info_outline_rounded,
                    title: AppConstants.appName,
                    subtitle: 'Version 1.0.0 local testing build.'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile(
      {required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: NeuroColors.mintMist,
        foregroundColor: NeuroColors.sage,
        child: Icon(icon),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}
