import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/domain/payment_method.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/point_sale_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/cash_session_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/current_session.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/features/sales/presentation/pos_resume_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_step_controller.dart';

/// Interrupting and resuming at each reachable step, per quickstart.md
/// Scenario 4 (US3): a sale left as a draft, one left confirmed but unpaid,
/// and one left paid — each is found again by the register's open-sales
/// listing and reopens where the sale itself says it should
/// (contracts/pos-screen.md §5, FR-057).
///
/// **Run the POS live tests serially** (`flutter test -j 1 ...`). They commit
/// stock against the same dev dataset, so two of them confirming concurrently
/// race and one loses with a `409` on `confirm`.
///
/// Requires mbe-api at [apiBaseUrl], an **already open cash session**, and the
/// same `MBE_POS_*` defines as the other POS live tests. Leaves the sales it
/// creates behind (a confirmed sale cannot be deleted) — dev tenants only.
const _username = String.fromEnvironment('MBE_POS_USERNAME');
const _password = String.fromEnvironment('MBE_POS_PASSWORD');
const _productPattern = String.fromEnvironment(
  'MBE_POS_PRODUCT_PATTERN',
  defaultValue: 'a',
);

const _canRun = _username != '' && _password != '';

void main() {
  test(
    'a draft, an unpaid sale and a paid one are each found in the register\'s '
    'open sales and reopen at the right step (Scenario 4)',
    () async {
      final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
      final token = await AuthRepositoryImpl(
        dio,
      ).login(username: _username, password: _password);
      dio.options.headers['Authorization'] = 'Bearer $token';

      final sessions = CashSessionRepositoryImpl(dio);
      final salesOrders = SalesOrderRepositoryImpl(dio);
      final payments = CustomerPaymentRepositoryImpl(dio);

      if ((await sessions.getCurrent()).state == SessionState.none) {
        markTestSkipped('this account has no open cash session');
        return;
      }

      final probe = await salesOrders.open();
      final pointSale = await PointSaleRepositoryImpl(
        dio,
      ).get(pointSaleId: probe.pointSale);
      final facility = await FacilityRepositoryImpl(
        dio,
      ).get(facilityId: probe.facility);
      final warehouse = pointSale.warehouseId;

      final matches = await salesOrders.productLookup(
        pattern: _productPattern,
        customer: probe.customer,
        warehouse: warehouse,
      );
      final product = matches
          .where(
            (p) =>
                compareAmounts(p.price, '0') > 0 &&
                (!p.stockRequired ||
                    p.stock.any(
                      (s) =>
                          s.warehouse == warehouse &&
                          compareAmounts(s.available, '2') >= 0,
                    )),
          )
          .firstOrNull;
      if (product == null) {
        markTestSkipped('no product with stock in warehouse $warehouse');
        return;
      }

      Future<Sale> saleWithALine(Sale on) => salesOrders.addLine(
        saleId: on.id,
        product: product.product,
        quantity: '1',
        warehouse: warehouse,
      );

      // ── Left as a draft ────────────────────────────────────────────────
      final draft = await saleWithALine(probe);
      expect(draft.status, SaleStatus.draft);

      // ── Left confirmed but unpaid ──────────────────────────────────────
      final unpaid = await salesOrders.confirm(
        saleId: (await saleWithALine(await salesOrders.open())).id,
      );
      expect(unpaid.status, SaleStatus.completed);
      expect(compareAmounts(unpaid.balance, '0'), greaterThan(0));

      // ── Left paid ──────────────────────────────────────────────────────
      final settled = await salesOrders.confirm(
        saleId: (await saleWithALine(await salesOrders.open())).id,
      );
      final paymentId = await payments.createPayment(
        customer: settled.customer,
        amount: settled.balance,
        method: PaymentMethod.cash.code,
        currency: settled.currency,
      );
      await payments.applyPayment(
        customerPaymentId: paymentId,
        salesOrder: settled.id,
        amount: settled.balance,
      );
      final paid = await salesOrders.getById(saleId: settled.id);
      expect(paid.isPaid, isTrue);

      // ── The register finds the unfinished ones again ───────────────────
      final drafts = await salesOrders.listOpen(
        pointSale: probe.pointSale,
        status: SaleStatus.draft,
      );
      final completed = await salesOrders.listOpen(
        pointSale: probe.pointSale,
        status: SaleStatus.completed,
      );

      expect(
        drafts.items.map((s) => s.id),
        contains(draft.id),
        reason: 'a draft left open is offered for resuming',
      );
      expect(
        completed.items.map((s) => s.id),
        contains(unpaid.id),
        reason: 'a confirmed sale still owing money is offered too',
      );

      // ── And each reopens where its own state says it should ────────────
      expect(
        resumeTargetFor(
          await salesOrders.getById(saleId: draft.id),
          facilityAddressId: facility.addressId,
        ).step,
        PosStep.venta,
      );
      expect(
        resumeTargetFor(
          await salesOrders.getById(saleId: unpaid.id),
          facilityAddressId: facility.addressId,
        ).step,
        PosStep.cobro,
      );
      // This one is a counter sale — paid means finished, so it lands on
      // Cobro (nothing owed) rather than on a delivery step it never had.
      expect(
        resumeTargetFor(paid, facilityAddressId: facility.addressId).step,
        PosStep.cobro,
      );

      // ── Abandoning an empty sale (US3 scenario 6) ──────────────────────
      final empty = await salesOrders.open();
      await salesOrders.cancel(saleId: empty.id);
      final afterCancel = await salesOrders.listOpen(
        pointSale: probe.pointSale,
        status: SaleStatus.draft,
      );
      expect(
        afterCancel.items.map((s) => s.id),
        isNot(contains(empty.id)),
        reason: 'an abandoned empty sale must not clutter the selector',
      );
    },
    skip: !_canRun,
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
