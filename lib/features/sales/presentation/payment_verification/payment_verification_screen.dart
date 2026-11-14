import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/domain/payment_method.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart'
    show emptyValuePlaceholder;
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_sheet.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/date_range_filter_chip.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/facility_list_item.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_payment.dart';
import 'package:mbe_ui/features/sales/presentation/payment_verification/payment_verification_filter.dart';
import 'package:mbe_ui/features/sales/presentation/payment_verification/reject_payment_dialog.dart';
import 'package:mbe_ui/features/sales/presentation/payment_verification/verification_payment_panel.dart';
import 'package:mbe_ui/features/sales/presentation/payment_verification/verification_queue_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payment_verification/verify_payment_dialog.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payment_widgets.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payments_filter.dart'
    show encodePaymentsDateFacet;
import 'package:mbe_ui/l10n/app_localizations.dart';

const paymentVerificationPath = '/sales/payment-verification';

/// Verificación de pagos: the unverified customer payments of **every
/// facility**, newest first, for a supervisor to check against the bank
/// statement (spec 060 US1).
///
/// Gated by Payments Verification (108) read, and the row actions by 108
/// update — the same rights the server checks (constitution §IV). The queue is
/// company-wide on purpose, as verification is on the server and in the legacy
/// screen: there is no facility scoping, only an optional facility filter.
///
/// A standard list screen — filter row, list, pagination — with no search box,
/// because the endpoint has none (§VI). The total is the table footer's. A row
/// acts through its own icons without opening the payment, since Pagos refuses
/// another facility's payment to a verifier without Payments Editor read
/// (SC-006); a row tap opens a read-only panel built from the row instead.
class PaymentVerificationScreen extends ConsumerWidget {
  const PaymentVerificationScreen({super.key, required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final access = ref.watch(accessControlProvider);
    final canAct = access.can(
      SystemObject.paymentsVerification,
      AccessRight.update,
    );
    final canPickFacility = access.can(
      SystemObject.facilities,
      AccessRight.read,
    );
    final filter = PaymentVerificationFilter.fromQuery(query);
    final pageAsync = ref.watch(verificationQueueControllerProvider(filter));
    final fmt = ref.watch(formattersProvider);
    final spacing = Theme.of(context).spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.fieldGapVertical,
      children: [
        CatalogFilterBar(
          // No search: `/customer-payments/unverified` has none, so the box is
          // omitted rather than reserved (§VI). Nothing else goes in this row:
          // the total is the table footer's.
          filters: [
            Badge.count(
              count: filter.activeFilterCount,
              isLabelVisible: filter.activeFilterCount > 0,
              child: IconButton.outlined(
                key: const Key('verification_filter_button'),
                icon: const Icon(Icons.tune),
                tooltip: l10n.filtersTooltip,
                onPressed: () => showCatalogFilterSheet(
                  context,
                  title: l10n.filtersButton,
                  clearAllLabel: l10n.clearAllFilters,
                  applyLabel: l10n.applyFilters,
                  // The bare address is the opening state: Transfer, every
                  // facility, any date (spec 060 R3).
                  onClearAll: () => context.go(paymentVerificationPath),
                  builder: (_) => CurrentListQueryBuilder(
                    builder: (context, query) => _VerificationFiltersPanel(
                      query: query,
                      canPickFacility: canPickFacility,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          // A refusal is not a failure: the user isn't allowed this list, and
          // asking again won't change that.
          child: _isForbidden(pageAsync)
              ? const _QueueForbidden()
              : CatalogListStateView<CustomerPayment>(
                  state: pageAsync,
                  isFiltered: filter.differsFromDefault,
                  emptyMessage: l10n.paymentVerificationEmpty,
                  clearFiltersLabel: l10n.clearFiltersButton,
                  onClearFilters: () => context.go(paymentVerificationPath),
                  retryLabel: l10n.retryButton,
                  onRetry: () => ref.invalidate(
                    verificationQueueControllerProvider(filter),
                  ),
                  onData: (page) => DataTableView<CustomerPayment>(
                    key: const Key('verification_table'),
                    columns: [
                      DataTableColumn(
                        label: l10n.paymentsColumnFolio,
                        fixedWidth: 90,
                        cellBuilder: (context, p) =>
                            Text('${p.customerPaymentId}'),
                      ),
                      DataTableColumn(
                        label: l10n.paymentsColumnFacility,
                        size: ColumnSize.M,
                        cellBuilder: (context, p) =>
                            _FacilityNameCell(facilityId: p.facilityId),
                      ),
                      DataTableColumn(
                        label: l10n.paymentsColumnDate,
                        size: ColumnSize.L,
                        cellBuilder: (context, p) =>
                            Text(fmt.display.dateTime(p.date)),
                      ),
                      DataTableColumn(
                        label: l10n.paymentsColumnCustomer,
                        size: ColumnSize.L,
                        cellBuilder: (context, p) => PaymentCustomerName(
                          customerId: p.customerId,
                          name: p.customerName,
                        ),
                      ),
                      DataTableColumn(
                        label: l10n.paymentsColumnMethod,
                        // A short label ("Transferencia"): it gives up width
                        // to the amount, which must never clip (§V).
                        size: ColumnSize.M,
                        cellBuilder: (context, p) =>
                            PaymentMethodText(payment: p),
                      ),
                      DataTableColumn.text(
                        label: l10n.paymentsColumnReference,
                        size: ColumnSize.M,
                        text: (p) => p.reference ?? emptyValuePlaceholder,
                      ),
                      DataTableColumn(
                        label: l10n.paymentsColumnAmount,
                        numeric: true,
                        // Wide enough for "$150,000.00 MXN" at the largest
                        // text size with real fonts (live check, spec 060
                        // T018): at M it clipped by up to 10 px.
                        size: ColumnSize.L,
                        cellBuilder: (context, p) =>
                            Text(paymentAmountLabel(fmt, p.amount, p.currency)),
                      ),
                    ],
                    rows: page.items,
                    pagination: page,
                    onPageChanged: (pageIndex) => context.go(
                      filter
                          .copyWith(pageIndex: pageIndex)
                          .toQuery()
                          .toUri(paymentVerificationPath)
                          .toString(),
                    ),
                    // A payment has no Edit here (it isn't editable), so the
                    // primary slot is the queue's own job: verify, with reject
                    // as the one direct secondary action — two icons, as §VI
                    // allows. Without update there are no actions, and no
                    // column.
                    rowActionsBuilder: canAct
                        ? (context, p) => buildCatalogRowActions(
                            editTooltip: l10n.editActionTooltip,
                            primaryAction: CatalogRowAction(
                              key: Key('verify_payment_${p.customerPaymentId}'),
                              icon: Icons.check_circle_outline,
                              tooltip: l10n.paymentVerifyAction,
                              onPressed: () => _verify(context, p),
                            ),
                            extraActions: [
                              CatalogRowAction(
                                key: Key(
                                  'reject_payment_${p.customerPaymentId}',
                                ),
                                icon: Icons.block,
                                tooltip: l10n.paymentRejectAction,
                                onPressed: () => _reject(context, p),
                              ),
                            ],
                          )
                        : null,
                    onRowTap: (p) => showVerificationPaymentPanel(context, p),
                  ),
                ),
        ),
      ],
    );
  }
}

/// Verifies [payment] after its confirmation, and says so once it went
/// through. The queue reloads by itself: the write controller invalidates it.
Future<void> _verify(BuildContext context, CustomerPayment payment) async {
  final messenger = ScaffoldMessenger.of(context);
  final message = AppLocalizations.of(
    context,
  )!.paymentVerifiedSnack('${payment.customerPaymentId}');
  final done = await showVerifyPaymentDialog(context, payment);
  if (done) messenger.showSnackBar(SnackBar(content: Text(message)));
}

/// Rejects [payment] with a reason, and says so once it was recorded. The row
/// stays where it is: a rejection changes nothing the queue can read, so the
/// payment is still unverified and still listed (spec 060 FR-011, FR-012). No
/// local "rejected" mark is kept, since it would vanish on reload and claim
/// knowledge the app doesn't have.
Future<void> _reject(BuildContext context, CustomerPayment payment) async {
  final messenger = ScaffoldMessenger.of(context);
  final message = AppLocalizations.of(
    context,
  )!.paymentRejectedSnack('${payment.customerPaymentId}');
  final done = await showRejectPaymentDialog(context, payment);
  if (done) messenger.showSnackBar(SnackBar(content: Text(message)));
}

/// Whether the server refused the queue outright (403): an access change
/// mid-session, since the route is gated on the same right. A retry button on
/// it would be wrong.
bool _isForbidden(AsyncValue<Object?> page) {
  final error = page.error;
  return error != null &&
      switch (toAppError(error)) {
        ServerError(statusCode: 403) => true,
        _ => false,
      };
}

/// The queue's "not allowed" state: a message and nothing to retry.
class _QueueForbidden extends StatelessWidget {
  const _QueueForbidden();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(spacing.screenMargin),
        child: Text(
          l10n.paymentsListForbidden,
          key: const Key('verification_forbidden'),
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// A facility's name, falling back to its number while loading or when it
/// can't be read: the name needs Facilities read, which a verifier may not
/// hold (spec 060 R7).
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

/// The drawer's facets: facility (only with Facilities read, R7), date range
/// and method. Each change writes the address and returns to the first page;
/// "Limpiar todo" in the sheet goes back to the opening state.
class _VerificationFiltersPanel extends ConsumerWidget {
  const _VerificationFiltersPanel({
    required this.query,
    required this.canPickFacility,
  });

  final ListQuery query;
  final bool canPickFacility;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = PaymentVerificationFilter.fromQuery(query);
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final titleStyle = Theme.of(context).textTheme.titleSmall;

    void goTo(ListQuery updated) => context.go(
      updated.copyWith(pageIndex: 0).toUri(paymentVerificationPath).toString(),
    );

    final facilityName = filter.facilityId == null
        ? null
        : ref.watch(facilityDisplayNameProvider(filter.facilityId!)).value;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.fieldGapVertical,
      children: [
        if (canPickFacility)
          CatalogEntityPicker<FacilityListItem>(
            key: const Key('verification_filter_facility'),
            label: l10n.paymentFieldFacility,
            displayStringForOption: (f) => f.name,
            optionsBuilder: (search) async {
              final result = await ref
                  .read(facilityRepositoryProvider)
                  .list(search: search.isEmpty ? null : search);
              return result.items;
            },
            onSelected: (f) =>
                goTo(query.withFacet('facility', '${f.facilityId}')),
            // Unset shows "every facility", not a blank field.
            initialDisplayText: filter.facilityId == null
                ? l10n.paymentVerificationFacilityAll
                : (facilityName ?? '${filter.facilityId}'),
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
                    .withFacet('date-to', encodePaymentsDateFacet(range.end)),
              ),
              onClear: () => goTo(
                query.withFacet('date-from', null).withFacet('date-to', null),
              ),
            ),
          ],
        ),
        // Rebuilt when the method changes: the dropdown only reads its
        // initial value once.
        KeyedSubtree(
          key: ValueKey(filter.methodCode),
          child: DropdownButtonFormField<int?>(
            key: const Key('verification_filter_method'),
            initialValue: filter.methodCode,
            isExpanded: true,
            decoration: InputDecoration(labelText: l10n.paymentsFilterMethod),
            items: [
              DropdownMenuItem<int?>(
                value: null,
                child: Text(l10n.paymentVerificationMethodAll),
              ),
              for (final method in PaymentMethod.values)
                DropdownMenuItem<int?>(
                  value: method.code,
                  child: Text(paymentMethodLabel(l10n, method.code)),
                ),
            ],
            onChanged: (code) => goTo(
              query.withFacet(
                'method',
                methodFacetValue(
                  code == null
                      ? const VerificationMethodFilter.all()
                      : VerificationMethodFilter.code(code),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
