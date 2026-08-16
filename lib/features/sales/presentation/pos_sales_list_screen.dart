import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/date_range_filter_chip.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/core/widgets/money_formatters.dart';
import 'package:mbe_ui/features/sales/domain/entities/current_session.dart';
import 'package:mbe_ui/features/sales/domain/entities/open_sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/sale_workability.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_customer_controller.dart';
import 'package:mbe_ui/features/sales/presentation/current_session_controller.dart';
import 'package:mbe_ui/features/sales/presentation/open_sales_selector_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sales_list_controller.dart';
import 'package:mbe_ui/features/sales/presentation/register_controller.dart';
import 'package:mbe_ui/features/sales/presentation/widgets/pos_sale_status_chip.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const _posPath = '/sales/pos';

/// The register's sales (spec 023 contracts/pos-sales-list.md) — what
/// `/sales/pos` renders now that the sale itself lives at the top-level
/// `/sales/pos/new` / `/sales/pos/:saleId` routes (`PosWorkspaceScreen`).
///
/// [query] is decoded from the route by the router builder, exactly like
/// every other catalog list screen — the URL is this screen's only source of
/// view state.
class PosSalesListScreen extends ConsumerWidget {
  const PosSalesListScreen({super.key, required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final pointSale = ref.watch(registerPointSaleProvider);

    // FR-003 / Edge Cases: distinct from "no sales in range" — no query is
    // issued at all when the signed-in user has no register configured.
    if (pointSale == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            key: const Key('pos_sales_no_register'),
            l10n.posSalesNoRegister,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Read once and reused: the filter's default range and every "is this
    // filtered?" question below must be judged against the same instant.
    final today = DateTime.now();
    final filter = PosSalesFilter.fromQuery(query, today: today);
    final pageAsync = ref.watch(posSalesListControllerProvider(pointSale, filter));

    // The register's open-sales set — already computed for today by the
    // header selector's own provider — is exactly what `saleIsWorkable`
    // needs for the one case a summary alone cannot decide (a zero-balance
    // paid sale). An unresolved/failed lookup degrades to an *empty* set,
    // per `saleIsWorkable`'s own contract — not a gate on the whole
    // workability check: a draft or a completed sale with a balance is
    // workable independent of this set, and must not be held hostage by it
    // still loading.
    final resumableIds = ref
            .watch(openSalesSelectorControllerProvider(pointSale))
            .valueOrNull
            ?.map((sale) => sale.id)
            .toSet() ??
        const <int>{};

    final access = ref.watch(accessControlProvider);
    final canUpdate = access.can(SystemObject.salesOrders, AccessRight.update);
    final canCreate = access.can(SystemObject.pos, AccessRight.create);
    final sessionOpen =
        ref.watch(currentSessionControllerProvider).valueOrNull?.state !=
        SessionState.none;
    final locale = Localizations.localeOf(context).toString();

    void goTo(ListQuery updated) => context.go(updated.toUri(_posPath).toString());

    Future<void> openSale(int saleId) async {
      await context.push('$_posPath/$saleId');
      if (!context.mounted) return;
      // FR-009: a sale finished or abandoned in the workspace must not still
      // read as open once the cashier is back on the list.
      ref.invalidate(posSalesListControllerProvider(pointSale, filter));
      ref.invalidate(openSalesSelectorControllerProvider(pointSale));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: CatalogFilterBar(
            search: CatalogSearchBar(
              key: const Key('pos_sales_search_field'),
              label: l10n.posSalesSearchLabel,
              searchTooltip: l10n.searchButtonTooltip,
              initialValue: filter.search,
              onSubmitted: (value) =>
                  goTo(query.copyWith(search: value, pageIndex: 0)),
            ),
            actions: [
              _NewSaleAction(
                canCreate: canCreate,
                sessionOpen: sessionOpen,
                onPressed: () => context.push('$_posPath/new'),
              ),
            ],
            filters: [
              DateRangeFilterChip(
                from: filter.from,
                to: filter.to,
                isToday: filter.isToday(today),
                onChanged: (range) => goTo(
                  query
                      .withFacet('date-from', encodePosSalesDateFacet(range.start))
                      .withFacet('date-to', encodePosSalesDateFacet(range.end))
                      .copyWith(pageIndex: 0),
                ),
                onClear: () => goTo(
                  query
                      .withFacet('date-from', null)
                      .withFacet('date-to', null)
                      .copyWith(pageIndex: 0),
                ),
              ),
              _StatusFilterChip(
                status: filter.status,
                onChanged: (status) => goTo(
                  query
                      .withFacet('status', status?.name)
                      .copyWith(pageIndex: 0),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: CatalogListStateView<OpenSale>(
            state: pageAsync,
            // `emptyMessage` renders only for the plain (unfiltered) empty
            // state — a filtered-empty result gets the shared generic
            // message every other catalog uses, driven by `isFiltered`
            // alone (list_state_views.dart), not a second custom string.
            isFiltered: !filter.isToday(today) || filter.status != null || filter.search.isNotEmpty,
            emptyMessage: l10n.posSalesEmptyToday,
            clearFiltersLabel: l10n.clearFiltersButton,
            onClearFilters: () => context.go(_posPath),
            retryLabel: l10n.retryButton,
            onRetry: () =>
                ref.invalidate(posSalesListControllerProvider(pointSale, filter)),
            onData: (page) => DataTableView<OpenSale>(
              key: const Key('pos_sales_list_table'),
              columns: [
                DataTableColumn(
                  label: l10n.posSalesColumnReference,
                  size: ColumnSize.S,
                  cellBuilder: (context, sale) =>
                      Text('${sale.serial ?? sale.id}'),
                ),
                DataTableColumn(
                  label: l10n.posSalesColumnDate,
                  size: ColumnSize.M,
                  cellBuilder: (context, sale) =>
                      Text(MoneyFormatters.dateTime(sale.date, locale: locale)),
                ),
                DataTableColumn(
                  label: l10n.posSalesColumnCustomer,
                  size: ColumnSize.L,
                  cellBuilder: (context, sale) => _CustomerCell(sale: sale),
                ),
                DataTableColumn(
                  label: l10n.posSalesColumnStatus,
                  size: ColumnSize.S,
                  cellBuilder: (context, sale) => PosSaleStatusChip(status: sale.status),
                ),
                DataTableColumn(
                  label: l10n.posSalesColumnTotal,
                  numeric: true,
                  size: ColumnSize.S,
                  cellBuilder: (context, sale) =>
                      Text(MoneyFormatters.currency(sale.total, locale: locale)),
                ),
                DataTableColumn(
                  label: l10n.posSalesColumnBalance,
                  numeric: true,
                  size: ColumnSize.S,
                  cellBuilder: (context, sale) =>
                      Text(MoneyFormatters.currency(sale.balance, locale: locale)),
                ),
              ],
              rows: page.items,
              pagination: page,
              onPageChanged: (pageIndex) =>
                  context.go(query.copyWith(pageIndex: pageIndex).toUri(_posPath).toString()),
              rowActionsBuilder: (context, sale) {
                // A draft or a completed sale with a balance is workable
                // independent of `resumableIds` — only a zero-balance paid
                // sale actually consults it, and an unresolved set then
                // reads as provisionally not workable (data-model §3)
                // rather than offering an Edit that would land on a
                // refusal.
                final workable = saleIsWorkable(sale, resumableIds: resumableIds);
                // Absent uniformly whether the reason is the RBAC privilege
                // or the sale's own state (constitution §VI: a row action a
                // user cannot use is hidden, never shown disabled) — the
                // status chip already tells a cashier *why* a finished or
                // cancelled sale has no Edit icon, so nothing here repeats it.
                return buildCatalogRowActions(
                  editTooltip: l10n.editActionTooltip,
                  onEdit: canUpdate && workable ? () => openSale(sale.id) : null,
                );
              },
              // FR-006a: a stray click always opens the sale, read-only for
              // anything the row's own Edit icon would not offer — the
              // workspace itself decides editable vs. read-only from the
              // sale's status, not this list.
              onRowTap: (sale) => openSale(sale.id),
            ),
          ),
        ),
      ],
    );
  }
}

/// The customer a sale is for, resolved from its own `customer` id.
///
/// `OpenSale.customerName` alone is not the answer, which is why this column
/// read "—" for every row: that field is the per-document *override* mbe's
/// data dictionary calls "Override customer name on docs", and mbe-api sets
/// it only from what a client sends — so it is null on every ordinary sale,
/// the walk-in customer included, even while the customer record itself
/// knows the name. `CustomerBar` hit this exact problem on the sale surface
/// and resolves the same way (FR-023); reusing its provider means a page of
/// sales for one customer costs one lookup, not one per row, since the
/// family caches per id.
///
/// The override still wins nothing — it is the fallback — because a sale
/// carrying one is a sale whose document deliberately names someone else.
class _CustomerCell extends ConsumerWidget {
  const _CustomerCell({required this.sale});

  final OpenSale sale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resolved = ref
        .watch(saleCustomerControllerProvider(sale.customer))
        .valueOrNull;
    final name = resolved?.name ?? sale.customerName ?? '—';
    // The same treatment `DataTableColumn.text` gives every other text cell,
    // since this is one — a tooltip carrying the full value behind a
    // single ellipsized line.
    return Tooltip(
      message: name,
      child: Text(name, overflow: TextOverflow.ellipsis, maxLines: 1),
    );
  }
}

/// The list's primary action (contracts/pos-sales-list.md §7): enabled with
/// an open/stale cash session, disabled with a reason when there is none,
/// absent without the `pos` create privilege.
class _NewSaleAction extends StatelessWidget {
  const _NewSaleAction({
    required this.canCreate,
    required this.sessionOpen,
    required this.onPressed,
  });

  final bool canCreate;
  final bool sessionOpen;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (!canCreate) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;

    final button = FilledButton.icon(
      key: const Key('pos_sales_new_sale_button'),
      icon: Icon(CatalogAction.create.icon),
      label: Text(l10n.posSalesNewSaleAction),
      onPressed: sessionOpen ? onPressed : null,
    );
    if (sessionOpen) return button;
    return Tooltip(message: l10n.posSalesNewSaleBlockedNoSession, child: button);
  }
}

/// Single-select status facet (contracts/pos-sales-list.md §4.2), absent
/// meaning every status. A menu rather than four separate chips — mbe-api's
/// `status` filter answers with more than what was asked (spec 020's own
/// finding on `listOpen`), which the list controller narrows client-side;
/// this control only picks the one status a cashier means.
class _StatusFilterChip extends StatelessWidget {
  const _StatusFilterChip({required this.status, required this.onChanged});

  final SaleStatus? status;
  final ValueChanged<SaleStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = status == null
        ? l10n.posSalesStatusFilterAll
        : posSaleStatusLabel(l10n, status!);

    return PopupMenuButton<SaleStatus?>(
      key: const Key('pos_sales_status_filter_chip'),
      tooltip: l10n.posSalesStatusFilterLabel,
      onSelected: onChanged,
      itemBuilder: (context) => [
        PopupMenuItem(value: null, child: Text(l10n.posSalesStatusFilterAll)),
        for (final s in SaleStatus.values)
          PopupMenuItem(value: s, child: Text(posSaleStatusLabel(l10n, s))),
      ],
      child: Chip(
        avatar: const Icon(Icons.filter_alt_outlined, size: 18),
        label: Text(label),
        backgroundColor: status != null
            ? Theme.of(context).colorScheme.secondaryContainer
            : null,
      ),
    );
  }
}
