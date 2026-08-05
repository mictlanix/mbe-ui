import 'package:flutter/material.dart';

import 'package:mbe_ui/features/sales/domain/cash_session_status.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The localized name of [status] (contracts/cash-session-screens.md).
String cashSessionStatusLabel(AppLocalizations l10n, CashSessionStatus status) =>
    switch (status) {
      CashSessionStatus.open => l10n.cashSessionStatusOpen,
      CashSessionStatus.stale => l10n.cashSessionStatusStale,
      CashSessionStatus.closed => l10n.cashSessionStatusClosed,
    };

/// A table cell / summary field showing a session's [status]. Mirrors
/// `EntityStatusCell`'s colour-pair `switch` + `Chip` shape (research.md §9)
/// — unlike that widget, every state gets a chip here, since none of the
/// three is the unmarked default the way `active` is for [EntityStatus].
/// `stale` uses the error pair: it hard-blocks the cashier from selling
/// (FR-025's sharpest edge) and is the state a supervisor most needs to
/// notice at a glance.
class CashSessionStatusChip extends StatelessWidget {
  const CashSessionStatusChip({super.key, required this.status});

  final CashSessionStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final label = cashSessionStatusLabel(l10n, status);

    final (background, foreground) = switch (status) {
      CashSessionStatus.open => (
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
      ),
      CashSessionStatus.stale => (scheme.errorContainer, scheme.onErrorContainer),
      CashSessionStatus.closed => (
        scheme.surfaceContainerHighest,
        scheme.onSurfaceVariant,
      ),
    };

    return Chip(
      key: Key('cash_session_status_chip_${status.name}'),
      label: Text(label),
      backgroundColor: background,
      labelStyle: TextStyle(color: foreground),
      visualDensity: VisualDensity.compact,
    );
  }
}
