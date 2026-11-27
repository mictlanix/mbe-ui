import 'package:flutter/material.dart';

import 'package:mbe_ui/core/widgets/status_chip.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_request.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// A request status's localized name (spec 079).
String purchaseRequestStatusLabel(
  AppLocalizations l10n,
  PurchaseRequestStatus status,
) => switch (status) {
  PurchaseRequestStatus.draft => l10n.purchaseRequestStatusDraft,
  PurchaseRequestStatus.submitted => l10n.purchaseRequestStatusSubmitted,
  PurchaseRequestStatus.approved => l10n.purchaseRequestStatusApproved,
  PurchaseRequestStatus.cancelled => l10n.purchaseRequestStatusCancelled,
};

/// A status's tone and icon (data-model.md): every status shows an icon and a
/// word, so none relies on colour alone.
StatusLook purchaseRequestStatusLook(PurchaseRequestStatus status) =>
    switch (status) {
      PurchaseRequestStatus.draft => (StatusTone.neutral, Icons.edit_note),
      PurchaseRequestStatus.submitted => (StatusTone.info, Icons.schedule_send),
      PurchaseRequestStatus.approved => (StatusTone.success, Icons.task_alt),
      PurchaseRequestStatus.cancelled => (StatusTone.error, Icons.block),
    };

/// The request's status chip, shared by the list and the detail screen.
class PurchaseRequestStatusChip extends StatelessWidget {
  const PurchaseRequestStatusChip({super.key, required this.status});

  final PurchaseRequestStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (tone, icon) = purchaseRequestStatusLook(status);
    return StatusChip<PurchaseRequestStatus>(
      key: const Key('purchase_request_status_chip'),
      value: status,
      label: purchaseRequestStatusLabel(l10n, status),
      tone: tone,
      icon: icon,
    );
  }
}
