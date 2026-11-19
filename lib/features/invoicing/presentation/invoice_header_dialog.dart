import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/domain/payment_method.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart'
    show emptyValuePlaceholder;
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/sat_catalog_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_batch_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/facility_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/fiscal_document_kind.dart';
import 'package:mbe_ui/features/catalog/domain/entities/sat_catalog_item.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_actions.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_refusal.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The most an issue date may lie in the past (mbe-api validates the same).
const invoiceIssueWindow = Duration(hours: 72);

/// Whether [issued] is an issue date the server accepts: not in the future and
/// no more than [invoiceIssueWindow] in the past. The server checks it again.
bool isInvoiceIssueDateAllowed(DateTime issued, {DateTime? now}) {
  final clock = now ?? DateTime.now();
  return !issued.isAfter(clock) &&
      !issued.isBefore(clock.subtract(invoiceIssueWindow));
}

/// Edits the header of draft [document] (spec 066 C7, research R8): recipient,
/// series, CFDI use, payment terms and form, issue date, facility, reference
/// and notes. Only the changed fields are sent. A refusal shows inline and
/// keeps the dialog open. `true` once saved.
///
/// A credit note (spec 073 R9) has only CFDI use, payment form, issue date,
/// reference and notes: the rest comes from its invoice, and its terms are
/// always PUE. It never offers form 99, and opens with no form chosen when 99
/// is what it has, so the clerk must pick the real one.
///
/// A payment receipt (spec 074 C40) has only the payment's date, amount and
/// form, its operation number and ordering bank, the issue date and notes: its
/// usage (CP01), currency and terms are fixed. It never offers form 99 either.
///
/// An issue date, once set, can't be emptied again from here: the server
/// treats an absent value as unchanged.
Future<bool> showInvoiceHeaderDialog(
  BuildContext context,
  FiscalDocument document,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (_) => _HeaderDialog(document: document),
    ) ??
    false;

class _HeaderDialog extends ConsumerStatefulWidget {
  const _HeaderDialog({required this.document});

  final FiscalDocument document;

  @override
  ConsumerState<_HeaderDialog> createState() => _HeaderDialogState();
}

class _HeaderDialogState extends ConsumerState<_HeaderDialog> {
  late String? _recipient = _doc.summary.recipientRfc;
  late String? _series = _doc.summary.series;
  late String? _usage = _doc.usage;
  late InvoicePaymentTerms _terms = _doc.paymentTerms;
  late int? _form =
      (_isNote || _isReceipt) &&
          _doc.paymentForm == PaymentMethod.toBeDefined.code
      ? null
      : _doc.paymentForm;
  late DateTime? _paymentDate = _doc.paymentDate;
  late final _paymentAmount = TextEditingController(
    text: _doc.paymentAmount == null
        ? ''
        : ref
              .read(formattersProvider)
              .field
              .price(_doc.paymentAmount.toString()),
  );
  late final _paymentReference = TextEditingController(
    text: _doc.paymentReference ?? '',
  );
  late final _orderingBank = TextEditingController(
    text: _doc.orderingBank ?? '',
  );
  late DateTime? _issued = _doc.summary.issued;
  late int? _facility = _doc.facilityId;
  late final _reference = TextEditingController(text: _doc.reference ?? '');
  late final _comment = TextEditingController(text: _doc.comment ?? '');
  bool _busy = false;
  AppError? _refusal;

  Future<List<String>>? _recipients;
  Future<List<String>>? _seriesOptions;

  FiscalDocument get _doc => widget.document;
  bool get _isNote => _doc.isCreditNote;
  bool get _isReceipt => _doc.isPaymentReceipt;

