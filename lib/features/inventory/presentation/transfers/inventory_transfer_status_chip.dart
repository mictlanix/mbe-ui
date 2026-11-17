import 'package:flutter/material.dart';

import 'package:mbe_ui/core/widgets/status_chip.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_transfer.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// A transfer status's localized name (spec 069). Masculine forms, unlike
/// the shared document statuses.
String inventoryTransferStatusLabel(
  AppLocalizations l10n,
  InventoryTransferStatus status,
) => switch (status) {
  InventoryTransferStatus.draft => l10n.inventoryTransferStatusDraft,
  InventoryTransferStatus.inTransit => l10n.inventoryTransferStatusInTransit,
  InventoryTransferStatus.received => l10n.inventoryTransferStatusReceived,
  InventoryTransferStatus.cancelled => l10n.inventoryTransferStatusCancelled,
};

/// A status's `(background, foreground)` pair: draft neutral, in transit
/// tertiary, received success, cancelled error.
(Color, Color) inventoryTransferStatusColors(
  ColorScheme scheme,
  InventoryTransferStatus status,
) => switch (status) {
  InventoryTransferStatus.draft => (
    scheme.surfaceContainerHighest,
    scheme.onSurface,
  ),
  InventoryTransferStatus.inTransit => (
    scheme.tertiaryContainer,
    scheme.onTertiaryContainer,
  ),
  InventoryTransferStatus.received => (
    scheme.secondaryContainer,
    scheme.onSecondaryContainer,
  ),
  InventoryTransferStatus.cancelled => (
    scheme.errorContainer,
    scheme.onErrorContainer,
  ),
};

/// The transfer's status chip, shared by the list and the detail screen.
class InventoryTransferStatusChip extends StatelessWidget {
  const InventoryTransferStatusChip({super.key, required this.status});

  final InventoryTransferStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return StatusChip<InventoryTransferStatus>(
      key: const Key('inventory_transfer_status_chip'),
      value: status,
      label: inventoryTransferStatusLabel(l10n, status),
      colors: (scheme) => inventoryTransferStatusColors(scheme, status),
    );
  }
}
