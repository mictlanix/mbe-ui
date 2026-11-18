import 'package:flutter/material.dart';

import 'package:mbe_ui/core/design/design.dart';
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
  const FiscalDocumentRefusal({super.key, required this.error, this.hint});

  final AppError error;

  /// What to do next, in the app's own words, shown under the message (spec 072
  /// C24). Only for a refusal where the server's message alone leaves the
  /// clerk without the way out, such as a stale issue date on a stamp.
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final banner = error is NetworkError
        ? FormErrorBanner(
            key: const Key('fiscal_document_action_unknown'),
            headline: l10n.fiscalDocumentUnknownResult,
          )
        : ErrorBanner(key: const Key('fiscal_document_refusal'), error: error);
    if (hint == null) return banner;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: theme.spacing.xs,
      children: [
        banner,
        Text(
          hint!,
          key: const Key('fiscal_document_refusal_hint'),
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

/// A dismissible note that is not a failure (spec 072 C23): a refresh that
/// succeeded and left the document in process. Styled like the detail
/// screen's status banners, not like an error.
class FiscalDocumentNotice extends StatelessWidget {
  const FiscalDocumentNotice({
    super.key,
    required this.message,
    required this.onDismissed,
  });

  final String message;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Material(
      color: colors.primaryContainer,
      borderRadius: theme.shapes.mdRadius,
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: theme.spacing.md,
          top: theme.spacing.xs,
          bottom: theme.spacing.xs,
          end: theme.spacing.xs,
        ),
        child: Row(
          spacing: theme.spacing.sm,
          children: [
            Icon(Icons.info_outline, color: colors.onPrimaryContainer),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: colors.onPrimaryContainer),
              ),
            ),
            IconButton(
              key: const Key('fiscal_document_notice_dismiss'),
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              icon: Icon(Icons.close, color: colors.onPrimaryContainer),
              onPressed: onDismissed,
            ),
          ],
        ),
      ),
    );
  }
}
