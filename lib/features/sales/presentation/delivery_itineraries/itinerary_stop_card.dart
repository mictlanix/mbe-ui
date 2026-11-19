import 'package:data_table_2/data_table_2.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_itinerary.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_order.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/add_stop_dialog.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/itinerary_dialogs.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/itinerary_lookups.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/itinerary_status_chip.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/load_line_dialog.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// One stop of a trip, as a titled section (spec 075 FR-009, ui-contract
/// "Trip screen"): its order, customer and ship-to, the actions its trip's
/// status allows, and a table of its lines.
///
/// The columns follow the trip's status. Abierto shows what is pending on the
/// order and what is loaded, with ✎ and 🗑 for a user with update. Once the
/// trip has left, a line shows what was sent and, on a closed stop, what was
/// delivered and returned, and why.
///
/// Every control is absent, not disabled, when its right is missing (§IV). A
/// write's outcome goes to [onResult], so the screen shows a refusal.
class ItineraryStopCard extends ConsumerWidget {
  const ItineraryStopCard({
    super.key,
    required this.trip,
    required this.stop,
    required this.canUpdate,
    required this.onResult,
    this.onCloseStop,
  });

  final Itinerary trip;
  final ItineraryStop stop;

  /// Update on Delivery Itineraries (87).
  final bool canUpdate;
  final ValueChanged<ItineraryActionResult?> onResult;

  /// "Cerrar parada", offered on a pending stop of a departed trip. `null`
  /// when the user can't close stops.
  final VoidCallback? onCloseStop;

  bool get _isOpen => trip.status == ItineraryStatus.open;

  Set<int> get _existingOrderIds => {
    for (final s in trip.stops)
      if (s.deliveryOrderId != null) s.deliveryOrderId!,
  };

  /// The order this stop loads from. A stop that has none of its own
  /// (created before mbe-api#343) first asks the user for it.
  Future<int?> _orderFor(BuildContext context) async =>
      stop.deliveryOrderId ??
      showPickStopOrderDialog(context, existingOrderIds: _existingOrderIds);

  Future<void> _loadAll(BuildContext context) async {
    final orderId = await _orderFor(context);
    if (orderId == null || !context.mounted) return;
    onResult(
      await showLoadAllDialog(
        context,
        itineraryId: trip.id,
        stopId: stop.id,
        deliveryOrderId: orderId,
      ),
    );
  }

