import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../providers/app_settings_provider.dart';
import '../../widgets/neurosign_logo.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(NeuroSpacing.lg),
          child: Column(
            children: [
              const Spacer(),
              const NeuroSignLogo(size: 138),
              const SizedBox(height: 34),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  color: isDark ? NeuroColors.darkPanel : Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: NeuroColors.sage
                          .withValues(alpha: isDark ? 0.18 : 0.10),
                      blurRadius: 34,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(Icons.sign_language_rounded,
                        color: Theme.of(context).colorScheme.primary, size: 58),
                    const SizedBox(height: 18),
                    Text(
                      'Communicate with confidence',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Live sign recognition, speech, text conversion, practice tools, and conversation history in one calm workspace.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => ref
                      .read(appSettingsProvider.notifier)
                      .completeOnboarding(),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Start NeuroSign'),
                ),
              ),
              const SizedBox(height: 12),
              Text(AppConstants.appTagline,
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
