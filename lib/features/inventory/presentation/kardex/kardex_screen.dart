import 'dart:math' as math;

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_sheet.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/core/widgets/compact_field.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/date_range_filter_chip.dart';
import 'package:mbe_ui/core/widgets/fact_strip_row.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/inventory/domain/entities/kardex.dart';
import 'package:mbe_ui/features/inventory/presentation/kardex/kardex_controller.dart';
import 'package:mbe_ui/features/inventory/presentation/kardex/kardex_selection.dart';
import 'package:mbe_ui/features/inventory/presentation/kardex/kardex_sources.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_name_cells.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_warehouse_options.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const kardexPath = '/inventory/kardex';

/// The Kardex as its own pushed page, for screens outside the shell (the
/// product view's "Ver kardex"): pushing the shell branch from there would
/// put a second shell on the root navigator.
const kardexPagePath = '$kardexPath/view';

/// Rows per in-memory page (research R8).
const _pageSize = 100;

/// The Kardex: one product's movements in one warehouse over a date range
/// (spec 071 US3, contracts/ui-contract.md "Kardex"). Gated by Kardex
/// (SystemObject 32) read.
///
/// Read-only. The product, warehouse and range live in the URL and are
/// picked in the filter sheet; a facts strip above the table always shows
/// them (research R2). A movement whose document has a screen the user can
/// read opens it on tap (FR-011).
// simplified: the whole range is held in memory (at most 366 days); if a product's range grows past a few thousand rows, ask mbe-api to page it.
class KardexScreen extends ConsumerStatefulWidget {
  const KardexScreen({super.key, required this.selection, this.pushed = false});

  final KardexSelection selection;

  /// Shown at [kardexPagePath] over the screen that pushed it: its own app
  /// bar with back, and selection changes replace this page instead of
  /// going to the tab.
  final bool pushed;

  @override
  ConsumerState<KardexScreen> createState() => _KardexScreenState();
}

class _KardexScreenState extends ConsumerState<KardexScreen> {
  int _pageIndex = 0;

  @override
  void didUpdateWidget(KardexScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Another product, warehouse or range: back to page 1.
    if (oldWidget.selection != widget.selection) _pageIndex = 0;
  }

  void _openSheet() {
    final l10n = AppLocalizations.of(context)!;
    showCatalogFilterSheet(
      context,
      title: l10n.filtersButton,
      clearAllLabel: l10n.clearAllFilters,
      applyLabel: l10n.applyFilters,
      onClearAll: () =>
          _goTo(context, KardexSelection.initial(), pushed: widget.pushed),
      builder: (_) => _KardexFiltersPanel(pushed: widget.pushed),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final selection = widget.selection;
    final access = ref.watch(accessControlProvider);
    // Products (0) read: the sheet's Producto picker.
    final canReadProducts = access.can(SystemObject.products, AccessRight.read);
    // Warehouses (4) read: the sheet's Almacén picker.
    final canReadWarehouses = access.can(
      SystemObject.warehouses,
      AccessRight.read,
    );

    final defaults = KardexSelection.initial();
    final activeFilterCount =
        (selection.productId != null ? 1 : 0) +
        (selection.warehouseId != null ? 1 : 0) +
        (selection.from != defaults.from || selection.to != defaults.to
            ? 1
            : 0);

    final Widget body;
    switch (selection.state) {
      case KardexSelectionState.incomplete:
        // "Elegir" opens the sheet; it is absent when the sheet has no
        // picker for what is missing.
        final canPick =
            (selection.productId != null || canReadProducts) &&
            (selection.warehouseId != null || canReadWarehouses);
        body = ListEmptyView(
          message: l10n.inventoryKardexIncompletePrompt,
          createLabel: canPick ? l10n.inventoryKardexIncompleteButton : null,
          onCreate: _openSheet,
        );
      case KardexSelectionState.reversed:
        body = _RangeMessage(
          key: const Key('kardex_range_reversed'),
          text: l10n.inventoryKardexRangeReversed,
        );
      case KardexSelectionState.tooLong:
        body = _RangeMessage(
          key: const Key('kardex_range_too_long'),
          text: l10n.inventoryKardexRangeTooLong('$kardexMaxRangeDays'),
        );
      case KardexSelectionState.ready:
        body = ref
            .watch(kardexControllerProvider(selection))
            .when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => ListFailedView(
                error: toAppError(error),
                retryLabel: l10n.retryButton,
                onRetry: () =>
                    ref.invalidate(kardexControllerProvider(selection)),
              ),
              data: (kardex) => kardex == null
                  ? const SizedBox.shrink()
                  : _KardexBody(
                      kardex: kardex,
                      pageIndex: _pageIndex,
                      onPageChanged: (index) =>
                          setState(() => _pageIndex = index),
                    ),
            );
    }

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.fieldGapVertical,
      children: [
        CatalogFilterBar(
          filters: [
            Badge.count(
              count: activeFilterCount,
              isLabelVisible: activeFilterCount > 0,
              child: IconButton.outlined(
                key: const Key('kardex_filter_button'),
                icon: const Icon(Icons.tune),
                tooltip: l10n.filtersTooltip,
                onPressed: _openSheet,
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.cardPadding),
          child: _SelectionStrip(selection: selection),
        ),
        Expanded(child: body),
      ],
    );
    if (!widget.pushed) return content;
    // Read-only: no app bar actions (constitution §VI).
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navInventoryKardex)),
      body: content,
    );
  }
}

