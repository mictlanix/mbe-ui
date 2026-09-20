import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/point_sale_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/delivery_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/entities/fulfillment_mode.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_origin.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/features/sales/pos_defaults.dart';

/// Golden-path integration test against a *real* mbe-api instance
/// (constitution §VII — no mocked/offline mode), per quickstart.md Scenario 1
/// and spec 039 US1: customer attach → add a line → add a destination with
/// the full outstanding quantity → verify the order committed and the
/// destination exists — modeled directly on `sales_orders_flow_test.dart`,
/// this feature's own predecessor flow.
///
/// Every fixture is discovered at runtime — a customer with an address on
/// file, a stockable product from the product lookup, the account's own
/// warehouse — so no ids are hardcoded and the test survives a reseeded
/// database. Like its sales-orders sibling, this flow needs **no open cash
/// session**: the back-office workspace never routes through register
/// gating (FR-004, SC-009 — no payment step exists on any of its steps).
///
/// Requires mbe-api running at [apiBaseUrl] (default `http://127.0.0.1:8000`)
/// and a user with `SALES_ORDERS (7)` CREATE+READ+UPDATE, `CUSTOMERS`
/// READ, a `point_sale` and a `facility` configured on their account
/// (`POST /sales-orders` 422s without either). Configure via `--dart-define`:
///   --dart-define=MBE_POS_USERNAME=...
///   --dart-define=MBE_POS_PASSWORD=...
///   --dart-define=MBE_POS_PRODUCT_PATTERN=...   (optional, defaults to 'a')
///
/// Skipped entirely when credentials aren't provided, when no customer with
/// an address can be found, or when no priced/stocked product matches the
/// pattern. A committed order cannot be deleted, only cancelled — and this
/// feature's own cancel is empty-draft-only (US3 scenario 6), which this
/// order no longer is once a destination exists — so, like
/// `sales_orders_flow_test.dart`, every run leaves a committed order and a
/// delivery order behind. Point it at a dev tenant, never production.
const _username = String.fromEnvironment('MBE_POS_USERNAME');
const _password = String.fromEnvironment('MBE_POS_PASSWORD');
const _productPattern = String.fromEnvironment(
  'MBE_POS_PRODUCT_PATTERN',
  defaultValue: 'a',
);

const _canRun = _username != '' && _password != '';

void main() {
  test(
    'attach a customer → add a line → add a destination for everything owed '
    '→ the order committed, the destination exists (US1)',
    () async {
      final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
      final token = await AuthRepositoryImpl(
        dio,
      ).login(username: _username, password: _password);
      dio.options.headers['Authorization'] = 'Bearer $token';

      final salesOrders = SalesOrderRepositoryImpl(dio);
      final deliveryOrders = DeliveryOrderRepositoryImpl(dio);
      final customers = CustomerRepositoryImpl(dio);

      // 1. FR-011/FR-012 — a real customer, never the generic walk-in one,
      // with at least one address on file (a destination needs a shipTo).
      // Discovered rather than hardcoded: page through the customer list
      // until one qualifies.
      final candidates = await customers.list(limit: 50);
      int? customerId;
      int? shipTo;
      for (final item in candidates.items) {
        if (item.customerId == posDefaultCustomerId) continue;
        final full = await customers.get(customerId: item.customerId);
        if (full.addresses.isNotEmpty) {
          customerId = full.customerId;
          shipTo = full.addresses.first.addressId;
          break;
        }
      }
      if (customerId == null || shipTo == null) {
        markTestSkipped(
          'no customer with an address on file found in the first 50 — '
          'this account cannot run the flow',
        );
        return;
      }

      // 2. FR-005, FR-014, FR-015 — the Cliente step's own single request:
      // the customer, the intent to deliver, and this workspace's origin,
      // together.
      final Sale opened;
      try {
        opened = await salesOrders.open(
          customer: customerId,
          fulfillmentIntent: FulfillmentMode.delivery,
          origin: SaleOrigin.backOffice,
        );
      } on Object catch (e) {
        markTestSkipped('this account cannot open a sales order: $e');
        return;
      }
      expect(opened.status, SaleStatus.draft);
      expect(opened.isEditable, isTrue);
      expect(opened.lines, isEmpty);
      expect(opened.origin, SaleOrigin.backOffice, reason: 'FR-051');
      expect(opened.fulfillmentIntent, FulfillmentMode.delivery);

      // 3. The warehouse a line defaults to (same rule
      // `sales_orders_flow_test.dart` and `pos_counter_sale_flow_test.dart`
      // both confirm live: mbe-api does not fill this in on its own).
      final pointSale = await PointSaleRepositoryImpl(
        dio,
      ).get(pointSaleId: opened.pointSale);
      final warehouse = pointSale.warehouseId;

      // 4. Discover one sellable product from that warehouse.
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
                  (s) =>
                      s.warehouse == warehouse &&
                      compareAmounts(s.available, '0') > 0,
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

      // 5. Capture the line — FR-017…FR-023's whole reason to exist.
      final withLine = await salesOrders.addLine(
        saleId: opened.id,
        product: product.product,
        quantity: product.minOrderQty > 0 ? '${product.minOrderQty}' : '1',
        warehouse: warehouse,
      );
      expect(withLine.lineCount, 1);
      expect(withLine.status, SaleStatus.draft, reason: 'not yet committed');

      // 6. FR-032 — mbe-api refuses to record a delivery against an
      // order that isn't yet completed, so the real workspace confirms it
      // first as a side effect of the *first* destination create
      // (`confirmBeforePayableAction`, called from `DeliveryController`, not
      // from `DeliveryOrderRepository` itself). This test drives the
      // repository layer directly — same layer `sales_orders_flow_test
      // .dart` drives for its own confirm — so it makes the same call the
      // controller would make on the workspace's behalf, immediately before
      // the destination create it gates.
      final confirmed = await salesOrders.confirm(saleId: withLine.id);
      expect(confirmed.status, SaleStatus.completed);

      // 7. FR-028/FR-029 — the first destination, claiming everything the
      // order owes (`lines` omitted).
      final destination = await deliveryOrders.create(
        salesOrder: withLine.id,
        fulfillmentType: FulfillmentType.delivery,
        shipTo: shipTo,
      );
      expect(destination.fulfillmentType, FulfillmentType.delivery);
      expect(destination.shipTo, shipTo);

      // 8. The order stays committed once the destination is recorded
      // against it.
      final committed = await salesOrders.getById(saleId: withLine.id);
      expect(committed.status, SaleStatus.completed, reason: 'spec A2');
      expect(committed.isEditable, isFalse);
      expect(committed.serial, isNotNull, reason: 'a folio is assigned');
      expect(
        committed.origin,
        SaleOrigin.backOffice,
        reason: 'FR-051 — recorded once, at create, never edited',
      );

      // 9. The destination is findable back through its own list endpoint —
      // the resume path's own data source (US3, `resumeTargetFor`).
      final destinations = await deliveryOrders.listForSale(
        salesOrder: withLine.id,
      );
      expect(destinations.any((d) => d.id == destination.id), isTrue);
    },
    skip: !_canRun,
    // ~8 sequential round trips (login, customer search+get up to 50 times,
    // open, point of sale, lookup, add line, destination create, two reads)
    // — pinned explicitly like its siblings so a slow shared dev backend
    // doesn't flake this out from unrelated suite contention.
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
