import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/sales/presentation/capture/facility_warehouses_controller.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_name_cells.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Which lines of a delivery order its ticket prints (spec 064 data-model):
/// every line, or only the ones leaving from one warehouse.
@immutable
class DeliveryTicketScope {
  /// Every line of the order.
  const DeliveryTicketScope.all() : warehouseId = null, warehouseName = null;

  /// Only the lines from [warehouseId]; [warehouseName] goes into the
  /// preview's title.
  const DeliveryTicketScope.warehouse(
    int this.warehouseId,
    String this.warehouseName,
  );

  /// Null for every line.
  final int? warehouseId;

  /// Null for every line.
  final String? warehouseName;
}

/// Asks which lines of a multi-warehouse order to print (spec 064 contracts
/// U5, research R6): "Todos los almacenes" first and preselected, then one
/// option per warehouse the order's lines come from, by name. Resolves to the
/// choice, or `null` when the dialog is dismissed, in which case nothing is
/// fetched.
///
/// A [ResponsiveDialog], so it fills the screen on a phone like every other
/// delivery-order dialog.
Future<DeliveryTicketScope?> showDeliveryTicketScopeDialog(
  BuildContext context, {
  required int facilityId,
  required List<int> warehouseIds,
}) => showResponsiveDialog<DeliveryTicketScope>(
  context,
  builder: (_) => _DeliveryTicketScopeDialog(
    facilityId: facilityId,
    warehouseIds: warehouseIds,
  ),
);

class _DeliveryTicketScopeDialog extends ConsumerStatefulWidget {
  const _DeliveryTicketScopeDialog({
    required this.facilityId,
    required this.warehouseIds,
  });

  final int facilityId;
  final List<int> warehouseIds;

  @override
  ConsumerState<_DeliveryTicketScopeDialog> createState() =>
      _DeliveryTicketScopeDialogState();
}

class _DeliveryTicketScopeDialogState
    extends ConsumerState<_DeliveryTicketScopeDialog> {
  /// The chosen warehouse; null is "Todos los almacenes".
  int? _selected;

  /// The warehouse's name for the title, or `#id` when the user can't read the
  /// catalog (as [DeliveryOrderWarehouseName] shows it).
  String _nameOf(int warehouseId) {
    final warehouses = ref
        .read(facilityWarehousesControllerProvider(widget.facilityId))
        .value;
    return warehouses
            ?.where((w) => w.warehouseId == warehouseId)
            .firstOrNull
            ?.name ??
        '#$warehouseId';
  }

  void _confirm() {
    final id = _selected;
    Navigator.of(context).pop(
      id == null
          ? const DeliveryTicketScope.all()
          : DeliveryTicketScope.warehouse(id, _nameOf(id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ResponsiveDialog(
      key: const Key('delivery_ticket_scope_dialog'),
      title: l10n.deliveryTicketScopeTitle,
      primaryAction: ResponsiveDialogAction(
        key: const Key('delivery_ticket_scope_confirm'),
        label: l10n.deliveryOrderViewTicket,
        onPressed: _confirm,
      ),
      secondaryAction: ResponsiveDialogAction(
        key: const Key('delivery_ticket_scope_cancel'),
        label: l10n.cancelButton,
        onPressed: () => Navigator.of(context).pop(),
      ),
      body: RadioGroup<int?>(
        groupValue: _selected,
        onChanged: (value) => setState(() => _selected = value),
        child: Column(
          children: [
            RadioListTile<int?>(
              key: const Key('delivery_ticket_scope_all'),
              value: null,
              title: Text(l10n.deliveryTicketScopeAll),
            ),
            for (final id in widget.warehouseIds)
              RadioListTile<int?>(
                key: Key('delivery_ticket_scope_$id'),
                value: id,
                title: DeliveryOrderWarehouseName(
                  facilityId: widget.facilityId,
                  warehouseId: id,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
