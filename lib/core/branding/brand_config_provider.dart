import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/branding/brand_config.dart';

/// The active deployment's [BrandConfig], resolved once from build-time
/// `--dart-define` values (spec 010 US3). Overridable in tests to exercise
/// both branded and default-placeholder paths.
final brandConfigProvider = Provider<BrandConfig>(
  (ref) => BrandConfig.fromEnvironment(),
);