  @override
  void initState() {
    super.initState();
    final access = ref.read(accessControlProvider);
    final customerId = _doc.customerId;
    // The customer's RFCs (Customers read); a legacy draft with no customer
    // has no recipient to change.
    if (customerId != null && !_isNote && !_isReceipt) {
      _recipients = ref
          .read(customerRepositoryProvider)
          .get(customerId: customerId)
          .then((c) => [for (final t in c.taxpayers) t.taxpayerRecipientId]);
    }
    // The issuer's invoice series (Taxpayers (24) read).
    if (!_isNote &&
        !_isReceipt &&
        access.can(SystemObject.taxpayers, AccessRight.read)) {
      _seriesOptions = ref
          .read(taxpayerBatchRepositoryProvider)
          .listForIssuer(_doc.summary.issuerRfc)
          .then(
            (batches) => [
              for (final b in batches)
                if (b.kind == FiscalDocumentKind.invoice) b.series,
            ],
          );
    }
  }

  @override
  void dispose() {
    _reference.dispose();
    _comment.dispose();
    _paymentAmount.dispose();
    _paymentReference.dispose();
    _orderingBank.dispose();
    super.dispose();
  }

  bool get _issuedChanged => _issued != _doc.summary.issued;

  /// A changed issue date must be within the last 72 hours and not in the
  /// future; the server checks it again.
  bool get _issuedValid {
    final issued = _issued;
    if (!_issuedChanged || issued == null) return true;
    return isInvoiceIssueDateAllowed(issued);
  }

  bool get _formNeeded =>
      _isNote || _isReceipt || _terms == InvoicePaymentTerms.pue;
  bool get _referenceValid => _reference.text.trim().length <= 25;
  bool get _commentValid => _comment.text.trim().length <= 1000;

  /// `null` while the amount field is empty or unreadable.
  Decimal? get _paymentAmountValue {
    final parsed = ref
        .read(formattersProvider)
        .field
        .parsePrice(_paymentAmount.text);
    return parsed == null ? null : Decimal.tryParse(parsed);
  }

  bool get _paymentAmountChanged =>
      _paymentAmount.text.trim().isNotEmpty &&
      _paymentAmountValue != _doc.paymentAmount;

  /// An empty field means "unchanged": only a positive amount is sent.
  bool get _paymentAmountValid =>
      _paymentAmount.text.trim().isEmpty ||
      (_paymentAmountValue ?? Decimal.zero) > Decimal.zero;

  /// The server's column limits: 50 for the operation number, 25 for the
  /// ordering bank (stored in `reference`).
  bool get _paymentReferenceValid => _paymentReference.text.trim().length <= 50;
  bool get _orderingBankValid => _orderingBank.text.trim().length <= 25;

  InvoiceHeaderPatch get _receiptPatch {
    final reference = _paymentReference.text.trim();
    final bank = _orderingBank.text.trim();
    final comment = _comment.text.trim();
    return InvoiceHeaderPatch(
      paymentDate: _paymentDate != _doc.paymentDate ? _paymentDate : null,
      paymentAmount: _paymentAmountChanged ? _paymentAmountValue : null,
      paymentForm: _form != _doc.paymentForm ? _form : null,
      paymentReference: reference != (_doc.paymentReference ?? '')
          ? reference
          : null,
      orderingBank: bank != (_doc.orderingBank ?? '') ? bank : null,
      issued: _issuedChanged ? _issued : null,
      comment: comment != (_doc.comment ?? '') ? comment : null,
    );
  }

  InvoiceHeaderPatch get _patch {
    if (_isReceipt) return _receiptPatch;
    final termsChanged = _terms != _doc.paymentTerms;
    final formChanged = _form != _doc.paymentForm;
    final reference = _reference.text.trim();
    final comment = _comment.text.trim();
    return InvoiceHeaderPatch(
      recipientRfc: _recipient != _doc.summary.recipientRfc ? _recipient : null,
      // The series is locked once the invoice has a serial.
      series: _doc.summary.serial == null && _series != _doc.summary.series
          ? _series
          : null,
      usage: _usage != _doc.usage ? _usage : null,
      paymentTerms: termsChanged ? _terms : null,
      // PPD sends no form: the server forces 99.
      paymentForm: _formNeeded && (formChanged || termsChanged) ? _form : null,
      issued: _issuedChanged ? _issued : null,
      facilityId: _facility != _doc.facilityId ? _facility : null,
      reference: reference != (_doc.reference ?? '') ? reference : null,
      comment: comment != (_doc.comment ?? '') ? comment : null,
    );
  }

