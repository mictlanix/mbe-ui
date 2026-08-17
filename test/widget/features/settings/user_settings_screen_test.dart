import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/design/text_scale.dart';
import 'package:mbe_ui/core/settings/user_display_preferences_controller.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/settings/presentation/user_settings_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

Future<void> _pump(WidgetTester tester, {Map<String, Object> prefs = const {}}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sharedPreferences = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(sharedPreferences)],
      child: MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const UserSettingsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('UserSettingsScreen (spec 027 US3, FR-016/017/018/019/023)', () {
    testWidgets('renders all three controls with no RBAC gate', (tester) async {
      await _pump(tester);

      expect(find.byKey(const Key('settings_appearance_selector')), findsOneWidget);
      expect(find.byKey(const Key('settings_text_size_selector')), findsOneWidget);
      expect(find.byKey(const Key('settings_language_selector')), findsOneWidget);
    });

    testWidgets('AppBar.actions is empty (constitution §VI)', (tester) async {
      await _pump(tester);

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.actions, anyOf(isNull, isEmpty));
    });

    testWidgets('tapping Dark calls setThemeMode and updates immediately (FR-020)', (
      tester,
    ) async {
      await _pump(tester);

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(UserSettingsScreen));
      final state = ProviderScope.containerOf(context).read(
        userDisplayPreferencesControllerProvider,
      );
      expect(state.themeMode, ThemeMode.dark);
    });

    testWidgets('tapping a text-size level calls setTextSizeLevel', (tester) async {
      await _pump(tester);

      await tester.tap(find.text('Extra large'));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(UserSettingsScreen));
      final state = ProviderScope.containerOf(context).read(
        userDisplayPreferencesControllerProvider,
      );
      expect(state.textSizeLevel, TextSizeLevel.extraLarge);
    });

    testWidgets('tapping a language calls setLocaleOverride', (tester) async {
      await _pump(tester);

      await tester.tap(find.text('Spanish'));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(UserSettingsScreen));
      final state = ProviderScope.containerOf(context).read(
        userDisplayPreferencesControllerProvider,
      );
      expect(state.localeOverride, const Locale('es'));
    });

    testWidgets('a previously-stored preference is reflected on open', (tester) async {
      await _pump(tester, prefs: {'theme_mode': 'dark', 'text_size_level': 'large'});

      final appearance = tester.widget<SegmentedButton<ThemeMode>>(
        find.byKey(const Key('settings_appearance_selector')),
      );
      expect(appearance.selected, {ThemeMode.dark});

      final textSize = tester.widget<SegmentedButton<TextSizeLevel>>(
        find.byKey(const Key('settings_text_size_selector')),
      );
      expect(textSize.selected, {TextSizeLevel.large});
    });
  });
}
