import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:mbe_ui/app/app.dart';

Future<void> main() async {
  // Dev-only: lets an agent/tooling session drive the running app (tap,
  // enter text, read widget state) via `flutter_driver_command` instead of
  // relying on a human to click through the UI. Must run first — it
  // constructs its own binding (which mixes in `WidgetsBinding`), so calling
  // `WidgetsFlutterBinding.ensureInitialized()` beforehand trips "Binding is
  // already initialized" (a different binding type would already be live).
  enableFlutterDriverExtension();
  // Required by PricingFormatters.date (package:intl's DateFormat throws
  // LocaleDataException without this) — the feature's first use of intl's
  // DateFormat beyond the generated l10n code (specs/011-product-pricing
  // research.md §10).
  await initializeDateFormatting();
  runApp(const ProviderScope(child: App()));
}
