import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_language_app/main.dart';

void main() {
  testWidgets('NeuroSign shows onboarding on first launch', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ProviderScope(child: SignLanguageApp()));
    await tester.pumpAndSettle();

    expect(find.text('Start NeuroSign'), findsOneWidget);
    expect(find.text('Communicate with confidence'), findsOneWidget);
  });
}
