import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/sales/domain/entities/credit_note.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// What the cashier confirmed in [showCreditNoteTicketDialog]: the note, and
/// the exact amount the dialog showed as "Se aplicará" — so what is applied is
/// what was seen, never a figure recomputed after the fact.
class CreditNoteRedemption {
  const CreditNoteRedemption({required this.note, required this.amount});

  final CreditNote note;
  final String amount;
}

/// Redeems a walk-in credit-note ticket (spec 056 FR-005, FR-006, FR-006a):
/// the cashier scans or types the number under the ticket's barcode, sees what
/// is left on that note and what will be applied, and confirms.
///
/// [enteredAmount] is the Cobro step's own amount field. It can only lower
/// what is applied — the dialog has no amount field of its own, so there is
/// one place to say how much to take. Resolves to `null` when cancelled.
Future<CreditNoteRedemption?> showCreditNoteTicketDialog(
  BuildContext context, {
  required Sale sale,
  String? enteredAmount,
}) => showDialog<CreditNoteRedemption>(
  context: context,
  builder: (_) =>
      _CreditNoteTicketDialog(sale: sale, enteredAmount: enteredAmount),
);

class _CreditNoteTicketDialog extends ConsumerStatefulWidget {
  const _CreditNoteTicketDialog({required this.sale, this.enteredAmount});

  final Sale sale;
  final String? enteredAmount;

  @override
  ConsumerState<_CreditNoteTicketDialog> createState() =>
      _CreditNoteTicketDialogState();
}

class _CreditNoteTicketDialogState
    extends ConsumerState<_CreditNoteTicketDialog> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  bool _searching = false;
  CreditNoteLookup? _lookup;
  AppError? _error;

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  /// The number is looked up on Enter, which is what a keyboard-wedge scanner
  /// sends after the digits.
  Future<void> _search() async {
    final number = int.tryParse(_controller.text.trim());
    if (number == null || _searching) return;
    setState(() {
      _searching = true;
      _lookup = null;
      _error = null;
    });
    CreditNoteLookup? found;
    AppError? failure;
    try {
      found = await ref
          .read(paymentControllerProvider.notifier)
          .lookupCreditNoteTicket(widget.sale, number);
    } on AppError catch (e) {
      failure = e;
    }
    if (!mounted) return;
    setState(() {
      _searching = false;
      _lookup = found;
      _error = failure;
    });
    // A refusal leaves the number in place and focused, so the cashier can fix
    // a digit and press Enter again.
    _focus.requestFocus();
  }

  /// `min(remaining, sale balance, the Cobro amount when typed)` — the cap the
  /// dialog shows before it applies anything (wireframes Open Question 3).
  String _amountToApply(CreditNote note) {
    var amount = note.remaining;
    final balance = widget.sale.balanceOrZero;
    if (compareAmounts(balance, amount) < 0) amount = balance;
    final entered = widget.enteredAmount == null
        ? null
        : tryParseAmount(widget.enteredAmount!);
    if (entered != null &&
        compareAmounts(entered, '0') > 0 &&
        compareAmounts(entered, amount) < 0) {
      amount = entered;
    }
    return amount;
  }

  String _refusalMessage(AppLocalizations l10n, CreditNoteLookup lookup) =>
      switch (lookup.refusal!) {
        CreditNoteRefusal.notFound => l10n.creditNoteNotFound,
        CreditNoteRefusal.usedUp => l10n.creditNoteUsedUp,
        CreditNoteRefusal.alreadyOnSale => l10n.creditNoteAlreadyOnSale,
        CreditNoteRefusal.otherCustomer => l10n.creditNoteOtherCustomer(
          lookup.ownerName ?? '—',
        ),
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final fmt = ref.watch(formattersProvider);
    final lookup = _lookup;
    final note = lookup?.note;

    final Widget status;
    if (_searching) {
      status = Row(
        key: const Key('credit_note_ticket_searching'),
        children: [
          const SizedBox.square(
            dimension: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: spacing.sm),
          Text(l10n.creditNoteTicketSearching),
        ],
      );
    } else if (_error != null) {
      status = ErrorBanner(error: _error!);
    } else if (lookup != null && lookup.refusal != null) {
      status = Text(
        _refusalMessage(l10n, lookup),
        key: const Key('credit_note_ticket_refusal'),
        style: TextStyle(color: theme.colorScheme.error),
      );
    } else if (note != null) {
      status = Container(
        key: const Key('credit_note_ticket_found'),
        padding: EdgeInsets.all(spacing.sm),
        decoration: BoxDecoration(
          borderRadius: theme.shapes.mdRadius,
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.creditNoteTicketHeading(
                note.customerPaymentId,
                fmt.display.dateTime(note.date),
              ),
              style: theme.typeRoles.cardTitle,
            ),
            SizedBox(height: spacing.xs),
            Text(
              l10n.creditNoteTicketAvailable(
                fmt.display.currency(note.remaining),
              ),
            ),
            Text(
              l10n.creditNoteTicketWillApply(
                fmt.display.currency(_amountToApply(note)),
              ),
              key: const Key('credit_note_ticket_will_apply'),
              style: theme.typeRoles.money,
            ),
          ],
        ),
      );
    } else {
      status = const SizedBox.shrink();
    }

    return ResponsiveDialog(
      key: const Key('credit_note_ticket_dialog'),
      title: l10n.creditNoteTicketTitle,
      maxWidth: 440,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            key: const Key('credit_note_ticket_input'),
            controller: _controller,
            focusNode: _focus,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: l10n.creditNoteTicketInput,
              helperText: l10n.creditNoteTicketHelp,
              helperMaxLines: 2,
            ),
            // Typing again discards a previous answer, so a stale "Se aplicará"
            // can never be confirmed against a different number.
            onChanged: (_) {
              if (_lookup != null || _error != null) {
                setState(() {
                  _lookup = null;
                  _error = null;
                });
              }
            },
            onSubmitted: (_) => _search(),
          ),
          SizedBox(height: spacing.md),
          status,
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: () => Navigator.of(context).pop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('credit_note_ticket_confirm'),
        label: l10n.creditNoteTicketConfirm,
        onPressed: note == null || _searching
            ? null
            : () => Navigator.of(context).pop(
                CreditNoteRedemption(note: note, amount: _amountToApply(note)),
              ),
      ),
    );
  }
}
