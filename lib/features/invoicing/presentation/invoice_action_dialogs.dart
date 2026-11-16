import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
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
