import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/errors/localize_problem.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// A form's failure banner: the form's own [headline], which says what failed
/// ("Couldn't save the operator"), and below it the reason the server gave,
/// in the user's language when the app has a message for its code (spec 058).
///
/// The form keeps the [cause] itself rather than the English text it carried
/// when the error happened, so the reason is built here, at display time, and
/// follows a language change while the error is on screen.
///
/// A field-level validation refusal is shown at its fields, so its banner
/// carries only the headline, as forms have always done.
class FormErrorBanner extends ConsumerWidget {
  const FormErrorBanner({
    super.key,
    required this.headline,
    this.cause,
    this.onDismiss,
  });

  /// What failed, in the user's language, from the form's own client-side
  /// error code.
  final String headline;

  /// The server's refusal, when there was one.
  final AppError? cause;

  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cause = this.cause;
    final fmt = cause?.problem == null ? null : ref.watch(formattersProvider);
    final reason = switch (cause) {
      null => null,
      ValidationError(errors: final errors) when errors.isNotEmpty => null,
      _ => cause.userMessage(l10n, fmt),
    };
    return ErrorBanner(
      onDismiss: onDismiss,
      error: AppError.validation([
        FieldError(loc: const [], msg: headline, type: 'error'),
        if (reason != null && reason.isNotEmpty)
          FieldError(loc: const [], msg: reason, type: 'error'),
      ]),
    );
  }
}
