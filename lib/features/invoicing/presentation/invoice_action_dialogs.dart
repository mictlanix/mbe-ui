import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/catalog/presentation/fiscal_document_kind_label.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_actions.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_refusal.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

// The confirmation dialogs the invoice detail screen opens (spec 066 C8, C12,
// C13). Each runs its own write through `FiscalDocumentActions`, which
// reloads the document whatever the outcome.

/// Asks before removing [line] from draft [documentId] (C8: "¿Quitar esta
/// partida de la factura?"), then removes it. A refusal shows inline and keeps
/// the dialog open. `true` once removed.
Future<bool> showRemoveInvoiceLineDialog(
  BuildContext context, {
  required int documentId,
  required InvoiceLine line,
}) async {
  final result = await showDialog<FiscalDocumentActionResult>(
    context: context,
    builder: (_) => _ConfirmActionDialog(
      dialogKey: const Key('invoice_line_remove_dialog'),
      submitKey: const Key('invoice_line_remove_submit'),
      title: (l10n) => l10n.fiscalDocumentRemoveLineTitle,
      body: (l10n) => l10n.fiscalDocumentRemoveLineBody,
      actionLabel: (l10n) => l10n.fiscalDocumentRemoveAction,
      refusalsInline: true,
      run: (actions) => actions.removeLine(documentId, line.id),
    ),
  );
  return result != null && result.error == null;
}

/// Asks before removing [paid] from receipt draft [documentId] (spec 074 C42),
/// then removes it. A refusal shows inline and keeps the dialog open. `true`
/// once removed.
Future<bool> showRemovePaidInvoiceDialog(
  BuildContext context, {
  required int documentId,
  required PaidInvoice paid,
}) async {
  final result = await showDialog<FiscalDocumentActionResult>(
    context: context,
    builder: (_) => _ConfirmActionDialog(
      dialogKey: const Key('paid_invoice_remove_dialog'),
      submitKey: const Key('paid_invoice_remove_submit'),
      title: (l10n) => l10n.removePaidInvoiceTitle,
      body: (l10n) => l10n.removePaidInvoiceBody(paid.folioLabel),
      actionLabel: (l10n) => l10n.fiscalDocumentRemoveAction,
      refusalsInline: true,
      run: (actions) => actions.removePaidInvoice(documentId, paid.relationId),
    ),
  );
  return result != null && result.error == null;
}

/// Asks before removing [relation] from draft [documentId] (C12), then
/// removes it. A refusal shows inline and keeps the dialog open. `true` once
/// removed.
Future<bool> showRemoveInvoiceRelationDialog(
  BuildContext context, {
  required int documentId,
  required InvoiceRelation relation,
}) async {
  final result = await showDialog<FiscalDocumentActionResult>(
    context: context,
    builder: (_) => _ConfirmActionDialog(
      dialogKey: const Key('invoice_relation_remove_dialog'),
      submitKey: const Key('invoice_relation_remove_submit'),
      title: (l10n) => l10n.fiscalDocumentRemoveRelationTitle,
      body: (l10n) => l10n.fiscalDocumentRemoveRelationBody,
      actionLabel: (l10n) => l10n.fiscalDocumentRemoveAction,
      refusalsInline: true,
      run: (actions) => actions.removeRelation(documentId, relation.id),
    ),
  );
  return result != null && result.error == null;
}

/// Asks before confirming (sealing) draft [document] (C13): a folio of its
/// series will be used, and it can only be reopened while it isn't stamped.
/// Any refusal closes the dialog and is answered to the caller to show above
/// its action area (each confirm-validation code has its own message). `null`
/// when the user backed out.
Future<FiscalDocumentActionResult?> showConfirmInvoiceDialog(
  BuildContext context, {
  required FiscalDocument document,
}) => showDialog<FiscalDocumentActionResult>(
  context: context,
  builder: (_) => _ConfirmActionDialog(
    dialogKey: const Key('invoice_confirm_dialog'),
    submitKey: const Key('invoice_confirm_submit'),
    title: (l10n) => l10n.fiscalDocumentConfirmTitle,
    body: (l10n) =>
        l10n.fiscalDocumentConfirmBody(document.summary.series ?? ''),
    actionLabel: (l10n) => l10n.fiscalDocumentConfirmAction,
    run: (actions) => actions.confirm(document.id),
  ),
);

/// Asks before reopening sealed [document] (C13): it goes back to draft and
/// keeps its folio, and the seal is discarded. Any refusal closes the dialog
/// and is answered to the caller. `null` when the user backed out.
Future<FiscalDocumentActionResult?> showReopenInvoiceDialog(
  BuildContext context, {
  required FiscalDocument document,
}) => showDialog<FiscalDocumentActionResult>(
  context: context,
  builder: (_) => _ConfirmActionDialog(
    dialogKey: const Key('invoice_reopen_dialog'),
    submitKey: const Key('invoice_reopen_submit'),
    title: (l10n) => l10n.fiscalDocumentReopenTitle,
    body: (l10n) => l10n.fiscalDocumentReopenBody(
      document.summary.folioLabel ?? '#${document.id}',
    ),
    actionLabel: (l10n) => l10n.fiscalDocumentReopenAction,
    run: (actions) => actions.reopen(document.id),
  ),
);

