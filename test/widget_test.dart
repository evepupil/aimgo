import 'package:aimgo/app/app.dart';
import 'package:aimgo/core/services/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders four tabs and profile settings entry', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final localStorageService = await LocalStorageService.create();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageServiceProvider.overrideWithValue(localStorageService),
        ],
        child: const AimGoApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(4));

    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byIcon(Icons.settings_outlined), findsAtLeastNWidgets(1));
  });
}
