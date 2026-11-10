import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/errors/localize_problem.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Renders an [AppError] as a dismissible banner. When the server sent a
/// `code` the app has a message for, the banner shows that message in the
/// user's language and nothing else (spec 058 FR-012). Otherwise
/// `ValidationError` lists each field-level message and other variants show a
/// generic message (FR-008 — never exposes which field/credential was wrong
/// for auth errors) followed by the server's English detail where it sent one.
class ErrorBanner extends ConsumerWidget {
  const ErrorBanner({super.key, required this.error, this.onDismiss});

  final AppError error;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // The formatters are only needed to render a coded problem's amounts and
    // dates, so an error without one (a network failure, an older server) does
    // not depend on them.
    final fmt = error.problem == null ? null : ref.watch(formattersProvider);
    final messages = _messagesFor(context, error, fmt);

    return Material(
      color: theme.colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final message in messages)
                    Text(
                      message,
                      style: TextStyle(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                ],
              ),
            ),
            if (onDismiss != null)
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: theme.colorScheme.onErrorContainer,
                ),
                tooltip: AppLocalizations.of(context)?.dismissErrorTooltip,
                onPressed: onDismiss,
              ),
          ],
        ),
      ),
    );
  }

  List<String> _messagesFor(
    BuildContext context,
    AppError error,
    AppFormatters? fmt,
  ) {
    final l10n = AppLocalizations.of(context)!;

    // A message built from the server's code and params replaces the generic
    // headline and the English line alike (spec 058).
    final localized = error.localizedMessage(l10n, fmt);
    if (localized != null) return [localized];

    final generic = switch (error) {
      ValidationError(errors: final errors) when errors.isNotEmpty =>
        errors
            .map((e) => localizeValidationType(e.type, l10n) ?? e.msg)
            .toList(),
      ValidationError() => [l10n.errorValidationGeneric],
      AuthError() => [l10n.errorAuthGeneric],
      NotFoundError() => [l10n.errorNotFoundGeneric],
      ServerError() => [l10n.errorServerGeneric],
      NetworkError() => [l10n.errorNetworkGeneric],
      CreditHoldError() => [l10n.errorCreditHoldGeneric],
    };

    // The server's own detail, when it sent one, below the localized
    // headline — this is what `AppErrorServerMessage.serverMessage` exists
    // for. Without it a refusal that names *which* line is at fault (a
    // sales-order confirmation naming its zero-priced or out-of-stock
    // products, a destination over-claim naming the line and shortfall) was
    // rendered as an unactionable "something went wrong" (FR-037, FR-039).
    //
    // Only for the variants whose message mbe-api actually authored (its
    // `detail` string). `AuthError` is excluded because FR-008 requires that
    // a failed sign-in never reveal which credential was wrong, and
    // `NetworkError` because its message is the raw `DioException` text,
    // which SC-008 forbids putting in front of a user.
    final detail = switch (error) {
      ServerError(message: final m) => m,
      NotFoundError(message: final m) => m,
      CreditHoldError(message: final m) => m,
      ValidationError(message: final m) => m,
      AuthError() || NetworkError() => null,
    };
    if (detail == null || detail.isEmpty) return generic;
    return [...generic, detail];
  }
}