/// Writes [selection] to the URL: the tab goes to itself; the pushed page
/// replaces itself, so the screen under it stays and back returns there.
void _goTo(
  BuildContext context,
  KardexSelection selection, {
  required bool pushed,
}) => pushed
    ? context.replace(selection.toUri(kardexPagePath).toString())
    : context.go(selection.toUri(kardexPath).toString());

/// The product's "{code} {name}", or `#id` without Products read or when it
/// can't be read.
String _productLabel(WidgetRef ref, int productId) {
  // Products (0) read: the name comes from the catalog.
  final canRead = ref
      .watch(accessControlProvider)
      .can(SystemObject.products, AccessRight.read);
  final label = canRead
      ? ref.watch(kardexProductLabelProvider(productId)).value
      : null;
  return label ?? '#$productId';
}

/// Producto · Almacén · Rango, always shown (research R2).
class _SelectionStrip extends ConsumerWidget {
  const _SelectionStrip({required this.selection});

  final KardexSelection selection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final fmt = ref.watch(formattersProvider);
    final productId = selection.productId;
    final warehouseId = selection.warehouseId;
    return FactStripRow(
      key: const Key('kardex_selection'),
      facts: [
        CompactField(
          label: l10n.inventoryKardexSelectionProduct,
          child: Text(
            productId == null
                ? emptyValuePlaceholder
                : _productLabel(ref, productId),
          ),
        ),
        CompactField(
          label: l10n.inventoryKardexSelectionWarehouse,
          child: warehouseId == null
              ? const Text(emptyValuePlaceholder)
              : InventoryWarehouseName(warehouseId: warehouseId),
        ),
        CompactField(
          label: l10n.inventoryKardexSelectionRange,
          child: Text(
            l10n.dateRangeFilterRange(
              fmt.display.date(selection.from),
              fmt.display.date(selection.to),
            ),
          ),
        ),
      ],
      trailing: const SizedBox.shrink(),
    );
  }
}

/// An invalid range's text, shown instead of loading (FR-009).
class _RangeMessage extends StatelessWidget {
  const _RangeMessage({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(theme.spacing.screenMargin),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
      ),
    );
  }
}

/// The summary strip, then the movements a page at a time, in the server's
/// order.
class _KardexBody extends ConsumerWidget {
  const _KardexBody({
    required this.kardex,
    required this.pageIndex,
    required this.onPageChanged,
  });

