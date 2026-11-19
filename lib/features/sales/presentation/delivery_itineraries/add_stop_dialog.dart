import 'dart:async';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/sales/data/delivery_order_admin_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_order.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/delivery_itinerary_actions.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/itinerary_dialogs.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const _pageSize = 20;

/// "Agregar parada" (spec 075 FR-008, research R5): a paged list of
/// delivery-type orders in En preparación, with a folio search and the orders
/// already on this trip left out. Confirm adds the chosen order as a stop.
///
/// A refusal such as `delivery_order.not_in_preparation` shows inline and
/// keeps the dialog open. Needs read on Delivery Orders (71), which the caller
/// checks. Answers the write's outcome, or `null` when the user backed out.
Future<ItineraryActionResult?> showAddStopDialog(
  BuildContext context, {
  required int itineraryId,
  required Set<int> existingOrderIds,
}) => showResponsiveDialog<ItineraryActionResult>(
  context,
  builder: (context) => _AddStopDialog(
    itineraryId: itineraryId,
    existingOrderIds: existingOrderIds,
  ),
);

/// The same list, only to choose a delivery order: for a stop that has none of
/// its own (created before mbe-api#343), which first asks the user for the
/// order before loading lines onto it (spec Edge Cases). Answers the chosen
/// order's id, or `null` when the user backed out.
Future<int?> showPickStopOrderDialog(
  BuildContext context, {
  required Set<int> existingOrderIds,
}) => showResponsiveDialog<int>(
  context,
  builder: (context) => _PickOrderDialog(existingOrderIds: existingOrderIds),
);

class _AddStopDialog extends ConsumerStatefulWidget {
  const _AddStopDialog({
    required this.itineraryId,
    required this.existingOrderIds,
  });

  final int itineraryId;
  final Set<int> existingOrderIds;

  @override
  ConsumerState<_AddStopDialog> createState() => _AddStopDialogState();
}

class _AddStopDialogState extends ConsumerState<_AddStopDialog> {
  DeliveryOrderSummary? _chosen;
  bool _busy = false;
  AppError? _refusal;

  Future<void> _add() async {
    final order = _chosen;
    if (_busy || order == null) return;
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _refusal = null;
    });
    final error = await ref
        .read(deliveryItineraryActionsProvider.notifier)
        .addStop(widget.itineraryId, deliveryOrderId: order.id);
    if (!mounted) return;
    // Any refusal keeps the dialog open so the user can pick another order.
    if (error != null) {
      setState(() {
        _busy = false;
        _refusal = error;
      });
      return;
    }
    navigator.pop((error: null));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ResponsiveDialog(
      key: const Key('itinerary_add_stop_dialog'),
      title: l10n.itineraryAddStopTitle,
      dismissible: !_busy,
      maxWidth: 760,
      body: _OrderPicker(
        existingOrderIds: widget.existingOrderIds,
        enabled: !_busy,
        refusal: _refusal,
        onChosen: (order) => setState(() => _chosen = order),
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).pop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('itinerary_add_stop_submit'),
        label: l10n.itineraryAddStopConfirm,
        busy: _busy,
        onPressed: _chosen == null ? null : _add,
      ),
    );
  }
}

class _PickOrderDialog extends StatefulWidget {
  const _PickOrderDialog({required this.existingOrderIds});

  final Set<int> existingOrderIds;

  @override
  State<_PickOrderDialog> createState() => _PickOrderDialogState();
}

class _PickOrderDialogState extends State<_PickOrderDialog> {
  DeliveryOrderSummary? _chosen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ResponsiveDialog(
      key: const Key('itinerary_pick_order_dialog'),
      title: l10n.itineraryPickOrderTitle,
      maxWidth: 760,
      body: _OrderPicker(
        existingOrderIds: widget.existingOrderIds,
        onChosen: (order) => setState(() => _chosen = order),
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: () => Navigator.of(context).pop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('itinerary_pick_order_submit'),
        label: l10n.itineraryAddStopConfirm,
        onPressed: _chosen == null
            ? null
            : () => Navigator.of(context).pop(_chosen!.id),
      ),
    );
  }
}

