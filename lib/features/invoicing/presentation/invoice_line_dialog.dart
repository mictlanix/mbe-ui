import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_actions.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_labels.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_refusal.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Edits one line of draft [document] (spec 066 C8): quantity, unit price,
/// discount, VAT rate, internal code, description and comment. Only the
/// changed fields are sent.
///
/// `quantity_exceeds_invoiceable` keeps the dialog open with what remains to
/// invoice, and so does `credit_quantity_exceeds_line` (spec 073) with the
/// most a credit note can take; any other refusal closes it and is answered to the caller to show
/// above its action area. `null` when the user backed out.
Future<FiscalDocumentActionResult?> showInvoiceLineDialog(
  BuildContext context, {
  required FiscalDocument document,
  required InvoiceLine line,
}) => showDialog<FiscalDocumentActionResult>(
  context: context,
  builder: (_) => _InvoiceLineDialog(document: document, line: line),
);

class _InvoiceLineDialog extends ConsumerStatefulWidget {
  const _InvoiceLineDialog({required this.document, required this.line});

  final FiscalDocument document;
  final InvoiceLine line;

  @override
  ConsumerState<_InvoiceLineDialog> createState() => _InvoiceLineDialogState();
}

class _InvoiceLineDialogState extends ConsumerState<_InvoiceLineDialog> {
  late final TextEditingController _quantity;
  late final TextEditingController _price;
  late final TextEditingController _discount;
  late final TextEditingController _code;
  late final TextEditingController _name;
  late final TextEditingController _comment;
  late String _initialQuantity;
  late String _initialPrice;
  late String _initialDiscount;
  late InvoiceTaxRate? _tax;
  bool _busy = false;
  AppError? _refusal;

  InvoiceLine get _line => widget.line;

  @override
  void initState() {
    super.initState();
    final field = ref.read(formattersProvider).field;
    _initialQuantity = field.quantity(_line.quantity.toString());
    _initialPrice = field.price(_line.price.toString());
    _initialDiscount = field.rate(_line.discountRate.toString());
    _tax = _line.tax;
    _quantity = TextEditingController(text: _initialQuantity);
    _price = TextEditingController(text: _initialPrice);
    _discount = TextEditingController(text: _initialDiscount);
    _code = TextEditingController(text: _line.productCode ?? '');
    _name = TextEditingController(text: _line.productName);
    _comment = TextEditingController(text: _line.comment ?? '');
  }

  @override
  void dispose() {
    for (final c in [_quantity, _price, _discount, _code, _name, _comment]) {
      c.dispose();
    }
    super.dispose();
  }

  Decimal? get _quantityValue {
    final parsed = ref
        .read(formattersProvider)
        .field
        .parseQuantity(_quantity.text);
    return parsed == null ? null : Decimal.parse(parsed);
  }

  Decimal? get _priceValue {
    final parsed = ref.read(formattersProvider).field.parsePrice(_price.text);
    return parsed == null ? null : Decimal.parse(parsed);
  }

  Decimal? get _discountValue => Decimal.tryParse(_discount.text.trim());

  bool get _quantityValid => (_quantityValue ?? Decimal.zero) > Decimal.zero;
  bool get _priceValid => (_priceValue ?? Decimal.fromInt(-1)) >= Decimal.zero;
  bool get _discountValid {
    final v = _discountValue;
    return v != null && v >= Decimal.zero && v <= Decimal.fromInt(100);
  }

  bool get _codeValid => _code.text.trim().length <= 35;

  bool get _quantityChanged => _quantity.text.trim() != _initialQuantity;
  bool get _priceChanged => _price.text.trim() != _initialPrice;
  bool get _discountChanged => _discount.text.trim() != _initialDiscount;
  bool get _taxChanged => _tax != _line.tax;
  bool get _codeChanged => _code.text.trim() != (_line.productCode ?? '');
  bool get _nameChanged => _name.text.trim() != _line.productName;
  bool get _commentChanged => _comment.text.trim() != (_line.comment ?? '');

  bool get _dirty =>
      _quantityChanged ||
      _priceChanged ||
      _discountChanged ||
      _taxChanged ||
      _codeChanged ||
      _nameChanged ||
      _commentChanged;

  bool get _valid =>
      _quantityValid && _priceValid && _discountValid && _codeValid;

  bool get _canSave => !_busy && _valid && _dirty;

