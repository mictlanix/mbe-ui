import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/app/router/app_router.dart';
import 'package:mbe_ui/app/theme/app_theme.dart';
import 'package:mbe_ui/core/branding/brand_config_provider.dart';
import 'package:mbe_ui/core/design/design_theme.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Root widget: wires the redirect-guarded router (T022), the brand-driven
/// light/dark theme + persisted `ThemeMode` (T021; spec 019), and `es-MX`
/// as the first-class locale (constitution §V).
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeControllerProvider);
    final brand = ref.watch(brandConfigProvider);
    final appTheme = ref.watch(appThemeProvider);

    return MaterialApp.router(
      title: brand.displayName,
      routerConfig: router,
      theme: appTheme.light,
      darkTheme: appTheme.dark,
      themeMode: themeMode,
      locale: const Locale('es', 'MX'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      // Resolves the width tier once, above the Navigator, and re-applies a
      // tier-resolved theme (spec 022 research R1) so every route/dialog/
      // sheet below inherits tier-aware spacing/shape/elevation/density/
      // type-role tokens without each screen re-deriving the tier itself.
      builder: (context, child) {
        final tier = LayoutBreakpoints.tierOfContext(context);
        return Theme(
          data: DesignTheme.forTier(Theme.of(context), tier),
          child: child!,
        );
      },
    );
  }
}
