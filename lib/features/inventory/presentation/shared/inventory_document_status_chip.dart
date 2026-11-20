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

/// A status's tone: draft neutral, confirmed success, cancelled error.
StatusLook inventoryDocumentStatusLook(InventoryDocumentStatus status) =>
    switch (status) {
      InventoryDocumentStatus.draft => (StatusTone.neutral, Icons.edit_note),
      InventoryDocumentStatus.completed => (StatusTone.success, null),
      InventoryDocumentStatus.cancelled => (StatusTone.error, null),
    };

/// The receipt's status chip, shared by the list and the detail screen.
class InventoryDocumentStatusChip extends StatelessWidget {
  const InventoryDocumentStatusChip({super.key, required this.status});

  final InventoryDocumentStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (tone, icon) = inventoryDocumentStatusLook(status);
    return StatusChip<InventoryDocumentStatus>(
      key: const Key('inventory_document_status_chip'),
      value: status,
      label: inventoryDocumentStatusLabel(l10n, status),
      tone: tone,
      icon: icon,
    );
  }
}
