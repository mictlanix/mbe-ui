import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/domain/payment_method.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/point_sale_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/cash_session_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/current_session.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';

/// Golden-path integration test against a *real* mbe-api instance
/// (constitution §VII — no mocked/offline mode), per quickstart.md
/// Scenario 1: open a sale, capture two lines, confirm, pay it to a zero
/// balance (SC-001).
///
/// Every fixture is discovered at runtime — a stockable product from the
/// product lookup, the customer the sale opens with, the cashier's own
/// session — so no ids are hardcoded and the test survives a reseeded
/// database.
///
/// **Run the POS live tests serially** (`flutter test -j 1 ...`). They commit
/// stock against the same dev dataset, so two of them confirming concurrently
/// race and one loses with a `409` on `confirm` — a property of the shared
/// database, not of the code under test.
///
/// Requires mbe-api running at [apiBaseUrl] (default `http://127.0.0.1:8000`)
/// and a user with `POS (44)` READ and `SALES_ORDERS (7)` CREATE+UPDATE, plus
/// an **already open cash session** — this feature's own hard precondition
/// (FR-002a), which the test asserts rather than creating, so it never leaves
/// a stray session behind. Configure via `--dart-define`:
///   --dart-define=MBE_POS_USERNAME=...
///   --dart-define=MBE_POS_PASSWORD=...
///   --dart-define=MBE_POS_PRODUCT_PATTERN=...   (optional, defaults to 'a')
///
/// Skipped entirely when credentials aren't provided. A confirmed sale cannot
/// be deleted, only cancelled, so every run leaves a paid sale behind — point
/// it at a dev tenant, never production.
const _username = String.fromEnvironment('MBE_POS_USERNAME');
const _password = String.fromEnvironment('MBE_POS_PASSWORD');
const _productPattern = String.fromEnvironment(
  'MBE_POS_PRODUCT_PATTERN',
  defaultValue: 'a',
);

const _canRun = _username != '' && _password != '';

void main() {
  test(
    'open a sale → capture two lines → confirm → pay to a zero balance '
    '(SC-001)',
    () async {
      final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
      final token = await AuthRepositoryImpl(
        dio,
      ).login(username: _username, password: _password);
      dio.options.headers['Authorization'] = 'Bearer $token';

      final sessionRepository = CashSessionRepositoryImpl(dio);
      final salesOrderRepository = SalesOrderRepositoryImpl(dio);
      final paymentRepository = CustomerPaymentRepositoryImpl(dio);

      // 0. The cash-session gate (FR-002a) — a hard precondition, asserted
      // rather than created, so this test never leaves a session behind.
      final session = await sessionRepository.getCurrent();
      if (session.state == SessionState.none) {
        markTestSkipped(
          'this account has no open cash session — open one before running',
        );
        return;
      }

      // 1. FR-002 — entering the screen opens a sale.
      final opened = await salesOrderRepository.open();
      expect(opened.status, SaleStatus.draft);
      expect(opened.isEditable, isTrue);
      expect(opened.lines, isEmpty);
      expect(opened.serial, isNull, reason: 'no folio before confirmation');

      // 2. The warehouse a line defaults to (FR-024). mbe-api does **not**
      // fill this in: a line created without one is stored with
      // `warehouse: null` and confirmation then refuses it with "requires
      // stock but no warehouse is set" (verified against a live backend), so
      // resolving it is entirely the client's job — exactly what
      // `defaultWarehouseControllerProvider` does on the screen.
      final pointSale = await PointSaleRepositoryImpl(
        dio,
      ).get(pointSaleId: opened.pointSale);
      final warehouse = pointSale.warehouseId;

      // 3. Discover two products that are actually sellable *from that
      // warehouse* (FR-020, FR-021) — priced, stockable, and with stock on
      // hand where this register draws from. Anything else would fail
      // confirmation for reasons the flow under test is not about.
      final matches = await salesOrderRepository.productLookup(
        pattern: _productPattern,
        customer: opened.customer,
        warehouse: warehouse,
      );
      final sellable = matches
          .where(
            (p) =>
                compareAmounts(p.price, '0') > 0 &&
                (!p.stockRequired ||
                    p.stock.any(
                      (s) =>
                          s.warehouse == warehouse &&
                          compareAmounts(s.available, '0') > 0,
                    )),
          )
          .take(2)
          .toList();
      if (sellable.length < 2) {
        markTestSkipped(
          'fewer than two priced products matching "$_productPattern" are in '
          'stock in warehouse $warehouse for this customer',
        );
        return;
      }

      // 4. Capture both lines against that warehouse. The quantity is set
      // explicitly for the same reason the capture step sets it: most
      // products carry `minOrderQty: 0`, and mbe-api pre-fills the line from
      // that, producing a zero-quantity, zero-total line.
      var sale = opened;
      for (final product in sellable) {
        sale = await salesOrderRepository.addLine(
          saleId: sale.id,
          product: product.product,
          quantity: product.minOrderQty > 0 ? '${product.minOrderQty}' : '1',
          warehouse: warehouse,
        );
      }
      expect(
        sale.lines.every((l) => l.warehouse == warehouse),
        isTrue,
        reason: 'FR-024: every line carries the register\'s warehouse',
      );
      expect(sale.lineCount, 2);
      expect(
        compareAmounts(sale.total, '0'),
        greaterThan(0),
        reason: 'a two-line sale must total more than zero',
      );

      // 5. FR-038–FR-040 — confirm assigns the folio and freezes the sale.
      final confirmed = await salesOrderRepository.confirm(saleId: sale.id);
      expect(confirmed.status, SaleStatus.completed);
      expect(confirmed.isEditable, isFalse);
      expect(confirmed.serial, isNotNull, reason: 'FR-040: a folio is assigned');
      expect(confirmed.total, sale.total, reason: 'confirmation must not reprice');

      // 6. FR-046 — one cash tender for the full balance: create, then apply.
      final paymentId = await paymentRepository.createPayment(
        customer: confirmed.customer,
        amount: confirmed.balance,
        method: PaymentMethod.cash.code,
        currency: confirmed.currency,
      );
      await paymentRepository.applyPayment(
        customerPaymentId: paymentId,
        salesOrder: confirmed.id,
        amount: confirmed.balance,
      );

      // 7. SC-001 — the sale is paid and owes nothing.
      final paid = await salesOrderRepository.getById(saleId: confirmed.id);
      expect(isZeroAmount(paid.balance), isTrue, reason: 'SC-001: zero balance');
      expect(paid.isPaid, isTrue);
      expect(paid.lineCount, 2, reason: 'both lines survive payment');
      expect(paid.serial, confirmed.serial);

      // 8. The payment is listed against the sale, not against the session
      // (research §11) — reachable on a reload, which is what the payment
      // step reads.
      final applied = await paymentRepository.listForOrder(saleId: paid.id);
      expect(applied, hasLength(1));
      expect(applied.single.cancelled, isFalse);
      expect(applied.single.methodCode, PaymentMethod.cash.code);
    },
    skip: !_canRun,
    // The golden path is ~10 sequential round trips (login, session, open,
    // point of sale, lookup, two line creates, confirm, create+apply
    // payment, re-read, payments list) and takes ~25s alone — past the 30s
    // default once the rest of the suite is competing for the same backend.
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
