import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/shell/neurosign_shell.dart';
import 'providers/app_settings_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: SignLanguageApp(),
    ),
  );
}

class SignLanguageApp extends ConsumerWidget {
  const SignLanguageApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);

    return MaterialApp(
      title: 'NeuroSign',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(settings.largeText ? 1.12 : 1.0),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: settings.hasCompletedOnboarding
          ? const NeuroSignShell()
          : const OnboardingScreen(),
    );
  }
}