  final Kardex kardex;
  final int pageIndex;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final fmt = ref.watch(formattersProvider);
    final access = ref.watch(accessControlProvider);

    // Negative figures stay negative (FR-016).
    String quantity(Object value) => fmt.display.quantity(value.toString());

    Widget total(String label, Object value) =>
        CompactField(label: label, child: Text(quantity(value)));

    final movements = kardex.movements;
    final lastPage = math.max(0, (movements.length - 1) ~/ _pageSize);
    final page = math.min(pageIndex, lastPage);
    final rows = movements.skip(page * _pageSize).take(_pageSize).toList();

    String? route(KardexMovement m) => kardexDocumentRoute(m.document, access);

    final linkStyle = TextStyle(
      color: theme.colorScheme.primary,
      decoration: TextDecoration.underline,
      decorationColor: theme.colorScheme.primary,
    );

    DataTableColumn<KardexMovement> quantityColumn(
      String label,
      String Function(KardexMovement m) value,
    ) => DataTableColumn(
      label: label,
      size: ColumnSize.S,
      numeric: true,
      cellBuilder: (context, m) => Text(value(m), textAlign: TextAlign.end),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: spacing.fieldGapVertical,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.cardPadding),
          child: FactStripRow(
            key: const Key('kardex_summary'),
            facts: [
              total(l10n.inventoryKardexSummaryOpening, kardex.opening),
              total(l10n.inventoryKardexSummaryIn, kardex.totalIn),
              total(l10n.inventoryKardexSummaryOut, kardex.totalOut),
              total(l10n.inventoryKardexSummaryClosing, kardex.closing),
            ],
            trailing: const SizedBox.shrink(),
          ),
        ),
        Expanded(
          child: movements.isEmpty
              ? ListEmptyView(message: l10n.inventoryKardexEmpty)
              : DataTableView<KardexMovement>(
                  key: const Key('kardex_table'),
                  // The page is complete (paged here, not by the server),
                  // so the table never draws placeholder rows.
                  rows: rows,
                  pagination: CatalogPage<KardexMovement>(
                    items: rows,
                    total: movements.length,
                    pageIndex: page,
                    pageSize: _pageSize,
                  ),
                  onPageChanged: onPageChanged,
                  onRowTap: (m) {
                    final target = route(m);
                    if (target != null) context.push(target);
                  },
                  columns: [
                    DataTableColumn(
                      label: l10n.inventoryKardexColumnDate,
                      size: ColumnSize.M,
                      cellBuilder: (context, m) =>
                          Text(fmt.display.dateTime(m.date)),
                    ),
                    DataTableColumn(
                      label: l10n.inventoryKardexColumnSource,
                      size: ColumnSize.M,
                      cellBuilder: (context, m) =>
                          Text(kardexSourceLabel(l10n, m.sourceType)),
                    ),
                    DataTableColumn(
                      label: l10n.inventoryKardexColumnDocument,
                      size: ColumnSize.S,
                      cellBuilder: (context, m) => route(m) == null
                          ? Text(_documentLabel(m))
                          : Text(
                              _documentLabel(m),
                              key: Key('kardex_doc_${m.id}'),
                              style: linkStyle,
                            ),
                    ),
                    // One of Entrada and Salida is filled per row; a zero
                    // one is left blank (wireframes).
                    quantityColumn(
                      l10n.inventoryKardexColumnIn,
                      (m) =>
                          m.quantityIn.sign == 0 ? '' : quantity(m.quantityIn),
                    ),
                    quantityColumn(
                      l10n.inventoryKardexColumnOut,
                      (m) => m.quantityOut.sign == 0
                          ? ''
                          : quantity(m.quantityOut),
                    ),
                    quantityColumn(
                      l10n.inventoryKardexColumnBalance,
                      (m) => quantity(m.balance),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

/// The document's folio, else "#{id}", else "#{reference}" when the row has
/// one, else "—".
String _documentLabel(KardexMovement m) {
  final document = m.document;
  if (document != null) {
    final serial = document.serial;
    return serial != null ? '$serial' : '#${document.id}';
  }
  return m.reference != 0 ? '#${m.reference}' : emptyValuePlaceholder;
}

/// The sheet's facets (spec 071 ui-contract): Producto with Products read,
/// Almacén with Warehouses (4) read, and Rango. Each change writes the URL.
class _KardexFiltersPanel extends ConsumerWidget {
  const _KardexFiltersPanel({required this.pushed});

  final bool pushed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter.of(context);
    return ListenableBuilder(
      listenable: router.routerDelegate,
      builder: (context, _) => _panel(
        context,
        ref,
        KardexSelection.fromUri(currentRouteUri(router)),
      ),
    );
  }

  Widget _panel(BuildContext context, WidgetRef ref, KardexSelection s) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final access = ref.watch(accessControlProvider);
    // Products (0) read: the picker lists products.
    final canReadProducts = access.can(SystemObject.products, AccessRight.read);
    // Warehouses (4) read: the picker lists warehouses.
    final canReadWarehouses = access.can(
      SystemObject.warehouses,
      AccessRight.read,
    );
    final productId = s.productId;
    final warehouseId = s.warehouseId;
    final warehouseName = warehouseId == null || !canReadWarehouses
        ? null
        : ref.watch(warehouseDisplayNameProvider(warehouseId)).value;

    void goTo(KardexSelection updated) =>
        _goTo(context, updated, pushed: pushed);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.fieldGapVertical,
      children: [
        if (canReadProducts)
          CatalogEntityPicker<ProductListItem>(
            key: const Key('kardex_product_filter'),
            label: l10n.inventoryKardexFilterProduct,
            displayStringForOption: (p) => '${p.code} ${p.name}',
            // Stockable, active or not, so a discontinued product's history
            // can still be read (research R12).
            optionsBuilder: (search) async =>
                (await ref
                        .read(productRepositoryProvider)
                        .list(
                          search: search.isEmpty ? null : search,
                          stockable: true,
                          status: null,
                          limit: 10,
                        ))
                    .items,
            onSelected: (p) => goTo(s.copyWith(productId: () => p.productId)),
            initialDisplayText: productId == null
                ? null
                : _productLabel(ref, productId),
          ),
        if (canReadWarehouses)
          CatalogEntityPicker<Warehouse>(
            key: const Key('kardex_warehouse_filter'),
            label: l10n.inventoryKardexFilterWarehouse,
            displayStringForOption: (w) => w.name,
            optionSubtitle: (w) => w.facilityName,
            optionsBuilder: (search) => inventoryFilterWarehouseOptions(
              ref.read(warehouseRepositoryProvider),
              search,
            ),
            onSelected: (w) =>
                goTo(s.copyWith(warehouseId: () => w.warehouseId)),
            initialDisplayText:
                warehouseName ?? (warehouseId == null ? null : '#$warehouseId'),
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: spacing.sm,
          children: [
            Text(
              l10n.inventoryKardexFilterRange,
              style: theme.textTheme.titleSmall,
            ),
            // The real range, never "Hoy"; clearing returns to the last 30
            // days. The 366-day limit is the screen's check (research R3).
            DateRangeFilterChip(
              from: s.from,
              to: s.to,
              isToday: false,
              firstDate: DateTime(2000),
              onChanged: (range) => goTo(
                s.copyWith(
                  from: DateUtils.dateOnly(range.start),
                  to: DateUtils.dateOnly(range.end),
                ),
              ),
              onClear: () {
                final defaults = KardexSelection.initial();
                goTo(s.copyWith(from: defaults.from, to: defaults.to));
              },
            ),
          ],
        ),
      ],
    );
  }
}