/// Asks before stamping sealed [document] (spec 072 C20): it goes to the PAC,
/// and once stamped it can no longer be reopened or edited, only cancelled.
/// Any refusal closes the dialog and is answered to the caller, which shows it
/// above its action area: each stamp refusal has its own message, and a
/// `pac.timeout` leaves the document stamping, so the screen reloads it.
/// `null` when the user backed out.
Future<FiscalDocumentActionResult?> showStampFiscalDocumentDialog(
  BuildContext context, {
  required FiscalDocument document,
}) => showDialog<FiscalDocumentActionResult>(
  context: context,
  builder: (_) => _ConfirmActionDialog(
    dialogKey: const Key('fiscal_document_stamp_dialog'),
    submitKey: const Key('fiscal_document_stamp_submit'),
    title: (l10n) => l10n.fiscalDocumentStampTitle(
      documentKindLabel(l10n, document),
      document.summary.folioLabel ?? '#${document.id}',
    ),
    body: (l10n) => l10n.fiscalDocumentStampBody,
    actionLabel: (l10n) => l10n.fiscalDocumentStampAction,
    run: (actions) => actions.stamp(document.id),
  ),
);

/// Asks before creating a credit-note draft for issued [invoice] (spec 073
/// C26). `Crear` runs the write; a refusal stays in the dialog, in the
/// clerk's words, and the buttons are off while the request runs. Answers the
/// new credit note's id, or `null` when the user backed out.
Future<int?> showIssueCreditNoteDialog(
  BuildContext context,
  FiscalDocument invoice,
) => showDialog<int>(
  context: context,
  builder: (_) => _IssueCreditNoteDialog(invoice: invoice),
);

class _IssueCreditNoteDialog extends ConsumerStatefulWidget {
  const _IssueCreditNoteDialog({required this.invoice});

  final FiscalDocument invoice;

  @override
  ConsumerState<_IssueCreditNoteDialog> createState() =>
      _IssueCreditNoteDialogState();
}

class _IssueCreditNoteDialogState
    extends ConsumerState<_IssueCreditNoteDialog> {
  bool _busy = false;
  AppError? _refusal;

  Future<void> _create() async {
    if (_busy) return;
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _refusal = null;
    });
    final result = await ref
        .read(fiscalDocumentActionsProvider.notifier)
        .createCreditNote(widget.invoice.id);
    if (!mounted) return;
    final id = result.id;
    if (id != null) {
      navigator.pop(id);
      return;
    }
    setState(() {
      _busy = false;
      _refusal = result.error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final summary = widget.invoice.summary;

    return ResponsiveDialog(
      key: const Key('issue_credit_note_dialog'),
      title: l10n.fiscalDocumentIssueCreditNoteTitle,
      dismissible: !_busy,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          Text(
            l10n.fiscalDocumentIssueCreditNoteBody(
              summary.folioLabel ?? '#${widget.invoice.id}',
              summary.recipientName ?? summary.recipientRfc ?? '',
            ),
          ),
          if (_refusal != null)
            KeyedSubtree(
              key: const Key('issue_credit_note_refusal'),
              child: FiscalDocumentRefusal(error: _refusal!),
            ),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        key: const Key('issue_credit_note_cancel'),
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).pop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('issue_credit_note_create'),
        label: l10n.fiscalDocumentIssueCreditNoteCreate,
        busy: _busy,
        onPressed: _create,
      ),
    );
  }
}

/// "Factura", or the name of the document's other type (also used by the
/// detail screen's sealed / reopened messages).
String documentKindLabel(AppLocalizations l10n, FiscalDocument document) {
  final kind = document.summary.kind;
  return kind == null
      ? l10n.fiscalDocumentKindUnknown(document.summary.typeCode)
      : fiscalDocumentKindLabel(l10n, kind);
}

/// One confirm-then-write dialog. With [refusalsInline] a refusal shows in
/// the dialog and keeps it open; otherwise it closes the dialog and is
/// answered to the caller to show above its action area. `null` when the user
/// backed out.
class _ConfirmActionDialog extends ConsumerStatefulWidget {
  const _ConfirmActionDialog({
    required this.dialogKey,
    required this.submitKey,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.run,
    this.refusalsInline = false,
  });

  final Key dialogKey;
  final Key submitKey;
  final String Function(AppLocalizations l10n) title;
  final String Function(AppLocalizations l10n) body;
  final String Function(AppLocalizations l10n) actionLabel;
  final Future<AppError?> Function(FiscalDocumentActions actions) run;
  final bool refusalsInline;

  @override
  ConsumerState<_ConfirmActionDialog> createState() =>
      _ConfirmActionDialogState();
}

class _ConfirmActionDialogState extends ConsumerState<_ConfirmActionDialog> {
  bool _busy = false;
  AppError? _refusal;

  Future<void> _run() async {
    if (_busy) return;
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _refusal = null;
    });
    final error = await widget.run(
      ref.read(fiscalDocumentActionsProvider.notifier),
    );
    if (!mounted) return;
    if (error != null && widget.refusalsInline) {
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
      key: widget.dialogKey,
      title: widget.title(l10n),
      dismissible: !_busy,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          Text(widget.body(l10n)),
          if (_refusal != null) FiscalDocumentRefusal(error: _refusal!),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).pop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: widget.submitKey,
        label: widget.actionLabel(l10n),
        busy: _busy,
        onPressed: _run,
      ),
    );
  }
}
