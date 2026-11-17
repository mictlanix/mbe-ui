import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_transfer.dart';

part 'inventory_transfers_filter.freezed.dart';

/// The "Traspasos" list's addressable view state (spec 069). Every field
/// lives in the URL, so Back from a transfer returns to the same page and
/// filters. There is no search box: the endpoint has none.
@freezed
abstract class InventoryTransfersFilter with _$InventoryTransfersFilter {
  const InventoryTransfersFilter._();

  const factory InventoryTransfersFilter({
    InventoryTransferStatus? status,

    /// Matches the origin or the destination on the server.
    int? warehouseId,
    @Default(0) int pageIndex,
  }) = _InventoryTransfersFilter;

  /// An unknown `status` or a non-numeric `warehouse` is ignored.
  factory InventoryTransfersFilter.fromQuery(ListQuery query) {
    final status = query.facet('status');
    final warehouse = query.facet('warehouse');
    return InventoryTransfersFilter(
      status: InventoryTransferStatus.values
          .where((s) => _wire(s) == status)
          .firstOrNull,
      warehouseId: warehouse == null ? null : int.tryParse(warehouse),
      pageIndex: query.pageIndex,
    );
  }

  /// This filter as a URL query. The `status` value is the wire value
  /// (`draft`, `in_transit`, `received`, `cancelled`).
  ListQuery toQuery() => ListQuery(pageIndex: pageIndex)
      .withFacet('status', status == null ? null : _wire(status!))
      .withFacet('warehouse', warehouseId?.toString());

  /// What the filter badge counts: one per facet in use, not the page.
  int get activeCount =>
      (status != null ? 1 : 0) + (warehouseId != null ? 1 : 0);

  bool get isNarrowed => activeCount > 0;

  /// "Limpiar todo": every facet emptied, back to page 1.
  InventoryTransfersFilter cleared() => const InventoryTransfersFilter();
}

String _wire(InventoryTransferStatus status) => switch (status) {
  InventoryTransferStatus.draft => 'draft',
  InventoryTransferStatus.inTransit => 'in_transit',
  InventoryTransferStatus.received => 'received',
  InventoryTransferStatus.cancelled => 'cancelled',
};
