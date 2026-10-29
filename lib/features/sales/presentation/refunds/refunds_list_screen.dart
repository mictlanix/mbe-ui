import 'dart:async';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_sheet.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer_list_item.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_refund.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payment_link_providers.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payment_widgets.dart';
import 'package:mbe_ui/features/sales/presentation/refunds/refund_detail_screen.dart';
import 'package:mbe_ui/features/sales/presentation/refunds/refund_open_or_resume.dart';
import 'package:mbe_ui/features/sales/presentation/refunds/refunds_filter.dart';
import 'package:mbe_ui/features/sales/presentation/refunds/refunds_list_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const refundsPath = '/sales/refunds';

/// Devoluciones: the facility's customer refunds, newest first (spec 057
/// US2, contracts C4). Gated by Customer Refunds read.
///
/// A standard list screen — filter row, list, pagination — and read-only: a
/// refund is opened by its row tap, so rows carry no Edit icon. The "Nueva
/// devolución" button starts a refund from an order number and exists only
/// for a user who can create one.
///
/// There is no search box: `GET /customer-refunds` has no free-text
/// parameter (constitution §VI).
class RefundsListScreen extends ConsumerWidget {
  const RefundsListScreen({super.key, required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final access = ref.watch(accessControlProvider);
    final filter = RefundsFilter.fromQuery(query);
    final pageAsync = ref.watch(refundsListControllerProvider(filter));
    final fmt = ref.watch(formattersProvider);
    final spacing = Theme.of(context).spacing;
    final compact = LayoutBreakpoints.isCompact(context);
    final canCreate = access.can(
      SystemObject.customerRefunds,
      AccessRight.create,
    );
    final clearedPath = const ListQuery().toUri(refundsPath).toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.fieldGapVertical,
      children: [
        CatalogFilterBar(
          actions: [
            if (canCreate)
              FilledButton.icon(
                key: const Key('refunds_new_button'),
                icon: const Icon(Icons.add),
                label: Text(compact ? l10n.refundsNewShort : l10n.refundsNew),
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => const _NewRefundDialog(),
                ),
              ),
          ],
          filters: [
            Badge.count(
              count: filter.activeFilterCount,
              isLabelVisible: filter.isNarrowed,
              child: IconButton.outlined(
                key: const Key('refunds_filter_button'),
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
                        _RefundsFiltersPanel(query: query),
                  ),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: _isForbidden(pageAsync)
              ? const _ListForbidden()
              : CatalogListStateView<CustomerRefundSummary>(
                  state: pageAsync,
                  isFiltered: filter.isNarrowed,
                  emptyMessage: l10n.refundsEmpty,
                  clearFiltersLabel: l10n.clearFiltersButton,
                  onClearFilters: () => context.go(clearedPath),
                  retryLabel: l10n.retryButton,
                  onRetry: () =>
                      ref.invalidate(refundsListControllerProvider(filter)),
                  onData: (page) => DataTableView<CustomerRefundSummary>(
                    key: const Key('refunds_table'),
                    columns: [
                      DataTableColumn(
                        label: l10n.refundsColumnNumber,
                        size: ColumnSize.S,
                        cellBuilder: (context, r) => Text(
                          r.serial == null
                              ? emptyValuePlaceholder
                              : '${r.serial}',
                        ),
                      ),
                      if (!compact)
                        DataTableColumn(
                          label: l10n.refundsColumnDate,
                          size: ColumnSize.M,
                          cellBuilder: (context, r) =>
                              Text(fmt.display.dateTime(r.date)),
                        ),
                      if (!compact)
                        DataTableColumn(
                          label: l10n.refundsColumnCustomer,
                          size: ColumnSize.L,
                          cellBuilder: (context, r) => r.customerId == null
                              ? const Text(emptyValuePlaceholder)
                              // simplified: one lookup per distinct customer; map customer_display_name when mbe-api#284 ships
                              : PaymentCustomerName(
                                  customerId: r.customerId!,
                                  name: null,
                                ),
                        ),
                      DataTableColumn(
                        label: l10n.refundsColumnOrder,
                        size: ColumnSize.S,
                        cellBuilder: (context, r) => _OrderCell(
                          orderId: r.salesOrderId,
                          statusDot: compact ? r.status : null,
                        ),
                      ),
                      if (!compact)
                        DataTableColumn(
                          label: l10n.refundsColumnStatus,
                          size: ColumnSize.M,
                          cellBuilder: (context, r) =>
                              RefundStatusChip(status: r.status),
                        ),
                      DataTableColumn(
                        label: l10n.refundsColumnTotal,
                        numeric: true,
                        size: ColumnSize.M,
                        cellBuilder: (context, r) =>
                            Text(fmt.display.currency(r.total)),
                      ),
                    ],
                    rows: page.items,
                    pagination: page,
                    onPageChanged: (pageIndex) => context.go(
                      query
                          .copyWith(pageIndex: pageIndex)
                          .toUri(refundsPath)
                          .toString(),
                    ),
                    // A refund has no row icons: the tap is the way in.
                    onRowTap: (r) => context.push('$refundsPath/${r.id}'),
                  ),
                ),
        ),
      ],
    );
  }
}

/// Whether the server refused the list outright (403) — not a failure, so no
/// retry button (as on Pagos and Notas de crédito).
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
          l10n.refundsForbidden,
          key: const Key('refunds_forbidden'),
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// The order as a link when [orderLinkTargetProvider] finds a destination the
/// user can open, plain text otherwise. [statusDot] adds the refund's status
/// as a coloured dot (compact tier, where the Estado column is dropped).
class _OrderCell extends ConsumerWidget {
  const _OrderCell({required this.orderId, this.statusDot});

