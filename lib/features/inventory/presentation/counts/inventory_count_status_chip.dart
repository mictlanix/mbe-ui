import 'package:flutter/material.dart';

import 'package:mbe_ui/core/widgets/status_chip.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_document_status_chip.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// A count status's localized name (spec 070 research R2). Masculine forms,
/// unlike the shared document statuses.
String inventoryCountStatusLabel(
  AppLocalizations l10n,
  InventoryDocumentStatus status,
) => switch (status) {
  InventoryDocumentStatus.draft => l10n.inventoryCountStatusDraft,
  InventoryDocumentStatus.completed => l10n.inventoryCountStatusCompleted,
  InventoryDocumentStatus.cancelled => l10n.inventoryCountStatusCancelled,
};

/// The count's status chip, shared by the list and the detail screen. Its
/// tones are the shared document ones.
class InventoryCountStatusChip extends StatelessWidget {
  const InventoryCountStatusChip({super.key, required this.status});

  final InventoryDocumentStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (tone, icon) = inventoryDocumentStatusLook(status);
    return StatusChip<InventoryDocumentStatus>(
      key: const Key('inventory_count_status_chip'),
      value: status,
      label: inventoryCountStatusLabel(l10n, status),
      tone: tone,
      icon: icon,
    );
  }
}
