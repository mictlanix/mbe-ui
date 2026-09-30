import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/documents/domain/document_kind.dart';
import 'package:mbe_ui/core/documents/domain/document_ref.dart';
import 'package:mbe_ui/core/documents/presentation/document_actions.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The "Venta completada" dialog (FR-050): the finished sale's folio, a way to
/// print its ticket, and the way to start the next sale.
///
/// "Imprimir ticket" sends the final receipt straight to the device's print
/// dialog with no preview, because a cashier does it on every sale (spec 044
/// FR-002). The dialog stays open afterwards so the ticket can be printed
/// again, and "Nueva venta" stays the primary action so the default key still
/// starts the next sale. The order is committed on the server before this
/// dialog is shown, so the server answers with the receipt, never the
/// pre-payment ticket.
class PosSaleCompletedDialog extends ConsumerStatefulWidget {
  const PosSaleCompletedDialog({
    super.key,
    required this.saleId,
    required this.reference,
    required this.onNewSale,
  });

  /// The sale's id; `null` hides the print action.
  final int? saleId;

  /// The folio (or provisional reference) shown to the cashier.
  final String reference;

  final VoidCallback onNewSale;

  @override
  ConsumerState<PosSaleCompletedDialog> createState() =>
      _PosSaleCompletedDialogState();
}

class _PosSaleCompletedDialogState
    extends ConsumerState<PosSaleCompletedDialog> {
  bool _printing = false;
  AppError? _error;

  Future<void> _print(int saleId) async {
    final title = AppLocalizations.of(
      context,
    )!.documentTicketTitle(widget.reference);
    setState(() {
      _printing = true;
      _error = null;
    });
    try {
      await ref
          .read(documentActionsProvider)
          .printDirect(
            DocumentRef(
              kind: DocumentKind.saleTicket,
              recordId: saleId,
              title: title,
            ),
          );
    } catch (e) {
      // A platform failure (no printer service, for one) is not an AppError;
      // it reads as a generic failure rather than escaping the handler.
      if (mounted) {
        setState(() => _error = e is AppError ? e : const AppError.server());
      }
    } finally {
      if (mounted) {
        setState(() => _printing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final saleId = widget.saleId;
    final canPrint =
        saleId != null &&
        canOpenDocument(
          ref.watch(accessControlProvider),
          DocumentKind.saleTicket,
        );
    final error = _error;

    return AlertDialog(
      title: Text(l10n.posSaleCompletedTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.posSaleReference(widget.reference)),
          if (error != null) ...[
            SizedBox(height: spacing.sm),
            Text(l10n.posSalePrintTicketError),
            SizedBox(height: spacing.xxs),
            ErrorBanner(error: error),
          ],
        ],
      ),
      actions: [
        if (canPrint)
          OutlinedButton.icon(
            key: const Key('print_ticket_button'),
            onPressed: _printing ? null : () => _print(saleId),
            icon: _printing
                ? SizedBox.square(
                    dimension: spacing.md,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.print_outlined),
            label: Text(
              error != null ? l10n.retryButton : l10n.posSalePrintTicketAction,
            ),
          ),
        FilledButton(
          key: const Key('start_new_sale_button'),
          onPressed: widget.onNewSale,
          child: Text(l10n.posNewSaleAction),
        ),
      ],
    );
  }
}
