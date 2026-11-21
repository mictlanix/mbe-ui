import 'package:flutter/material.dart';

import 'package:mbe_ui/core/widgets/status_chip.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// A document status's localized name (spec 066 C4).
String fiscalDocumentStatusLabel(
  AppLocalizations l10n,
  FiscalDocumentStatus status,
) => switch (status) {
  FiscalDocumentStatus.draft => l10n.fiscalDocumentStatusDraft,
  FiscalDocumentStatus.sealed => l10n.fiscalDocumentStatusSealed,
  FiscalDocumentStatus.stamping => l10n.fiscalDocumentStatusStamping,
  FiscalDocumentStatus.issued => l10n.fiscalDocumentStatusIssued,
  FiscalDocumentStatus.cancellationPending =>
    l10n.fiscalDocumentStatusCancellationPending,
  FiscalDocumentStatus.cancelled => l10n.fiscalDocumentStatusCancelled,
};

/// A status's tone (C4, spec 077): draft neutral, sealed info, issued success,
/// cancelled error. Stamping and cancellation pending are the "waiting" tone,
/// the one delivery orders and POS sales use too (spec 072 R10).
StatusLook fiscalDocumentStatusLook(FiscalDocumentStatus status) =>
    switch (status) {
      FiscalDocumentStatus.draft => (StatusTone.neutral, Icons.edit_note),
      FiscalDocumentStatus.sealed => (StatusTone.info, Icons.lock_outline),
      FiscalDocumentStatus.stamping => (StatusTone.warning, null),
      FiscalDocumentStatus.cancellationPending => (StatusTone.warning, null),
      FiscalDocumentStatus.issued => (StatusTone.success, null),
      FiscalDocumentStatus.cancelled => (StatusTone.error, null),
    };

/// The document's status chip, shared by the list and the detail screen.
/// Never truncated: give it the width its label needs.
class FiscalDocumentStatusChip extends StatelessWidget {
  const FiscalDocumentStatusChip({super.key, required this.status});

  final FiscalDocumentStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (tone, icon) = fiscalDocumentStatusLook(status);
    return StatusChip<FiscalDocumentStatus>(
      key: Key('fiscal_document_status_chip_${status.name}'),
      value: status,
      label: fiscalDocumentStatusLabel(l10n, status),
      tone: tone,
      icon: icon,
    );
  }
}
