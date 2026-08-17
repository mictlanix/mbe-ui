import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/branding/brand_config.dart';
import 'package:mbe_ui/core/config/app_settings_provider.dart';

/// The active deployment's [BrandConfig] — [AppSettings.brand], composed
/// (not re-resolved) so there is exactly one [BrandConfig] instance
/// (spec 027 data-model.md §1.1). Overridable in tests to exercise both
/// branded and default-placeholder paths.
final brandConfigProvider = Provider<BrandConfig>(
  (ref) => ref.watch(appSettingsProvider).brand,
);
