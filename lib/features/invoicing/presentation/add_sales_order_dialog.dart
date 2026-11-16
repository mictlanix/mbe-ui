import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_actions.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_refusal.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/open_sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const _pageSize = 20;

/// Adds one of [customerId]'s completed sales orders to draft [documentId]
/// (spec 066 C10, FR-007). Picking a row adds the order's lines at their
/// remaining quantity. Answers the order's folio when one was added, `null`
/// when the user backed out.
///
/// The server refuses an order with nothing left to invoice
/// (`no_invoiceable_lines`) or one it can't invoice (`order_not_invoiceable`);
/// both stay inline so the user can pick another. The picker lists fully
/// invoiced orders too, since the API exposes no remaining quantity.
Future<String?> showAddSalesOrderDialog(
  BuildContext context, {
  required int documentId,
  required int customerId,
}) => showResponsiveDialog<String>(
  context,
  builder: (_) =>
      _AddSalesOrderDialog(documentId: documentId, customerId: customerId),
);

class _AddSalesOrderDialog extends ConsumerStatefulWidget {
  const _AddSalesOrderDialog({
    required this.documentId,
    required this.customerId,
  });

  final int documentId;
  final int customerId;

  @override
  ConsumerState<_AddSalesOrderDialog> createState() =>
      _AddSalesOrderDialogState();
}

class _AddSalesOrderDialogState extends ConsumerState<_AddSalesOrderDialog> {
  final _search = TextEditingController();
  Timer? _debounce;
  int _request = 0;
  List<OpenSale>? _orders;
  int _total = 0;
  bool _loadingMore = false;
  AppError? _loadError;

  bool _busy = false;
  AppError? _refusal;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _load({bool more = false}) async {
    final request = ++_request;
    setState(() {
      _loadError = null;
      if (more) {
        _loadingMore = true;
      } else {
        _orders = null;
      }
    });
    final search = _search.text.trim();
    try {
      final page = await ref
          .read(salesOrderRepositoryProvider)
          .listOrders(
            customer: widget.customerId,
            status: SaleStatus.completed,
            search: search.isEmpty ? null : search,
            skip: more ? _orders?.length ?? 0 : 0,
            limit: _pageSize,
          );
      if (!mounted || request != _request) return;
      setState(() {
        _orders = [if (more) ...?_orders, ...page.items];
        _total = page.total;
        _loadingMore = false;
      });
    } on AppError catch (e) {
      if (!mounted || request != _request) return;
      setState(() {
        _loadError = e;
        _loadingMore = false;
      });
    }
  }

  void _searchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(ref.read(inputDebounceProvider), _load);
  }

  Future<void> _add(OpenSale order) async {
    if (_busy) return;
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _refusal = null;
    });
    final error = await ref
        .read(fiscalDocumentActionsProvider.notifier)
        .addSalesOrder(widget.documentId, order.id);
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _busy = false;
        _refusal = error;
      });
      return;
    }
    navigator.pop('${order.serial ?? order.id}');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final fmt = ref.watch(formattersProvider);
    final customer =
        ref.watch(customerDisplayNameProvider(widget.customerId)).value ??
        '#${widget.customerId}';
    final orders = _orders;

    final Widget list;
    if (_loadError != null) {
      list = ListFailedView(
        error: _loadError!,
        retryLabel: l10n.retryButton,
        onRetry: _load,
      );
    } else if (orders == null) {
      list = const Center(child: CircularProgressIndicator());
    } else if (orders.isEmpty) {
      list = KeyedSubtree(
        key: const Key('add_sales_order_empty'),
        child: ListEmptyView(message: l10n.fiscalDocumentAddOrderEmpty),
      );
    } else {
      Widget row(List<Widget> cells, {TextStyle? style}) => Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.sm,
          vertical: spacing.sm,
        ),
        child: DefaultTextStyle.merge(
          style: style,
          child: Row(
            spacing: spacing.md,
            children: [
              Expanded(child: cells[0]),
              Expanded(child: cells[1]),
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: cells[2],
                ),
              ),
            ],
          ),
        ),
      );
      list = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          row([
            Text(l10n.fiscalDocumentAddOrderColFolio),
            Text(l10n.fiscalDocumentAddOrderColDate),
            Text(l10n.fiscalDocumentAddOrderColTotal),
          ], style: theme.textTheme.labelMedium),
          const Divider(height: 1),
          for (final order in orders)
            InkWell(
              key: Key('add_sales_order_row_${order.id}'),
              onTap: _busy ? null : () => _add(order),
              child: row([
                Text('${order.serial ?? '#${order.id}'}'),
                Text(fmt.display.date(order.date)),
                Text(fmt.display.currency(order.total)),
              ]),
            ),
          if (orders.length < _total)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                key: const Key('add_sales_order_load_more'),
                onPressed: _loadingMore ? null : () => _load(more: true),
                child: Text(l10n.fiscalDocumentAddOrderLoadMore),
              ),
            ),
        ],
      );
    }

    return ResponsiveDialog(
      key: const Key('add_sales_order_dialog'),
      title: l10n.fiscalDocumentAddOrderTitle,
      dismissible: !_busy,
      maxWidth: 640,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          Text(l10n.fiscalDocumentAddOrderIntro(customer)),
          TextField(
            key: const Key('add_sales_order_search'),
            controller: _search,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: l10n.fiscalDocumentAddOrderSearch,
            ),
            onChanged: _searchChanged,
            onSubmitted: (_) {
              _debounce?.cancel();
              unawaited(_load());
            },
          ),
          if (_refusal != null) FiscalDocumentRefusal(error: _refusal!),
          list,
        ],
      ),
      // Picking a row is the action, so the only button closes the dialog.
      primaryAction: ResponsiveDialogAction(
        key: const Key('add_sales_order_close'),
        label: l10n.cancelButton,
        busy: _busy,
        onPressed: _busy ? null : () => Navigator.of(context).pop(),
      ),
    );
  }
}
