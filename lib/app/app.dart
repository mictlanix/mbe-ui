import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/app/router/app_router.dart';
import 'package:mbe_ui/app/theme/app_theme.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Root widget: wires the redirect-guarded router (T022), the seeded
/// light/dark theme + persisted `ThemeMode` (T021), and `es-MX` as the
/// first-class locale (constitution §V).
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeControllerProvider);

    return MaterialApp.router(
      title: 'Mictlanix Business Essentials',
      routerConfig: router,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: const Locale('es', 'MX'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
    );
  }
}
