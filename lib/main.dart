import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:mbe_ui/app/app.dart';

Future<void> main() async {
  if (kDebugMode) {
    // Dev-only: lets an agent/tooling session drive the running app (tap,
    // enter text, read widget state) via `flutter_driver_command` instead of
    // relying on a human to click through the UI (README.md "Driving the
    // running app"). `kDebugMode` is a compile-time constant, so this whole
    // branch — and the `flutter_driver` import — is dead-code-eliminated
    // from profile/release builds; it never ships.
    //
    // Must run before any other binding initialization: it constructs its
    // own binding (which mixes in `WidgetsBinding`), so calling
    // `WidgetsFlutterBinding.ensureInitialized()` first would trip "Binding
    // is already initialized" (a different binding type would already be
    // live).
    enableFlutterDriverExtension();
  } else {
    WidgetsFlutterBinding.ensureInitialized();
  }
  // Required by PricingFormatters.date (package:intl's DateFormat throws
  // LocaleDataException without this) — the feature's first use of intl's
  // DateFormat beyond the generated l10n code (specs/011-product-pricing
  // research.md §10).
  await initializeDateFormatting();
  runApp(const ProviderScope(child: App()));
}
