import 'dart:ui';

import 'package:intl/date_symbol_data_local.dart';

import 'package:mbe_ui/core/config/formatting_settings.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';
import 'package:mbe_ui/l10n/app_localizations_en.dart';
import 'package:mbe_ui/l10n/app_localizations_es.dart';

/// Both languages with the formatters each one is shown with, for the tests
/// of `localizeProblem` and its siblings (spec 058). Call [load] in
/// `setUpAll`: `AppFormatters` needs the date data initialised first.
class ProblemEnv {
  ProblemEnv._(this.en, this.es, this.fmtEn, this.fmtEs);

  final AppLocalizations en;
  final AppLocalizations es;
  final AppFormatters fmtEn;
  final AppFormatters fmtEs;

  static Future<ProblemEnv> load() async {
    await initializeDateFormatting();
    const settings = FormattingSettings();
    return ProblemEnv._(
      AppLocalizationsEn(),
      AppLocalizationsEs(),
      AppFormatters(locale: const Locale('en', 'US'), settings: settings),
      AppFormatters(locale: const Locale('es', 'MX'), settings: settings),
    );
  }
}
