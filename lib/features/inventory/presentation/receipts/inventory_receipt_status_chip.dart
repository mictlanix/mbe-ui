import 'package:flutter/material.dart';

import 'package:mbe_ui/core/widgets/status_chip.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_receipt.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// A receipt status's localized name (spec 067).
String inventoryReceiptStatusLabel(
  AppLocalizations l10n,
  ReceiptStatus status,
) => switch (status) {
  ReceiptStatus.draft => l10n.inventoryReceiptStatusDraft,
  ReceiptStatus.completed => l10n.inventoryReceiptStatusCompleted,
  ReceiptStatus.cancelled => l10n.inventoryReceiptStatusCancelled,
};

/// A status's `(background, foreground)` pair: draft neutral, confirmed
/// success, cancelled error.
(Color, Color) inventoryReceiptStatusColors(
  ColorScheme scheme,
  ReceiptStatus status,
) => switch (status) {
  ReceiptStatus.draft => (scheme.surfaceContainerHighest, scheme.onSurface),
  ReceiptStatus.completed => (
    scheme.secondaryContainer,
    scheme.onSecondaryContainer,
  ),
  ReceiptStatus.cancelled => (scheme.errorContainer, scheme.onErrorContainer),
};

/// The receipt's status chip, shared by the list and the detail screen.
class InventoryReceiptStatusChip extends StatelessWidget {
  const InventoryReceiptStatusChip({super.key, required this.status});

  final ReceiptStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return StatusChip<ReceiptStatus>(
      key: const Key('inventory_receipt_status_chip'),
      value: status,
      label: inventoryReceiptStatusLabel(l10n, status),
      colors: (scheme) => inventoryReceiptStatusColors(scheme, status),
    );
  }
}
