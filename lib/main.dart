import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:mbe_ui/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Required by PricingFormatters.date (package:intl's DateFormat throws
  // LocaleDataException without this) — the feature's first use of intl's
  // DateFormat beyond the generated l10n code (specs/011-product-pricing
  // research.md §10).
  await initializeDateFormatting();
  runApp(const ProviderScope(child: App()));
}
