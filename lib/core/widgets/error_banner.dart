import 'package:flutter/material.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Renders an [AppError] as a dismissible banner. `ValidationError` lists
/// each field-level message; other variants show a generic message
/// (FR-008 — never exposes which field/credential was wrong for auth
/// errors).
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({super.key, required this.error, this.onDismiss});

  final AppError error;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final messages = _messagesFor(context, error);

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
                onPressed: onDismiss,
              ),
          ],
        ),
      ),
    );
  }

  List<String> _messagesFor(BuildContext context, AppError error) {
    final l10n = AppLocalizations.of(context)!;
    final generic = switch (error) {
      ValidationError(errors: final errors) when errors.isNotEmpty =>
        errors.map((e) => e.msg).toList(),
      ValidationError() => [l10n.errorValidationGeneric],
      AuthError() => [l10n.errorAuthGeneric],
      NotFoundError() => [l10n.errorNotFoundGeneric],
      ServerError() => [l10n.errorServerGeneric],
      NetworkError() => [l10n.errorNetworkGeneric],
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
      AuthError() || NetworkError() || ValidationError() => null,
    };
    if (detail == null || detail.isEmpty) return generic;
    return [...generic, detail];
  }
}