/// The folio search, the table and its pager.
class _OrderPicker extends ConsumerStatefulWidget {
  const _OrderPicker({
    required this.existingOrderIds,
    required this.onChosen,
    this.enabled = true,
    this.refusal,
  });

  final Set<int> existingOrderIds;
  final ValueChanged<DeliveryOrderSummary?> onChosen;
  final bool enabled;
  final AppError? refusal;

  @override
  ConsumerState<_OrderPicker> createState() => _OrderPickerState();
}

class _OrderPickerState extends ConsumerState<_OrderPicker> {
  String _search = '';
  int _pageIndex = 0;
  int _request = 0;
  CatalogPage<DeliveryOrderSummary>? _page;
  AppError? _error;
  DeliveryOrderSummary? _chosen;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final request = ++_request;
    setState(() {
      _page = null;
      _error = null;
    });
    try {
      final result = await ref
          .read(deliveryOrderAdminRepositoryProvider)
          .list(
            statuses: [DeliveryOrderStatus.inPreparation],
            type: FulfillmentType.delivery,
            search: _search.isEmpty ? null : _search,
            skip: _pageIndex * _pageSize,
            limit: _pageSize,
          );
      if (!mounted || request != _request) return;
      setState(() {
        // simplified: orders already on this trip are dropped from the page
        // after it is fetched, so a page can show fewer than 20 rows; filter
        // server-side if the server ever takes an exclusion. The total drops
        // by the same count, so the pager never promises rows the table
        // doesn't have.
        final shown = [
          for (final o in result.items)
            if (!widget.existingOrderIds.contains(o.id)) o,
        ];
        _page = CatalogPage(
          items: shown,
          total: result.total - (result.items.length - shown.length),
          pageIndex: _pageIndex,
          pageSize: _pageSize,
        );
      });
    } on AppError catch (e) {
      if (!mounted || request != _request) return;
      setState(() => _error = e);
    }
  }

  void _choose(DeliveryOrderSummary? order) {
    setState(() => _chosen = order);
    widget.onChosen(order);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final fmt = ref.watch(formattersProvider);
    final page = _page;

    Widget content;
    if (_error != null) {
      content = ErrorBanner(error: _error!);
    } else if (page == null) {
      content = const Center(child: CircularProgressIndicator());
    } else if (page.items.isEmpty) {
      content = Text(
        l10n.itineraryAddStopEmpty,
        key: const Key('itinerary_add_stop_empty'),
      );
    } else {
      content = SizedBox(
        height: 360,
        child: DataTableView<DeliveryOrderSummary>(
          key: const Key('itinerary_add_stop_table'),
          columns: [
            DataTableColumn(
              label: '',
              fixedWidth: 48,
              cellBuilder: (context, o) => Icon(
                o.id == _chosen?.id
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
              ),
            ),
            DataTableColumn.text(
              label: l10n.itineraryAddStopColumnFolio,
              size: ColumnSize.S,
              text: (o) => '${o.serial ?? o.id}',
            ),
            DataTableColumn.text(
              label: l10n.itineraryAddStopColumnCustomer,
              size: ColumnSize.L,
              text: (o) => o.customerName ?? '#${o.customerId}',
            ),
            DataTableColumn.text(
              label: l10n.itineraryAddStopColumnAddress,
              size: ColumnSize.L,
              text: (o) => o.shipToLabel ?? '—',
            ),
            DataTableColumn.text(
              label: l10n.itineraryAddStopColumnDate,
              size: ColumnSize.S,
              text: (o) => fmt.display.date(o.date),
            ),
          ],
          rows: page.items,
          pagination: page,
          onPageChanged: (index) {
            _pageIndex = index;
            _choose(null);
            unawaited(_load());
          },
          onRowTap: widget.enabled ? _choose : null,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: spacing.fieldGapVertical,
      children: [
        CatalogSearchBar(
          key: const Key('itinerary_add_stop_search'),
          label: l10n.itineraryAddStopSearch,
          searchTooltip: l10n.searchButtonTooltip,
          // The server's search matches a folio number only.
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onSubmitted: (value) {
            _search = value.trim();
            _pageIndex = 0;
            _choose(null);
            unawaited(_load());
          },
        ),
        content,
        if (widget.refusal != null) ItineraryRefusal(error: widget.refusal!),
      ],
    );
  }
}
