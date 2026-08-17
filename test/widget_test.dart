import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/app/app.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';

void main() {
  testWidgets('App renders a redirect-only shell', (WidgetTester tester) async {
    // App reads UserDisplayPreferencesController (spec 027), which reads
    // sharedPreferencesProvider — unimplemented by default (main.dart seeds
    // it before runApp), so every test pumping the real App must override
    // it, matching main.dart's own setup.
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const App(),
      ),
    );
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