  final int orderId;
  final RefundStatus? statusDot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final target = ref.watch(orderLinkTargetProvider(orderId)).value;
    final theme = Theme.of(context);
    final label = '#$orderId';
    final text = target == null
        ? Text(label)
        : InkWell(
            key: Key('refund_order_link_$orderId'),
            onTap: () => context.push(target),
            child: Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.primary,
                decoration: TextDecoration.underline,
                decorationColor: theme.colorScheme.primary,
              ),
            ),
          );
    final status = statusDot;
    if (status == null) return text;
    final l10n = AppLocalizations.of(context)!;
    final spacing = theme.spacing;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: spacing.xs,
      children: [
        text,
        Tooltip(
          message: refundStatusLabel(l10n, status),
          child: Container(
            key: Key('refund_status_dot_${status.name}'),
            width: spacing.sm,
            height: spacing.sm,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: refundStatusColors(theme.colorScheme, status).$2,
            ),
          ),
        ),
      ],
    );
  }
}

/// The drawer's facets: status, customer and order number. Each change writes
/// the URL and returns to the first page.
class _RefundsFiltersPanel extends ConsumerWidget {
  const _RefundsFiltersPanel({required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = RefundsFilter.fromQuery(query);
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;

    void goTo(ListQuery updated) => context.go(
      updated.copyWith(pageIndex: 0).toUri(refundsPath).toString(),
    );

    final customerName = filter.customerId == null
        ? null
        : ref.watch(customerDisplayNameProvider(filter.customerId!)).value;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.fieldGapVertical,
      children: [
        Text(
          l10n.refundsFilterStatus,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        SegmentedButton<RefundStatus?>(
          key: const Key('refunds_status_filter'),
          showSelectedIcon: false,
          segments: [
            ButtonSegment(value: null, label: Text(l10n.refundsFilterAll)),
            ButtonSegment(
              value: RefundStatus.draft,
              label: Text(l10n.refundsFilterOpen),
            ),
            ButtonSegment(
              value: RefundStatus.completed,
              label: Text(l10n.refundsFilterConfirmed),
            ),
            ButtonSegment(
              value: RefundStatus.cancelled,
              label: Text(l10n.refundsFilterCancelled),
            ),
          ],
          selected: {filter.status},
          onSelectionChanged: (selection) =>
              goTo(query.withFacet('status', selection.first?.wireName)),
        ),
        CatalogEntityPicker<CustomerListItem>(
          key: const Key('refunds_customer_filter'),
          label: l10n.refundsColumnCustomer,
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
        _OrderFilterField(
          initialValue: filter.salesOrderId?.toString(),
          label: l10n.refundsFilterOrder,
          onApply: (value) {
            final order = int.tryParse(value);
            if (value.isEmpty || order != null) {
              goTo(query.withFacet('order', order?.toString()));
            }
          },
        ),
      ],
    );
  }
}

/// The order-number filter: applies after the typing pause
/// (`inputDebounceProvider`) and on submit, never once per digit.
class _OrderFilterField extends ConsumerStatefulWidget {
  const _OrderFilterField({
    required this.initialValue,
    required this.label,
    required this.onApply,
  });

  final String? initialValue;
  final String label;
  final ValueChanged<String> onApply;

  @override
  ConsumerState<_OrderFilterField> createState() => _OrderFilterFieldState();
}

class _OrderFilterFieldState extends ConsumerState<_OrderFilterField> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _apply(String value) {
    _debounce?.cancel();
    widget.onApply(value);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: const Key('refunds_order_filter'),
      initialValue: widget.initialValue,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(labelText: widget.label),
      onChanged: (value) {
        _debounce?.cancel();
        _debounce = Timer(ref.read(inputDebounceProvider), () => _apply(value));
      },
      onFieldSubmitted: _apply,
    );
  }
}

