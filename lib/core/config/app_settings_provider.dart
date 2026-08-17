import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/config/app_settings.dart';

/// The active deployment's [AppSettings], resolved once from build-time
/// `--dart-define-from-file=.env` values (spec 027 FR-001). Overridable in
/// tests so configured behavior (base URL, brand, default locale) can be
/// asserted without depending on whatever a developer's local `.env`
/// happens to set (research.md R11).
final appSettingsProvider = Provider<AppSettings>(
  (ref) => AppSettings.fromEnvironment(),
);
