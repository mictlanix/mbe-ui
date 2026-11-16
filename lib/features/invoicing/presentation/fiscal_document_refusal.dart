import 'package:flutter/material.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/form_error_banner.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// What a fiscal-document dialog reports back once it has closed: `error` is
/// `null` when the server accepted, otherwise the refusal the screen shows
/// above its action area. The dialog itself answers `null` when the user
/// backed out.
typedef FiscalDocumentActionResult = ({AppError? error});

/// A write's failure, as a dialog or the screen shows it: a lost connection
/// leaves the outcome unknown, so it says that rather than claiming it failed;
/// anything else is the server's refusal, localized from its code (§III).
class FiscalDocumentRefusal extends StatelessWidget {
  const FiscalDocumentRefusal({super.key, required this.error});

  final AppError error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return error is NetworkError
        ? FormErrorBanner(
            key: const Key('fiscal_document_action_unknown'),
            headline: l10n.fiscalDocumentUnknownResult,
          )
        : ErrorBanner(key: const Key('fiscal_document_refusal'), error: error);
  }
}