/// "Nueva devolución": asks for an order number, then resumes or opens that
/// order's refund (contracts C3). A refusal is shown inline and the dialog
/// stays open so the number can be corrected.
class _NewRefundDialog extends ConsumerStatefulWidget {
  const _NewRefundDialog();

  @override
  ConsumerState<_NewRefundDialog> createState() => _NewRefundDialogState();
}

class _NewRefundDialogState extends ConsumerState<_NewRefundDialog> {
  final _controller = TextEditingController();
  bool _busy = false;
  String? _refusal;
  AppError? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final orderId = int.tryParse(_controller.text.trim());
    if (orderId == null || _busy) return;
    final l10n = AppLocalizations.of(context)!;
    final router = GoRouter.of(context);
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _refusal = null;
      _error = null;
    });
    try {
      switch (await openOrResume(ref, orderId)) {
        case RefundOpened(:final refundId):
          navigator.pop();
          router.push('$refundsPath/$refundId');
          return;
        case RefundRefused(:final reason, :final serverDetail):
          var message = switch (reason) {
            RefundRefusal.orderNotFound => l10n.refundRefusalOrderNotFound(
              orderId,
            ),
            RefundRefusal.notCompleted => l10n.refundRefusalNotCompleted(
              orderId,
            ),
            RefundRefusal.notPaid => l10n.refundRefusalNotPaid(orderId),
            RefundRefusal.nothingToReturn => l10n.refundRefusalNothingToReturn(
              orderId,
            ),
          };
          if (reason == RefundRefusal.nothingToReturn && serverDetail != null) {
            message = '$message $serverDetail';
          }
          if (mounted) setState(() => _refusal = message);
      }
    } on AppError catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    return ResponsiveDialog(
      key: const Key('refund_new_dialog'),
      title: l10n.refundsNew,
      maxWidth: 440,
      dismissible: !_busy,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          TextField(
            key: const Key('refund_new_order_input'),
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(labelText: l10n.refundNewOrderLabel),
            onSubmitted: (_) => _submit(),
          ),
          if (_refusal != null)
            Text(
              _refusal!,
              key: const Key('refund_new_refusal'),
              style: TextStyle(color: theme.colorScheme.error),
            ),
          if (_error != null) ErrorBanner(error: _error!),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).pop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('refund_new_continue'),
        label: l10n.refundNewContinue,
        busy: _busy,
        onPressed: _submit,
      ),
    );
  }
}
