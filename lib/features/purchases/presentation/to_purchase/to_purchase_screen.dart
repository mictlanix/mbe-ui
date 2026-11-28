import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_sheet.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/facility_list_item.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_name_cells.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_order.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/purchase_order_actions.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/purchase_order_availability.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/purchase_order_detail_screen.dart';
import 'package:mbe_ui/features/purchases/presentation/to_purchase/to_purchase_controller.dart';
import 'package:mbe_ui/features/purchases/presentation/to_purchase/to_purchase_filter.dart';
import 'package:mbe_ui/features/purchases/presentation/to_purchase/to_purchase_selection.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const toPurchasePath = '/purchases/to-purchase';

/// A group's identity on screen, supplier or not.
typedef _GroupId = (int?, int);

_GroupId _idOf(ToPurchaseGroup g) => (g.supplierId, g.facilityId);

/// The selection key of [g], or null for a "Sin proveedor" group.
ToPurchaseGroupKey? _keyOf(ToPurchaseGroup g) {
  final supplierId = g.supplierId;
  return supplierId == null
      ? null
      : (supplierId: supplierId, facilityId: g.facilityId);
}

/// Por comprar: the marked lines of approved requests not yet on an order,
/// grouped by supplier and facility, for a buyer to turn a group into a
/// draft order (spec 080 US1, contracts/ui-contract.md "Por comprar",
/// research R5). Gated by PurchasesOrders (SystemObject 20) read, at the
/// route.
///
/// The filter row has no search (the endpoint has none). Its one facet,
/// Sucursal, lives in the filter drawer (§VI), which needs Facilities read.
/// "Crear orden" (create on 20) is the one toolbar create (§VI): it acts on
/// the group selected by its radio or a tap on its header.
///
/// simplified: client-side paging, no search or supplier facet, until
/// mictlanix/mbe-api#354.
class ToPurchaseScreen extends ConsumerStatefulWidget {
  const ToPurchaseScreen({super.key, required this.query});

  final ListQuery query;

  @override
  ConsumerState<ToPurchaseScreen> createState() => _ToPurchaseScreenState();
}

class _ToPurchaseScreenState extends ConsumerState<ToPurchaseScreen> {
  /// A create is in flight: Crear orden is disabled meanwhile.
  bool _creating = false;

  /// The last create's refusal, until the user refreshes, changes the
  /// filter or page, or picks another group.
  AppError? _error;

  /// The groups the user expanded; with one group on the page it is
  /// expanded regardless.
  final Set<_GroupId> _expanded = {};

  ToPurchaseFilter get _filter => ToPurchaseFilter.fromQuery(widget.query);

  @override
  void didUpdateWidget(ToPurchaseScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Another facility or page: the refusal was about a group not shown.
    if (ToPurchaseFilter.fromQuery(oldWidget.query) != _filter) _error = null;
  }

  void _refresh(ToPurchaseFilter filter) {
    setState(() => _error = null);
    ref.invalidate(toPurchaseControllerProvider(filter.facilityId));
  }

  void _select(ToPurchaseFilter filter, ToPurchaseGroupKey key) {
    setState(() => _error = null);
    ref.read(toPurchaseSelectionProvider(filter).notifier).select(key);
  }

