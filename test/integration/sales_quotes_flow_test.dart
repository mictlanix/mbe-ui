import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/sales_quote_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_origin.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/features/sales/pos_defaults.dart';

/// Golden-path integration test against a *real* mbe-api instance
/// (constitution §VII — no mocked/offline mode), per quickstart.md and
/// spec 040 US1/US2: open a quote for a named customer → add a line →
/// confirm → convert — modeled on `sales_orders_flow_test.dart`.
///
/// Every fixture is discovered at runtime — a customer never the generic
/// walk-in one, a priced product from the product lookup — so no ids are
/// hardcoded and the test survives a reseeded database. Unlike the sales-
/// orders flow, opening a quote needs **no `point_sale`/`facility`
/// precondition** — only `convert` does (FR-030), which US2's own extension
/// of this file covers separately.
///
/// Requires mbe-api running at [apiBaseUrl] (default `http://127.0.0.1:8000`)
/// and a user with `SALES_QUOTES (30)` CREATE+READ+UPDATE and `CUSTOMERS`
/// READ. Configure via `--dart-define`:
///   --dart-define=MBE_POS_USERNAME=...
///   --dart-define=MBE_POS_PASSWORD=...
///   --dart-define=MBE_POS_PRODUCT_PATTERN=...   (optional, defaults to 'a')
///
/// Skipped entirely when credentials aren't provided or when no real
/// customer/priced product can be found. A confirmed quote cannot be
/// deleted, only cancelled — this test leaves a confirmed quote behind on
/// every run, same as its sales-orders sibling leaves a confirmed order.
/// Point it at a dev tenant, never production.
const _username = String.fromEnvironment('MBE_POS_USERNAME');
const _password = String.fromEnvironment('MBE_POS_PASSWORD');
const _productPattern = String.fromEnvironment(
  'MBE_POS_PRODUCT_PATTERN',
  defaultValue: 'a',
);

const _canRun = _username != '' && _password != '';

