import 'package:flutter/material.dart';

import 'package:mbe_ui/core/widgets/status_chip.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The localized name of a quote's [status] as the quotes list states it —
/// mirrors `pos_sale_status_chip.dart`'s own `posSaleStatusLabel`. `paid`
/// has no quote counterpart (a quote never reaches it — data-model.md §1);
/// this arm exists only so the switch stays exhaustive.
String salesQuoteStatusLabel(AppLocalizations l10n, SaleStatus status) => switch (status) {
  SaleStatus.draft => l10n.salesQuoteStatusDraft,
  SaleStatus.completed => l10n.salesQuoteStatusCompleted,
  SaleStatus.paid => l10n.salesQuoteStatusCompleted,
  SaleStatus.cancelled => l10n.salesQuoteStatusCancelled,
};

/// The quotes list's status column (spec 040 FR-035, FR-037). Deliberately
/// carries no notion of "expired" — [SalesQuoteExpiredMarker] renders that
/// as its own, separate widget, since expiry is orthogonal to status
/// (`Sale.hasExpired`) rather than one of its values.
class SalesQuoteStatusChip extends StatelessWidget {
  const SalesQuoteStatusChip({super.key, required this.status});

  final SaleStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = salesQuoteStatusLabel(l10n, status);

    return StatusChip<SaleStatus>(
      key: Key('sales_quote_status_chip_${status.name}'),
      value: status,
      label: label,
      colors: (scheme) => switch (status) {
        SaleStatus.draft => (scheme.primaryContainer, scheme.onPrimaryContainer),
        SaleStatus.completed => (scheme.tertiaryContainer, scheme.onTertiaryContainer),
        SaleStatus.paid => (
          scheme.surfaceContainerHighest,
          scheme.onSurfaceVariant,
        ),
        SaleStatus.cancelled => (scheme.errorContainer, scheme.onErrorContainer),
      },
    );
  }
}

/// The expired marker (FR-024, FR-037) — a separate widget from
/// [SalesQuoteStatusChip] by construction, so "expired" can never be folded
/// into a status chip's own label or colour. Absent entirely when
/// [hasExpired] is `false`, rather than rendered blank.
class SalesQuoteExpiredMarker extends StatelessWidget {
  const SalesQuoteExpiredMarker({super.key, required this.hasExpired});

  final bool hasExpired;

  @override
  Widget build(BuildContext context) {
    if (!hasExpired) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    return Tooltip(
      key: const Key('sales_quote_expired_marker'),
      message: l10n.salesQuoteExpiredBadge,
      child: Icon(Icons.event_busy, size: 16, color: Theme.of(context).colorScheme.error),
    );
  }
}