  /// Creates the order for the group [key] names, pushes it and says how
  /// many lines it took (counted on the server's answer) and how many were
  /// left out (FR-018). Por comprar reloads by itself (the write invalidates
  /// it), which clears the selection.
  Future<void> _create(ToPurchaseGroupKey key) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _creating = true;
      _error = null;
    });
    final (:error, :id, :lines, :skipped) = await ref
        .read(purchaseOrderActionsProvider.notifier)
        .createFromGroup(
          supplierId: key.supplierId,
          facilityId: key.facilityId,
        );
    if (!mounted) return;
    setState(() {
      _creating = false;
      _error = error;
    });
    if (error != null || id == null) return;
    ref.read(toPurchaseSelectionProvider(_filter).notifier).clear();
    final created = l10n.toPurchaseCreatedSnack('$id', lines);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          skipped > 0
              ? '$created${l10n.purchaseOrderLeftOutSnack(skipped)}'
              : created,
        ),
      ),
    );
    context.push('$purchaseOrdersPath/$id');
  }

  void _goToPage(int index) => context.go(
    widget.query.copyWith(pageIndex: index).toUri(toPurchasePath).toString(),
  );

  void _toggle(ToPurchaseGroup g) => setState(() {
    final id = _idOf(g);
    if (!_expanded.remove(id)) _expanded.add(id);
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final access = ref.watch(accessControlProvider);
    // PurchasesOrders (20) create: Crear orden.
    final canCreate = PurchaseOrderAvailability(
      status: null,
      access: access,
    ).canCreateFromGroup;
    // Facilities (29) read: the Sucursal facet. Without it there is no
    // facet, so the filters button is left out.
    final canPickFacility = access.can(
      SystemObject.facilities,
      AccessRight.read,
    );
    final filter = _filter;
    final groupsAsync = ref.watch(
      toPurchaseControllerProvider(filter.facilityId),
    );
    final pageAsync = groupsAsync.whenData(
      (groups) => toPurchasePage(groups, filter.pageIndex),
    );
    final pageGroups = pageAsync.value?.items ?? const <ToPurchaseGroup>[];
    final chosen = ref.watch(toPurchaseSelectionProvider(filter));
    // With one group on the page, it starts selected (research R5).
    final selected =
        chosen ?? (pageGroups.length == 1 ? _keyOf(pageGroups.single) : null);
    final selectedGroup = selected == null
        ? null
        : pageGroups.where((g) => _keyOf(g) == selected).firstOrNull;
    final error = _error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: spacing.fieldGapVertical,
      children: [
        CatalogFilterBar(
          // No search: `/purchase-orders/to-purchase` has none.
          actions: [
            if (canPickFacility)
              Badge.count(
                count: filter.activeFilterCount,
                isLabelVisible: filter.activeFilterCount > 0,
                child: IconButton.outlined(
                  key: const Key('to_purchase_filter_button'),
                  icon: const Icon(Icons.tune),
                  tooltip: l10n.filtersTooltip,
                  onPressed: () => showCatalogFilterSheet(
                    context,
                    title: l10n.filtersButton,
                    clearAllLabel: l10n.clearAllFilters,
                    applyLabel: l10n.applyFilters,
                    onClearAll: () => context.go(toPurchasePath),
                    builder: (_) => CurrentListQueryBuilder(
                      builder: (context, query) =>
                          _ToPurchaseFiltersPanel(query: query),
                    ),
                  ),
                ),
              ),
            OutlinedButton.icon(
              key: const Key('to_purchase_refresh'),
              onPressed: () => _refresh(filter),
              icon: const Icon(Icons.refresh),
              label: Text(l10n.toPurchaseRefresh),
            ),
            // Present with create on 20; disabled until a group with a
            // supplier is selected (state, not rights).
            if (canCreate)
              _withReason(
                // Says why it is disabled while nothing is selected.
                selectedGroup == null
                    ? l10n.toPurchaseCreateOrderNoSelection
                    : null,
                FilledButton.icon(
                  key: const Key('to_purchase_create_order'),
                  onPressed: selectedGroup == null || _creating
                      ? null
                      : () => _create(selected!),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.toPurchaseCreateOrder),
                ),
              ),
          ],
        ),
        if (error != null)
          ErrorBanner(key: const Key('to_purchase_refusal'), error: error),
        Expanded(
          child: CatalogListStateView<ToPurchaseGroup>(
            state: pageAsync,
            isFiltered: filter.facilityId != null,
            emptyMessage: l10n.toPurchaseEmpty,
            clearFiltersLabel: l10n.clearFiltersButton,
            onClearFilters: () => context.go(toPurchasePath),
            retryLabel: l10n.retryButton,
            onRetry: () =>
                ref.invalidate(toPurchaseControllerProvider(filter.facilityId)),
            onData: (page) => RadioGroup<ToPurchaseGroupKey>(
              groupValue: selected,
              onChanged: (key) {
                if (key != null) _select(filter, key);
              },
              child: ListView(
                key: const Key('to_purchase_groups'),
                children: [
                  for (final g in page.items)
                    _GroupCard(
                      group: g,
                      expanded:
                          page.items.length == 1 ||
                          _expanded.contains(_idOf(g)),
                      onToggle: () => _toggle(g),
                      onSelect: switch (_keyOf(g)) {
                        final key? => () => _select(filter, key),
                        null => null,
                      },
                    ),
                  _PaginationFooter(page: page, onPageChanged: _goToPage),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// [child] with [reason] as its tooltip, or alone when there is none.
Widget _withReason(String? reason, Widget child) =>
    reason == null ? child : Tooltip(message: reason, child: child);

/// One group: a header with its radio (only with a supplier), supplier,
/// facility, line count and estimate; its lines below when expanded.
class _GroupCard extends ConsumerWidget {
  const _GroupCard({
    required this.group,
    required this.expanded,
    required this.onToggle,
    required this.onSelect,
  });

  final ToPurchaseGroup group;
  final bool expanded;
  final VoidCallback onToggle;

  /// Null on a "Sin proveedor" group: it can't be selected.
  final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final fmt = ref.watch(formattersProvider);
    final key = _keyOf(group);
    final tag = '${group.supplierId ?? 'none'}_${group.facilityId}';
    final supplier = group.supplierId == null
        ? l10n.toPurchaseNoSupplier
        : (group.supplierName ?? '${group.supplierId}');

    return Card(
      key: Key('to_purchase_group_$tag'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            key: Key('to_purchase_group_header_$tag'),
            onTap: onSelect ?? onToggle,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.sm,
                vertical: spacing.xs,
              ),
              child: Row(
                spacing: spacing.sm,
                children: [
                  if (key != null)
                    Radio<ToPurchaseGroupKey>(
                      key: Key('to_purchase_group_radio_$tag'),
                      value: key,
                    )
                  else
                    SizedBox(width: kMinInteractiveDimension),
                  IconButton(
                    key: Key('to_purchase_group_toggle_$tag'),
                    icon: Icon(
                      expanded ? Icons.expand_more : Icons.chevron_right,
                    ),
                    onPressed: onToggle,
                  ),
                  // The count and estimate sit at the end when they fit and
                  // wrap under the supplier when they don't: on a narrow
                  // window at the largest text, never cut (the money least).
                  Expanded(
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: spacing.sm,
                      children: [
                        Wrap(
                          spacing: spacing.xs,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(supplier, style: theme.textTheme.titleSmall),
                            const Text('·'),
                            InventoryFacilityName(facilityId: group.facilityId),
                          ],
                        ),
                        Wrap(
                          spacing: spacing.sm,
                          children: [
                            Text(l10n.toPurchaseLineCount(group.lineCount)),
                            Text(
                              l10n.toPurchaseEstimate(
                                fmt.display.currency(
                                  group.estimatedTotal.toString(),
                                ),
                              ),
                              key: Key('to_purchase_group_total_$tag'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (key == null)
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: spacing.xl,
                bottom: spacing.sm,
              ),
              child: Text(
                l10n.toPurchaseNoSupplierHint,
                style: theme.textTheme.bodySmall,
              ),
            ),
          if (expanded) _GroupLines(group: group, tag: tag),
        ],
      ),
    );
  }
}

/// A group's lines: Solicitud, Código, Producto, Cantidad, Almacén, Costo.
class _GroupLines extends ConsumerWidget {
  const _GroupLines({required this.group, required this.tag});

  final ToPurchaseGroup group;
  final String tag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final fmt = ref.watch(formattersProvider);
    return Padding(
      padding: EdgeInsets.all(spacing.sm),
      child: DataTableView<ToPurchaseLine>(
        key: Key('to_purchase_group_lines_$tag'),
        shrinkWrap: true,
        margin: EdgeInsets.zero,
        rows: group.lines,
        columns: [
          DataTableColumn.text(
            label: l10n.toPurchaseColRequest,
            size: ColumnSize.S,
            text: (line) => '${line.serial ?? '#${line.requestId}'}',
          ),
          DataTableColumn.text(
            label: l10n.toPurchaseColCode,
            size: ColumnSize.S,
            text: (line) => line.productCode,
          ),
          DataTableColumn.text(
            label: l10n.toPurchaseColProduct,
            size: ColumnSize.L,
            text: (line) => line.productName ?? emptyValuePlaceholder,
          ),
          DataTableColumn(
            label: l10n.toPurchaseColQuantity,
            numeric: true,
            size: ColumnSize.S,
            cellBuilder: (context, line) =>
                Text(fmt.display.quantity(line.quantity.toString())),
          ),
          DataTableColumn(
            label: l10n.toPurchaseColWarehouse,
            size: ColumnSize.M,
            cellBuilder: (context, line) =>
                InventoryWarehouseName(warehouseId: line.warehouseId),
          ),
          DataTableColumn(
            label: l10n.toPurchaseColCost,
            numeric: true,
            size: ColumnSize.S,
            cellBuilder: (context, line) => Text(
              line.cost.sign == 0
                  ? l10n.toPurchaseNoCost
                  : fmt.display.currency(line.cost.toString()),
              key: Key('to_purchase_line_cost_${line.requestLineId}'),
            ),
          ),
        ],
      ),
    );
  }
}

/// The pagination footer for the group cards. `DataTableView`'s pagination
/// is `data_table_2`'s and can't drive cards, so this mirrors the facilities
/// list's card footer (§VI: pagination stays).
class _PaginationFooter extends ConsumerWidget {
  const _PaginationFooter({required this.page, required this.onPageChanged});

  final CatalogPage<ToPurchaseGroup> page;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (page.total == 0) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final fmt = ref.watch(formattersProvider);
    final start = page.pageIndex * page.pageSize + 1;
    final end = start + page.items.length - 1;
    final lastPageIndex = (page.total - 1) ~/ page.pageSize;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacing.sm,
        vertical: theme.spacing.xs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            l10n.toPurchasePaginationSummary(
              fmt.display.count(start),
              fmt.display.count(end),
              fmt.display.count(page.total),
            ),
            key: const Key('to_purchase_pagination_summary'),
            style: theme.textTheme.bodySmall,
          ),
          IconButton(
            key: const Key('to_purchase_previous_page'),
            icon: const Icon(Icons.chevron_left),
            tooltip: l10n.previousPageTooltip,
            onPressed: page.pageIndex > 0
                ? () => onPageChanged(page.pageIndex - 1)
                : null,
          ),
          IconButton(
            key: const Key('to_purchase_next_page'),
            icon: const Icon(Icons.chevron_right),
            tooltip: l10n.nextPageTooltip,
            onPressed: page.pageIndex < lastPageIndex
                ? () => onPageChanged(page.pageIndex + 1)
                : null,
          ),
        ],
      ),
    );
  }
}

/// The drawer's one facet, Sucursal (shown only with Facilities read). A
/// change writes the address and returns to the first page.
class _ToPurchaseFiltersPanel extends ConsumerWidget {
  const _ToPurchaseFiltersPanel({required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final facilityId = ToPurchaseFilter.fromQuery(query).facilityId;
    final facilityName = facilityId == null
        ? null
        : ref.watch(facilityDisplayNameProvider(facilityId)).value;

    return CatalogEntityPicker<FacilityListItem>(
      key: const Key('to_purchase_filter_facility'),
      label: l10n.toPurchaseFacetFacility,
      displayStringForOption: (f) => f.name,
      optionsBuilder: (search) async {
        final result = await ref
            .read(facilityRepositoryProvider)
            .list(search: search.isEmpty ? null : search);
        return result.items;
      },
      onSelected: (f) => context.go(
        query
            .withFacet('facility', '${f.facilityId}')
            .copyWith(pageIndex: 0)
            .toUri(toPurchasePath)
            .toString(),
      ),
      initialDisplayText: facilityId == null
          ? null
          : (facilityName ?? '$facilityId'),
    );
  }
}
