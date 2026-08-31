import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/domain/payment_method.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/navigation/list_search_submit.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_sheet.dart';
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/entity_status_controls.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/facility_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/payment_method_option.dart';
import 'package:mbe_ui/features/catalog/presentation/payment_method_options_list_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const _paymentMethodOptionsPath = '/payment-method-options';

/// Payment Method Options catalog list screen (FR-001, FR-002, FR-031, US1).
/// Gated by `can(SystemObject.paymentMethodOptions, AccessRight.read)` in the
/// router. Ships a filter drawer (facility picker + status) since the list
/// endpoint exposes both facets, per constitution §VI.
class PaymentMethodOptionsListScreen extends ConsumerWidget {
  const PaymentMethodOptionsListScreen({super.key, required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = PaymentMethodOptionFilter.fromQuery(query);
    final pageAsync = ref.watch(
      paymentMethodOptionsListControllerProvider(filter),
    );
    final access = ref.watch(accessControlProvider);
    final canCreate = access.can(
      SystemObject.paymentMethodOptions,
      AccessRight.create,
    );
    final canUpdate = access.can(
      SystemObject.paymentMethodOptions,
      AccessRight.update,
    );
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        CatalogFilterBar(
          search: CatalogSearchBar(
            key: const Key('payment_method_options_search_field'),
            label: l10n.paymentMethodOptionsSearchLabel,
            searchTooltip: l10n.searchButtonTooltip,
            initialValue: filter.search,
            onSubmitted: (value) => submitCatalogSearch(
              context: context,
              query: query,
              path: _paymentMethodOptionsPath,
              submitted: value,
              current: filter.search,
              refresh: () => ref.invalidate(
                paymentMethodOptionsListControllerProvider(filter),
              ),
            ),
          ),
          actions: [
            if (canCreate)
              FilledButton.icon(
                key: const Key('new_payment_method_option_button'),
                icon: Icon(CatalogAction.create.icon),
                label: Text(l10n.newPaymentMethodOptionTooltip),
                onPressed: () => context.push('/payment-method-options/new'),
              ),
          ],
          filters: [
            Badge.count(
              count: filter.activeFilterCount,
              isLabelVisible: filter.hasActiveFilters,
              child: IconButton.outlined(
                key: const Key('payment_method_options_filter_button'),
                icon: const Icon(Icons.tune),
                tooltip: l10n.filtersTooltip,
                onPressed: () => showCatalogFilterSheet(
                  context,
                  title: l10n.filtersButton,
                  clearAllLabel: l10n.clearAllFilters,
                  applyLabel: l10n.applyFilters,
                  onClearAll: () => context.go(_paymentMethodOptionsPath),
                  builder: (_) => CurrentListQueryBuilder(
                    builder: (context, query) =>
                        _PaymentMethodOptionFiltersPanel(query: query),
                  ),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: CatalogListStateView<PaymentMethodOption>(
            state: pageAsync,
            isFiltered: isFilteredBeyondStatusDefault(query, filter.status),
            emptyMessage: l10n.noPaymentMethodOptionsFound,
            createLabel: canCreate ? l10n.newPaymentMethodOptionTooltip : null,
            onCreate: canCreate
                ? () => context.push('/payment-method-options/new')
                : null,
            clearFiltersLabel: l10n.clearFiltersButton,
            onClearFilters: () => context.go(_paymentMethodOptionsPath),
            retryLabel: l10n.retryButton,
            onRetry: () => ref.invalidate(
              paymentMethodOptionsListControllerProvider(filter),
            ),
            onData: (page) => DataTableView<PaymentMethodOption>(
              key: const Key('payment_method_options_table'),
              columns: [
                DataTableColumn.text(
                  label: l10n.columnFacility,
                  text: (o) => o.facilityDisplayName(l10n.unknownFacilityLabel),
                  size: ColumnSize.M,
                ),
                DataTableColumn.text(
                  label: l10n.columnName,
                  text: (o) => o.name,
                  size: ColumnSize.L,
                ),
                DataTableColumn.text(
                  label: l10n.columnPaymentMethod,
                  text: (o) => paymentMethodLabel(l10n, o.paymentMethod),
                  size: ColumnSize.M,
                ),
                DataTableColumn(
                  label: l10n.columnNumberOfPayments,
                  numeric: true,
                  fixedWidth: 100,
                  cellBuilder: (context, o) => Text('${o.numberOfPayments}'),
                ),
                DataTableColumn(
                  label: l10n.columnStatus,
                  fixedWidth: 130,
                  cellBuilder: (context, o) =>
                      EntityStatusCell(status: o.status),
                ),
              ],
              rows: page.items,
              pagination: page,
              onPageChanged: (pageIndex) => context.go(
                query
                    .copyWith(pageIndex: pageIndex)
                    .toUri(_paymentMethodOptionsPath)
                    .toString(),
              ),
              onRowTap: (o) => context.push(
                '/payment-method-options/${o.paymentMethodOptionId}?view=true',
              ),
              rowActionsBuilder: (context, o) => buildCatalogRowActions(
                editTooltip: l10n.editActionTooltip,
                onEdit: canUpdate
                    ? () => context.push(
                        '/payment-method-options/${o.paymentMethodOptionId}',
                      )
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The Payment Method Options catalog's facet filters (facility picker +
/// status), rendered inside the filter panel (FR-002).
class _PaymentMethodOptionFiltersPanel extends ConsumerWidget {
  const _PaymentMethodOptionFiltersPanel({required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = PaymentMethodOptionFilter.fromQuery(query);
    final l10n = AppLocalizations.of(context)!;
    final facilityRepo = ref.read(facilityRepositoryProvider);

    final resolvedFacilityName = filter.facilityId != null
        ? ref.watch(facilityDisplayNameProvider(filter.facilityId!)).valueOrNull
        : null;

    void goTo(ListQuery updated) =>
        context.go(updated.toUri(_paymentMethodOptionsPath).toString());

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatalogEntityPicker<FacilityListItem>(
          key: const Key('payment_method_options_filter_facility'),
          label: l10n.facilityFieldLabel,
          displayStringForOption: (f) => f.name,
          optionsBuilder: (searchQuery) async {
            final result = await facilityRepo.list(
              search: searchQuery.isEmpty ? null : searchQuery,
            );
            return result.items;
          },
          onSelected: (f) => goTo(
            query
                .withFacet('facility', '${f.facilityId}')
                .copyWith(pageIndex: 0),
          ),
          initialDisplayText:
              resolvedFacilityName ?? filter.facilityId?.toString(),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.statusFilterLabel,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        EntityStatusFilterChips(
          filterKey: 'payment_method_options_filter_status',
          value: filter.status,
          onChanged: (status) =>
              goTo(encodeStatusFacet(query, status).copyWith(pageIndex: 0)),
        ),
      ],
    );
  }
}
