import 'package:flutter/material.dart';

import 'package:mbe_ui/core/widgets/status_chip.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// A receipt status's localized name (spec 067).
String inventoryDocumentStatusLabel(
  AppLocalizations l10n,
  InventoryDocumentStatus status,
) => switch (status) {
  InventoryDocumentStatus.draft => l10n.inventoryDocumentStatusDraft,
  InventoryDocumentStatus.completed => l10n.inventoryDocumentStatusCompleted,
  InventoryDocumentStatus.cancelled => l10n.inventoryDocumentStatusCancelled,
};

/// A status's `(background, foreground)` pair: draft neutral, confirmed
/// success, cancelled error.
(Color, Color) inventoryDocumentStatusColors(
  ColorScheme scheme,
  InventoryDocumentStatus status,
) => switch (status) {
  InventoryDocumentStatus.draft => (
    scheme.surfaceContainerHighest,
    scheme.onSurface,
  ),
  InventoryDocumentStatus.completed => (
    scheme.secondaryContainer,
    scheme.onSecondaryContainer,
  ),
  InventoryDocumentStatus.cancelled => (
    scheme.errorContainer,
    scheme.onErrorContainer,
  ),
};

/// The receipt's status chip, shared by the list and the detail screen.
class InventoryDocumentStatusChip extends StatelessWidget {
  const InventoryDocumentStatusChip({super.key, required this.status});

  final InventoryDocumentStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return StatusChip<InventoryDocumentStatus>(
      key: const Key('inventory_document_status_chip'),
      value: status,
      label: inventoryDocumentStatusLabel(l10n, status),
      colors: (scheme) => inventoryDocumentStatusColors(scheme, status),
    );
  }
}
