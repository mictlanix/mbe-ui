import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/purchase_orders_filter.dart';

/// Spec 080 research R15: the list's view state lives in the URL.
void main() {
  test('no facets: nothing narrowed, page 0, own scope', () {
    final filter = PurchaseOrdersFilter.fromQuery(const ListQuery());

    expect(filter, const PurchaseOrdersFilter());
    expect(filter.all, isFalse);
    expect(filter.activeFilterCount, 0);
    expect(filter.isNarrowed, isFalse);
  });

  test('a full filter round-trips through the URL', () {
    final filter = PurchaseOrdersFilter(
      all: true,
      status: InventoryDocumentStatus.completed,
      supplierId: 12,
      creatorId: 5,
      from: DateTime(2026, 11, 1),
      to: DateTime(2026, 11, 30),
      orderId: 310,
      search: '310',
      pageIndex: 2,
    );

    final query = filter.toQuery();
    expect(query.search, '310');
    expect(query.facet('all'), 'true');
    expect(query.facet('status'), 'completed');
    expect(query.facet('supplier'), '12');
    expect(query.facet('creator'), '5');
    expect(query.facet('from'), '2026-11-01');
    expect(query.facet('to'), '2026-11-30');
    expect(query.pageIndex, 2);
    expect(PurchaseOrdersFilter.fromQuery(query), filter);
  });

  test('every status round-trips through its wire value', () {
    for (final status in InventoryDocumentStatus.values) {
      final filter = PurchaseOrdersFilter(status: status);
      expect(filter.toQuery().facet('status'), status.name);
      expect(PurchaseOrdersFilter.fromQuery(filter.toQuery()), filter);
    }
  });

  test('the default scope puts no all facet in the URL', () {
    expect(const PurchaseOrdersFilter().toQuery().facet('all'), isNull);
  });

  test('the badge counts all, each facet and the date range as one, not the '
      'search or the page', () {
    expect(
      PurchaseOrdersFilter(
        all: true,
        status: InventoryDocumentStatus.draft,
        supplierId: 1,
        creatorId: 2,
        from: DateTime(2026, 11, 1),
        to: DateTime(2026, 11, 30),
        orderId: 5,
        search: '5',
        pageIndex: 3,
      ).activeFilterCount,
      5,
    );
    expect(
      const PurchaseOrdersFilter(
        orderId: 5,
        search: '5',
        pageIndex: 3,
      ).activeFilterCount,
      0,
    );
  });

  test('an unknown status is ignored', () {
    final filter = PurchaseOrdersFilter.fromQuery(
      const ListQuery().withFacet('status', 'paid'),
    );

    expect(filter.status, isNull);
    expect(filter.activeFilterCount, 0);
  });

  test('a non-numeric supplier or creator is ignored', () {
    final filter = PurchaseOrdersFilter.fromQuery(
      const ListQuery().withFacet('supplier', 'x').withFacet('creator', '-'),
    );

    expect(filter.supplierId, isNull);
    expect(filter.creatorId, isNull);
  });

  test('a non-numeric search is kept for the box but sends no id', () {
    final filter = PurchaseOrdersFilter.fromQuery(
      const ListQuery(search: 'abc'),
    );

    expect(filter.search, 'abc');
    expect(filter.orderId, isNull);
    expect(filter.isNarrowed, isTrue);
    expect(filter.activeFilterCount, 0);
    expect(filter.toQuery().search, 'abc');
  });

  test('a half-open or reversed date range is dropped', () {
    final half = PurchaseOrdersFilter.fromQuery(
      const ListQuery().withFacet('from', '2026-11-01'),
    );
    final reversed = PurchaseOrdersFilter.fromQuery(
      const ListQuery()
          .withFacet('from', '2026-11-30')
          .withFacet('to', '2026-11-01'),
    );

    expect(half.from, isNull);
    expect(reversed.from, isNull);
    expect(reversed.to, isNull);
  });

  test('cleared() empties everything and goes back to page 0', () {
    final filter = PurchaseOrdersFilter(
      all: true,
      status: InventoryDocumentStatus.draft,
      supplierId: 1,
      orderId: 5,
      search: '5',
      pageIndex: 4,
    );

    expect(filter.cleared(), const PurchaseOrdersFilter());
    expect(filter.cleared().isNarrowed, isFalse);
  });

  test('the drawer\'s "Limpiar todo" keeps the number search; the scope '
      'alone is not a narrowing for the empty state (T023)', () {
    final filter = PurchaseOrdersFilter.fromQuery(
      ListQuery.fromUri(
        Uri.parse('/purchases/orders?search=55&all=true&status=draft&page=3'),
      ),
    );

    final facetsCleared = filter.cleared().copyWith(search: filter.search);
    expect(facetsCleared.toQuery().search, '55');
    expect(facetsCleared.activeFilterCount, 0);
    expect(facetsCleared.pageIndex, 0);

    final allOnly = const PurchaseOrdersFilter(all: true);
    expect(allOnly.activeFilterCount, 1);
    expect(allOnly.copyWith(all: false).isNarrowed, isFalse);
  });
}
