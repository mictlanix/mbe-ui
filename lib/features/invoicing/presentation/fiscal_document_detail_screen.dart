import 'package:data_table_2/data_table_2.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/documents/domain/document_kind.dart';
import 'package:mbe_ui/core/documents/domain/document_ref.dart';
import 'package:mbe_ui/core/documents/presentation/document_actions.dart';
import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/domain/payment_method.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/errors/localize_problem.dart';
import 'package:mbe_ui/core/files/file_saver.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart'
    show emptyValuePlaceholder;
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/compact_field.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/fact_strip_row.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart' show toAppError;
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/presentation/fiscal_document_kind_label.dart';
import 'package:mbe_ui/features/invoicing/data/fiscal_document_repository_impl.dart';
import 'package:mbe_ui/features/invoicing/presentation/add_product_dialog.dart';
import 'package:mbe_ui/features/invoicing/presentation/add_relation_dialog.dart';
import 'package:mbe_ui/features/invoicing/presentation/add_sales_order_dialog.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/features/invoicing/domain/xml_filename.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_detail_controller.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_labels.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_refusal.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_status_chip.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_documents_list_screen.dart';
import 'package:mbe_ui/features/invoicing/presentation/invoice_action_dialogs.dart';
import 'package:mbe_ui/features/invoicing/presentation/invoice_header_dialog.dart';
import 'package:mbe_ui/features/invoicing/presentation/invoice_line_dialog.dart';
import 'package:mbe_ui/features/invoicing/presentation/invoice_totals.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// One fiscal document (spec 066 contracts C5): a status banner, the header
/// facts, the lines, the related documents, the totals and the action area.
///
/// A full screen with its own address rather than a side panel, because a
/// document owns child collections (lines, relations) and is linked from the
/// list (constitution §VI record-surface criteria). `AppBar.actions` stays
/// empty; every action belongs in the body.
class FiscalDocumentDetailScreen extends ConsumerWidget {
  /// [fiscalDocumentId] is `null` for an address whose id isn't a number,
  /// which shows the not-found state instead of throwing.
  const FiscalDocumentDetailScreen({super.key, required this.fiscalDocumentId});

  final int? fiscalDocumentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final id = fiscalDocumentId;
    if (id == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.navFiscalDocuments)),
        body: const _NotFound(),
      );
    }
    final detail = ref.watch(fiscalDocumentDetailProvider(id));
    final document = detail.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          document == null ? l10n.navFiscalDocuments : _title(l10n, document),
        ),
      ),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => error is NotFoundError
            ? const _NotFound()
            : _LoadFailed(
                error: toAppError(error),
                onRetry: () => ref.invalidate(fiscalDocumentDetailProvider(id)),
              ),
        data: (document) => _FiscalDocumentBody(document: document),
      ),
    );
  }
}

/// "Factura {folio}", "Borrador #{id}", or the kind's name for other types.
String _title(AppLocalizations l10n, FiscalDocument d) {
  final folio = d.summary.folioLabel;
  if (d.isInvoice) {
    return folio == null
        ? l10n.fiscalDocumentTitleDraft(d.id)
        : l10n.fiscalDocumentTitle(folio);
  }
  final kind = d.summary.kind;
  return l10n.fiscalDocumentTitleKind(
    kind == null
        ? l10n.fiscalDocumentKindUnknown(d.summary.typeCode)
        : fiscalDocumentKindLabel(l10n, kind),
    folio ?? '#${d.id}',
  );
}

/// Back to the list: pops when the list is underneath, otherwise goes there.
void _backToList(BuildContext context) =>
    context.canPop() ? context.pop() : context.go(fiscalDocumentsPath);

class _NotFound extends StatelessWidget {
  const _NotFound();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    return Padding(
      padding: EdgeInsets.all(spacing.screenMargin),
      child: Column(
        key: const Key('fiscal_document_not_found'),
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.fieldGapVertical,
        children: [
          const ErrorBanner(error: AppError.notFound()),
          OutlinedButton(
            key: const Key('fiscal_document_back_to_list'),
            onPressed: () => _backToList(context),
            child: Text(l10n.fiscalDocumentBackToList),
          ),
        ],
      ),
    );
  }
}