  Future<void> _loadLine(BuildContext context) async {
    final orderId = await _orderFor(context);
    if (orderId == null || !context.mounted) return;
    onResult(
      await showLoadLineDialog(
        context,
        itineraryId: trip.id,
        stopId: stop.id,
        deliveryOrderId: orderId,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final fmt = ref.watch(formattersProvider);
    final access = ref.watch(accessControlProvider);
    final canReadOrders = access.can(
      SystemObject.deliveryOrders,
      AccessRight.read,
    );
    final editable = _isOpen && canUpdate;

    return Card(
      key: Key('itinerary_stop_${stop.id}'),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: spacing.sm,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _Title(stop: stop, canReadOrders: canReadOrders),
                ),
                if (!_isOpen) ...[
                  StopOutcomeChip(outcome: stop.outcome),
                  if (stop.arrivedAt != null)
                    Padding(
                      padding: EdgeInsetsDirectional.only(start: spacing.sm),
                      child: Text(
                        l10n.itineraryStopClosedAt(
                          fmt.display.dateTime(stop.arrivedAt),
                        ),
                        key: Key('itinerary_stop_closed_${stop.id}'),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                ],
                if (editable)
                  PopupMenuButton<void>(
                    key: Key('itinerary_stop_menu_${stop.id}'),
                    tooltip: l10n.itineraryStopMenuTooltip,
                    itemBuilder: (context) => [
                      PopupMenuItem<void>(
                        key: Key('itinerary_stop_remove_${stop.id}'),
                        onTap: () async => onResult(
                          await showRemoveStopDialog(
                            context,
                            itineraryId: trip.id,
                            stop: stop,
                          ),
                        ),
                        child: Text(l10n.itineraryActionRemoveStop),
                      ),
                    ],
                  ),
              ],
            ),
            if (editable)
              Wrap(
                alignment: WrapAlignment.end,
                spacing: spacing.sm,
                runSpacing: spacing.sm,
                children: [
                  OutlinedButton(
                    key: Key('itinerary_stop_load_all_${stop.id}'),
                    onPressed: () => _loadAll(context),
                    child: Text(l10n.itineraryActionLoadAll),
                  ),
                  // Choosing a line needs the order's lines (71 read).
                  if (canReadOrders)
                    OutlinedButton.icon(
                      key: Key('itinerary_stop_load_line_${stop.id}'),
                      onPressed: () => _loadLine(context),
                      icon: Icon(CatalogAction.create.icon),
                      label: Text(l10n.itineraryActionLoadLine),
                    ),
                ],
              ),
            if (stop.lines.isEmpty)
              Text(
                l10n.itineraryStopEmpty,
                key: Key('itinerary_stop_empty_${stop.id}'),
              )
            else
              _Lines(
                trip: trip,
                stop: stop,
                canUpdate: canUpdate,
                onResult: onResult,
              ),
            if (onCloseStop != null &&
                trip.status == ItineraryStatus.departed &&
                stop.isPending)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: FilledButton.icon(
                  key: Key('itinerary_stop_close_${stop.id}'),
                  onPressed: onCloseStop,
                  icon: const Icon(Icons.check),
                  label: Text(l10n.itineraryActionCloseStop),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// "Parada {n} · Orden {folio} ↗ · {customer} · {ship-to}".
///
/// The order links to its own screen with read on Delivery Orders (71). A
/// stop with no order of its own (created before mbe-api#343) lists the
/// orders its lines belong to instead.
class _Title extends ConsumerWidget {
  const _Title({required this.stop, required this.canReadOrders});

  final ItineraryStop stop;
  final bool canReadOrders;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final orderId = stop.deliveryOrderId;

    final Widget order;
    if (orderId != null) {
      final label = l10n.itineraryStopOrder(orderId);
      order = canReadOrders
          ? TextButton.icon(
              key: Key('itinerary_stop_order_${stop.id}'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => context.push('/sales/delivery-orders/$orderId'),
              icon: const Icon(Icons.open_in_new, size: 16),
              iconAlignment: IconAlignment.end,
              label: Text(label),
            )
          : Text(label, key: Key('itinerary_stop_order_${stop.id}'));
    } else if (stop.deliveryOrderIds.isNotEmpty) {
      order = Text(
        l10n.itineraryStopOrders(stop.deliveryOrderIds.join(', ')),
        key: Key('itinerary_stop_order_${stop.id}'),
      );
    } else {
      order = const SizedBox.shrink();
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: spacing.sm,
      runSpacing: spacing.xs,
      children: [
        Text(
          l10n.itineraryStopTitle(stop.sequence),
          style: theme.textTheme.titleMedium,
        ),
        order,
        if (stop.customerName != null) Text(stop.customerName!),
        if (stop.shipToLabel != null)
          Text(stop.shipToLabel!, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

/// A stop's lines: a table on a wide screen, a card per line on a compact one.
class _Lines extends ConsumerWidget {
  const _Lines({
    required this.trip,
    required this.stop,
    required this.canUpdate,
    required this.onResult,
  });

  final Itinerary trip;
  final ItineraryStop stop;
  final bool canUpdate;
  final ValueChanged<ItineraryActionResult?> onResult;

  bool get _isOpen => trip.status == ItineraryStatus.open;

  /// The stop has been closed: it shows what was delivered and why not.
  bool get _closed => !stop.isPending;

  /// What is still open on the order for [line], or `null` when the order
  /// can't be read.
  Decimal? _pending(WidgetRef ref, ItineraryLine line) {
    final order = ref.watch(itineraryOrderProvider(line.deliveryOrderId)).value;
    return order?.lines
        .where((l) => l.id == line.deliveryOrderLineId)
        .map((DeliveryOrderLine l) => l.open)
        .firstOrNull;
  }

  /// ✎ and 🗑, as separate widgets: the table sizes its actions column by how
  /// many it is given.
  List<Widget> _actions(
    BuildContext context,
    WidgetRef ref,
    ItineraryLine line,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return buildCatalogRowActions(
      editTooltip: l10n.itineraryLineEditTooltip,
      editKey: Key('itinerary_line_edit_${line.id}'),
      onEdit: () async => onResult(
        await showAdjustQuantityDialog(
          context,
          itineraryId: trip.id,
          stopId: stop.id,
          line: line,
          pending: _pending(ref, line),
        ),
      ),
      extraActions: [
        CatalogRowAction(
          key: Key('itinerary_line_release_${line.id}'),
          icon: Icons.delete_outline,
          tooltip: l10n.itineraryLineReleaseTooltip,
          onPressed: () async => onResult(
            await showReleaseLineDialog(
              context,
              itineraryId: trip.id,
              stopId: stop.id,
              line: line,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final fmt = ref.watch(formattersProvider);
    final showActions = _isOpen && canUpdate;

    String qty(Decimal value) => fmt.display.quantity(value.toString());
    String pendingText(ItineraryLine line) {
      final pending = _pending(ref, line);
      return pending == null ? emptyValuePlaceholder : qty(pending);
    }

    // (label, value) pairs after the product, by the trip's status.
    final quantities = <(String, String Function(ItineraryLine))>[
      if (_isOpen) ...[
        (l10n.itineraryLinePending, pendingText),
        (l10n.itineraryLineLoaded, (l) => qty(l.committed)),
      ] else ...[
        (l10n.itineraryLineSent, (l) => qty(l.sent)),
        if (_closed) ...[
          (l10n.itineraryLineDelivered, (l) => qty(l.delivered)),
          (l10n.itineraryLineReturned, (l) => qty(l.returned)),
        ],
      ],
    ];
    String reasonOf(ItineraryLine line) => line.reason == null
        ? emptyValuePlaceholder
        : shortfallReasonLabel(l10n, line.reason!);

    if (LayoutBreakpoints.isCompact(context)) {
      return Column(
        key: Key('itinerary_stop_lines_${stop.id}'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final line in stop.lines) ...[
            Padding(
              key: Key('itinerary_line_card_${line.id}'),
              padding: EdgeInsets.symmetric(vertical: spacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: spacing.xs,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text('${line.productCode} ${line.productName}'),
                      ),
                      if (showActions) ..._actions(context, ref, line),
                    ],
                  ),
                  Wrap(
                    spacing: spacing.md,
                    runSpacing: spacing.xs,
                    children: [
                      for (final (label, value) in quantities)
                        Text(
                          '$label ${value(line)}'
                          '${line.unitSymbol == null ? '' : ' ${line.unitSymbol}'}',
                          style: theme.textTheme.bodySmall,
                        ),
                      if (_closed && line.reason != null)
                        Text(
                          '${l10n.itineraryLineReason} ${reasonOf(line)}',
                          style: theme.textTheme.bodySmall,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
          ],
        ],
      );
    }

    return DataTableView<ItineraryLine>(
      key: Key('itinerary_stop_lines_${stop.id}'),
      shrinkWrap: true,
      margin: EdgeInsets.zero,
      rows: stop.lines,
      rowActionsBuilder: showActions
          ? (context, line) => _actions(context, ref, line)
          : null,
      columns: [
        DataTableColumn.text(
          label: l10n.itineraryLineCode,
          size: ColumnSize.S,
          text: (line) => line.productCode,
        ),
        DataTableColumn.text(
          label: l10n.itineraryLineProduct,
          size: ColumnSize.L,
          text: (line) => line.productName,
        ),
        DataTableColumn.text(
          label: l10n.itineraryLineUnit,
          size: ColumnSize.S,
          text: (line) => line.unitSymbol ?? emptyValuePlaceholder,
        ),
        for (final (label, value) in quantities)
          DataTableColumn(
            label: label,
            numeric: true,
            size: ColumnSize.S,
            cellBuilder: (context, line) => Text(value(line)),
          ),
        if (_closed)
          DataTableColumn.text(
            label: l10n.itineraryLineReason,
            size: ColumnSize.M,
            text: reasonOf,
          ),
      ],
    );
  }
}
