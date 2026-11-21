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

/// A status's tone: draft neutral, in transit info, received success,
/// cancelled error.
StatusLook inventoryTransferStatusLook(InventoryTransferStatus status) =>
    switch (status) {
      InventoryTransferStatus.draft => (StatusTone.neutral, Icons.edit_note),
      InventoryTransferStatus.inTransit => (
        StatusTone.info,
        Icons.local_shipping_outlined,
      ),
      InventoryTransferStatus.received => (StatusTone.success, null),
      InventoryTransferStatus.cancelled => (StatusTone.error, null),
    };

/// The transfer's status chip, shared by the list and the detail screen.
class InventoryTransferStatusChip extends StatelessWidget {
  const InventoryTransferStatusChip({super.key, required this.status});

  final InventoryTransferStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (tone, icon) = inventoryTransferStatusLook(status);
    return StatusChip<InventoryTransferStatus>(
      key: const Key('inventory_transfer_status_chip'),
      value: status,
      label: inventoryTransferStatusLabel(l10n, status),
      tone: tone,
      icon: icon,
    );
  }
}
