import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/domain/payment_method.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/address_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/point_sale_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/address_list_item.dart';
import 'package:mbe_ui/features/sales/data/cash_session_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/delivery_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/current_session.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/entities/line_distribution.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/features/sales/domain/repositories/delivery_order_repository.dart';

/// Delivery split + mixed remainder against a *real* mbe-api instance, per
/// quickstart.md Scenarios 2–3: one line spread across two addresses, the
/// rest swept to the counter, and SC-005 asserted **server-side** — every
/// line's quantities across all delivery orders sum to what was ordered.
///
/// This is also the end-to-end check on the two workarounds this feature
/// carries, both of which are invisible to unit tests:
///
/// - a destination is created with a POST then a PUT, because
///   `DeliveryOrderCreate` cannot carry the header (mbe-api#146);
/// - "the destinations of sale N" is reconstructed from line ids, because a
///   delivery order does not record which sale it came from (mbe-api#147).
///
/// **Currently blocked by [mbe-api#149](https://github.com/mictlanix/mbe-api/issues/149)**:
/// `POST /delivery-orders` returns 500 for every request, because
/// `create_from_sales_order` shadows its own `lines` parameter with the
/// sale's ORM rows. Nothing in this test or in the client can work around
/// that — no destination of any kind can be recorded. The test is written
/// against the documented contract and is expected to pass unchanged once
/// #149 lands; until then it fails at the first `deliveries.create`. It does
/// not run in a default `flutter test` (no `MBE_POS_*` defines), so it does
/// not redden the suite.
///
/// Requires mbe-api at [apiBaseUrl], an **already open cash session**, and
/// the same `MBE_POS_*` defines as `pos_counter_sale_flow_test.dart`. Creates
/// two addresses and links them to the sale's customer — the delivery step's
/// own inline-create path — so point it at a dev tenant, never production.
const _username = String.fromEnvironment('MBE_POS_USERNAME');
const _password = String.fromEnvironment('MBE_POS_PASSWORD');
const _productPattern = String.fromEnvironment(
  'MBE_POS_PRODUCT_PATTERN',
  defaultValue: 'a',
);

const _canRun = _username != '' && _password != '';

AddressCreatePayload _address(String nickname) => AddressCreatePayload(
  street: 'Av. Prueba',
  exteriorNumber: nickname,
  postalCode: '06600',
  neighborhood: 'Juárez',
  borough: 'Cuauhtémoc',
  addressState: 'CDMX',
  country: 'MX',
  nickname: 'POS test $nickname',
);

