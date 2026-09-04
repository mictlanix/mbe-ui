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

/// The deployment's search-field debounce (spec 036 FR-028/FR-029) — every
/// search-style field (`CatalogEntityPicker`, `ProductSearchField`) reads
/// this instead of its own hardcoded delay.
final inputDebounceProvider = Provider<Duration>(
  (ref) => ref.watch(appSettingsProvider).inputDebounce,
);

/// The deployment's quantity-commit debounce (spec 036 FR-028/FR-029) —
/// `QuantityStepperController`'s two hosts (`sale_line_editing.dart`,
/// `destination_card.dart`) read this instead of the shared
/// `kQuantityCommitDebounce` constant.
final quantityCommitDebounceProvider = Provider<Duration>(
  (ref) => ref.watch(appSettingsProvider).quantityCommitDebounce,
);