  InvoiceLinePatch get _patch => InvoiceLinePatch(
    quantity: _quantityChanged ? _quantityValue : null,
    price: _priceChanged ? _priceValue : null,
    discountPercent: _discountChanged ? _discountValue : null,
    taxRate: _taxChanged ? _tax : null,
    productCode: _codeChanged ? _code.text.trim() : null,
    // A blank description is sent blank: the server resets it to the
    // product's name.
    productName: _nameChanged ? _name.text.trim() : null,
    comment: _commentChanged ? _comment.text.trim() : null,
  );

  Future<void> _save() async {
    if (!_canSave) return;
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _refusal = null;
    });
    final error = await ref
        .read(fiscalDocumentActionsProvider.notifier)
        .updateLine(widget.document.id, _line.id, _patch);
    if (!mounted) return;
    // The refusal the user can fix in place keeps the dialog open.
    final code = error?.problem?.code;
    if (code == api.ErrorCode.fiscalDocumentPeriodQuantityExceedsInvoiceable ||
        code == api.ErrorCode.fiscalDocumentPeriodCreditQuantityExceedsLine) {
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
    const decimalKeyboard = TextInputType.numberWithOptions(decimal: true);

    return ResponsiveDialog(
      key: const Key('invoice_line_dialog'),
      title: l10n.fiscalDocumentLineDialogTitle,
      dismissible: !_busy,
      hasUnsavedChanges: () => _dirty,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          Text(_line.productName),
          TextField(
            key: const Key('invoice_line_quantity'),
            controller: _quantity,
            enabled: !_busy,
            autofocus: true,
            textAlign: TextAlign.end,
            keyboardType: decimalKeyboard,
            decoration: InputDecoration(
              labelText: l10n.fiscalDocumentLineFieldQuantity,
              errorText: _quantityValid
                  ? null
                  : l10n.fiscalDocumentLineQuantityInvalid,
            ),
            onChanged: (_) => setState(() {}),
          ),
          TextField(
            key: const Key('invoice_line_price'),
            controller: _price,
            enabled: !_busy,
            textAlign: TextAlign.end,
            keyboardType: decimalKeyboard,
            decoration: InputDecoration(
              labelText: l10n.fiscalDocumentLineFieldPrice,
              errorText: _priceValid
                  ? null
                  : l10n.fiscalDocumentLinePriceInvalid,
            ),
            onChanged: (_) => setState(() {}),
          ),
          TextField(
            key: const Key('invoice_line_discount'),
            controller: _discount,
            enabled: !_busy,
            textAlign: TextAlign.end,
            keyboardType: decimalKeyboard,
            decoration: InputDecoration(
              labelText: l10n.fiscalDocumentLineFieldDiscount,
              errorText: _discountValid
                  ? null
                  : l10n.fiscalDocumentLineDiscountInvalid,
            ),
            onChanged: (_) => setState(() {}),
          ),
          DropdownButtonFormField<InvoiceTaxRate>(
            key: const Key('invoice_line_tax'),
            initialValue: _tax,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l10n.fiscalDocumentLineFieldTax,
              // A rate the app doesn't know is shown, not hidden.
              hintText: _line.tax == null
                  ? invoiceTaxRateLabel(l10n, _line.taxRate)
                  : null,
            ),
            items: [
              for (final rate in InvoiceTaxRate.values)
                DropdownMenuItem(
                  value: rate,
                  child: Text(invoiceTaxRateLabel(l10n, rate.rate)),
                ),
            ],
            onChanged: _busy ? null : (v) => setState(() => _tax = v),
          ),
          TextField(
            key: const Key('invoice_line_code'),
            controller: _code,
            enabled: !_busy,
            inputFormatters: [LengthLimitingTextInputFormatter(40)],
            decoration: InputDecoration(
              labelText: l10n.fiscalDocumentLineFieldCode,
              errorText: _codeValid ? null : l10n.fiscalDocumentLineCodeTooLong,
            ),
            onChanged: (_) => setState(() {}),
          ),
          TextField(
            key: const Key('invoice_line_name'),
            controller: _name,
            enabled: !_busy,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: l10n.fiscalDocumentLineFieldName,
              helperText: l10n.fiscalDocumentLineNameHelper,
            ),
            onChanged: (_) => setState(() {}),
          ),
          TextField(
            key: const Key('invoice_line_comment'),
            controller: _comment,
            enabled: !_busy,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: l10n.fiscalDocumentLineFieldComment,
            ),
            onChanged: (_) => setState(() {}),
          ),
          if (_refusal != null) FiscalDocumentRefusal(error: _refusal!),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).maybePop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('invoice_line_submit'),
        label: l10n.saveButton,
        busy: _busy,
        onPressed: _canSave ? _save : null,
      ),
    );
  }
}
