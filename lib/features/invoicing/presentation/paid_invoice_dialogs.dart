import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_actions.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_candidate_picker.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_refusal.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Adds a paid invoice to receipt draft [receipt] (spec 074 C41): a stamped
/// invoice of the receipt's issuer and recipient, with an optional amount.
/// Blank means the server's default: the invoice's balance, up to what is left
/// of the payment (research R5).
///
/// Every refusal (`invoice_not_payable`, `invoice_already_on_receipt`,
/// `amount_exceeds_balance`, `amounts_exceed_payment`,
/// `payment_date_out_of_range`) stays inline so another invoice can be picked.
/// `true` once an invoice was added.
Future<bool> showAddPaidInvoiceDialog(
  BuildContext context, {
  required FiscalDocument receipt,
}) async {
  final added = await showResponsiveDialog<bool>(
    context,
    builder: (_) => _AddPaidInvoiceDialog(receipt: receipt),
  );
  return added ?? false;
}

class _AddPaidInvoiceDialog extends ConsumerStatefulWidget {
  const _AddPaidInvoiceDialog({required this.receipt});

  final FiscalDocument receipt;

  @override
  ConsumerState<_AddPaidInvoiceDialog> createState() =>
      _AddPaidInvoiceDialogState();
}

class _AddPaidInvoiceDialogState extends ConsumerState<_AddPaidInvoiceDialog> {
  final _amount = TextEditingController();
  FiscalDocumentSummary? _picked;
  bool _busy = false;
  AppError? _refusal;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  /// `null` for a blank field, which asks for the server's default.
  Decimal? get _amountValue {
    final text = _amount.text.trim();
    if (text.isEmpty) return null;
    final parsed = ref.read(formattersProvider).field.parsePrice(text);
    return parsed == null ? null : Decimal.tryParse(parsed);
  }

  bool get _amountValid {
    if (_amount.text.trim().isEmpty) return true;
    final v = _amountValue;
    return v != null && v > Decimal.zero;
  }

  bool get _canSubmit => !_busy && _picked != null && _amountValid;

  Future<void> _submit() async {
    final picked = _picked;
    if (!_canSubmit || picked == null) return;
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _refusal = null;
    });
    final error = await ref
        .read(fiscalDocumentActionsProvider.notifier)
        .addPaidInvoice(widget.receipt.id, picked.id, amount: _amountValue);
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _busy = false;
        _refusal = error;
      });
      return;
    }
    navigator.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final receipt = widget.receipt;
    final picked = _picked;

    return ResponsiveDialog(
      key: const Key('add_paid_invoice_dialog'),
      title: l10n.addPaidInvoiceTitle,
      dismissible: !_busy,
      maxWidth: 720,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          Text(
            l10n.addPaidInvoiceIntro(
              receipt.summary.issuerRfc,
              receipt.summary.recipientRfc ?? '',
            ),
          ),
          FiscalDocumentCandidatePicker(
            keyPrefix: 'add_paid_invoice',
            issuerRfc: receipt.summary.issuerRfc,
            status: FiscalDocumentStatus.issued,
            typeCode: 0,
            excludeIds: {for (final p in receipt.paidInvoices) p.invoiceId},
            initialSearch: receipt.summary.recipientRfc ?? '',
            recipientRfc: receipt.summary.recipientRfc,
            emptyMessage: l10n.addPaidInvoiceEmpty,
            enabled: !_busy,
            onPicked: (d) => setState(() {
              _picked = d;
              _refusal = null;
            }),
            notice: _refusal == null
                ? null
                : FiscalDocumentRefusal(
                    key: const Key('add_paid_invoice_refusal'),
                    error: _refusal!,
                  ),
          ),
          if (picked != null)
            Text(
              picked.folioLabel ?? '#${picked.id}',
              key: const Key('add_paid_invoice_selected'),
              style: Theme.of(context).textTheme.titleSmall,
            ),
          TextField(
            key: const Key('add_paid_invoice_amount'),
            controller: _amount,
            enabled: !_busy,
            textAlign: TextAlign.end,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.addPaidInvoiceAmountLabel,
              helperText: l10n.addPaidInvoiceAmountHelper,
              errorText: _amountValid
                  ? null
                  : l10n.editPaidInvoiceAmountPositive,
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).pop(false),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('add_paid_invoice_submit'),
        label: l10n.addPaidInvoiceSubmit,
        busy: _busy,
        onPressed: _canSubmit ? _submit : null,
      ),
    );
  }
}

