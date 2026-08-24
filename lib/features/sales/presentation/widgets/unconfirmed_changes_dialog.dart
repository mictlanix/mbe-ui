import 'package:flutter/material.dart';

import 'package:mbe_ui/l10n/app_localizations.dart';

/// What the cashier chose in response to [showUnconfirmedChangesDialog]
/// (spec 031 FR-024…FR-030).
enum UnconfirmedChangesAnswer {
  /// Commit every unconfirmed field exactly as Enter would (FR-026).
  keep,

  /// Discard every unconfirmed field, with the usual acknowledgement
  /// (FR-027).
  discard,

  /// Do nothing — the sale stays on its current step, typed text intact
  /// (FR-028).
  keepEditing,
}

/// Raised when a step's primary action is pressed while a field on that
/// step still holds unconfirmed text (spec 031 FR-024): a decision, not a
/// warning to dismiss (research R11) — `barrierDismissible: false`, and an
/// unanswerable dismissal (Esc, a back-button press) resolves to
/// [UnconfirmedChangesAnswer.keepEditing], the one answer that changes
/// nothing, so no dismissal can silently save or silently lose a value.
Future<UnconfirmedChangesAnswer> showUnconfirmedChangesDialog(
  BuildContext context,
) async {
  final l10n = AppLocalizations.of(context)!;
  final answer = await showDialog<UnconfirmedChangesAnswer>(
    context: context,
    barrierDismissible: false,
    builder: (context) => PopScope(
      // Same "changes nothing" rule for the system back gesture as for the
      // barrier: neither is a real answer, so both land on keepEditing
      // rather than on whichever variant happened to be built first.
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pop(UnconfirmedChangesAnswer.keepEditing);
        }
      },
      child: AlertDialog(
        title: Text(l10n.posUnconfirmedChangesTitle),
        content: Text(l10n.posUnconfirmedChangesBody),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(UnconfirmedChangesAnswer.keepEditing),
            child: Text(l10n.posUnconfirmedChangesKeepEditing),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(UnconfirmedChangesAnswer.discard),
            child: Text(l10n.posUnconfirmedChangesDiscard),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pop(UnconfirmedChangesAnswer.keep),
            child: Text(l10n.posUnconfirmedChangesKeep),
          ),
        ],
      ),
    ),
  );
  return answer ?? UnconfirmedChangesAnswer.keepEditing;
}