void main() {
  test(
    'split one line across two addresses → sweep the remainder to the '
    'counter → every line still sums to what was ordered (SC-005)',
    () async {
      final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
      final token = await AuthRepositoryImpl(
        dio,
      ).login(username: _username, password: _password);
      dio.options.headers['Authorization'] = 'Bearer $token';

      final sessionRepository = CashSessionRepositoryImpl(dio);
      final salesOrders = SalesOrderRepositoryImpl(dio);
      final payments = CustomerPaymentRepositoryImpl(dio);
      final deliveries = DeliveryOrderRepositoryImpl(dio);
      final addresses = AddressRepositoryImpl(dio);
      final customers = CustomerRepositoryImpl(dio);

      if ((await sessionRepository.getCurrent()).state == SessionState.none) {
        markTestSkipped('this account has no open cash session');
        return;
      }

      // ── Capture ────────────────────────────────────────────────────────
      final opened = await salesOrders.open();
      final pointSale = await PointSaleRepositoryImpl(
        dio,
      ).get(pointSaleId: opened.pointSale);
      final warehouse = pointSale.warehouseId;

      final matches = await salesOrders.productLookup(
        pattern: _productPattern,
        customer: opened.customer,
        warehouse: warehouse,
      );
      // The first line is split 2+1, so it needs at least 3 on hand.
      final sellable = matches
          .where(
            (p) =>
                compareAmounts(p.price, '0') > 0 &&
                (!p.stockRequired ||
                    p.stock.any(
                      (s) =>
                          s.warehouse == warehouse &&
                          compareAmounts(s.available, '3') >= 0,
                    )),
          )
          .take(2)
          .toList();
      if (sellable.length < 2) {
        markTestSkipped(
          'need two products with at least 3 on hand in warehouse $warehouse',
        );
        return;
      }

      var sale = await salesOrders.addLine(
        saleId: opened.id,
        product: sellable[0].product,
        quantity: '3',
        warehouse: warehouse,
      );
      sale = await salesOrders.addLine(
        saleId: sale.id,
        product: sellable[1].product,
        quantity: '2',
        warehouse: warehouse,
      );
      final splitLine = sale.lines.firstWhere(
        (l) => l.product == sellable[0].product,
      );
      final otherLine = sale.lines.firstWhere(
        (l) => l.product == sellable[1].product,
      );

      // ── Confirm and pay ────────────────────────────────────────────────
      final confirmed = await salesOrders.confirm(saleId: sale.id);
      expect(confirmed.status, SaleStatus.completed);

      final paymentId = await payments.createPayment(
        customer: confirmed.customer,
        amount: confirmed.balance,
        method: PaymentMethod.cash.code,
        currency: confirmed.currency,
      );
      await payments.applyPayment(
        customerPaymentId: paymentId,
        salesOrder: confirmed.id,
        amount: confirmed.balance,
      );
      final paid = await salesOrders.getById(saleId: confirmed.id);
      expect(paid.isPaid, isTrue, reason: 'delivery runs after payment (D-002)');

      // ── Two destinations ───────────────────────────────────────────────
      // The customer needs addresses to ship to; creating and linking them is
      // exactly what the delivery step's inline-create path does.
      final first = await addresses.create(_address('A'));
      final second = await addresses.create(_address('B'));
      final customer = await customers.get(customerId: paid.customer);
      await customers.update(
        customerId: paid.customer,
        addresses: [
          ...customer.addresses.map((a) => a.addressId),
          first.addressId,
          second.addressId,
        ],
      );

      // Destination 1 takes 2 of the split line. This exercises the
      // POST-then-PUT sequence: `shipTo` is only settable on the PUT.
      final destinationOne = await deliveries.create(
        salesOrder: paid.id,
        fulfillmentType: FulfillmentType.delivery,
        shipTo: first.addressId,
        comment: 'POS split test — destination 1',
        lines: [
          DestinationLineRequest(salesOrderDetail: splitLine.id, quantity: '2'),
        ],
      );
      expect(
        destinationOne.shipTo,
        first.addressId,
        reason: 'the header PUT must have landed',
      );

      // Destination 2 takes the remaining 1 of the split line, plus 1 of the
      // other — proving a named subset claims exactly what it names.
      final destinationTwo = await deliveries.create(
        salesOrder: paid.id,
        fulfillmentType: FulfillmentType.delivery,
        shipTo: second.addressId,
        comment: 'POS split test — destination 2',
        lines: [
          DestinationLineRequest(salesOrderDetail: splitLine.id, quantity: '1'),
          DestinationLineRequest(salesOrderDetail: otherLine.id, quantity: '1'),
        ],
      );
      expect(destinationTwo.shipTo, second.addressId);
      expect(destinationOne.id, isNot(destinationTwo.id));

      // ── The mixed-mode remainder ───────────────────────────────────────
      // 1 of the other line is still undistributed. Omitting `lines` claims
      // everything the sale still owes, computed server-side (FR-036).
      final remainder = await deliveries.create(
        salesOrder: paid.id,
        fulfillmentType: FulfillmentType.counterPickup,
      );
      expect(remainder.isCounterPickup, isTrue);

      // ── SC-005, asserted from what the server actually stored ──────────
      final recorded = await deliveries.listForSale(
        salesOrder: paid.id,
        customer: paid.customer,
        saleLineIds: paid.lines.map((l) => l.id).toSet(),
      );
      expect(
        recorded.map((d) => d.id).toSet(),
        {destinationOne.id, destinationTwo.id, remainder.id},
        reason: 'listForSale must find all three despite mbe-api#147',
      );

      final distribution = distributionFor(sale: paid, destinations: recorded);
      for (final line in distribution) {
        expect(
          isZeroAmount(line.atCounter),
          isTrue,
          reason:
              'SC-005: ${line.productName} ordered ${line.ordered} but '
              '${line.distributed} was distributed across '
              '${line.perDestination.length} destinations',
        );
      }

      // And the split line really is spread across both addresses.
      final split = distribution.firstWhere((d) => d.saleLineId == splitLine.id);
      expect(split.perDestination[destinationOne.id], isNotNull);
      expect(split.perDestination[destinationTwo.id], isNotNull);
      expect(
        compareAmounts(split.perDestination[destinationOne.id]!, '2'),
        0,
      );
      expect(
        compareAmounts(split.perDestination[destinationTwo.id]!, '1'),
        0,
      );
    },
    skip: !_canRun,
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
