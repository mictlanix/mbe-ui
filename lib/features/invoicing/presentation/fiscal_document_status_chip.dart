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
  FiscalDocumentStatus.issued => l10n.fiscalDocumentStatusIssued,
  FiscalDocumentStatus.cancelled => l10n.fiscalDocumentStatusCancelled,
};

/// A status's `(background, foreground)` pair (C4): draft neutral, sealed
/// info, issued success, cancelled error.
(Color, Color) fiscalDocumentStatusColors(
  ColorScheme scheme,
  FiscalDocumentStatus status,
) => switch (status) {
  FiscalDocumentStatus.draft => (
    scheme.surfaceContainerHighest,
    scheme.onSurface,
  ),
  FiscalDocumentStatus.sealed => (
    scheme.primaryContainer,
    scheme.onPrimaryContainer,
  ),
  FiscalDocumentStatus.issued => (
    scheme.secondaryContainer,
    scheme.onSecondaryContainer,
  ),
  FiscalDocumentStatus.cancelled => (
    scheme.errorContainer,
    scheme.onErrorContainer,
  ),
};

/// The document's status chip, shared by the list and the detail screen.
/// Never truncated: give it the width its label needs.
class FiscalDocumentStatusChip extends StatelessWidget {
  const FiscalDocumentStatusChip({super.key, required this.status});

  final FiscalDocumentStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return StatusChip<FiscalDocumentStatus>(
      key: Key('fiscal_document_status_chip_${status.name}'),
      value: status,
      label: fiscalDocumentStatusLabel(l10n, status),
      colors: (scheme) => fiscalDocumentStatusColors(scheme, status),
    );
  }
}
