import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart' show toAppError;
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer_list_item.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_actions.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_refusal.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_payment.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payment_widgets.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// "Nueva factura" (spec 066 C6): pick a customer, then one of its RFCs, and
/// start an invoice draft. Answers the new document's id, or `null` when the
/// user backed out. Every refusal (`issuer_has_no_series`,
/// `recipient_not_linked`, `user.no_facility`) stays inline.
Future<int?> showNewInvoiceDialog(BuildContext context) =>
    showNewFiscalDocumentDialog(context, NewFiscalDocumentMode.invoice);

/// What the shared create dialog starts (spec 074 C35, R13).
class NewFiscalDocumentMode {
  const NewFiscalDocumentMode._(this._kind, [this.payment]);

  /// "Nueva factura" (spec 066).
  static const invoice = NewFiscalDocumentMode._(_Kind.invoice);

  /// "Nuevo complemento de pago", by hand: the customer is picked.
  static const receipt = NewFiscalDocumentMode._(_Kind.receipt);

  /// "Emitir complemento de pago" from a customer payment: the customer is
  /// the payment's, and the server proposes the invoices it settles.
  factory NewFiscalDocumentMode.receiptFromPayment(CustomerPayment payment) =>
      NewFiscalDocumentMode._(_Kind.receiptFromPayment, payment);

  final _Kind _kind;

  /// The payment a receipt starts from; `null` in the other modes.
  final CustomerPayment? payment;

  bool get isReceipt => _kind != _Kind.invoice;
}

enum _Kind { invoice, receipt, receiptFromPayment }

/// The create dialog for an invoice, a payment receipt by hand, or a payment
/// receipt from a customer payment. Answers the new (or, for a payment that
/// already has a receipt, the existing) document's id, or `null` when the
/// user backed out.
Future<int?> showNewFiscalDocumentDialog(
  BuildContext context,
  NewFiscalDocumentMode mode,
) => showDialog<int>(
  context: context,
  builder: (_) => _NewInvoiceDialog(mode: mode),
);

class _NewInvoiceDialog extends ConsumerStatefulWidget {
  const _NewInvoiceDialog({required this.mode});

  final NewFiscalDocumentMode mode;

  @override
  ConsumerState<_NewInvoiceDialog> createState() => _NewInvoiceDialogState();
}

class _NewInvoiceDialogState extends ConsumerState<_NewInvoiceDialog> {
  int? _customerId;
  Future<Customer>? _customer;
  String? _rfc;
  bool _busy = false;
  AppError? _refusal;

  @override
  void initState() {
    super.initState();
    // A receipt from a payment is for that payment's customer: nothing to pick.
    final payment = widget.mode.payment;
    if (payment != null) {
      _customerId = payment.customerId;
      _customer = ref
          .read(customerRepositoryProvider)
          .get(customerId: payment.customerId);
    }
  }

  void _pick(CustomerListItem item) {
    setState(() {
      _customerId = item.customerId;
      _rfc = null;
      _refusal = null;
      _customer = ref
          .read(customerRepositoryProvider)
          .get(customerId: item.customerId);
    });
  }

  Future<void> _create() async {
    final customerId = _customerId;
    final rfc = _rfc;
    if (_busy || customerId == null || rfc == null) return;
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _refusal = null;
    });
    final actions = ref.read(fiscalDocumentActionsProvider.notifier);
    final result = widget.mode.isReceipt
        ? await actions.createPaymentReceipt(
            NewPaymentReceipt(
              customerId: customerId,
              recipientRfc: rfc,
              customerPaymentId: widget.mode.payment?.customerPaymentId,
            ),
          )
        : await actions.create(
            NewInvoice(customerId: customerId, recipientRfc: rfc),
          );
    if (!mounted) return;
    final error = result.error;
    if (error != null) {
      setState(() {
        _busy = false;
        _refusal = error;
      });
      return;
    }
    navigator.pop(result.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final fmt = ref.watch(formattersProvider);
    final payment = widget.mode.payment;
    final title = payment != null
        ? l10n.fiscalDocumentIssueReceiptTitle
        : widget.mode.isReceipt
        ? l10n.fiscalDocumentNewReceiptTitle
        : l10n.fiscalDocumentNewTitle;
    // The payment a receipt was already made for (spec 074 R9): the server
    // sends its id, not its folio, so the dialog offers to open it.
    final problem = _refusal?.problem;
    final existingReceipt =
        problem?.code ==
            api.ErrorCode.fiscalDocumentPeriodPaymentAlreadyReceipted
        ? problem?.intParam('fiscal_document_id')
        : null;

    return ResponsiveDialog(
      key: const Key('new_invoice_dialog'),
      title: title,
      dismissible: !_busy,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          if (payment != null) ...[
            Text(
              l10n.fiscalDocumentIssueReceiptPaymentSummary(
                payment.customerPaymentId,
                payment.customerName ?? '#${payment.customerId}',
                paymentAmountLabel(fmt, payment.amount, payment.currency),
                fmt.display.date(payment.date),
              ),
              key: const Key('new_receipt_payment_summary'),
            ),
            Text(
              l10n.fiscalDocumentIssueReceiptHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ] else if (widget.mode.isReceipt)
            Text(
              l10n.fiscalDocumentNewReceiptHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          if (payment == null)
            CatalogEntityPicker<CustomerListItem>(
              key: const Key('new_invoice_customer'),
              label: l10n.fiscalDocumentNewCustomer,
              enabled: !_busy,
              displayStringForOption: (c) => '${c.code} — ${c.name}',
              optionsBuilder: (search) async {
                final result = await ref
                    .read(customerRepositoryProvider)
                    .list(search: search.isEmpty ? null : search, limit: 10);
                return result.items;
              },
              onSelected: _pick,
            ),
          if (_customer != null)
            FutureBuilder<Customer>(
              key: ValueKey(_customerId),
              future: _customer,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return FiscalDocumentRefusal(
                    error: toAppError(snapshot.error!),
                  );
                }
                final customer = snapshot.data;
                if (customer == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                final taxpayers = customer.taxpayers;
                if (taxpayers.isEmpty) {
                  return Text(
                    l10n.fiscalDocumentNewNoTaxpayers,
                    key: const Key('new_invoice_no_taxpayers'),
                  );
                }
                // One RFC needs no choice.
                final selected =
                    _rfc ??
                    (taxpayers.length == 1
                        ? taxpayers.single.taxpayerRecipientId
                        : null);
                if (selected != _rfc) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _rfc = selected);
                  });
                }
                return DropdownButtonFormField<String>(
                  key: const Key('new_invoice_recipient'),
                  initialValue: selected,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l10n.fiscalDocumentNewRecipient,
                  ),
                  items: [
                    for (final t in taxpayers)
                      DropdownMenuItem(
                        value: t.taxpayerRecipientId,
                        child: Text(
                          '${t.taxpayerRecipientId} · ${t.name}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: _busy ? null : (v) => setState(() => _rfc = v),
                );
              },
            ),
          if (_refusal != null) FiscalDocumentRefusal(error: _refusal!),
          if (existingReceipt != null)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                key: const Key('new_receipt_open_existing'),
                onPressed: () => Navigator.of(context).pop(existingReceipt),
                child: Text(l10n.fiscalDocumentReceiptOpenExisting),
              ),
            ),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).pop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('new_invoice_submit'),
        label: l10n.fiscalDocumentNewCreate,
        busy: _busy,
        onPressed: _rfc == null ? null : _create,
      ),
    );
  }
}
