import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_transfer.dart';
import 'package:mbe_ui/features/inventory/presentation/transfers/inventory_transfers_filter.dart';

/// Spec 069 research R4: the list's view state lives in the URL.
void main() {
  test('no facets: nothing narrowed, page 0', () {
    final filter = InventoryTransfersFilter.fromQuery(const ListQuery());

    expect(filter, const InventoryTransfersFilter());
    expect(filter.activeCount, 0);
    expect(filter.isNarrowed, isFalse);
  });

  test('a full filter round-trips, in transit as in_transit', () {
    const filter = InventoryTransfersFilter(
      status: InventoryTransferStatus.inTransit,
      warehouseId: 12,
      pageIndex: 2,
    );

    final query = filter.toQuery();
    expect(query.facet('status'), 'in_transit');
    expect(query.facet('warehouse'), '12');
    expect(query.pageIndex, 2);
    expect(InventoryTransfersFilter.fromQuery(query), filter);
  });

  test('every status round-trips through its wire value', () {
    for (final status in InventoryTransferStatus.values) {
      final filter = InventoryTransfersFilter(status: status);
      expect(InventoryTransfersFilter.fromQuery(filter.toQuery()), filter);
    }
  });

  test('an unknown status and a non-numeric warehouse are ignored', () {
    final filter = InventoryTransfersFilter.fromQuery(
      const ListQuery()
          .withFacet('status', 'inTransit')
          .withFacet('warehouse', 'x'),
    );

    expect(filter.status, isNull);
    expect(filter.warehouseId, isNull);
    expect(filter.activeCount, 0);
  });

  test('activeCount counts each facet in use, not the page', () {
    expect(
      const InventoryTransfersFilter(
        status: InventoryTransferStatus.draft,
        pageIndex: 4,
      ).activeCount,
      1,
    );
    const both = InventoryTransfersFilter(
      status: InventoryTransferStatus.draft,
      warehouseId: 3,
    );
    expect(both.activeCount, 2);
    expect(both.isNarrowed, isTrue);
    expect(both.cleared(), const InventoryTransfersFilter());
  });
}
