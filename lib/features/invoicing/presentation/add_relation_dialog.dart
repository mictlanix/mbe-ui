import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_actions.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_candidate_picker.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_labels.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_refusal.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Adds a related document to draft [document] (spec 066 C12): a relation
/// type (04 substitution of a cancelled invoice, 07 application of an
/// advance) and a document of the same issuer and recipient to relate. The
/// type is locked to the one the invoice already has, since an invoice has
/// one relation type.
///
/// The picker lists cancelled documents for 04 and issued ones for 07, with
/// the search prefilled with the recipient's RFC. `relation_not_allowed`,
/// `already_related` and `relation_types_mixed` stay inline so another
/// document can be picked; any other refusal closes the dialog and is
/// answered to the caller. `null` when the user backed out.
Future<FiscalDocumentActionResult?> showAddInvoiceRelationDialog(
  BuildContext context, {
  required FiscalDocument document,
}) => showResponsiveDialog<FiscalDocumentActionResult>(
  context,
  builder: (_) => _AddRelationDialog(document: document),
);

const _inlineCodes = {
  api.ErrorCode.fiscalDocumentPeriodRelationNotAllowed,
  api.ErrorCode.fiscalDocumentPeriodAlreadyRelated,
  api.ErrorCode.fiscalDocumentPeriodRelationTypesMixed,
};

class _AddRelationDialog extends ConsumerStatefulWidget {
  const _AddRelationDialog({required this.document});

  final FiscalDocument document;

  @override
  ConsumerState<_AddRelationDialog> createState() => _AddRelationDialogState();
}

class _AddRelationDialogState extends ConsumerState<_AddRelationDialog> {
  late InvoiceRelationType _type =
      widget.document.relationType ?? InvoiceRelationType.substitution;

  bool _busy = false;
  AppError? _refusal;

  FiscalDocument get _doc => widget.document;

  /// Locked to the type the invoice already has, if it has one.
  bool get _typeLocked => _doc.relationType != null;

  Future<void> _add(FiscalDocumentSummary target) async {
    if (_busy) return;
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _refusal = null;
    });
    final error = await ref
        .read(fiscalDocumentActionsProvider.notifier)
        .addRelation(_doc.id, target.id, _type);
    if (!mounted) return;
    if (error != null && _inlineCodes.contains(error.problem?.code)) {
      setState(() {
        _busy = false;
        _refusal = error;
      });
      return;
    }
    navigator.pop((error: error));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;

    return ResponsiveDialog(
      key: const Key('add_relation_dialog'),
      title: l10n.fiscalDocumentAddRelationTitle,
      dismissible: !_busy,
      maxWidth: 720,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          DropdownButtonFormField<InvoiceRelationType>(
            key: const Key('add_relation_type'),
            initialValue: _type,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l10n.fiscalDocumentRelationType,
            ),
            items: [
              for (final t in [
                InvoiceRelationType.substitution,
                InvoiceRelationType.advanceApplication,
              ])
                DropdownMenuItem(
                  value: t,
                  child: Text(invoiceRelationTypeLabel(l10n, t)),
                ),
            ],
            onChanged: _typeLocked || _busy
                ? null
                : (t) {
                    if (t == null || t == _type) return;
                    setState(() => _type = t);
                  },
          ),
          // The picker reloads when the status it lists changes.
          FiscalDocumentCandidatePicker(
            keyPrefix: 'add_relation',
            issuerRfc: _doc.summary.issuerRfc,
            status: _type == InvoiceRelationType.substitution
                ? FiscalDocumentStatus.cancelled
                : FiscalDocumentStatus.issued,
            initialSearch: _doc.summary.recipientRfc ?? '',
            emptyMessage: l10n.fiscalDocumentRelationEmpty,
            enabled: !_busy,
            onPicked: _add,
            notice: _refusal == null
                ? null
                : FiscalDocumentRefusal(error: _refusal!),
          ),
        ],
      ),
      // Picking a row is the action, so the only button closes the dialog.
      primaryAction: ResponsiveDialogAction(
        key: const Key('add_relation_close'),
        label: l10n.cancelButton,
        busy: _busy,
        onPressed: _busy ? null : () => Navigator.of(context).pop(),
      ),
    );
  }
}