/// Changes the amount [paid] on receipt draft [receipt] (spec 074 C42): more
/// than 0 and no more than its previous balance. The server's refusals
/// (`amount_exceeds_balance`, `amounts_exceed_payment`) stay inline. `true`
/// once saved.
Future<bool> showEditPaidInvoiceDialog(
  BuildContext context, {
  required FiscalDocument receipt,
  required PaidInvoice paid,
}) async {
  final saved = await showResponsiveDialog<bool>(
    context,
    builder: (_) => _EditPaidInvoiceDialog(receipt: receipt, paid: paid),
  );
  return saved ?? false;
}

class _EditPaidInvoiceDialog extends ConsumerStatefulWidget {
  const _EditPaidInvoiceDialog({required this.receipt, required this.paid});

  final FiscalDocument receipt;
  final PaidInvoice paid;

  @override
  ConsumerState<_EditPaidInvoiceDialog> createState() =>
      _EditPaidInvoiceDialogState();
}

class _EditPaidInvoiceDialogState
    extends ConsumerState<_EditPaidInvoiceDialog> {
  late final TextEditingController _amount;
  late final String _initial;
  bool _busy = false;
  AppError? _refusal;

  @override
  void initState() {
    super.initState();
    _initial = ref
        .read(formattersProvider)
        .field
        .price(widget.paid.amount.toString());
    _amount = TextEditingController(text: _initial);
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Decimal? get _value {
    final parsed = ref.read(formattersProvider).field.parsePrice(_amount.text);
    return parsed == null ? null : Decimal.tryParse(parsed);
  }

  bool get _positive => (_value ?? Decimal.zero) > Decimal.zero;
  bool get _withinBalance =>
      (_value ?? Decimal.zero) <= widget.paid.previousBalance;
  bool get _canSave =>
      !_busy && _positive && _withinBalance && _amount.text.trim() != _initial;

  Future<void> _save() async {
    final value = _value;
    if (!_canSave || value == null) return;
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _refusal = null;
    });
    final error = await ref
        .read(fiscalDocumentActionsProvider.notifier)
        .updatePaidInvoice(widget.receipt.id, widget.paid.relationId, value);
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _busy = false;
        _refusal = error;
      });
      return;
    }
    navigator.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final fmt = ref.watch(formattersProvider);

    return ResponsiveDialog(
      key: const Key('edit_paid_invoice_dialog'),
      title: l10n.editPaidInvoiceTitle(widget.paid.folioLabel),
      dismissible: !_busy,
      hasUnsavedChanges: () => _amount.text.trim() != _initial,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          Text(
            l10n.editPaidInvoicePreviousBalance(
              fmt.display.currency(widget.paid.previousBalance.toString()),
            ),
            key: const Key('edit_paid_invoice_previous_balance'),
          ),
          TextField(
            key: const Key('edit_paid_invoice_amount'),
            controller: _amount,
            enabled: !_busy,
            autofocus: true,
            textAlign: TextAlign.end,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.addPaidInvoiceAmountLabel,
              errorText: !_positive
                  ? l10n.editPaidInvoiceAmountPositive
                  : !_withinBalance
                  ? l10n.editPaidInvoiceAmountMax(
                      fmt.display.currency(
                        widget.paid.previousBalance.toString(),
                      ),
                    )
                  : null,
            ),
            onChanged: (_) => setState(() {}),
          ),
          if (_refusal != null)
            FiscalDocumentRefusal(
              key: const Key('edit_paid_invoice_refusal'),
              error: _refusal!,
            ),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).pop(false),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('edit_paid_invoice_submit'),
        label: l10n.saveButton,
        busy: _busy,
        onPressed: _canSave ? _save : null,
      ),
    );
  }
}
