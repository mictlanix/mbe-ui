import 'package:flutter/material.dart';

import 'package:mbe_ui/core/widgets/status_chip.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_origin.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The localized name of an order's [origin] — shared by both sales lists
/// (spec 041 contracts/origin-filter.md §5). `null` reads as *unrecorded*,
/// never as a synonym for either workflow (sale_origin.dart).
String saleOriginLabel(AppLocalizations l10n, SaleOrigin? origin) => switch (origin) {
  SaleOrigin.pointOfSale => l10n.saleOriginPointOfSale,
  SaleOrigin.backOffice => l10n.saleOriginBackOffice,
  null => l10n.saleOriginUnrecorded,
};

/// Both sales lists' origin column (spec 041 FR-006, contracts/origin-filter.md §5).
/// Mirrors `PosSaleStatusChip`'s shape: a thin wrapper over the shared
/// [StatusChip], with the unrecorded state reading as the muted/inactive
/// pair since it carries no positive information about either workflow.
class SaleOriginChip extends StatelessWidget {
  const SaleOriginChip({super.key, required this.origin});

  final SaleOrigin? origin;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = saleOriginLabel(l10n, origin);

    return StatusChip<SaleOrigin?>(
      key: Key('sale_origin_chip_${origin?.name ?? 'unrecorded'}'),
      value: origin,
      label: label,
      colors: (scheme) => switch (origin) {
        SaleOrigin.pointOfSale => (scheme.primaryContainer, scheme.onPrimaryContainer),
        SaleOrigin.backOffice => (scheme.tertiaryContainer, scheme.onTertiaryContainer),
        null => (scheme.surfaceContainerHighest, scheme.onSurfaceVariant),
      },
    );
  }
}
