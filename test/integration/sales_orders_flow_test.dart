import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/point_sale_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';

/// Golden-path integration test against a *real* mbe-api instance
/// (constitution §VII — no mocked/offline mode), per quickstart.md: open a
/// back-office order, add a line, confirm it, then find it back through the
/// Sales Orders list's own data source (spec 029 FR-002, FR-020–FR-024,
/// FR-038–FR-040, US1).
///
/// Every fixture is discovered at runtime — a stockable product from the
/// product lookup, the register's own warehouse — so no ids are hardcoded
/// and the test survives a reseeded database. Unlike its POS siblings, this
/// flow needs **no open cash session**: sales orders don't route through
/// register gating at all (spec 029 has no cash-session precondition).
///
/// Requires mbe-api running at [apiBaseUrl] (default `http://127.0.0.1:8000`)
/// and a user with `SALES_ORDERS (7)` CREATE+READ+UPDATE, a `point_sale` and
/// a `facility` configured on their account (`POST /sales-orders` 422s
/// without either, FR-014). Configure via `--dart-define`:
///   --dart-define=MBE_POS_USERNAME=...
///   --dart-define=MBE_POS_PASSWORD=...
///   --dart-define=MBE_POS_PRODUCT_PATTERN=...   (optional, defaults to 'a')
///
/// Skipped entirely when credentials aren't provided. A confirmed order
/// cannot be deleted, only cancelled — and cancelling a document with lines
/// already committing stock isn't this feature's own concern (that's US2
/// scenario 6's *empty*-draft-only cancel) — so, like
/// `pos_counter_sale_flow_test.dart`, every run leaves a confirmed order
/// behind. Point it at a dev tenant, never production.
const _username = String.fromEnvironment('MBE_POS_USERNAME');
const _password = String.fromEnvironment('MBE_POS_PASSWORD');
const _productPattern = String.fromEnvironment(
  'MBE_POS_PRODUCT_PATTERN',
  defaultValue: 'a',
);

const _canRun = _username != '' && _password != '';

void main() {
  test(
    'open an order → add a line → confirm → find it in the Sales Orders '
    'list (US1)',
    () async {
      final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
      final token = await AuthRepositoryImpl(
        dio,
      ).login(username: _username, password: _password);
      dio.options.headers['Authorization'] = 'Bearer $token';

      final salesOrders = SalesOrderRepositoryImpl(dio);

      // 1. FR-002 — an empty POST opens a draft on the caller's own
      // configuration. A 422 here (no point_sale/facility configured) means
      // this account can't run the flow at all — surface that plainly
      // rather than let a confusing failure follow.
      final Sale opened;
      try {
        opened = await salesOrders.open();
      } on Object catch (e) {
        markTestSkipped('this account cannot open a sales order: $e');
        return;
      }
      expect(opened.status, SaleStatus.draft);
      expect(opened.isEditable, isTrue);
      expect(opened.lines, isEmpty);

      // 2. The warehouse a line defaults to — mbe-api does not fill this
      // in on its own (verified live for POS, `pos_counter_sale_flow_test
      // .dart` step 2 — the same document type, same rule).
      final pointSale = await PointSaleRepositoryImpl(
        dio,
      ).get(pointSaleId: opened.pointSale);
      final warehouse = pointSale.warehouseId;

      // 3. Discover one sellable product from that warehouse.
      final matches = await salesOrders.productLookup(
        pattern: _productPattern,
        customer: opened.customer,
        warehouse: warehouse,
      );
      final sellable = matches.where(
        (p) =>
            compareAmounts(p.price, '0') > 0 &&
            (!p.stockRequired ||
                p.stock.any(
                  (s) => s.warehouse == warehouse && compareAmounts(s.available, '0') > 0,
                )),
      );
      if (sellable.isEmpty) {
        markTestSkipped(
          'no priced product matching "$_productPattern" is in stock in '
          'warehouse $warehouse for this customer',
        );
        return;
      }
      final product = sellable.first;

      // 4. Capture the line.
      final withLine = await salesOrders.addLine(
        saleId: opened.id,
        product: product.product,
        quantity: product.minOrderQty > 0 ? '${product.minOrderQty}' : '1',
        warehouse: warehouse,
      );
      expect(withLine.lineCount, 1);
      expect(withLine.lines.single.warehouse, warehouse, reason: 'FR-024');

      // 5. FR-038–FR-040 — confirm assigns the folio and freezes the order.
      final confirmed = await salesOrders.confirm(saleId: withLine.id);
      expect(confirmed.status, SaleStatus.completed);
      expect(confirmed.isEditable, isFalse);
      expect(confirmed.serial, isNotNull, reason: 'a folio is assigned');

      // 6. Find it back through the Sales Orders list's own data source —
      // `mine: true`, today's range on both ends. This settles two things
      // at once (contracts/mbe-api-sales-orders.md's own §1 finding,
      // `:605`, re-confirmed live rather than only read from source):
      //
      //   - `date_to` is inclusive of its own day once the caller widens it
      //     to end-of-day (`wireDateEnd`, `sales_order_repository_impl.dart`)
      //     — this order's true timestamp is *after* midnight, so a naive
      //     `date_to = today at 00:00` would miss it; finding it here
      //     confirms the widening actually reaches the wire.
      //   - `mine=true` matches this order at all. It cannot, with a single
      //     test account, distinguish creator/updater/salesperson as three
      //     *independent* OR-branches (this account is unavoidably all
      //     three at once) — that would need a second account acting only
      //     as one of the three, which no `MBE_POS_*` credential set
      //     provides today.
      final today = DateTime.now();
      final page = await salesOrders.listOrders(
        mine: true,
        dateFrom: today,
        dateTo: today,
        limit: 100,
      );
      expect(
        page.items.any((s) => s.id == confirmed.id),
        isTrue,
        reason:
            'mine=true over [today, today] must find an order this account '
            'just created and confirmed today',
      );
    },
    skip: !_canRun,
    // ~7 sequential round trips (login, open, point of sale, lookup, add
    // line, confirm, list) — comfortably under the default timeout, but
    // pinned explicitly like its siblings so a slow shared dev backend
    // doesn't flake this out from unrelated suite contention.
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
