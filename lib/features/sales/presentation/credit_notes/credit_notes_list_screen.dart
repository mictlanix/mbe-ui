import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_sheet.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer_list_item.dart';
import 'package:mbe_ui/features/sales/domain/entities/credit_note.dart';
import 'package:mbe_ui/features/sales/presentation/credit_notes/credit_notes_filter.dart';
import 'package:mbe_ui/features/sales/presentation/credit_notes/credit_notes_list_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payment_link_providers.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payment_widgets.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payments_list_screen.dart';
import 'package:mbe_ui/features/sales/presentation/refunds/refunds_list_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const creditNotesPath = '/sales/credit-notes';

/// Notas de crédito: the store credit refunds have left with customers, newest
/// first (spec 056 US3). Gated by Credit Payments (83) read.
///
/// A standard list screen — filter row, list, pagination — and read-only: a
/// credit note is never edited, so its rows carry no icons and the row tap is
/// the only affordance, as on Pagos. The tap opens the note's backing payment
/// on the existing payment screen (FR-012), offered only to a user who can
/// read customer payments.
///
/// There is no search box: `GET /credit-notes` has no free-text parameter, so
/// the slot is omitted rather than reserved (constitution §VI).
///
/// The figures are the server's, exactly as sent (FR-015). Until mbe-api#277
/// ships, legacy notes read 0.00 issued — that is the upstream defect showing,
/// not something to patch here.
class CreditNotesListScreen extends ConsumerWidget {
  const CreditNotesListScreen({super.key, required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final access = ref.watch(accessControlProvider);
    final filter = CreditNotesFilter.fromQuery(query);
    final pageAsync = ref.watch(creditNotesListControllerProvider(filter));
    final fmt = ref.watch(formattersProvider);
    final spacing = Theme.of(context).spacing;
    final canOpenPayment = access.can(
      SystemObject.customerPayments,
      AccessRight.read,
    );
    final clearedPath = const ListQuery().toUri(creditNotesPath).toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.fieldGapVertical,
      children: [
        CatalogFilterBar(
          filters: [
            Badge.count(
              count: filter.activeFilterCount,
              isLabelVisible: filter.isNarrowed,
              child: IconButton.outlined(
                key: const Key('credit_notes_filter_button'),
                icon: const Icon(Icons.tune),
                tooltip: l10n.filtersTooltip,
                onPressed: () => showCatalogFilterSheet(
                  context,
                  title: l10n.filtersButton,
                  clearAllLabel: l10n.clearAllFilters,
                  applyLabel: l10n.applyFilters,
                  onClearAll: () => context.go(clearedPath),
                  builder: (_) => CurrentListQueryBuilder(
                    builder: (context, query) =>
                        _CreditNotesFiltersPanel(query: query),
                  ),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: _isForbidden(pageAsync)
              ? const _ListForbidden()
              : CatalogListStateView<CreditNote>(
                  state: pageAsync,
                  isFiltered: filter.isNarrowed,
                  emptyMessage: l10n.creditNotesEmpty,
                  clearFiltersLabel: l10n.clearFiltersButton,
                  onClearFilters: () => context.go(clearedPath),
                  retryLabel: l10n.retryButton,
                  onRetry: () =>
                      ref.invalidate(creditNotesListControllerProvider(filter)),
                  onData: (page) => DataTableView<CreditNote>(
                    key: const Key('credit_notes_table'),
                    columns: [
                      DataTableColumn(
                        label: l10n.creditNotesColumnDate,
                        size: ColumnSize.M,
                        cellBuilder: (context, n) =>
                            Text(fmt.display.dateTime(n.date)),
                      ),
                      DataTableColumn(
                        label: l10n.creditNotesColumnCustomer,
                        size: ColumnSize.M,
                        // No name arrives with a credit note, so each row
                        // resolves its customer once (spec 056 R9).
                        cellBuilder: (context, n) =>
                            PaymentCustomerName(customerId: n.customerId),
                      ),
                      DataTableColumn(
                        label: l10n.creditNotesColumnOrigin,
                        size: ColumnSize.L,
                        cellBuilder: (context, n) => _OriginCell(note: n),
                      ),
                      DataTableColumn(
                        label: l10n.creditNotesColumnIssued,
                        numeric: true,
                        size: ColumnSize.M,
                        cellBuilder: (context, n) =>
                            Text(fmt.display.currency(n.issued)),
                      ),
                      DataTableColumn(
                        label: l10n.creditNotesColumnRemaining,
                        numeric: true,
                        size: ColumnSize.M,
                        cellBuilder: (context, n) =>
                            Text(fmt.display.currency(n.remaining)),
                      ),
                    ],
                    rows: page.items,
                    pagination: page,
                    onPageChanged: (pageIndex) => context.go(
                      query
                          .copyWith(pageIndex: pageIndex)
                          .toUri(creditNotesPath)
                          .toString(),
                    ),
                    // A credit note is never edited (spec 056 FR-010): no row
                    // icons, and the tap is the only way onward.
                    onRowTap: canOpenPayment
                        ? (n) => context.push(
                            '$paymentsPath/${n.customerPaymentId}',
                          )
                        : null,
                  ),
                ),
        ),
      ],
    );
  }
}

/// Whether the server refused the list outright (403) — not a failure, so no
/// retry button (as on Pagos).
bool _isForbidden(AsyncValue<Object?> page) {
  final error = page.error;
  return error != null &&
      switch (toAppError(error)) {
        ServerError(statusCode: 403) => true,
        _ => false,
      };
}

class _ListForbidden extends StatelessWidget {
  const _ListForbidden();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(spacing.screenMargin),
        child: Text(
          l10n.creditNotesForbidden,
          key: const Key('credit_notes_forbidden'),
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// Where a note came from: its refund, then the order the refund was for. The
/// refund is a link to its screen for a user who can read refunds, plain text
/// otherwise. The order is a link when [orderLinkTargetProvider] finds a
/// destination the user can open, plain text otherwise (the same rule as an
/// application's order on the payment screen).
class _OriginCell extends ConsumerWidget {
  const _OriginCell({required this.note});

  final CreditNote note;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final access = ref.watch(accessControlProvider);
    final orderTarget = ref
        .watch(orderLinkTargetProvider(note.salesOrderId))
        .value;
    final refundTarget =
        access.can(SystemObject.customerRefunds, AccessRight.read)
        ? '$refundsPath/${note.customerRefundId}'
        : null;
    final text = l10n.creditNotesOrigin(
      note.customerRefundId,
      note.salesOrderId,
    );
    if (orderTarget == null && refundTarget == null) return Text(text);

    // The label is one localized string, so it is split on the refund's and
    // the order's own text to make just those parts tappable. One `Text.rich`,
    // so the numbers flow with the words and wrap with them: a long pair of
    // numbers goes onto a second line, never out of reach — origin is never
    // truncated (constitution §VI). The refund and order labels are located
    // independently, so a translation that orders them differently still works.
    final refundLabel = '#${note.customerRefundId}';
    final orderLabel = '#${note.salesOrderId}';
    final refundCut = text.indexOf(refundLabel);
    final orderCut = text.lastIndexOf(orderLabel);
    if (refundCut < 0 ||
        orderCut < 0 ||
        refundCut + refundLabel.length > orderCut) {
      return Text(text);
    }
    final theme = Theme.of(context);

    InlineSpan link(Key key, String label, String? target) {
      if (target == null) return TextSpan(text: label);
      return WidgetSpan(
        alignment: PlaceholderAlignment.baseline,
        baseline: TextBaseline.alphabetic,
        child: InkWell(
          key: key,
          onTap: () => context.push(target),
          child: Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.primary,
              decoration: TextDecoration.underline,
              decorationColor: theme.colorScheme.primary,
            ),
          ),
        ),
      );
    }

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: text.substring(0, refundCut)),
          link(
            Key('credit_note_refund_link_${note.customerRefundId}'),
            refundLabel,
            refundTarget,
          ),
          TextSpan(
            text: text.substring(refundCut + refundLabel.length, orderCut),
          ),
          link(
            Key('credit_note_order_link_${note.salesOrderId}'),
            orderLabel,
            orderTarget,
          ),
          TextSpan(text: text.substring(orderCut + orderLabel.length)),
        ],
      ),
    );
  }
}

