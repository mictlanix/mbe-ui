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
    return switch (error) {
      ValidationError(errors: final errors) when errors.isNotEmpty =>
        errors.map((e) => e.msg).toList(),
      ValidationError() => [l10n.errorValidationGeneric],
      AuthError() => [l10n.errorAuthGeneric],
      NotFoundError() => [l10n.errorNotFoundGeneric],
      ServerError() => [l10n.errorServerGeneric],
      NetworkError() => [l10n.errorNetworkGeneric],
    };
  }
}
