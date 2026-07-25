import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/domain/payment_method.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_sheet.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/entity_status_controls.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/facility_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/payment_method_option.dart';
import 'package:mbe_ui/features/catalog/presentation/payment_method_options_list_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Payment Method Options catalog list screen (FR-001, FR-002, FR-031, US1).
/// Gated by `can(SystemObject.paymentMethodOptions, AccessRight.read)` in the
/// router. Ships a filter drawer (facility picker + status) since the list
/// endpoint exposes both facets, per constitution §VI.
class PaymentMethodOptionsListScreen extends ConsumerWidget {
  const PaymentMethodOptionsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageAsync = ref.watch(paymentMethodOptionsListControllerProvider);
    final filter = ref.watch(paymentMethodOptionFilterControllerProvider);
    final filterController = ref.read(
      paymentMethodOptionFilterControllerProvider.notifier,
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
        Padding(
          padding: const EdgeInsets.all(8),
          child: CatalogFilterBar(
            search: CatalogSearchBar(
              key: const Key('payment_method_options_search_field'),
              label: l10n.paymentMethodOptionsSearchLabel,
              searchTooltip: l10n.searchButtonTooltip,
              initialValue: filter.search,
              onSubmitted: filterController.searchChanged,
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
                    onClearAll: filterController.reset,
                    builder: (_) => const _PaymentMethodOptionFiltersPanel(),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: pageAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) =>
                Center(child: Text(l10n.paymentMethodOptionsLoadError(e))),
            data: (CatalogPage<PaymentMethodOption> page) => page.items.isEmpty
                ? Center(child: Text(l10n.noPaymentMethodOptionsFound))
                : DataTableView<PaymentMethodOption>(
                    key: const Key('payment_method_options_table'),
                    columns: [
                      DataTableColumn.text(
                        label: l10n.columnFacility,
                        text: (o) =>
                            o.facilityDisplayName(l10n.unknownFacilityLabel),
                        size: ColumnSize.M,
                      ),
                      DataTableColumn.text(
                        label: l10n.columnName,
                        text: (o) => o.name,
                        size: ColumnSize.L,
                      ),
                      DataTableColumn.text(
                        label: l10n.columnPaymentMethod,
                        text: (o) => _paymentMethodLabel(l10n, o.paymentMethod),
                        size: ColumnSize.M,
                      ),
                      DataTableColumn(
                        label: l10n.columnNumberOfPayments,
                        numeric: true,
                        fixedWidth: 100,
                        cellBuilder: (context, o) =>
                            Text('${o.numberOfPayments}'),
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
                    onPageChanged: (pageIndex) => ref
                        .read(paymentMethodOptionsListControllerProvider.notifier)
                        .goToPage(pageIndex),
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
  const _PaymentMethodOptionFiltersPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(paymentMethodOptionFilterControllerProvider);
    final filterController = ref.read(
      paymentMethodOptionFilterControllerProvider.notifier,
    );
    final l10n = AppLocalizations.of(context)!;
    final facilityRepo = ref.read(facilityRepositoryProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatalogEntityPicker<FacilityListItem>(
          key: const Key('payment_method_options_filter_facility'),
          label: l10n.facilityFieldLabel,
          displayStringForOption: (f) => f.name,
          optionsBuilder: (query) async {
            final result = await facilityRepo.list(
              search: query.isEmpty ? null : query,
            );
            return result.items;
          },
          onSelected: (f) =>
              filterController.facilitySelected(f.facilityId, f.name),
          initialDisplayText: filter.facilityDisplayText,
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
          onChanged: filterController.statusChanged,
        ),
      ],
    );
  }
}

/// [code]'s label from the [PaymentMethod] lookup, falling back to the raw
/// code for an unmapped value (research §5).
String _paymentMethodLabel(AppLocalizations l10n, int code) {
  final method = PaymentMethod.fromCode(code);
  if (method == null) return '$code';
  return switch (method) {
    PaymentMethod.na => l10n.paymentMethodNa,
    PaymentMethod.cash => l10n.paymentMethodCash,
    PaymentMethod.check => l10n.paymentMethodCheck,
    PaymentMethod.eft => l10n.paymentMethodEft,
    PaymentMethod.creditCard => l10n.paymentMethodCreditCard,
    PaymentMethod.electronicPurse => l10n.paymentMethodElectronicPurse,
    PaymentMethod.electronicMoney => l10n.paymentMethodElectronicMoney,
    PaymentMethod.foodVouchers => l10n.paymentMethodFoodVouchers,
    PaymentMethod.giving => l10n.paymentMethodGiving,
    PaymentMethod.toTheSatisfactionOfTheCreditor =>
      l10n.paymentMethodCreditorSatisfaction,
    PaymentMethod.debitCard => l10n.paymentMethodDebitCard,
    PaymentMethod.serviceCard => l10n.paymentMethodServiceCard,
    PaymentMethod.advancePayments => l10n.paymentMethodAdvancePayments,
    PaymentMethod.toBeDefined => l10n.paymentMethodToBeDefined,
    PaymentMethod.governmentFunding => l10n.paymentMethodGovernmentFunding,
  };
}