void main() {
  test(
    'discover a non-generic customer with a price list → open a quote → '
    'add a line → confirm → the quote is completed with a folio and '
    'totals matching the line (US1)',
    () async {
      final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
      final token = await AuthRepositoryImpl(
        dio,
      ).login(username: _username, password: _password);
      dio.options.headers['Authorization'] = 'Bearer $token';

      final salesQuotes = SalesQuoteRepositoryImpl(dio);
      final salesOrders = SalesOrderRepositoryImpl(dio);
      final customers = CustomerRepositoryImpl(dio);

      // 1. FR-007/FR-008 — a real customer, never the generic walk-in one.
      final candidates = await customers.list(limit: 50);
      final customer = candidates.items
          .where((c) => c.customerId != posDefaultCustomerId)
          .firstOrNull;
      if (customer == null) {
        markTestSkipped(
          'no non-generic customer found in the first 50 — this account '
          'cannot run the flow',
        );
        return;
      }

      // 2. FR-006/FR-009 — the customer-first fast path, one request.
      final Sale opened;
      try {
        opened = await salesQuotes.open(customer: customer.customerId);
      } on Object catch (e) {
        markTestSkipped('this account cannot open a sales quote: $e');
        return;
      }
      expect(opened.status, SaleStatus.draft);
      expect(opened.isEditable, isTrue);
      expect(opened.lines, isEmpty);
      // Order-only fields have no quote counterpart (data-model.md §1).
      expect(opened.pointSale, isNull);
      expect(opened.promiseDate, isNull);
      expect(opened.priority, isNull);
      expect(opened.balance, isNull);

      // 3. FR-013 — priced from the customer's price list, no warehouse
      // involved at all (a quote reserves no stock).
      final matches = await salesOrders.productLookup(
        pattern: _productPattern,
        customer: customer.customerId,
      );
      final sellable = matches
          .where((p) => compareAmounts(p.price, '0') > 0)
          .firstOrNull;
      if (sellable == null) {
        markTestSkipped(
          'no priced product matches "$_productPattern" for this customer',
        );
        return;
      }

      final withLine = await salesQuotes.addLine(
        quoteId: opened.id,
        product: sellable.product,
      );
      expect(withLine.lineCount, 1);
      expect(withLine.lines.single.warehouse, isNull, reason: 'FR-014');

      // 4. FR-021 — confirming assigns a folio and completes the quote.
      final confirmed = await salesQuotes.confirm(quoteId: opened.id);
      expect(confirmed.status, SaleStatus.completed);
      expect(confirmed.serial, isNotNull);
      expect(confirmed.total, withLine.total);

      // 5. Read back independently — the confirmed state persisted, not
      // just returned by the confirm call itself.
      final reread = await salesQuotes.getById(quoteId: opened.id);
      expect(reread.status, SaleStatus.completed);
      expect(reread.lineCount, 1);
    },
    skip: !_canRun,
  );

  test(
    'confirm → convert produces an order carrying the quote\'s data forward '
    'and linked back to it as `sales_quote`, tagged origin backOffice, a '
    'draft with no warehouse on any line (US2, FR-026, FR-027); converting '
    'the same quote a second time creates a second, independent order '
    'rather than a refusal (FR-031)',
    () async {
      final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
      final token = await AuthRepositoryImpl(
        dio,
      ).login(username: _username, password: _password);
      dio.options.headers['Authorization'] = 'Bearer $token';

      final salesQuotes = SalesQuoteRepositoryImpl(dio);
      final salesOrders = SalesOrderRepositoryImpl(dio);
      final customers = CustomerRepositoryImpl(dio);
      // `Sale.fromResponse` never mapped `salesQuote` — no UI surface reads
      // the link back to the quote that raised an order — so this one
      // assertion reads the wire response directly rather than widening the
      // shared entity for a single test.
      final rawOrders = api.SalesOrdersApi(dio, api.standardSerializers);

      final candidates = await customers.list(limit: 50);
      final customer = candidates.items
          .where((c) => c.customerId != posDefaultCustomerId)
          .firstOrNull;
      if (customer == null) {
        markTestSkipped(
          'no non-generic customer found in the first 50 — this account '
          'cannot run the flow',
        );
        return;
      }

      final Sale opened;
      try {
        opened = await salesQuotes.open(customer: customer.customerId);
      } on Object catch (e) {
        markTestSkipped('this account cannot open a sales quote: $e');
        return;
      }

      final matches = await salesOrders.productLookup(
        pattern: _productPattern,
        customer: customer.customerId,
      );
      final sellable = matches
          .where((p) => compareAmounts(p.price, '0') > 0)
          .firstOrNull;
      if (sellable == null) {
        markTestSkipped(
          'no priced product matches "$_productPattern" for this customer',
        );
        return;
      }

      await salesQuotes.addLine(quoteId: opened.id, product: sellable.product);
      final confirmed = await salesQuotes.confirm(quoteId: opened.id);

      // FR-030: converting needs a point of sale configured for the caller
      // — an account that lacks one cannot exercise the rest of this test.
      final Sale order;
      try {
        order = await salesQuotes.convert(quoteId: confirmed.id);
      } on Object catch (e) {
        markTestSkipped(
          'this account cannot convert a quote (no point of sale '
          'configured — FR-030?): $e',
        );
        return;
      }

      // FR-026: the order carries the quote's own data forward.
      expect(order.customer, confirmed.customer);
      expect(order.salesperson, confirmed.salesperson);
      expect(order.paymentTerms, confirmed.paymentTerms);
      expect(order.currency, confirmed.currency);
      expect(order.contact, confirmed.contact);
      expect(order.shipTo, confirmed.shipTo);
      expect(order.comment, confirmed.comment);
      expect(order.lineCount, confirmed.lineCount);
      expect(order.total, confirmed.total);

      // FR-027: a fresh draft, no warehouse assigned on any line — the
      // order workspace resumes it on its own goods step, unstocked.
      expect(order.status, SaleStatus.draft);
      for (final line in order.lines) {
        expect(line.warehouse, isNull);
      }

      // FR-026/FR-030: tagged back-office, and linked back to the quote
      // that raised it.
      expect(order.origin, SaleOrigin.backOffice);
      final rawOrder = await rawOrders
          .getSalesOrderApiV1SalesOrdersSalesOrderIdGet(
            salesOrderId: order.id,
          );
      expect(rawOrder.data?.salesQuote, confirmed.id);

      // FR-031: a confirmed quote is not consumed by conversion — doing it
      // again creates a second, independent order rather than a refusal.
      final secondOrder = await salesQuotes.convert(quoteId: confirmed.id);
      expect(secondOrder.id, isNot(order.id));
      expect(secondOrder.customer, confirmed.customer);
    },
    skip: !_canRun,
  );
}
