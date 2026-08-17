import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/app/router/app_router.dart';
import 'package:mbe_ui/app/theme/app_theme.dart';
import 'package:mbe_ui/core/branding/brand_config_provider.dart';
import 'package:mbe_ui/core/design/design_theme.dart';
import 'package:mbe_ui/core/design/text_scale.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/settings/user_display_preferences_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Root widget: wires the redirect-guarded router (T022), the brand-driven
/// light/dark theme (spec 019), and the user's display preferences —
/// appearance, language and text-size level (spec 027 FR-017/FR-018/FR-019)
/// — in place of the formerly hard-coded `ThemeMode.system` restore and
/// `Locale('es', 'MX')` literal.
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final preferences = ref.watch(userDisplayPreferencesControllerProvider);
    final locale = ref.watch(resolvedLocaleProvider);
    final brand = ref.watch(brandConfigProvider);
    final appTheme = ref.watch(appThemeProvider);

    return MaterialApp.router(
      title: brand.displayName,
      routerConfig: router,
      theme: appTheme.light,
      darkTheme: appTheme.dark,
      themeMode: preferences.themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      // Resolves the width tier once, above the Navigator, and re-applies a
      // tier-resolved theme (spec 022 research R1) so every route/dialog/
      // sheet below inherits tier-aware spacing/shape/elevation/density/
      // type-role tokens without each screen re-deriving the tier itself.
      // The composing text scaler (spec 027 research R1) sits above that:
      // at TextSizeLevel.normal it is the identity, so this is the same
      // subtree that rendered before this feature at the default level —
      // no golden/screenshot re-baselining required there.
      builder: (context, child) {
        final tier = LayoutBreakpoints.tierOfContext(context);
        final themed = Theme(
          data: DesignTheme.forTier(Theme.of(context), tier),
          child: child!,
        );
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: ComposedTextScaler(
              platform: MediaQuery.textScalerOf(context),
              level: preferences.textSizeLevel,
            ),
          ),
          child: themed,
        );
      },
    );
  }
}
