import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_receipt.dart';
import 'package:mbe_ui/features/inventory/presentation/receipts/inventory_receipts_filter.dart';

/// Spec 067 research R9 (T008): the list's view state lives in the URL.
void main() {
  test('no facets: nothing narrowed, page 0', () {
    final filter = InventoryReceiptsFilter.fromQuery(const ListQuery());

    expect(filter, const InventoryReceiptsFilter());
    expect(filter.activeFilterCount, 0);
    expect(filter.isNarrowed, isFalse);
  });

  test('a full filter round-trips through the URL', () {
    const filter = InventoryReceiptsFilter(
      status: ReceiptStatus.completed,
      warehouseId: 3,
      pageIndex: 2,
    );

    final query = filter.toQuery();
    expect(query.facet('status'), 'completed');
    expect(query.facet('warehouse'), '3');
    expect(query.pageIndex, 2);
    expect(InventoryReceiptsFilter.fromQuery(query), filter);
  });

  test('every status round-trips through its wire value', () {
    for (final status in ReceiptStatus.values) {
      final filter = InventoryReceiptsFilter(status: status);
      expect(InventoryReceiptsFilter.fromQuery(filter.toQuery()), filter);
    }
    expect(
      const InventoryReceiptsFilter(
        status: ReceiptStatus.cancelled,
      ).toQuery().facet('status'),
      'cancelled',
    );
  });

  test('an unknown status and a non-numeric warehouse are ignored', () {
    final filter = InventoryReceiptsFilter.fromQuery(
      const ListQuery().withFacet('status', 'paid').withFacet('warehouse', 'x'),
    );

    expect(filter.status, isNull);
    expect(filter.warehouseId, isNull);
    expect(filter.activeFilterCount, 0);
  });

  test('the badge counts each facet in use, not the page', () {
    expect(
      const InventoryReceiptsFilter(
        status: ReceiptStatus.draft,
        pageIndex: 4,
      ).activeFilterCount,
      1,
    );
    const both = InventoryReceiptsFilter(
      status: ReceiptStatus.draft,
      warehouseId: 3,
    );
    expect(both.activeFilterCount, 2);
    expect(both.isNarrowed, isTrue);
  });

  test('cleared() empties every facet and goes back to page 1', () {
    const filter = InventoryReceiptsFilter(
      status: ReceiptStatus.draft,
      warehouseId: 3,
      pageIndex: 2,
    );

    expect(filter.cleared(), const InventoryReceiptsFilter());
  });
}
