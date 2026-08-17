import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The app's single [SharedPreferences] instance, seeded in `main()` via
/// `overrideWithValue` **before** `runApp` (spec 027 research.md R5) — so
/// every reader (`UserDisplayPreferencesController`) reads synchronously and
/// the first frame is already correct, rather than restoring asynchronously
/// and flashing the default for a frame (the defect `ThemeModeController`
/// had before this feature).
///
/// Deliberately left unimplemented: a provider read before `main()` performs
/// the override is a programming error, not a state to degrade gracefully
/// from, so it throws loudly rather than lazily calling
/// `SharedPreferences.getInstance()` itself.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden with a SharedPreferences '
    'instance obtained in main() before runApp (see main.dart).',
  );
});