  bool get _dirty {
    final p = _patch;
    return p.paymentDate != null ||
        p.paymentAmount != null ||
        p.paymentReference != null ||
        p.orderingBank != null ||
        p.recipientRfc != null ||
        p.series != null ||
        p.usage != null ||
        p.paymentTerms != null ||
        p.paymentForm != null ||
        p.issued != null ||
        p.facilityId != null ||
        p.reference != null ||
        p.comment != null;
  }

  bool get _valid =>
      _issuedValid &&
      (_isReceipt
          ? _paymentAmountValid && _paymentReferenceValid && _orderingBankValid
          : _referenceValid) &&
      _commentValid &&
      (!_formNeeded || _form != null);

  bool get _canSave => !_busy && _valid && _dirty;

  Future<void> _pickIssued() async {
    final now = DateTime.now();
    final current = _issued ?? now;
    final day = await showDatePicker(
      context: context,
      initialDate: current.isAfter(now) ? now : current,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
    );
    if (day == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (!mounted) return;
    final picked = time ?? TimeOfDay.fromDateTime(current);
    setState(
      () => _issued = DateTime(
        day.year,
        day.month,
        day.day,
        picked.hour,
        picked.minute,
      ),
    );
  }

  /// The payment's date: any day up to today (the server also checks it
  /// against the paid invoices' dates).
  Future<void> _pickPaymentDate() async {
    final now = DateTime.now();
    final current = _paymentDate ?? now;
    final day = await showDatePicker(
      context: context,
      initialDate: current.isAfter(now) ? now : current,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (day == null || !mounted) return;
    setState(() => _paymentDate = DateTime(day.year, day.month, day.day));
  }

  Future<void> _save() async {
    if (!_canSave) return;
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _refusal = null;
    });
    final error = await ref
        .read(fiscalDocumentActionsProvider.notifier)
        .updateHeader(_doc.id, _patch);
    if (!mounted) return;
    if (error == null) {
      navigator.pop(true);
      return;
    }
    setState(() {
      _busy = false;
      _refusal = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final fmt = ref.watch(formattersProvider);
    final access = ref.watch(accessControlProvider);
    // Changing the facility needs IssuedLocationId (103) update, or an
    // administrator.
    final canChangeFacility =
        !_isNote &&
        !_isReceipt &&
        (access.isAdministrator ||
            access.can(SystemObject.issuedLocationId, AccessRight.update));
    final serialAssigned = _doc.summary.serial != null;

    Widget stringDropdown({
      required Key key,
      required String label,
      required String? value,
      required List<String> options,
      required ValueChanged<String?>? onChanged,
      String? helper,
    }) {
      final items = {...options, ?value}.toList();
      return DropdownButtonFormField<String>(
        key: key,
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(labelText: label, helperText: helper),
        items: [
          for (final o in items) DropdownMenuItem(value: o, child: Text(o)),
        ],
        onChanged: _busy ? null : onChanged,
      );
    }

    final forms = [
      for (final m in PaymentMethod.values)
        if (m != PaymentMethod.governmentFunding &&
            !((_isNote || _isReceipt) && m == PaymentMethod.toBeDefined))
          m.code,
      if (_doc.paymentForm == PaymentMethod.governmentFunding.code)
        _doc.paymentForm,
    ];

    return ResponsiveDialog(
      key: const Key('invoice_header_dialog'),
      title: l10n.fiscalDocumentHeaderTitle,
      maxWidth: 640,
      dismissible: !_busy,
      hasUnsavedChanges: () => _dirty,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          if (_recipients != null)
            FutureBuilder<List<String>>(
              future: _recipients,
              builder: (context, snapshot) {
                final rfcs = snapshot.data;
                // Without the customer's RFCs the recipient can't be changed,
                // so the field is not offered.
                if (rfcs == null) return const SizedBox.shrink();
                return stringDropdown(
                  key: const Key('invoice_header_recipient'),
                  label: l10n.fiscalDocumentHeaderRecipient,
                  value: _recipient,
                  options: rfcs,
                  onChanged: (v) => setState(() => _recipient = v),
                );
              },
            ),
          if (_seriesOptions != null)
            FutureBuilder<List<String>>(
              future: _seriesOptions,
              builder: (context, snapshot) {
                final options = snapshot.data;
                if (options == null) return const SizedBox.shrink();
                return stringDropdown(
                  key: const Key('invoice_header_series'),
                  label: l10n.fiscalDocumentHeaderSeries,
                  value: _series,
                  options: options,
                  // Locked once the folio is assigned.
                  onChanged: serialAssigned
                      ? null
                      : (v) => setState(() => _series = v),
                  helper: serialAssigned
                      ? l10n.fiscalDocumentHeaderSeriesLocked
                      : null,
                );
              },
            ),
          if (!_isReceipt)
            CatalogEntityPicker<SatCatalogItem>(
              key: const Key('invoice_header_usage'),
              label: l10n.fiscalDocumentHeaderUsage,
              enabled: !_busy,
              initialDisplayText: _usage,
              displayStringForOption: (i) => i.description == null
                  ? i.code
                  : '${i.code} — ${i.description}',
              optionsBuilder: (query) async {
                final result = await ref
                    .read(satCatalogRepositoryProvider)
                    .listCfdiUsages(
                      search: query.trim().isEmpty ? null : query.trim(),
                      limit: 10,
                    );
                return result.items;
              },
              onSelected: (i) => setState(() => _usage = i.code),
            ),
          if (_isReceipt) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: spacing.xs,
              children: [
                Text(
                  l10n.fiscalDocumentHeaderPaymentDate,
                  style: theme.textTheme.labelMedium,
                ),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: OutlinedButton.icon(
                    key: const Key('invoice_header_payment_date'),
                    onPressed: _busy ? null : _pickPaymentDate,
                    icon: const Icon(Icons.event_outlined),
                    label: Text(
                      _paymentDate == null
                          ? emptyValuePlaceholder
                          : fmt.display.date(_paymentDate),
                    ),
                  ),
                ),
              ],
            ),
            TextField(
              key: const Key('invoice_header_payment_amount'),
              controller: _paymentAmount,
              enabled: !_busy,
              textAlign: TextAlign.end,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: l10n.fiscalDocumentHeaderPaymentAmount,
                errorText: _paymentAmountValid
                    ? null
                    : l10n.editPaidInvoiceAmountPositive,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ] else if (_isNote)
            Text(
              l10n.fiscalDocumentHeaderTermsFixedPue,
              key: const Key('invoice_header_terms_fixed'),
            )
          else
            SegmentedButton<InvoicePaymentTerms>(
              key: const Key('invoice_header_terms'),
              segments: [
                ButtonSegment(
                  value: InvoicePaymentTerms.pue,
                  label: Text(l10n.fiscalDocumentHeaderTermsPue),
                ),
                ButtonSegment(
                  value: InvoicePaymentTerms.ppd,
                  label: Text(l10n.fiscalDocumentHeaderTermsPpd),
                ),
              ],
              selected: {_terms},
              onSelectionChanged: _busy
                  ? null
                  : (s) => setState(() {
                      _terms = s.single;
                      if (_terms == InvoicePaymentTerms.pue &&
                          _form == PaymentMethod.toBeDefined.code) {
                        // 99 only goes with PPD: ask for a real form.
                        _form = null;
                      }
                    }),
            ),
          if (!_isNote && !_isReceipt && _terms == InvoicePaymentTerms.ppd)
            // PPD forces form 99, so it is shown and can't be changed.
            InputDecorator(
              key: const Key('invoice_header_form_ppd'),
              decoration: InputDecoration(
                labelText: l10n.fiscalDocumentHeaderForm,
                enabled: false,
              ),
              child: Text(l10n.fiscalDocumentHeaderFormPpd),
            )
          else
            DropdownButtonFormField<int>(
              key: const Key('invoice_header_form'),
              initialValue: _form,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.fiscalDocumentHeaderForm,
              ),
              items: [
                for (final code in forms)
                  DropdownMenuItem(
                    value: code,
                    child: Text('$code — ${paymentMethodLabel(l10n, code)}'),
                  ),
              ],
              onChanged: _busy ? null : (v) => setState(() => _form = v),
            ),
          if (_isReceipt) ...[
            TextField(
              key: const Key('invoice_header_payment_reference'),
              controller: _paymentReference,
              enabled: !_busy,
              decoration: InputDecoration(
                labelText: l10n.fiscalDocumentHeaderOperationNumber,
                errorText: _paymentReferenceValid
                    ? null
                    : l10n.fiscalDocumentHeaderOperationNumberTooLong,
              ),
              onChanged: (_) => setState(() {}),
            ),
            TextField(
              key: const Key('invoice_header_ordering_bank'),
              controller: _orderingBank,
              enabled: !_busy,
              decoration: InputDecoration(
                labelText: l10n.fiscalDocumentHeaderOrderingBank,
                helperText: l10n.fiscalDocumentHeaderOrderingBankHelper,
                errorText: _orderingBankValid
                    ? null
                    : l10n.fiscalDocumentHeaderOrderingBankTooLong,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: spacing.xs,
            children: [
              Text(
                l10n.fiscalDocumentHeaderIssued,
                style: theme.textTheme.labelMedium,
              ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: OutlinedButton.icon(
                  key: const Key('invoice_header_issued'),
                  onPressed: _busy ? null : _pickIssued,
                  icon: const Icon(Icons.event_outlined),
                  label: Text(
                    _issued == null
                        ? l10n.fiscalDocumentHeaderIssuedOnConfirm
                        : fmt.display.dateTime(_issued),
                  ),
                ),
              ),
              Text(
                _issuedValid
                    ? l10n.fiscalDocumentHeaderIssuedHelper
                    : l10n.fiscalDocumentHeaderIssuedOutOfRange,
                key: const Key('invoice_header_issued_helper'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _issuedValid ? null : theme.colorScheme.error,
                ),
              ),
            ],
          ),
          if (canChangeFacility)
            CatalogEntityPicker<FacilityListItem>(
              key: const Key('invoice_header_facility'),
              label: l10n.fiscalDocumentHeaderFacility,
              enabled: !_busy,
              initialDisplayText: _facility == null
                  ? null
                  : (ref.watch(facilityDisplayNameProvider(_facility!)).value ??
                        '#$_facility'),
              displayStringForOption: (f) => f.name,
              optionsBuilder: (query) async {
                final result = await ref
                    .read(facilityRepositoryProvider)
                    .list(search: query.trim().isEmpty ? null : query.trim());
                return result.items;
              },
              onSelected: (f) => setState(() => _facility = f.facilityId),
            ),
          if (!_isReceipt)
            TextField(
              key: const Key('invoice_header_reference'),
              controller: _reference,
              enabled: !_busy,
              decoration: InputDecoration(
                labelText: l10n.fiscalDocumentHeaderReference,
                errorText: _referenceValid
                    ? null
                    : l10n.fiscalDocumentHeaderReferenceTooLong,
              ),
              onChanged: (_) => setState(() {}),
            ),
          TextField(
            key: const Key('invoice_header_comment'),
            controller: _comment,
            enabled: !_busy,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: l10n.fiscalDocumentHeaderComment,
              errorText: _commentValid
                  ? null
                  : l10n.fiscalDocumentHeaderCommentTooLong,
            ),
            onChanged: (_) => setState(() {}),
          ),
          if (_isReceipt)
            Text(
              l10n.fiscalDocumentHeaderReceiptFixed,
              key: const Key('invoice_header_receipt_fixed'),
              style: theme.textTheme.bodySmall,
            ),
          if (_refusal != null) FiscalDocumentRefusal(error: _refusal!),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).maybePop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('invoice_header_submit'),
        label: l10n.saveButton,
        busy: _busy,
        onPressed: _canSave ? _save : null,
      ),
    );
  }
}
