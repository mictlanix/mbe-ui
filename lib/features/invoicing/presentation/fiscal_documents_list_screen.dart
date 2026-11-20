import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/navigation/list_search_submit.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_sheet.dart';
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/date_range_filter_chip.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/core/widgets/record_id_text.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_issuer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/fiscal_document_kind.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_issuer_list_item.dart';
import 'package:mbe_ui/features/catalog/presentation/fiscal_document_kind_label.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_status_chip.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_documents_filter.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_documents_list_controller.dart';
import 'package:mbe_ui/features/invoicing/presentation/new_invoice_dialog.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payments_filter.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const fiscalDocumentsPath = '/invoicing/fiscal-documents';

/// Facturas: every fiscal document, newest first (spec 066 US1, contracts
/// C2). Gated by FiscalDocuments (SystemObject 23) read.
///
/// A fiscal document is a document, so a row has no Edit icon and its tap
/// opens the detail screen (§VI "document reading").
class FiscalDocumentsListScreen extends ConsumerWidget {
  const FiscalDocumentsListScreen({super.key, required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final canCreate = ref
        .watch(accessControlProvider)
        .can(SystemObject.fiscalDocuments, AccessRight.create);
    final filter = FiscalDocumentsFilter.fromQuery(query);
    final pageAsync = ref.watch(fiscalDocumentsListControllerProvider(filter));
    final fmt = ref.watch(formattersProvider);
    final compact = LayoutBreakpoints.isCompact(context);
    final clearedPath = const ListQuery().toUri(fiscalDocumentsPath).toString();
    final facetsClearedPath = filter
        .cleared()
        .toQuery()
        .toUri(fiscalDocumentsPath)
        .toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.fieldGapVertical,
      children: [
        CatalogFilterBar(
          search: CatalogSearchBar(
            key: const Key('fiscal_documents_search'),
            label: l10n.fiscalDocumentsSearchHint,
            searchTooltip: l10n.searchButtonTooltip,
            initialValue: filter.search ?? '',
            onSubmitted: (value) => submitCatalogSearch(
              context: context,
              query: query,
              path: fiscalDocumentsPath,
              submitted: value,
              current: filter.search ?? '',
              refresh: () =>
                  ref.invalidate(fiscalDocumentsListControllerProvider(filter)),
            ),
          ),
          filters: [
            Badge.count(
              count: filter.activeFilterCount,
              isLabelVisible: filter.activeFilterCount > 0,
              child: IconButton.outlined(
                key: const Key('fiscal_documents_filter_button'),
                icon: const Icon(Icons.tune),
                tooltip: l10n.filtersTooltip,
                onPressed: () => showCatalogFilterSheet(
                  context,
                  title: l10n.filtersButton,
                  clearAllLabel: l10n.clearAllFilters,
                  applyLabel: l10n.applyFilters,
                  onClearAll: () => context.go(facetsClearedPath),
                  builder: (_) => CurrentListQueryBuilder(
                    builder: (context, query) =>
                        _FiscalDocumentsFiltersPanel(query: query),
                  ),
                ),
              ),
            ),
          ],
          // FiscalDocuments (23) create: Nueva factura, and a payment receipt
          // by hand (spec 074 C36). The invoice keeps the primary slot.
          actions: [
            if (canCreate)
              OutlinedButton.icon(
                key: const Key('fiscal_documents_new_receipt'),
                onPressed: () async {
                  final id = await showNewFiscalDocumentDialog(
                    context,
                    NewFiscalDocumentMode.receipt,
                  );
                  if (id != null && context.mounted) {
                    context.push('$fiscalDocumentsPath/$id');
                  }
                },
                icon: const Icon(Icons.receipt_long_outlined),
                label: Text(l10n.fiscalDocumentNewReceiptAction),
              ),
            if (canCreate)
              FilledButton.icon(
                key: const Key('fiscal_documents_new_button'),
                onPressed: () async {
                  final id = await showNewInvoiceDialog(context);
                  if (id != null && context.mounted) {
                    context.push('$fiscalDocumentsPath/$id');
                  }
                },
                icon: const Icon(Icons.add),
                label: Text(l10n.fiscalDocumentNewAction),
              ),
          ],
        ),
        Expanded(
          child: CatalogListStateView<FiscalDocumentSummary>(
            state: pageAsync,
            isFiltered: filter.isNarrowed,
            emptyMessage: l10n.fiscalDocumentsEmpty,
            clearFiltersLabel: l10n.clearFiltersButton,
            onClearFilters: () => context.go(clearedPath),
            retryLabel: l10n.retryButton,
            onRetry: () =>
                ref.invalidate(fiscalDocumentsListControllerProvider(filter)),
            onData: (page) => DataTableView<FiscalDocumentSummary>(
              key: const Key('fiscal_documents_table'),
              columns: [
                DataTableColumn(
                  label: l10n.fiscalDocumentColFolio,
                  size: ColumnSize.S,
                  cellBuilder: (context, d) => RecordIdText(
                    d.folioLabel ?? l10n.fiscalDocumentTitleDraft(d.id),
                  ),
                ),
                if (!compact)
                  DataTableColumn(
                    label: l10n.fiscalDocumentColType,
                    size: ColumnSize.S,
                    cellBuilder: (context, d) {
                      final kind = d.kind;
                      return Text(
                        kind == null
                            ? l10n.fiscalDocumentKindUnknown(d.typeCode)
                            : fiscalDocumentKindLabel(l10n, kind),
                      );
                    },
                  ),
                if (!compact)
                  DataTableColumn(
                    label: l10n.fiscalDocumentColIssuer,
                    size: ColumnSize.S,
                    cellBuilder: (context, d) => Tooltip(
                      message: d.issuerName ?? d.issuerRfc,
                      child: RecordIdText(d.issuerRfc),
                    ),
                  ),
                DataTableColumn(
                  label: l10n.fiscalDocumentColRecipient,
                  size: ColumnSize.L,
                  cellBuilder: (context, d) => _Recipient(summary: d),
                ),
                if (!compact)
                  DataTableColumn.timestamp(
                    label: l10n.fiscalDocumentColIssued,
                    size: ColumnSize.S,
                    text: (d) => fmt.display.date(d.issued),
                  ),
                DataTableColumn(
                  label: l10n.fiscalDocumentColStatus,
                  size: ColumnSize.S,
                  cellBuilder: (context, d) =>
                      FiscalDocumentStatusChip(status: d.status),
                ),
                DataTableColumn(
                  label: l10n.fiscalDocumentColTotal,
                  size: ColumnSize.S,
                  numeric: true,
                  cellBuilder: (context, d) => Text(
                    fmt.display.currency(d.total?.toString()),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
              rows: page.items,
              pagination: page,
              onPageChanged: (pageIndex) => context.go(
                query
                    .copyWith(pageIndex: pageIndex)
                    .toUri(fiscalDocumentsPath)
                    .toString(),
              ),
              onRowTap: (d) => context.push('$fiscalDocumentsPath/${d.id}'),
            ),
          ),
        ),
      ],
    );
  }
}

/// The recipient's name with its RFC under it.
class _Recipient extends StatelessWidget {
  const _Recipient({required this.summary});

  final FiscalDocumentSummary summary;

  @override
  Widget build(BuildContext context) {
    final name = summary.recipientName ?? summary.recipientRfc;
    if (name == null) return const Text('—');
    final rfc = summary.recipientRfc;
    return Tooltip(
      message: name,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, overflow: TextOverflow.ellipsis, maxLines: 1),
          if (rfc != null && rfc != name)
            RecordIdText(rfc, overflow: TextOverflow.ellipsis, maxLines: 1),
        ],
      ),
    );
  }
}

