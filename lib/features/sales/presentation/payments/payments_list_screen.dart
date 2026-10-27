import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/domain/payment_method.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/navigation/list_search_submit.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_sheet.dart';
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/date_range_filter_chip.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer_list_item.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/cash_session_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/cash_session.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_payment.dart';
import 'package:mbe_ui/features/sales/domain/payment_type.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payment_link_providers.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payment_widgets.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payments_filter.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payments_list_controller.dart';
import 'package:mbe_ui/features/sales/presentation/register_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const paymentsPath = '/sales/payments';

/// Pagos: the facility's customer payments, newest first (spec 054 US1).
///
/// A standard list screen — filter row, list, pagination — and read-only: a
/// row opens the payment's own screen, and nothing here creates, verifies or
/// reverses a payment (FR-003). Gated by Customer Payments (8) read.
///
/// The facility scope has no search box: `GET /customer-payments` has no
/// free-text search, so the shared filter row omits the control (constitution
/// §VI) rather than reserving space for one that does not exist. A Payments
/// Editor reader can switch to the all-facilities scope (US3), whose endpoint
/// does search by reference — the box appears only there.
class PaymentsListScreen extends ConsumerWidget {
  const PaymentsListScreen({super.key, required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final canSearchAll = ref
        .watch(accessControlProvider)
        .can(SystemObject.paymentsEditor, AccessRight.read);
    final filter = PaymentsFilter.fromQuery(
      query,
      canSearchAllFacilities: canSearchAll,
    );
    final allFacilities = filter.scope == PaymentsScope.allFacilities;
    final pageAsync = ref.watch(paymentsListControllerProvider(filter));
    final fmt = ref.watch(formattersProvider);
    final spacing = Theme.of(context).spacing;
    // "Clear all" keeps the scope: leaving "all facilities" is the switch's
    // job, not a filter's.
    final clearedPath = paymentsQueryForScope(
      const ListQuery(),
      filter.scope,
    ).toUri(paymentsPath).toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.fieldGapVertical,
      children: [
        CatalogFilterBar(
          // Only the all-facilities endpoint can search (by reference).
          search: allFacilities
              ? CatalogSearchBar(
                  key: const Key('payments_search_field'),
                  label: l10n.paymentsSearchReferenceHint,
                  searchTooltip: l10n.searchButtonTooltip,
                  initialValue: filter.reference ?? '',
                  onSubmitted: (value) => submitCatalogSearch(
                    context: context,
                    query: query,
                    path: paymentsPath,
                    submitted: value,
                    current: filter.reference ?? '',
                    refresh: () =>
                        ref.invalidate(paymentsListControllerProvider(filter)),
                  ),
                )
              : null,
          // The scope switch exists only for a Payments Editor reader —
          // absent, not disabled, for everyone else (FR-002).
          actions: [
            if (canSearchAll)
              SegmentedButton<PaymentsScope>(
                key: const Key('payments_scope_switch'),
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: PaymentsScope.facility,
                    label: Text(l10n.paymentsScopeFacility),
                  ),
                  ButtonSegment(
                    value: PaymentsScope.allFacilities,
                    label: Text(l10n.paymentsScopeAll),
                  ),
                ],
                selected: {filter.scope},
                onSelectionChanged: (selection) => context.go(
                  paymentsQueryForScope(
                    query,
                    selection.first,
                  ).toUri(paymentsPath).toString(),
                ),
              ),
          ],
          filters: [
            Badge.count(
              count: filter.activeFilterCount,
              isLabelVisible: filter.hasActiveFilters,
              child: IconButton.outlined(
                key: const Key('payments_filter_button'),
                icon: const Icon(Icons.tune),
                tooltip: l10n.filtersTooltip,
                onPressed: () => showCatalogFilterSheet(
                  context,
                  title: l10n.filtersButton,
                  clearAllLabel: l10n.clearAllFilters,
                  applyLabel: l10n.applyFilters,
                  onClearAll: () => context.go(clearedPath),
                  builder: (_) => CurrentListQueryBuilder(
                    builder: (context, query) => _PaymentsFiltersPanel(
                      query: query,
                      canSearchAllFacilities: canSearchAll,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: CatalogListStateView<CustomerPayment>(
            state: pageAsync,
            // The filter's own reading, not `query.isFiltered`: a stray
            // `search` in the address is ignored in the facility scope, so it
            // must not turn the empty state into a "filtered" one with
            // nothing to clear.
            isFiltered: filter.isNarrowed,
            emptyMessage: l10n.paymentsListEmpty,
            clearFiltersLabel: l10n.clearFiltersButton,
            onClearFilters: () => context.go(clearedPath),
            retryLabel: l10n.retryButton,
            onRetry: () =>
                ref.invalidate(paymentsListControllerProvider(filter)),
            onData: (page) => DataTableView<CustomerPayment>(
              key: const Key('payments_table'),
              columns: [
                DataTableColumn(
                  label: l10n.paymentsColumnFolio,
                  fixedWidth: 90,
                  cellBuilder: (context, p) => Text('${p.customerPaymentId}'),
                ),
                DataTableColumn(
                  label: l10n.paymentsColumnDate,
                  size: ColumnSize.M,
                  cellBuilder: (context, p) =>
                      Text(fmt.display.dateTime(p.date)),
                ),
                if (allFacilities)
                  DataTableColumn(
                    label: l10n.paymentsColumnFacility,
                    size: ColumnSize.M,
                    cellBuilder: (context, p) =>
                        _FacilityNameCell(facilityId: p.facilityId),
                  ),
                DataTableColumn(
                  label: l10n.paymentsColumnCustomer,
                  size: ColumnSize.L,
                  cellBuilder: (context, p) =>
                      PaymentCustomerName(customerId: p.customerId),
                ),
                DataTableColumn(
                  label: l10n.paymentsColumnAmount,
                  numeric: true,
                  size: ColumnSize.M,
                  cellBuilder: (context, p) =>
                      Text(paymentAmountLabel(fmt, p.amount, p.currency)),
                ),
                DataTableColumn(
                  label: l10n.paymentsColumnMethod,
                  size: ColumnSize.L,
                  cellBuilder: (context, p) => PaymentMethodText(payment: p),
                ),
                DataTableColumn.text(
                  label: l10n.paymentsColumnReference,
                  size: ColumnSize.M,
                  text: (p) => p.reference ?? emptyValuePlaceholder,
                ),
                DataTableColumn(
                  label: l10n.paymentsColumnType,
                  size: ColumnSize.M,
                  cellBuilder: (context, p) =>
                      Text(paymentTypeLabel(l10n, p.type)),
                ),
                DataTableColumn(
                  label: l10n.paymentsColumnUnapplied,
                  numeric: true,
                  size: ColumnSize.M,
                  cellBuilder: (context, p) =>
                      Text(paymentAmountLabel(fmt, p.unapplied, p.currency)),
                ),
                DataTableColumn(
                  label: l10n.paymentsColumnVerified,
                  fixedWidth: 140,
                  cellBuilder: (context, p) =>
                      PaymentVerifiedChip(verified: p.isVerified),
                ),
              ],
              rows: page.items,
              pagination: page,
              onPageChanged: (pageIndex) => context.go(
                query
                    .copyWith(pageIndex: pageIndex)
                    .toUri(paymentsPath)
                    .toString(),
              ),
              // No row action icons: a payment is read-only here (FR-003),
              // so the row itself is the only affordance — the same posture
              // as the cash-sessions list.
              onRowTap: (p) =>
                  context.push('$paymentsPath/${p.customerPaymentId}'),
            ),
          ),
        ),
      ],
    );
  }
}

/// A facility's name, falling back to its number while loading or when it
/// can't be resolved.
class _FacilityNameCell extends ConsumerWidget {
  const _FacilityNameCell({required this.facilityId});

  final int facilityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text =
        ref.watch(facilityDisplayNameProvider(facilityId)).value ??
        '#$facilityId';
    return Tooltip(
      message: text,
      child: Text(text, overflow: TextOverflow.ellipsis, maxLines: 1),
    );
  }
}

/// The drawer's facets (FR-006, FR-007, FR-006a). Each change writes the URL
/// and returns to the first page; "Limpiar todo" in the sheet clears them.
///
/// In the all-facilities scope only the customer and the date range are
/// offered — the endpoint has no other filters (FR-012).
class _PaymentsFiltersPanel extends ConsumerWidget {
  const _PaymentsFiltersPanel({
    required this.query,
    required this.canSearchAllFacilities,
  });

  final ListQuery query;
  final bool canSearchAllFacilities;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = PaymentsFilter.fromQuery(
      query,
      canSearchAllFacilities: canSearchAllFacilities,
    );
    final allFacilities = filter.scope == PaymentsScope.allFacilities;
    final l10n = AppLocalizations.of(context)!;
    final access = ref.watch(accessControlProvider);
    final spacing = Theme.of(context).spacing;
    final titleStyle = Theme.of(context).textTheme.titleSmall;

    void goTo(ListQuery updated) =>
        context.go(updated.toUri(paymentsPath).toString());

    final customerName = filter.customerId == null
        ? null
        : ref.watch(customerDisplayNameProvider(filter.customerId!)).value;
    final sessionLabel = filter.cashSessionId == null
        ? null
        : ref.watch(cashSessionLabelProvider(filter.cashSessionId!)).value;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.fieldGapVertical,
      children: [
        CatalogEntityPicker<CustomerListItem>(
          key: const Key('payments_filter_customer'),
          label: l10n.paymentsFilterCustomer,
          displayStringForOption: (c) => '${c.code} — ${c.name}',
          optionsBuilder: (search) async {
            final result = await ref
                .read(customerRepositoryProvider)
                .list(search: search.isEmpty ? null : search, limit: 10);
            return result.items;
          },
          onSelected: (c) => goTo(
            query
                .withFacet('customer', '${c.customerId}')
                .copyWith(pageIndex: 0),
          ),
          initialDisplayText: customerName ?? filter.customerId?.toString(),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: spacing.sm,
          children: [
            Text(l10n.paymentsFilterDate, style: titleStyle),
            DateRangeFilterChip(
              from: filter.dateFrom,
              to: filter.dateTo,
              isToday: false,
              onChanged: (range) => goTo(
                query
                    .withFacet(
                      'date-from',
                      encodePaymentsDateFacet(range.start),
                    )
                    .withFacet('date-to', encodePaymentsDateFacet(range.end))
                    .copyWith(pageIndex: 0),
              ),
              onClear: () => goTo(
                query
                    .withFacet('date-from', null)
                    .withFacet('date-to', null)
                    .copyWith(pageIndex: 0),
              ),
            ),
          ],
        ),
        if (!allFacilities)
          DropdownButtonFormField<int?>(
            key: Key('payments_filter_method_${filter.methodCode}'),
            initialValue: filter.methodCode,
            isExpanded: true,
            decoration: InputDecoration(labelText: l10n.paymentsFilterMethod),
            items: [
              DropdownMenuItem<int?>(
                value: null,
                child: Text(l10n.paymentsFilterMethodAll),
              ),
              for (final method in PaymentMethod.values)
                DropdownMenuItem<int?>(
                  value: method.code,
                  child: Text(paymentMethodLabel(l10n, method.code)),
                ),
            ],
            onChanged: (code) => goTo(
              query
                  .withFacet('method', code == null ? null : '$code')
                  .copyWith(pageIndex: 0),
            ),
          ),
        if (!allFacilities)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: spacing.sm,
            children: [
              Text(l10n.paymentsFilterVerified, style: titleStyle),
              Wrap(
                spacing: spacing.sm,
                runSpacing: spacing.sm,
                children: [
                  for (final (key, label, value) in [
                    ('any', l10n.paymentsVerifiedAny, null),
                    ('yes', l10n.paymentsVerifiedYes, true),
                    ('no', l10n.paymentsVerifiedNo, false),
                  ])
                    ChoiceChip(
                      key: Key('payments_filter_verified_$key'),
                      label: Text(label),
                      selected: filter.verified == value,
                      onSelected: (_) => goTo(
                        query
                            .withFacet(
                              'verified',
                              value == null ? null : '$value',
                            )
                            .copyWith(pageIndex: 0),
                      ),
                    ),
                ],
              ),
            ],
          ),
        // The cash-session lookups are gated by POS (44) read on the server,
        // so the facet is absent — not disabled — without it (FR-006a). Like the
        // method and verified facets it is offered in the facility scope only.
        if (!allFacilities && access.can(SystemObject.pos, AccessRight.read))
          CatalogEntityPicker<CashSession>(
            key: const Key('payments_filter_cash_session'),
            label: l10n.paymentsFilterCashSession,
            displayStringForOption: (s) =>
                cashSessionLabel(s, ref.read(formattersProvider)),
            optionsBuilder: (search) => cashSessionPickerOptions(
              ref.read(cashSessionRepositoryProvider),
              facilityId: ref.read(userFacilityIdProvider),
              query: search,
            ),
            onSelected: (s) => goTo(
              query
                  .withFacet('cash-session', '${s.cashSessionId}')
                  .copyWith(pageIndex: 0),
            ),
            initialDisplayText:
                sessionLabel ??
                (filter.cashSessionId == null
                    ? null
                    : '#${filter.cashSessionId}'),
          ),
      ],
    );
  }
}
