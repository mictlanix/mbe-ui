import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/core/settings/user_display_preferences_controller.dart';

/// The single formatting surface (spec 028 FR-001), derived from
/// [appSettingsProvider] and the same [resolvedLocaleProvider] that drives
/// `MaterialApp.locale` — so the interface language and every formatted
/// value can never disagree (research.md R1).
///
/// Resolve **once per build** and close over it; do not call
/// `ref.watch(formattersProvider)` per cell:
///
/// ```dart
/// final fmt = ref.watch(formattersProvider);
/// Text(fmt.display.currency(sale.total))
/// ```
final formattersProvider = Provider<AppFormatters>((ref) {
  final settings = ref.watch(appSettingsProvider);
  final locale = ref.watch(resolvedLocaleProvider);
  return AppFormatters(locale: locale, settings: settings.formatting);
});