/// The drawer's facets (contracts C3): status, type, issuer (with Taxpayers
/// read) and issue date. Each change writes the URL and returns to the first
/// page.
class _FiscalDocumentsFiltersPanel extends ConsumerWidget {
  const _FiscalDocumentsFiltersPanel({required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Taxpayers (24) read: the issuer picker lists taxpayer issuers.
    final canReadIssuers = ref
        .watch(accessControlProvider)
        .can(SystemObject.taxpayers, AccessRight.read);
    final filter = FiscalDocumentsFilter.fromQuery(query);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final knownKind =
        filter.kind == null ||
        FiscalDocumentKind.fromCode(filter.kind!) != null;

    void goTo(ListQuery updated) => context.go(
      updated.copyWith(pageIndex: 0).toUri(fiscalDocumentsPath).toString(),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.fieldGapVertical,
      children: [
        // Rebuilt when the value changes: a dropdown reads its initial value
        // only once.
        KeyedSubtree(
          key: ValueKey(('status', filter.status)),
          child: DropdownButtonFormField<FiscalDocumentStatus?>(
            key: const Key('fiscal_documents_status_filter'),
            initialValue: filter.status,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l10n.fiscalDocumentFacetStatus,
            ),
            items: [
              DropdownMenuItem<FiscalDocumentStatus?>(
                value: null,
                child: Text(l10n.fiscalDocumentFacetAll),
              ),
              for (final s in FiscalDocumentStatus.values)
                DropdownMenuItem<FiscalDocumentStatus?>(
                  value: s,
                  child: Text(fiscalDocumentStatusLabel(l10n, s)),
                ),
            ],
            onChanged: (s) => goTo(query.withFacet('status', s?.wireName)),
          ),
        ),
        KeyedSubtree(
          key: ValueKey(('type', filter.kind)),
          child: DropdownButtonFormField<int?>(
            key: const Key('fiscal_documents_type_filter'),
            initialValue: filter.kind,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l10n.fiscalDocumentFacetType,
            ),
            items: [
              DropdownMenuItem<int?>(
                value: null,
                child: Text(l10n.fiscalDocumentFacetAll),
              ),
              for (final kind in FiscalDocumentKind.values)
                DropdownMenuItem<int?>(
                  value: kind.code,
                  child: Text(fiscalDocumentKindLabel(l10n, kind)),
                ),
              // A code in the URL that the app doesn't know still applies.
              if (!knownKind)
                DropdownMenuItem<int?>(
                  value: filter.kind,
                  child: Text(l10n.fiscalDocumentKindUnknown(filter.kind!)),
                ),
            ],
            onChanged: (code) =>
                goTo(query.withFacet('type', code?.toString())),
          ),
        ),
        if (canReadIssuers)
          CatalogEntityPicker<TaxpayerIssuerListItem>(
            key: const Key('fiscal_documents_issuer_filter'),
            label: l10n.fiscalDocumentFacetIssuer,
            displayStringForOption: (i) => '${i.rfc} — ${i.displayText}',
            optionsBuilder: (search) async {
              final result = await ref
                  .read(taxpayerIssuerRepositoryProvider)
                  .list(search: search.isEmpty ? null : search, limit: 10);
              return result.items;
            },
            onSelected: (i) => goTo(query.withFacet('issuer', i.rfc)),
            initialDisplayText: filter.issuerRfc,
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: spacing.sm,
          children: [
            Text(
              l10n.fiscalDocumentFacetIssued,
              style: theme.textTheme.titleSmall,
            ),
            DateRangeFilterChip(
              key: const Key('fiscal_documents_date_filter'),
              from: filter.from,
              to: filter.to,
              isToday: false,
              onChanged: (range) => goTo(
                query
                    .withFacet('from', encodePaymentsDateFacet(range.start))
                    .withFacet('to', encodePaymentsDateFacet(range.end)),
              ),
              onClear: () =>
                  goTo(query.withFacet('from', null).withFacet('to', null)),
            ),
            Text(
              l10n.fiscalDocumentDateFacetHelper,
              key: const Key('fiscal_documents_date_helper'),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}
