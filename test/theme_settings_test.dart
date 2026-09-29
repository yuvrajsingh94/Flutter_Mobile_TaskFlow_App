import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:taskflow_flutter/core/storage/storage_service.dart';
import 'package:taskflow_flutter/core/theme/theme_provider.dart';
import 'package:taskflow_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskflow_flutter/features/settings/presentation/screens/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storageService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    const secure = FlutterSecureStorage();
    final prefs = await SharedPreferences.getInstance();
    storageService = StorageService(secureStorage: secure, prefs: prefs);
  });

  group('Appearance & Theme Settings Tests', () {
    testWidgets('SettingsScreen renders Appearance section and Theme selector options',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storageServiceProvider.overrideWithValue(storageService),
          ],
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Appearance header and Theme label
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Settings & Connection'), findsOneWidget);

      // Verify all 3 options exist
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);

      // Verify icons
      expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);
      expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);
      expect(find.byIcon(Icons.brightness_auto_rounded), findsOneWidget);
    });

    testWidgets('Tapping Dark switches ThemeMode to dark and persists preference',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      late WidgetRef capturedRef;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storageServiceProvider.overrideWithValue(storageService),
          ],
          child: Consumer(
            builder: (context, ref, child) {
              capturedRef = ref;
              return const MaterialApp(
                home: SettingsScreen(),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initial state is Light
      expect(capturedRef.read(themeModeProvider), equals(ThemeMode.light));

      // Tap 'Dark'
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      // Theme mode is now Dark
      expect(capturedRef.read(themeModeProvider), equals(ThemeMode.dark));
      expect(storageService.getString('@taskflow_theme_pref'), equals('dark'));

      // Tap 'System'
      await tester.tap(find.text('System'));
      await tester.pumpAndSettle();

      expect(capturedRef.read(themeModeProvider), equals(ThemeMode.system));
      expect(storageService.getString('@taskflow_theme_pref'), equals('system'));

      // Tap 'Light'
      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();

      expect(capturedRef.read(themeModeProvider), equals(ThemeMode.light));
      expect(storageService.getString('@taskflow_theme_pref'), equals('light'));
    });

    test('Rehydrates saved theme mode on startup', () async {
      await storageService.setString('@taskflow_theme_pref', 'dark');

      final container = ProviderContainer(
        overrides: [
          storageServiceProvider.overrideWithValue(storageService),
        ],
      );
      addTearDown(container.dispose);

      final mode = container.read(themeModeProvider);
      expect(mode, equals(ThemeMode.dark));
    });

    testWidgets('SettingsScreen displays 3 sections in correct order', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storageServiceProvider.overrideWithValue(storageService),
          ],
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final appearanceFinder = find.text('Appearance');
      final backendFinder = find.text('Backend Configuration');
      final aboutFinder = find.text('About Client');

      expect(appearanceFinder, findsOneWidget);
      expect(backendFinder, findsOneWidget);
      expect(aboutFinder, findsOneWidget);

      final appearanceY = tester.getTopLeft(appearanceFinder).dy;
      final backendY = tester.getTopLeft(backendFinder).dy;
      final aboutY = tester.getTopLeft(aboutFinder).dy;

      // Section order: 1. Appearance, 2. Backend Configuration, 3. About Client
      expect(appearanceY < backendY, isTrue);
      expect(backendY < aboutY, isTrue);
    });
  });
}
