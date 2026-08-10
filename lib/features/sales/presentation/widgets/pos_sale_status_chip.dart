import 'package:flutter/material.dart';

import 'package:mbe_ui/core/widgets/status_chip.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The localized name of a sale's [status] as the sales list states it —
/// deliberately distinct from `open_sales_selector.dart`'s own labels
/// (`posOpenSaleDraft`/`Unpaid`/`Undelivered`), which describe what the
/// *selector* wants doing about a sale rather than the status itself, and
/// have no label at all for `cancelled` (data-model §7).
String posSaleStatusLabel(AppLocalizations l10n, SaleStatus status) => switch (status) {
  SaleStatus.draft => l10n.posSaleStatusDraft,
  SaleStatus.completed => l10n.posSaleStatusCompleted,
  SaleStatus.paid => l10n.posSaleStatusPaid,
  SaleStatus.cancelled => l10n.posSaleStatusCancelled,
};

/// The sales list's status column (spec 023 contracts/pos-sales-list.md §2).
/// Mirrors `CashSessionStatusChip`'s colour-pair shape: `cancelled` reads as
/// the muted/inactive state, `completed` (still owing money) gets the
/// attention-worthy tertiary pair, `paid` the calm success pair, and `draft`
/// the neutral in-progress pair.
class PosSaleStatusChip extends StatelessWidget {
  const PosSaleStatusChip({super.key, required this.status});

  final SaleStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = posSaleStatusLabel(l10n, status);

    return StatusChip<SaleStatus>(
      key: Key('pos_sale_status_chip_${status.name}'),
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