/// The drawer's facets (FR-011): a customer and the balance switch. Each
/// change writes the URL and returns to the first page.
class _CreditNotesFiltersPanel extends ConsumerWidget {
  const _CreditNotesFiltersPanel({required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = CreditNotesFilter.fromQuery(query);
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;

    void goTo(ListQuery updated) => context.go(
      updated.copyWith(pageIndex: 0).toUri(creditNotesPath).toString(),
    );

    final customerName = filter.customerId == null
        ? null
        : ref.watch(customerDisplayNameProvider(filter.customerId!)).value;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.fieldGapVertical,
      children: [
        CatalogEntityPicker<CustomerListItem>(
          key: const Key('credit_notes_customer_filter'),
          label: l10n.creditNotesCustomerFilter,
          displayStringForOption: (c) => '${c.code} — ${c.name}',
          optionsBuilder: (search) async {
            final result = await ref
                .read(customerRepositoryProvider)
                .list(search: search.isEmpty ? null : search, limit: 10);
            return result.items;
          },
          onSelected: (c) =>
              goTo(query.withFacet('customer', '${c.customerId}')),
          initialDisplayText: customerName ?? filter.customerId?.toString(),
        ),
        // A plain on/off, not a tri-state: the list is never narrowed to notes
        // *without* a balance.
        SwitchListTile(
          key: const Key('credit_notes_open_only_filter'),
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.creditNotesOpenOnlyFilter),
          value: filter.openOnly,
          onChanged: (on) => goTo(query.withFacet('open', on ? '1' : null)),
        ),
      ],
    );
  }
}