class _LoadFailed extends StatelessWidget {
  const _LoadFailed({required this.error, required this.onRetry});

  final AppError error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    return Padding(
      padding: EdgeInsets.all(spacing.screenMargin),
      child: Column(
        key: const Key('fiscal_document_load_failed'),
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.fieldGapVertical,
        children: [
          ErrorBanner(error: error),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: [
              OutlinedButton(
                key: const Key('fiscal_document_back_to_list'),
                onPressed: () => _backToList(context),
                child: Text(l10n.fiscalDocumentBackToList),
              ),
              FilledButton(
                key: const Key('fiscal_document_retry_button'),
                onPressed: onRetry,
                child: Text(l10n.retryButton),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The loaded document, as a column of sections (contracts C5). The action
/// area stays last.
///
/// Stateful so the busy flag of the XML download survives the rebuilds a
/// reload triggers.
class _FiscalDocumentBody extends ConsumerStatefulWidget {
  const _FiscalDocumentBody({required this.document});

  final FiscalDocument document;

  @override
  ConsumerState<_FiscalDocumentBody> createState() =>
      _FiscalDocumentBodyState();
}

class _FiscalDocumentBodyState extends ConsumerState<_FiscalDocumentBody> {
  bool _downloadingXml = false;

  /// The last refusal of a write whose dialog closed over it, shown above the
  /// action area. Cleared when the next action starts.
  AppError? _actionError;

  FiscalDocument get _document => widget.document;

  Future<void> _viewPdf() {
    final l10n = AppLocalizations.of(context)!;
    return ref
        .read(documentActionsProvider)
        .preview(
          context,
          DocumentRef(
            kind: DocumentKind.fiscalDocument,
            recordId: _document.id,
            title: _title(l10n, _document),
          ),
        );
  }

  Future<void> _editHeader() async {
    setState(() => _actionError = null);
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final saved = await showInvoiceHeaderDialog(context, _document);
    if (saved) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.fiscalDocumentHeaderSaved)),
      );
    }
  }

  Future<void> _editLine(InvoiceLine line) async {
    setState(() => _actionError = null);
    final result = await showInvoiceLineDialog(
      context,
      document: _document,
      line: line,
    );
    if (mounted && result?.error != null) {
      setState(() => _actionError = result!.error);
    }
  }

  Future<void> _removeLine(InvoiceLine line) async {
    setState(() => _actionError = null);
    await showRemoveInvoiceLineDialog(
      context,
      documentId: _document.id,
      line: line,
    );
  }

  Future<void> _addProduct() async {
    setState(() => _actionError = null);
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final result = await showAddInvoiceProductDialog(
      context,
      documentId: _document.id,
    );
    if (!mounted || result == null) return;
    if (result.error != null) {
      setState(() => _actionError = result.error);
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.fiscalDocumentProductAdded)),
      );
    }
  }

  Future<void> _confirm() async {
    setState(() => _actionError = null);
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final id = _document.id;
    final result = await showConfirmInvoiceDialog(context, document: _document);
    if (!mounted || result == null) return;
    if (result.error != null) {
      setState(() => _actionError = result.error);
      return;
    }
    // The folio is assigned by the server: read it from the reloaded document.
    final sealed = await ref.read(fiscalDocumentDetailProvider(id).future);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          l10n.fiscalDocumentConfirmed(
            sealed.summary.folioLabel ?? '#${sealed.id}',
          ),
        ),
      ),
    );
  }

  Future<void> _reopen() async {
    setState(() => _actionError = null);
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final folio = _document.summary.folioLabel ?? '#${_document.id}';
    final result = await showReopenInvoiceDialog(context, document: _document);
    if (!mounted || result == null) return;
    if (result.error != null) {
      setState(() => _actionError = result.error);
      return;
    }
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.fiscalDocumentReopened(folio))),
    );
  }

  Future<void> _addRelation() async {
    setState(() => _actionError = null);
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final result = await showAddInvoiceRelationDialog(
      context,
      document: _document,
    );
    if (!mounted || result == null) return;
    if (result.error != null) {
      setState(() => _actionError = result.error);
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.fiscalDocumentRelationAdded)),
      );
    }
  }

  Future<void> _removeRelation(InvoiceRelation relation) async {
    setState(() => _actionError = null);
    await showRemoveInvoiceRelationDialog(
      context,
      documentId: _document.id,
      relation: relation,
    );
  }

  Future<void> _addOrder() async {
    setState(() => _actionError = null);
    final customerId = _document.customerId;
    if (customerId == null) return;
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final folio = await showAddSalesOrderDialog(
      context,
      documentId: _document.id,
      customerId: customerId,
    );
    if (folio != null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.fiscalDocumentOrderAdded(folio))),
      );
    }
  }

  Future<void> _downloadXml() async {
    if (_downloadingXml) return;
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _downloadingXml = true);
    try {
      final xml = await ref
          .read(fiscalDocumentRepositoryProvider)
          .downloadXml(_document.id);
      final summary = _document.summary;
      final serial = summary.serial;
      final filename =
          xml.filename ??
          (serial == null
              ? 'factura-${_document.id}.xml'
              : invoiceXmlFilename(
                  issuerRfc: summary.issuerRfc,
                  series: summary.series,
                  serial: serial,
                ));
      final saved = await ref
          .read(fileSaverProvider)
          .save(bytes: xml.bytes, filename: filename);
      // A cancelled save dialog says nothing.
      if (saved) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.fiscalDocumentXmlSaved)),
        );
      }
    } on AppError catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            error.userMessage(l10n, ref.read(formattersProvider)) ??
                l10n.fiscalDocumentLoadFailed,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _downloadingXml = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final access = ref.watch(accessControlProvider);
    final document = _document;
    final canRead = access.can(SystemObject.fiscalDocuments, AccessRight.read);
    // A sealed document has no stamp, so the server refuses both files; only
    // issued and cancelled documents offer them.
    final offerFiles = canRead && document.hasDocuments;
    // Only a draft is editable, and only with FiscalDocuments (23) update.
    final canEdit =
        document.isEditableDraft &&
        access.can(SystemObject.fiscalDocuments, AccessRight.update);
    // "Agregar pedido" lists the customer's orders (SalesOrders (7) read),
    // and a legacy draft with no customer has none to list.
    final canAddOrder =
        canEdit &&
        document.customerId != null &&
        access.can(SystemObject.salesOrders, AccessRight.read);
    // Reopening a sealed invoice also needs FiscalDocuments (23) update.
    final canReopen =
        document.canReopen &&
        access.can(SystemObject.fiscalDocuments, AccessRight.update);
    // A manual line needs StandaloneFiscalDocuments (56) create.
    final canAddProduct =
        canEdit &&
        access.can(SystemObject.standaloneFiscalDocuments, AccessRight.create);

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.screenMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.sectionGap,
        children: [
          _StatusBanner(document: document),
          _HeaderFacts(
            document: document,
            onEditHeader: canEdit ? _editHeader : null,
          ),
          _LinesSection(
            document: document,
            onAddOrder: canAddOrder ? _addOrder : null,
            onAddProduct: canAddProduct ? _addProduct : null,
            onEditLine: canEdit ? _editLine : null,
            onRemoveLine: canEdit ? _removeLine : null,
          ),
          // Related documents show when there are some, or on an editable
          // draft, where they can be added.
          if (document.hasRelations || canEdit)
            _RelationsSection(
              document: document,
              onAdd: canEdit ? _addRelation : null,
              onRemove: canEdit ? _removeRelation : null,
            ),
          InvoiceTotals(document: document),
          if (_actionError != null) FiscalDocumentRefusal(error: _actionError!),
          if (offerFiles || canReopen || canEdit)
            Align(
              key: const Key('fiscal_document_actions'),
              alignment: AlignmentDirectional.centerEnd,
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: spacing.sm,
                runSpacing: spacing.sm,
                children: [
                  if (offerFiles) ...[
                    OutlinedButton.icon(
                      key: const Key('fiscal_document_view_pdf'),
                      onPressed: _viewPdf,
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: Text(l10n.fiscalDocumentViewPdf),
                    ),
                    OutlinedButton.icon(
                      key: const Key('fiscal_document_download_xml'),
                      onPressed: _downloadingXml ? null : _downloadXml,
                      icon: const Icon(Icons.download_outlined),
                      label: Text(l10n.fiscalDocumentDownloadXml),
                    ),
                  ],
                  if (canReopen)
                    OutlinedButton(
                      key: const Key('fiscal_document_reopen'),
                      onPressed: _reopen,
                      child: Text(l10n.fiscalDocumentReopenAction),
                    ),
                  // The primary action goes last.
                  if (canEdit)
                    FilledButton(
                      key: const Key('fiscal_document_confirm'),
                      onPressed: _confirm,
                      child: Text(l10n.fiscalDocumentConfirmAction),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// At most one banner: cancelled, sealed (stamping isn't available yet), or a
/// type this screen only reads.
class _StatusBanner extends ConsumerWidget {
  const _StatusBanner({required this.document});

  final FiscalDocument document;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final fmt = ref.watch(formattersProvider);
    final String? text;
    final String key;
    if (document.status == FiscalDocumentStatus.cancelled) {
      text = l10n.fiscalDocumentBannerCancelled(
        fmt.display.date(document.cancellationDate),
      );
      key = 'cancelled';
    } else if (document.canReopen) {
      text = l10n.fiscalDocumentBannerSealed;
      key = 'sealed';
    } else if (!document.isInvoice) {
      text = l10n.fiscalDocumentBannerReadOnlyKind;
      key = 'read_only_kind';
    } else {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final colors = document.status == FiscalDocumentStatus.cancelled
        ? (theme.colorScheme.errorContainer, theme.colorScheme.onErrorContainer)
        : (
            theme.colorScheme.primaryContainer,
            theme.colorScheme.onPrimaryContainer,
          );
    return Material(
      key: Key('fiscal_document_banner_$key'),
      color: colors.$1,
      borderRadius: theme.shapes.mdRadius,
      child: Padding(
        padding: EdgeInsets.all(theme.spacing.md),
        child: Row(
          spacing: theme.spacing.sm,
          children: [
            Icon(Icons.info_outline, color: colors.$2),
            Expanded(
              child: Text(text, style: TextStyle(color: colors.$2)),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderFacts extends ConsumerWidget {
  const _HeaderFacts({required this.document, this.onEditHeader});

  final FiscalDocument document;

  /// `null` hides "Editar encabezado" (contracts C9).
  final VoidCallback? onEditHeader;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final fmt = ref.watch(formattersProvider);
    final s = document.summary;
    final kind = s.kind;
    final isDraft = document.status == FiscalDocumentStatus.draft;
    final customerId = document.customerId;
    final facilityId = document.facilityId;
    final currency = Currency.fromValue(document.currencyCode);

    CompactField fact(String label, String? value, {Key? key}) => CompactField(
      key: key,
      label: label,
      child: Text(
        value == null || value.isEmpty ? emptyValuePlaceholder : value,
        key: key == null ? null : Key('${(key as ValueKey).value}_value'),
      ),
    );

    String party(String rfc, String? name) =>
        name == null || name.isEmpty ? rfc : '$rfc · $name';
    String regime(String? code, String? name) => [?code, ?name].join(' · ');

    return Column(
      key: const Key('fiscal_document_header'),
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.fieldGapVertical,
      children: [
        if (document.isEditableDraft && customerId == null)
          Text(
            l10n.fiscalDocumentNoCustomerNote,
            key: const Key('fiscal_document_no_customer'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        if (onEditHeader != null)
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: OutlinedButton.icon(
              key: const Key('fiscal_document_edit_header'),
              onPressed: onEditHeader,
              icon: Icon(CatalogAction.edit.icon),
              label: Text(l10n.fiscalDocumentEditHeader),
            ),
          ),
        FactStripRow(
          key: const Key('fiscal_document_facts'),
          facts: [
            CompactField(
              label: l10n.fiscalDocumentFactSeriesFolio,
              child: Text(
                s.folioLabel ?? l10n.fiscalDocumentDraftFolio,
                key: const Key('fiscal_document_folio'),
              ),
            ),
            CompactField(
              label: l10n.fiscalDocumentColStatus,
              child: FiscalDocumentStatusChip(status: document.status),
            ),
            CompactField(
              label: l10n.fiscalDocumentColType,
              child: Text(
                kind == null
                    ? l10n.fiscalDocumentKindUnknown(s.typeCode)
                    : fiscalDocumentKindLabel(l10n, kind),
              ),
            ),
            CompactField(
              label: l10n.fiscalDocumentFactIssued,
              child: Text(
                s.issued == null && isDraft
                    ? l10n.fiscalDocumentFactIssuedOnConfirm
                    : fmt.display.dateTime(s.issued),
                key: const Key('fiscal_document_issued'),
              ),
            ),
          ],
          trailing: const SizedBox.shrink(),
        ),
        Wrap(
          spacing: spacing.lg,
          runSpacing: spacing.sm,
          children: [
            CompactField(
              label: l10n.fiscalDocumentFactIssuer,
              supportingText: regime(
                document.issuerRegime,
                document.issuerRegimeName,
              ),
              child: Text(party(s.issuerRfc, s.issuerName)),
            ),
            if (s.recipientRfc != null)
              CompactField(
                label: l10n.fiscalDocumentFactRecipient,
                supportingText: [
                  regime(document.taxpayerRegime, null),
                  if (document.taxpayerPostalCode != null)
                    '${l10n.fiscalDocumentFactPostalCode} '
                        '${document.taxpayerPostalCode}',
                ].where((e) => e.isNotEmpty).join(' · '),
                child: Text(party(s.recipientRfc!, s.recipientName)),
              ),
            if (customerId != null)
              CompactField(
                label: l10n.fiscalDocumentFactCustomer,
                child: _ResolvedName(
                  key: const Key('fiscal_document_customer'),
                  fallback: '#$customerId',
                  value: ref.watch(customerDisplayNameProvider(customerId)),
                ),
              ),
            if (facilityId != null)
              CompactField(
                label: l10n.fiscalDocumentFactFacility,
                child: _ResolvedName(
                  key: const Key('fiscal_document_facility'),
                  fallback: '#$facilityId',
                  value: ref.watch(facilityDisplayNameProvider(facilityId)),
                ),
              ),
            fact(
              l10n.fiscalDocumentFactPaymentTerms,
              invoicePaymentTermsLabel(l10n, document.paymentTerms),
            ),
            fact(
              l10n.fiscalDocumentFactPaymentForm,
              paymentMethodLabel(l10n, document.paymentForm),
            ),
            fact(l10n.fiscalDocumentFactUsage, document.usage),
            fact(
              l10n.fiscalDocumentFactCurrency,
              currency == null
                  ? '${document.currencyCode}'
                  : currencyCodeLabel(currency),
            ),
            if (document.reference != null && document.reference!.isNotEmpty)
              fact(l10n.fiscalDocumentFactReference, document.reference),
            if (document.comment != null && document.comment!.isNotEmpty)
              fact(l10n.fiscalDocumentFactComment, document.comment),
            if (s.stampUuid != null)
              fact(
                l10n.fiscalDocumentFactUuid,
                s.stampUuid,
                key: const ValueKey('fiscal_document_uuid'),
              ),
            if (document.stamped != null)
              fact(
                l10n.fiscalDocumentFactStamped,
                fmt.display.dateTime(document.stamped),
              ),
          ],
        ),
      ],
    );
  }
}

/// A name that loads on its own, shown as [fallback] while it loads or when
/// the user can't read it.
class _ResolvedName extends StatelessWidget {
  const _ResolvedName({super.key, required this.value, required this.fallback});

  final AsyncValue<String?> value;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    final name = value.value;
    return Text(name == null || name.isEmpty ? fallback : name);
  }
}

class _LinesSection extends ConsumerWidget {
  const _LinesSection({
    required this.document,
    this.onAddOrder,
    this.onAddProduct,
    this.onEditLine,
    this.onRemoveLine,
  });

  final FiscalDocument document;

  /// Each `null` hides its control (contracts C9).
  final VoidCallback? onAddOrder;
  final VoidCallback? onAddProduct;
  final void Function(InvoiceLine line)? onEditLine;
  final void Function(InvoiceLine line)? onRemoveLine;

  /// ✎ and 🗑 for [line], or none when the lines aren't editable.
  List<Widget> _lineActions(AppLocalizations l10n, InvoiceLine line) {
    final onEdit = onEditLine;
    final onRemove = onRemoveLine;
    if (onEdit == null || onRemove == null) return const [];
    return buildCatalogRowActions(
      editTooltip: l10n.fiscalDocumentLineEditTooltip,
      editKey: Key('fiscal_document_line_edit_${line.id}'),
      onEdit: () => onEdit(line),
      extraActions: [
        CatalogRowAction(
          key: Key('fiscal_document_line_remove_${line.id}'),
          icon: Icons.delete_outline,
          tooltip: l10n.fiscalDocumentLineRemoveTooltip,
          onPressed: () => onRemove(line),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final fmt = ref.watch(formattersProvider);
    final lines = document.lines;

    String money(Object v) => fmt.display.currency(v.toString());
    String unit(InvoiceLine l) =>
        l.unitName ?? l.unitKey ?? emptyValuePlaceholder;
    String description(InvoiceLine l) => l.productName;

    Widget orderMarker(InvoiceLine l) => Chip(
      key: Key('fiscal_document_line_order_${l.id}'),
      label: Text(l10n.fiscalDocumentLineFromOrder),
      visualDensity: VisualDensity.compact,
    );

    final Widget table;
    if (lines.isEmpty) {
      table = Text(
        l10n.fiscalDocumentLinesEmpty,
        key: const Key('fiscal_document_lines_empty'),
      );
    } else if (LayoutBreakpoints.isCompact(context)) {
      table = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final line in lines) ...[
            Padding(
              key: Key('fiscal_document_line_card_${line.id}'),
              padding: EdgeInsets.symmetric(vertical: spacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: spacing.xs,
                children: [
                  Row(
                    spacing: spacing.sm,
                    children: [
                      Expanded(child: Text(description(line))),
                      if (line.orderLineId != null) orderMarker(line),
                      ..._lineActions(l10n, line),
                    ],
                  ),
                  Wrap(
                    spacing: spacing.md,
                    runSpacing: spacing.xs,
                    children: [
                      for (final text in [
                        '${l10n.fiscalDocumentLineQuantity} '
                            '${fmt.display.quantity(line.quantity.toString())} '
                            '${unit(line)}',
                        '${l10n.fiscalDocumentLinePrice} ${money(line.price)}',
                        if (line.discountRate > Decimal.zero)
                          '${l10n.fiscalDocumentLineDiscount} '
                              '${fmt.display.percent(line.discountRate.toString())}',
                        '${l10n.fiscalDocumentLineTax} '
                            '${invoiceTaxRateLabel(l10n, line.taxRate)}',
                        '${l10n.fiscalDocumentLineAmount} '
                            '${money(line.amounts.net)}',
                      ])
                        Text(text, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
          ],
        ],
      );
    } else {
      table = DataTableView<InvoiceLine>(
        key: const Key('fiscal_document_lines_table'),
        shrinkWrap: true,
        margin: EdgeInsets.zero,
        rows: lines,
        rowActionsBuilder: onEditLine == null
            ? null
            : (context, line) => _lineActions(l10n, line),
        columns: [
          DataTableColumn(
            label: l10n.fiscalDocumentLineQuantity,
            numeric: true,
            size: ColumnSize.S,
            cellBuilder: (context, l) =>
                Text(fmt.display.quantity(l.quantity.toString())),
          ),
          DataTableColumn.text(
            label: l10n.fiscalDocumentLineUnit,
            size: ColumnSize.S,
            text: unit,
          ),
          DataTableColumn.text(
            label: l10n.fiscalDocumentLineSatKey,
            size: ColumnSize.S,
            text: (l) => l.satProductKey ?? emptyValuePlaceholder,
          ),
          DataTableColumn(
            label: l10n.fiscalDocumentLineDescription,
            size: ColumnSize.L,
            cellBuilder: (context, l) => Row(
              spacing: spacing.sm,
              children: [
                Expanded(
                  child: Tooltip(
                    message: description(l),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          description(l),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (l.productCode != null && l.productCode!.isNotEmpty)
                          Text(
                            l10n.fiscalDocumentLineInternalCode(l.productCode!),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                ),
                if (l.orderLineId != null) orderMarker(l),
              ],
            ),
          ),
          DataTableColumn(
            label: l10n.fiscalDocumentLinePrice,
            numeric: true,
            size: ColumnSize.S,
            cellBuilder: (context, l) => Text(money(l.price)),
          ),
          DataTableColumn(
            label: l10n.fiscalDocumentLineDiscount,
            numeric: true,
            size: ColumnSize.S,
            cellBuilder: (context, l) =>
                Text(fmt.display.percent(l.discountRate.toString())),
          ),
          DataTableColumn(
            label: l10n.fiscalDocumentLineTax,
            size: ColumnSize.S,
            cellBuilder: (context, l) =>
                Text(invoiceTaxRateLabel(l10n, l.taxRate)),
          ),
          DataTableColumn(
            label: l10n.fiscalDocumentLineAmount,
            numeric: true,
            size: ColumnSize.S,
            cellBuilder: (context, l) => Text(money(l.amounts.net)),
          ),
        ],
      );
    }

    return Column(
      key: const Key('fiscal_document_lines'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: spacing.sm,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.fiscalDocumentLinesTitle,
                style: theme.textTheme.titleMedium,
              ),
            ),
            if (onAddOrder != null || onAddProduct != null)
              Flexible(
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: spacing.sm,
                  runSpacing: spacing.xs,
                  children: [
                    if (onAddOrder != null)
                      OutlinedButton.icon(
                        key: const Key('fiscal_document_add_order'),
                        onPressed: onAddOrder,
                        icon: const Icon(Icons.add),
                        label: Text(l10n.fiscalDocumentAddOrder),
                      ),
                    if (onAddProduct != null)
                      OutlinedButton.icon(
                        key: const Key('fiscal_document_add_product'),
                        onPressed: onAddProduct,
                        icon: const Icon(Icons.add),
                        label: Text(l10n.fiscalDocumentAddProduct),
                      ),
                  ],
                ),
              ),
          ],
        ),
        table,
      ],
    );
  }
}

/// The related documents: type, folio and UUID, with add and remove on an
/// editable draft (each `null` callback hides its control, contracts C9).
class _RelationsSection extends StatelessWidget {
  const _RelationsSection({required this.document, this.onAdd, this.onRemove});

  final FiscalDocument document;
  final VoidCallback? onAdd;
  final void Function(InvoiceRelation relation)? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    return Column(
      key: const Key('fiscal_document_relations'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: spacing.sm,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.fiscalDocumentRelationsTitle,
                style: theme.textTheme.titleMedium,
              ),
            ),
            if (onAdd != null)
              OutlinedButton.icon(
                key: const Key('fiscal_document_add_relation'),
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: Text(l10n.fiscalDocumentAddRelation),
              ),
          ],
        ),
        for (final r in document.relations)
          Padding(
            key: Key('fiscal_document_relation_${r.id}'),
            padding: EdgeInsets.symmetric(vertical: spacing.xs),
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: spacing.md,
                    runSpacing: spacing.xs,
                    children: [
                      if (r.type != null)
                        Text(invoiceRelationTypeLabel(l10n, r.type!)),
                      Text(
                        r.serial == null
                            ? '#${r.documentId}'
                            : '${r.series ?? ''}${r.serial}',
                      ),
                      if (r.stampUuid != null) Text(r.stampUuid!),
                    ],
                  ),
                ),
                if (onRemove != null)
                  IconButton(
                    key: Key('fiscal_document_relation_remove_${r.id}'),
                    icon: const Icon(Icons.delete_outline),
                    tooltip: l10n.fiscalDocumentRelationRemoveTooltip,
                    visualDensity: VisualDensity.compact,
                    onPressed: () => onRemove!(r),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
